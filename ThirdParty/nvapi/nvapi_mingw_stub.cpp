// Stub MinGW de NvAPI: nvapi64.lib está compilada con MSVC (objetos con /GS
// y CRT interno) y no enlaza con MinGW. Solo se usa 3D Vision estéreo;
// devolver "dispositivo no encontrado" desactiva esa rama igual que en un
// equipo sin GPU NVIDIA. Solo MinGW (ver ThirdParty/CMakeLists.txt).
#include <windows.h>
#include <unknwn.h>

#include "ThirdParty/nvapi/nvapi.h"

extern "C" {

NvAPI_Status NvAPI_Initialize() {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_GetErrorMessage(NvAPI_Status /*nr*/, NvAPI_ShortString szDesc) {
    szDesc[0] = 0;
    return NVAPI_OK;
}

NvAPI_Status NvAPI_Stereo_CreateConfigurationProfileRegistryKey(
    NV_STEREO_REGISTRY_PROFILE_TYPE /*registryProfileType*/) {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_CreateHandleFromIUnknown(IUnknown* /*pDevice*/, StereoHandle* pStereoHandle) {
    if (pStereoHandle) {
        *pStereoHandle = nullptr;
    }
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_DestroyHandle(StereoHandle /*stereoHandle*/) {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_Disable() {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_Enable() {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_IsEnabled(NvU8* pIsStereoEnabled) {
    if (pIsStereoEnabled) {
        *pIsStereoEnabled = 0;
    }
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_SetConvergence(StereoHandle /*stereoHandle*/, float /*newConvergence*/) {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

NvAPI_Status NvAPI_Stereo_SetSeparation(StereoHandle /*stereoHandle*/, float /*newSeparationPercentage*/) {
    return NVAPI_NVIDIA_DEVICE_NOT_FOUND;
}

} // extern "C"
