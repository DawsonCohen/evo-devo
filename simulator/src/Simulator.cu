#include "Simulator.h"
#include "sim_kernel.cu"
#include <math.h>
#include <algorithm>
#include <functional>
#include <fstream>
#include <iostream>

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) 
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

/*
TODO: Softening
*/ 

Simulator::Simulator(Element prototype, uint maxElements) :
	massesPerElement(prototype.masses.size()),
	springsPerElement(prototype.springs.size()),
	maxMasses(prototype.masses.size()*maxElements),
	maxSprings(prototype.springs.size()*maxElements),
	maxEnvs(1),
	m_hPos(0),
	m_hVel(0)
{
	m_dPos[0] = m_dPos[1] = 0;
    m_dVel[0] = m_dVel[1] = 0;
	
	_initialize();
}

Simulator::~Simulator() {
	// Free CPU
	delete[] m_hPos;
	delete[] m_hVel;

	delete[] m_hLbars;
	delete[] m_hPairs;
	delete[] m_hMats;

	delete[] massBuf;
	delete[] springBuf;
	delete[] envBuf;
	delete[] offsetBuf;

	// Free GPU
	cudaFree((void**) m_dPos[0]);
	cudaFree((void**) m_dPos[1]);
	cudaFree((void**) m_dVel[0]);
	cudaFree((void**) m_dVel[1]);

	cudaFree((void**) m_dLbars);
	cudaFree((void**) m_dPairs);
	cudaFree((void**) m_dMats);
}

void Simulator::Initialize(Element prototype, uint maxElements) {
	
	massesPerElement = prototype.masses.size();
	springsPerElement = prototype.springs.size();
	maxMasses = prototype.masses.size()*maxElements;
	maxSprings = prototype.springs.size()*maxElements;
	maxEnvs = 1;
	m_currentRead = 0;
	m_currentWrite = 1;

	_initialize();
}

void Simulator::_initialize() { //uint maxMasses, uint maxSprings) {
	if(initialized) {
		// Free CPU
		delete[] m_hPos;
		delete[] m_hVel;

		delete[] m_hLbars;
		delete[] m_hPairs;
		delete[] m_hMats;

		delete[] massBuf;
		delete[] springBuf;
		delete[] envBuf;
		delete[] offsetBuf;

		// Free GPU
		cudaFree((void**) m_dPos[0]);
		cudaFree((void**) m_dPos[1]);
		cudaFree((void**) m_dVel[0]);
		cudaFree((void**) m_dVel[1]);
		cudaFree((void**) m_dSpringCount);

		cudaFree((void**) m_dLbars);
		cudaFree((void**) m_dPairs);
		cudaFree((void**) m_dMats);
	}
	initialized = true;
	
	printf("Num Masses:\t%u\n",maxMasses);
	printf("Num Springs:\t%u\n",maxSprings);
	
	massBuf   = new Mass[maxMasses];
	springBuf = new Spring[maxSprings];
	offsetBuf = new uint[maxSprings];
	envBuf 	  =	new Environment[1];

	m_hLbars  = new float[maxSprings];
	m_hPairs  = new uint[maxSprings*2];
	m_hMats   = new float[maxSprings*4];

	m_hPos 	  = new float[maxMasses*4];
    m_hVel 	  = new float[maxMasses*4];

	memset(m_hPos, 0, maxMasses*4*sizeof(float));
    memset(m_hVel, 0, maxMasses*4*sizeof(float));
	
    unsigned int massSizefloat4   = sizeof(float) * 4 * maxMasses;
    unsigned int springSizefloat  = sizeof(float) * 1 * maxSprings;
    unsigned int springSizefloat4 = sizeof(float) * 4 * maxSprings;
    unsigned int springSizeuint2  = sizeof( uint) * 2 * maxSprings;
	
	printf("Pos size: %u\n",massSizefloat4);

	cudaMalloc((void**)&m_dSpringCount, sizeof(uint));
	cudaMalloc((void**)&m_dVel[0], massSizefloat4);
	cudaMalloc((void**)&m_dVel[1], massSizefloat4);

	cudaMalloc((void**)&m_dPos[0], massSizefloat4);
	cudaMalloc((void**)&m_dPos[1], massSizefloat4);


	cudaMalloc((void**)&m_dPairs,  springSizeuint2);
	cudaMalloc((void**)&m_dLbars,  springSizefloat);
	cudaMalloc((void**)&m_dMats,   springSizefloat4);

	envBuf[0] = Environment();
	envCount++;
}

