#include "vec_math.cuh"
#include "material.h"
#include <math.h>
#include <assert.h>

#define EPS (float) 1e-12

namespace EvoDevo {

struct SimOptions {
	float dt;
	uint massesPerBlock;
	uint springsPerBlock;
	uint facesPerBlock;
	uint cellsPerBlock;
	uint boundaryMassesPerBlock;
	uint maxMasses;
	uint maxSprings;
	uint maxFaces;
	uint maxCells;
	uint compositeCount;
	short shiftskip;
	float drag;
	float damping;
	float relaxation;
	float s;
};

struct DeviceData {
	// MASS DATA
	float    *dPos, *dNewPos, *dVel;
	uint32_t *dMassMatEncodings;

	// SPRING DATA
	ushort	 *dPairs;
	uint32_t *dSpringMatEncodings;
	uint8_t  *dSpringMatIds;
	float	 *dLbars;
	uint     *dSpringIDs;
	float	 *dSpringStresses;
	
	// SPRING DEVO DATA
	ushort   *dRandomPairs;
	uint     *dSpringIDs_Sorted;
	float	 *dSpringStresses_Sorted;

	// FACE DATA
	ushort	 *dFaces;
	
	// CELL DATA
	ushort	 *dCells;
	float	 *dVbars;
	float	 *dMats;
	float	 *dCellStresses;
};

__constant__ float4 compositeMats_id[COMPOSITE_COUNT];
__constant__ SimOptions cSimOpt;

void setCompositeMats_id(float* compositeMats, uint count) {
	cudaMemcpyToSymbol(compositeMats_id, compositeMats, sizeof(float)*4*count);
}

void setSimOpts(SimOptions opt) {
	cudaMemcpyToSymbol(cSimOpt, &opt, sizeof(SimOptions));
}

__device__
void surfaceDragForce(
		ushort4 face,
		const float3 *s_pos,
		const float3 *s_vel,
		float3 *s_force
	) {
		float area;
		float3 v, normal, force;

		// Drag Force: 0.5*rho*A*((Cd - Cl)*dot(v,n)*v + Cl*dot(v,v)*n)
		normal = cross((s_pos[face.y] - s_pos[face.x]), (s_pos[face.z]-s_pos[face.x]));
		v = (s_vel[face.x] + s_vel[face.y] + s_vel[face.z]) / 3.0f;
		area = norm3df(normal.x,normal.y,normal.z);
		normal = normal / (area + EPS);

		normal = dot(normal, v) > 0.0f ? normal : -normal;
		force = -0.5f*cSimOpt.drag*area*(0.8*dot(v,normal)*v + 0.2*dot(v,v)*normal);
		force = force / 3.0f; // allocate forces evenly amongst masses

		atomicAdd(&(s_force[face.x].x), force.x);
		atomicAdd(&(s_force[face.x].y), force.y);
		atomicAdd(&(s_force[face.x].z), force.z);

		atomicAdd(&(s_force[face.y].x), force.x);
		atomicAdd(&(s_force[face.y].y), force.y);
		atomicAdd(&(s_force[face.y].z), force.z);

		atomicAdd(&(s_force[face.z].x), force.x);
		atomicAdd(&(s_force[face.z].y), force.y);
		atomicAdd(&(s_force[face.z].z), force.z);
}


/*
	mat: float4 describing spring material
		x - k		stiffness
		y - dL0 	maximum percent change
		z - omega	frequency of oscillation
		w - phi		phase
*/
__device__
inline void springForce(const float3& bl, const float3& br, const float4& mat, 
					float mean_length, float time,
					float3& force, float& magF)
{
	float3	dir, diff;

	float	relative_change,
			rest_length,
			Lsqr, rL, L;

	// rest_length = mean_length * (1 + relative_change);
	relative_change = mat.y * sinf(mat.z*time+mat.w);
	rest_length = __fmaf_rn(mean_length, relative_change, mean_length);
	
	diff.x = bl.x - br.x;
	diff.y = bl.y - br.y;
	diff.z = bl.z - br.z;

	Lsqr = dot(diff,diff);
	L = __fsqrt_rn(Lsqr);
	rL = rsqrtf(Lsqr);

	dir = {
		__fmul_rn(diff.x,rL),
		__fmul_rn(diff.y,rL),
		__fmul_rn(diff.z,rL)
	};
	magF = mat.x*(rest_length-L);
	force = magF * dir;
}

__global__ void
inline solveIntegrateBodies(
	float4 *__restrict__ pos, float4 *__restrict__ vel,
	ushort2 *__restrict__ pairs, ushort4* __restrict__ faces,
	float* stresses,
	uint8_t *__restrict__ matIds, float *__restrict__ Lbars,
	float time, uint step, bool integrateForce)
{
	extern __shared__ float3 s[];
	float3  *s_pos = s;
	float3  *s_vel = (float3*) &s_pos[cSimOpt.massesPerBlock];
	float3  *s_force = (float3*) &s_vel[cSimOpt.massesPerBlock];
	
	uint massOffset   = blockIdx.x * cSimOpt.massesPerBlock;
	uint springOffset = blockIdx.x * cSimOpt.springsPerBlock;
	uint faceOffset = blockIdx.x * cSimOpt.facesPerBlock;
	uint i;

	int tid    = threadIdx.x;
	int stride = blockDim.x;
	
	// Initialize and compute environment forces
	float4 pos4, vel4;
	for(i = tid; i < cSimOpt.massesPerBlock && (i+massOffset) < cSimOpt.maxMasses; i+=stride) {
		pos4 = __ldg(&pos[i+massOffset]);
		vel4 = __ldg(&vel[i+massOffset]);
		s_pos[i] = {pos4.x,pos4.y,pos4.z};
		s_vel[i] = {vel4.x,vel4.y,vel4.z};
		s_force[i] = {0.0f, 0.0f, 0.0f};
	}
	__syncthreads();

	for(i = tid; i < cSimOpt.facesPerBlock && (i+faceOffset) < cSimOpt.maxFaces; i+=stride) {
		surfaceDragForce(
			__ldg(&faces[i+faceOffset]),
			s_pos, s_vel, s_force);
	}
	__syncthreads();
	

	float4	 mat;
	float3	 bl, br;
	float3	 force;
	ushort2	 pair;
	uint8_t  matId;
	float	 Lbar,
			 magF = 0x0f;
	ushort	 left, right;
	
	for(i = tid; i < cSimOpt.springsPerBlock && (i+springOffset) < cSimOpt.maxSprings; i+=stride) {
		matId = __ldg(&matIds[i+springOffset]);
		if(matId == materials::air.id) continue;

		pair = __ldg(&pairs[i+springOffset]);
		left  = pair.x;
		right = pair.y;
		bl = s_pos[left];
		br = s_pos[right];

		mat = compositeMats_id[ matId ];

		Lbar = __ldg(&Lbars[i+springOffset]);
		springForce(bl,br,mat,Lbar,time, force, magF);

		if(integrateForce) stresses[i+springOffset] += magF / Lbar;

		atomicAdd(&(s_force[left].x), force.x);
		atomicAdd(&(s_force[left].y), force.y);
		atomicAdd(&(s_force[left].z), force.z);

		atomicAdd(&(s_force[right].x), -force.x);
		atomicAdd(&(s_force[right].y), -force.y);
		atomicAdd(&(s_force[right].z), -force.z);
	}
	__syncthreads();

	// Calculate and store new mass states
	float3 oldPos, pos3, vel3;
	for(i = tid; i < cSimOpt.massesPerBlock && (i+massOffset) < cSimOpt.maxMasses; i+=stride) {
		oldPos = s_pos[i];
		vel3 = s_vel[i];

		// new position = old position + velocity * deltaTime
		// s_pos[i] += vel3 * cSimOpt.dt + s_force[i] * cSimOpt.dt*cSimOpt.dt;
		// s_pos[i] += s_vel[i]*cSimOpt.dt + s_force[i]*cSimOpt.dt*cSimOpt.dt;
		s_pos[i].x += vel3.x * cSimOpt.dt + s_force[i].x * cSimOpt.dt*cSimOpt.dt;
		s_pos[i].y += vel3.y * cSimOpt.dt + s_force[i].y * cSimOpt.dt*cSimOpt.dt;
		s_pos[i].z += vel3.z * cSimOpt.dt + s_force[i].z * cSimOpt.dt*cSimOpt.dt;

		// store new position and velocity
		pos3 = s_pos[i];
		vel3 = cSimOpt.damping * (pos3 - oldPos) / cSimOpt.dt;
		pos[i+massOffset] = {pos3.x, pos3.y, pos3.z};
		vel[i+massOffset] = {vel3.x, vel3.y, vel3.z};
	}
}

void integrateBodies(DeviceData deviceData, uint numElements,
	SimOptions opt, 
	float time, uint step, bool integrateForce
	) {
	// Calculate and store new mass states
	
	uint numThreadsPerBlockDrag = 1024;
	uint numThreadsPerBlockPreSolve = 256;
	uint numThreadsPerBlockSolve = 1024;
	uint numThreadsPerBlockUpdate = 256;
	
	/*
	Notes on SM resources:
	thread blocks	: 8
	threads			: 2048
	registers		: 65536
	shared mem		: 49152
	*/

	uint maxSharedMemSize = 49152;
	uint bytesPerMass = sizeof(float3) + sizeof(float3) + sizeof(float3);
	uint sharedMemSizeSolve = opt.massesPerBlock * bytesPerMass;
	uint numBlocksSolve = numElements;

	assert(sharedMemSizeSolve <= maxSharedMemSize);

	uint bytesPerBoundaryMass = sizeof(float3) + sizeof(float3) + sizeof(float3);
	uint sharedMemSizeDrag = opt.boundaryMassesPerBlock * bytesPerBoundaryMass;
	uint numBlocksDrag = numElements;

	assert(sharedMemSizeDrag <= maxSharedMemSize);

	uint numBlocksPreSolve = (opt.maxMasses + numThreadsPerBlockPreSolve - 1) / numThreadsPerBlockPreSolve;
	uint numBlocksUpdate = (opt.maxMasses + numThreadsPerBlockUpdate - 1) / numThreadsPerBlockUpdate;

	solveIntegrateBodies<<<numBlocksSolve,numThreadsPerBlockPreSolve,sharedMemSizeSolve>>>(
				(float4*) deviceData.dPos, (float4*) deviceData.dVel,
				(ushort2*)  deviceData.dPairs, (ushort4*) deviceData.dFaces,
				(float*) deviceData.dSpringStresses,
				(uint8_t*) deviceData.dSpringMatIds,  (float*) deviceData.dLbars,
				time, step, integrateForce);

	// surfaceDragForce<<<numBlocksDrag,numThreadsPerBlockDrag,sharedMemSizeDrag>>>(
	// 	(float4*) deviceData.dPos, (float4*) deviceData.dNewPos, 
	// 	(float4*) deviceData.dVel, (ushort4*) deviceData.dFaces);
	// pointDragForce<<<numBlocksPreSolve,numThreadsPerBlockPreSolve>>>(
	// 	(float4*) deviceData.dPos, (float4*) deviceData.dNewPos, 
	// 	(float4*) deviceData.dVel);
	// cudaDeviceSynchronize();

	// preSolve<<<numBlocksPreSolve, numThreadsPerBlockPreSolve>>>(
	// 	(float4*) deviceData.dPos, (float4*) deviceData.dNewPos,
	// 	(float4*) deviceData.dVel);
	// cudaDeviceSynchronize();

	// solveDistance<<<numBlocksSolve,numThreadsPerBlockSolve,sharedMemSizeSolve>>>(
	// 	(float4*) deviceData.dNewPos, (ushort2*)  deviceData.dPairs, 
	// 	(float*) deviceData.dSpringStresses, (uint8_t*) deviceData.dSpringMatIds, (float*) deviceData.dLbars,
	// 	time, step, integrateForce);
	// cudaDeviceSynchronize();
		
	// update<<<numBlocksUpdate,numThreadsPerBlockUpdate>>>((float4*) deviceData.dPos, (float4*) deviceData.dNewPos,
	// 	(float4*) deviceData.dVel);
	cudaDeviceSynchronize();
}

}