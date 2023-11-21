#ifndef __TRIANGULATION_H__
#define __TRIANGULATION_H__

#include <vector>
#include "mass.h"

namespace Triangulation {
    namespace Simplex {
        struct Edge {
            uint16_t v1;
            uint16_t v2;
            float dist;
        };
    }

    std::vector<Simplex::Edge> AlphaShape(const std::vector<Mass>& masses);

    std::vector<Simplex::Edge> KNN(const std::vector<Mass>& masses, uint16_t K);
    std::vector<Simplex::Edge> KNN_CPU(const std::vector<Mass>& mass_group, uint16_t K);

    /// @brief Computes the K Nearest neighbors for each mass of each mass_list
    /// @tparam T - requires variable masses
    /// @param point_groups 
    /// @param k 
    /// @return vector of KNNs for each mass in each group
    std::vector<Simplex::Edge> Batch(const std::vector<Mass>& mass_groups, uint16_t K);
}

#endif