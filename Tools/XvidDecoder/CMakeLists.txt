if (MINGW)
    # Sin libxvidcore (MSVC-only): backend stub, ver XvidDecoderStub.cpp.
    add_library(XvidDecoder SHARED
        XvidDecoderStub.cpp
        XvidDecoder.def
    )
else ()
    add_library(XvidDecoder SHARED
        XvidDecoder.cpp
        XvidDecoder.def
    )
endif ()

set_target_properties(XvidDecoder PROPERTIES
    OUTPUT_NAME XvidDecoder
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/Win
)

if (MINGW)
    # MinGW antepone "lib" a las SHARED; el cliente carga "XvidDecoder.dll".
    set_target_properties(XvidDecoder PROPERTIES PREFIX "")
endif ()

foreach (config ${CMAKE_CONFIGURATION_TYPES} ${CMAKE_BUILD_TYPE})
    string(TOUPPER ${config} config)
    set_target_properties(XvidDecoder PROPERTIES RUNTIME_OUTPUT_DIRECTORY_${config} ${CMAKE_SOURCE_DIR}/bin/Win)
endforeach ()

target_include_directories(XvidDecoder
    PRIVATE
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/ThirdParty/xvidcore/include
)

if (NOT MINGW)
    target_link_libraries(XvidDecoder
        PRIVATE
            ${CMAKE_SOURCE_DIR}/ThirdParty/xvidcore/lib/x64/libxvidcore.lib
    )
endif ()

if (MSVC)
    target_compile_options(XvidDecoder
        PRIVATE
            $<$<CONFIG:Debug>:/MD>
    )
endif ()
