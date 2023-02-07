#ifndef __EVALUATOR_H__
#define __EVALUATOR_H__

#include "robot.h"
#include "Simulator.h"
#include <vector>
#include <algorithm>

struct SolutionPair {
    Robot* first;
    Robot* second;
};

struct SexualRobotFamily {
    SolutionPair parents;
    RobotPair children;
};

struct AsexualRobotFamily {
    Robot* parent;
    Robot child;
};

class Evaluator {

public:
    static ulong eval_count;
    static Simulator Sim;

    static void Initialize(uint pop_size, float max_time);
    static void BatchEvaluate(std::vector<Robot>&);
    static float Distance(const RobotPair& robots);

    static void pareto_sort(std::vector<Robot>::iterator begin, std::vector<Robot>::iterator end) {
        for(auto i = begin; i < end; i++) {
            i->mParetoLayer = 0;
        }

        int Delta;
        uint run = 0;
        while(true) {
            Delta = 0;
            for(auto i = begin; i < end; i++) {
                if(i->mParetoLayer < run) continue;
                for(auto j = begin; j < end; j++) {
                    if(j->mParetoLayer < run) continue;
                    if(*j > *i) {
                        i->mParetoLayer++;
                        Delta++;
                        break;
                    }
                }
            }
            if(Delta == 0) break;
            run++;
        }
        std::sort(begin,end,std::greater<Robot>());
    }
};

#endif