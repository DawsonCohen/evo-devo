#ifndef __NN_ROBOT_H__
#define __NN_ROBOT_H__

// Evolvable Soft Body
#include <random>
#include <string>
#include <Eigen/Dense>
#include "SoftBody.h"

#define MIN_FITNESS (float) 0

class NNRobot : public SoftBody {
private:
    Eigen::MatrixXf relu(const Eigen::MatrixXf& x) {
        return x.array().max(0);
    }

    Eigen::MatrixXf tanh(const Eigen::MatrixXf& x) {
        return x.array().tanh();
    }

    Eigen::MatrixXf softmax(const Eigen::MatrixXf& input) {
        Eigen::MatrixXf output(input.rows(), input.cols());
        for (int j = 0; j < input.cols(); j++) {
            Eigen::VectorXf col = input.col(j);
            col.array() -= col.maxCoeff(); // subtract max for numerical stability
            col = col.array().exp();
            output.col(j) = col / col.sum();
        }
        return output;
    }

    Eigen::MatrixXf addBias(const Eigen::MatrixXf& A) {
        Eigen::MatrixXf B(A.rows()+1, A.cols());
        B.topRows(A.rows()) = A;
        B.row(A.rows()).setOnes();
        return B;
    }

    Eigen::MatrixXf forward(const Eigen::MatrixXf& input) {
        Eigen::MatrixXf x = input;
        
        for (uint i = 0; i < num_layers-2; i++) {
            // x = addBias(x);
            x = weights[i] * x;
            x = relu(x);
        }

        // x = addBias(x);
        x = weights[num_layers-2] * x;

        // tanh activation to position rows
        x.topRows(output_size - MATERIAL_COUNT) = tanh(x.topRows(output_size - MATERIAL_COUNT)); 
        
        // softmax activation to material rows
        x.bottomRows(MATERIAL_COUNT) = softmax(x.bottomRows(MATERIAL_COUNT)); 
        
        return x;
    }

protected:
    std::vector<Eigen::MatrixXf> weights;
    static std::vector<int> hidden_sizes;
    static uint num_layers;
    
    constexpr static uint input_size = 3;
    constexpr static uint output_size = 3 + MATERIAL_COUNT;
    
    
    
public:
    void Build();

    // NNRobot class configuration functions
    static void SetArchitecture(const std::vector<int>& hidden_sizes = std::vector<int>{25,25}) {
        NNRobot::num_layers = hidden_sizes.size();
    }

    // Initializers
    NNRobot(const uint num_masses = 1728);

    NNRobot(std::vector<Eigen::MatrixXf> weights) :
    weights(weights)
    {
        Build();
    };
    
    NNRobot(const NNRobot& src) : SoftBody(src),
        weights(src.weights)
    { }
    

    // Getters
    uint volume() const { return mVolume; }
    Eigen::Vector3f COM() const { return mBaseCOM; }

    void Randomize();
    void Mutate();

    static CandidatePair<NNRobot> Crossover(const CandidatePair<NNRobot>& parents);

    static float Distance(const CandidatePair<NNRobot>& robots);

    std::string Encode() const;
	void Decode(const std::string& filename);

    friend void swap(NNRobot& r1, NNRobot& r2) {
        using std::swap;
        swap(r1.weights, r2.weights);
        swap(r1.num_layers, r2.num_layers);
        swap(r1.mVolume, r2.mVolume);
        swap(r1.mBaseCOM, r2.mBaseCOM);
        swap(r1.mLength, r2.mLength);

        swap((SoftBody&) r1, (SoftBody&) r2);
    }

    NNRobot& operator=(NNRobot src) {
        swap(*this, src);

        return *this;
    }

    bool operator < (const NNRobot& R) const {
        return mParetoLayer > R.mParetoLayer;
    }

    bool operator > (const NNRobot& R) const {
        if(mParetoLayer < R.mParetoLayer)
            return true;
        else if(mParetoLayer == R.mParetoLayer)
            return mFitness > R.mFitness;
        
        return false;
    }

    bool operator <= (const NNRobot& R) const {
        return !(mFitness > R.mFitness);
    }

    bool operator >= (const NNRobot& R) const {
        return !(mFitness < R.mFitness);
    }
    
    static std::vector<float> findDiversity(std::vector<NNRobot> pop);
};

#endif
