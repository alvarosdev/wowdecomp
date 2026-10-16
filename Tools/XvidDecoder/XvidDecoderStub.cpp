// Stub MinGW de XvidDecoder: ThirdParty/xvidcore/lib/x64/libxvidcore.lib está
// compilada con MSVC (/GS, despacho ISA de VS2015+) y sus símbolos internos
// del CRT (__security_cookie, __GSHandlerCheck, __isa_available, ...) no
// enlazan con MinGW. Hasta compilar xvidcore desde fuente, las cinemáticas
// fallan de forma controlada (el cliente sigue 100% jugable).
// Ver Tools/XvidDecoder/CMakeLists.txt (rama MINGW).
#include <cstdint>

#include "ThirdParty/DivxDecoder/DivxDecoder.h"

int32_t DivxDecode(int32_t /*decoder*/, DivxDecodeFrame* /*frame*/, int32_t /*flags*/) {
    return 1;
}

int32_t InitializeDivxDecoder(int32_t /*decoder*/, int32_t /*width*/, int32_t /*height*/) {
    return 1;
}

int32_t SetOutputFormat(int32_t /*decoder*/, int32_t /*format*/, int32_t /*width*/, int32_t /*height*/) {
    return 1;
}

int32_t UnInitializeDivxDecoder(int32_t /*decoder*/) {
    return 0;
}
