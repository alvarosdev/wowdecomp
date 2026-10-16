file(GLOB_RECURSE PRIVATE_SOURCES CONFIGURE_DEPENDS "*.cpp")

if (NOT WIN32)
    list(FILTER PRIVATE_SOURCES EXCLUDE REGEX "/CGxDevice(D3d|D3d9Ex|OpenGL)/")
endif ()

add_library(Gx STATIC
    ${PRIVATE_SOURCES}
)

target_include_directories(Gx
    PUBLIC
        ${CMAKE_SOURCE_DIR}
)

if (MSVC)
    target_link_libraries(Gx PRIVATE d3d9.lib)
else ()
    # MinGW: enlaza contra libd3d9.a del toolchain (import lib del sistema).
    target_link_libraries(Gx PRIVATE d3d9)
endif ()

if (WIN32)
    target_link_libraries(Gx
        PRIVATE
            nvapi
    )
    if (MSVC)
        target_link_libraries(Gx PRIVATE opengl32.lib)
    else ()
        target_link_libraries(Gx PRIVATE opengl32)
    endif ()
endif ()
