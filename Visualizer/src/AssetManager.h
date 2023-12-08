#ifndef __ASSET_MANAGER_H__
#define __ASSET_MANAGER_H__

#include "Elastic.h"
#include "EvoDevo.h"

class AssetManager {
public:
    AssetManager() : m_CurrentAssetIndex(0)
    {}

    AssetManager(std::vector<Elastic::Mesh*> initAssets) :
        m_Assets(initAssets), m_CurrentAssetIndex(0)
    {}

    ~AssetManager();

    void loadAssets(std::vector<Elastic::Mesh*> assets) {
        m_Assets.insert(m_Assets.end(), assets.begin(), assets.end());
    }

    void loadAssets(std::string directory);
    void loadRandomAssets(size_t count, EvoDevo::RobotType type);

    void loadAsset(Elastic::Mesh* newAsset) {
        m_Assets.push_back(newAsset);
    }

    void switchToNextAsset() {
        if(m_CurrentAssetIndex + 1 == m_Assets.size()) m_AssetWrappedFlag = true;
        m_CurrentAssetIndex = (m_CurrentAssetIndex + 1) % m_Assets.size();
        m_AssetChangedFlag = true;
    }

    bool hasAssetChanged() {
        return m_AssetChangedFlag;
    }

    bool hasWrapped() {
        return m_AssetWrappedFlag;
    }

    size_t getAssetIndex() {
        return m_CurrentAssetIndex;
    }

    void clearAssetChangedFlag() {
        m_AssetChangedFlag = false;
    }

    void clearAssetWrappedFlag() {
        m_AssetWrappedFlag = false;
    }

    Elastic::Mesh* getCurrentAsset() const {
        return m_Assets[m_CurrentAssetIndex];
    }

private:
    std::vector<Elastic::Mesh*> m_Assets;
    size_t m_CurrentAssetIndex;
    bool m_AssetChangedFlag = false;
    bool m_AssetWrappedFlag = false;
};

#endif