std::vector<ElementTracker> Simulator::Simulate(std::vector<Element>& elements) {
	numMasses = 0; numSprings = 0; numElements = 0;

	std::vector<ElementTracker> trackers = Allocate(elements);
	
	float3 gravity = envBuf[0].g;
	float stiffness = envBuf[0].floor_stiffness;
	float mu = envBuf[0].friction;
	float zeta = envBuf[0].damping;
	float step_time = 0;
	glm::vec3 pos;
	for(uint i = 0; i < numMasses; i++) {
		float  mass = massBuf[i].mass;
		float3 vel  = massBuf[i].vel;
		pos = massBuf[i].pos;

		m_hPos[4*i]   = pos.x;
		m_hPos[4*i+1] = pos.y;
		m_hPos[4*i+2] = pos.z;
		m_hPos[4*i+3] = mass;
		
		m_hVel[4*i]   = vel.x;
		m_hVel[4*i+1] = vel.y;
		m_hVel[4*i+2] = vel.z;
	}

	for(uint i = 0; i < numSprings; i++) {
		Material mat    = springBuf[i].material;
		float    lbar   = springBuf[i].mean_length;
		uint     left   = springBuf[i].m0 + offsetBuf[i],
			     right  = springBuf[i].m1 + offsetBuf[i];

		m_hMats[4*i]   = mat.k;
		m_hMats[4*i+1] = mat.dL0;
		m_hMats[4*i+2] = mat.omega;
		m_hMats[4*i+3] = mat.phi;

		m_hPairs[2*i]   = left;
		m_hPairs[2*i+1] = right;
		m_hLbars[i] 	= lbar;
	}

	cudaMemcpy(m_dVel[m_currentRead], m_hVel,   numMasses   *4*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(m_dPos[m_currentRead], m_hPos,   numMasses   *4*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(m_dPairs,  m_hPairs, numSprings *2*sizeof(uint),  cudaMemcpyHostToDevice);
	cudaMemcpy(m_dLbars,  m_hLbars, numSprings  * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(m_dMats,   m_hMats,  numSprings *4*sizeof(float), cudaMemcpyHostToDevice);

	// uint requiredSize = numMasses * bytesPerMass; // 4 floats for pos
	// uint maxStreams = 32;
	// uint numKernels = (requiredSize + maxSharedMemSize - 1) / maxSharedMemSize;
	// uint sharedMemSize = massesPerKernel * bytesPerMass;
	// uint numGroups = (numKernels + maxStreams - 1) / maxStreams;
	// uint numKernelsPerGroup = min(maxStreams, numKernels);
	// uint massesPerGroup = massesPerKernel * numKernelsPerGroup;
	// uint springsPerGroup = springsPerKernel * numKernelsPerGroup;

	// printf("elementsPerKernel:\t%u\n",elementsPerKernel);
	// printf("requiredSize:\t%u\n",requiredSize);
	// printf("bytesPerMass:\t%u\n",bytesPerMass);
	// printf("sharedMemSize:\t%u\n",sharedMemSize);
	// printf("numKernels:\t%u\n",numKernels);
	// printf("numGroups:\t%u\n",numGroups);
	// printf("numKernelsPerGroup:\t%u\n",numKernelsPerGroup);

	/*
	Notes on SM resources:
	thread blocks	: 8
	threads			: 2048
	registers		: 65536
	shared mem		: 49152
	*/

	uint maxSharedMemSize = 49152;
	uint bytesPerMass = sizeof(float4) + sizeof(float3);
	uint bytesPerElement = massesPerElement*(sizeof(float4)+sizeof(float3));
	uint elementsPerBlock = min(maxSharedMemSize / bytesPerElement, numElements);
	uint massesPerBlock = massesPerElement * elementsPerBlock;
	uint springsPerBlock = springsPerElement * elementsPerBlock;
	uint sharedMemSize = massesPerBlock * bytesPerMass;

	int threadsPerBlock = 256;

	int numMassBlocks = (massesPerBlock + threadsPerBlock - 1) / threadsPerBlock;
	int numSpringBlocks = (springsPerBlock + threadsPerBlock - 1) / threadsPerBlock;
	int numBlocks = max(numMassBlocks, numSpringBlocks);
	
	uint step = 0;
	uint springCount = 0;
	while(step_time < max_time) {
		// integrateBodies<<<blockSize,numSpringBlocks>>>(
		
		integrateBodies<<<numBlocks,threadsPerBlock,sharedMemSize>>>(
			(float4*) m_dPos[m_currentWrite], (float4*) m_dVel[m_currentWrite],
			(float4*) m_dPos[m_currentRead], (float4*) m_dVel[m_currentRead],
			(uint2*)  m_dPairs,  (float4*) m_dMats,  (float*) m_dLbars, 
			step_period, total_time, make_float4(stiffness,mu,zeta,gravity.y),
			massesPerElement, springsPerElement,
			maxMasses, maxSprings, m_dSpringCount);

		gpuErrchk( cudaPeekAtLastError() );
		cudaDeviceSynchronize();

		std::swap(m_currentRead, m_currentWrite);
		
		step++;
		total_time += step_period;
		step_time += step_period;
	}

	cudaMemcpy(m_hPos,m_dPos[m_currentRead],numMasses*4*sizeof(float),cudaMemcpyDeviceToHost);
	cudaMemcpy(m_hVel,m_dVel[m_currentRead],numMasses*4*sizeof(float),cudaMemcpyDeviceToHost);
	
	cudaMemcpy(&springCount,m_dSpringCount,sizeof(uint),cudaMemcpyDeviceToHost);

	for(uint i = 0; i < numMasses; i++) {
		float3 pos = {m_hPos[4*i], m_hPos[4*i+1], m_hPos[4*i+2]};
		massBuf[i].pos = glm::vec3(pos.x,pos.y,pos.z);
	}

	return trackers;
}


std::vector<ElementTracker> Simulator::Allocate(const std::vector<Element>& elements) {
	std::vector<ElementTracker> trackers;

	for(uint i = 0; i < elements.size(); i++) {
		trackers.push_back(AllocateElement(elements[i]));
	}

	return trackers;
}

ElementTracker Simulator::AllocateElement(const Element& e) {
	ElementTracker tracker;

	
	tracker.mass_begin = massBuf + numMasses;
	tracker.spring_begin = springBuf + numSprings;
	tracker.offset_begin = offsetBuf + numSprings;
	tracker.mass_end = tracker.mass_begin; 
	tracker.spring_end = tracker.spring_begin;
	tracker.offset_end = tracker.offset_begin;
	uint massOffset = numMasses;
	
	numElements++;
	
	for(const Mass& m : e.masses) {
		massBuf[numMasses] = m;
		tracker.mass_end++;
		numMasses++;
	}

	for(const Spring& s : e.springs) {
		springBuf[numSprings] = s;
		tracker.spring_end++;

		offsetBuf[numSprings] = massOffset;
		tracker.offset_end++;
		numSprings++;
	}
	
	return tracker;
}

std::vector<Element> Simulator::Collect(const std::vector<ElementTracker>& trackers) {
	std::vector<Element> elements;
	for(const ElementTracker& tracker : trackers) {
		Element e = CollectElement(tracker);
		elements.push_back(e);
	}
	return elements;
}

Element Simulator::CollectElement(const ElementTracker& tracker) {
	std::vector<Mass> result_masses;
	std::vector<Spring> result_springs;

	for(Mass* i = tracker.mass_begin; i < tracker.mass_end; i++) {
		result_masses.push_back(*i);
	}

	for(Spring* i = tracker.spring_begin; i < tracker.spring_end; i++) {
		result_springs.push_back(*i);
	}
	
	return {result_masses, result_springs};
}
