#ifndef __VISUALIZER_UTIL_H__
#define __VISUALIZER_UTIL_H__

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <vector>
#include "visualizer_config.h"
#include "EvoDevo.h"

namespace Vis {
    namespace Util {
        VisualizerConfig ReadConfigFile(const std::string& filename);
    }
}

#endif