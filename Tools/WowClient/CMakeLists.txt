file(GLOB CLIENT_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/WoW/Source/*.cpp")

if (WOWDECOMP_ARCH_64)
    file(GLOB CLIENT_PLATFORM_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/WoW/Source/Win64/*.cpp")
    set(WOWCLIENT_OUTPUT_NAME WowClient64)
else ()
    file(GLOB CLIENT_PLATFORM_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/WoW/Source/Win32/*.cpp")
    set(WOWCLIENT_OUTPUT_NAME WowClient32)
endif ()

set(WOWCLIENT_OUTPUT_OVERRIDE "" CACHE STRING "WowClient executable name instead of WowClient64/WowClient32 (re/tools/build sets Waystone / WaystoneDev)")
if (WOWCLIENT_OUTPUT_OVERRIDE)
    set(WOWCLIENT_OUTPUT_NAME ${WOWCLIENT_OUTPUT_OVERRIDE})
endif ()

option(WOWCLIENT_CRASH_LOG "Crash logger with console window and WowClient_crash.log (re/tools/build release mode turns it off)" ON)
set(CLIENT_TOOL_SOURCES "")
if (WOWCLIENT_CRASH_LOG)
    list(APPEND CLIENT_TOOL_SOURCES crash_log.cpp)
endif ()

add_executable(WowClient WIN32 ${CLIENT_SOURCES} ${CLIENT_PLATFORM_SOURCES} ${CLIENT_TOOL_SOURCES})

set_target_properties(WowClient PROPERTIES
    OUTPUT_NAME ${WOWCLIENT_OUTPUT_NAME}
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/Win
)

foreach (config ${CMAKE_CONFIGURATION_TYPES} ${CMAKE_BUILD_TYPE})
    string(TOUPPER ${config} config)
    set_target_properties(WowClient PROPERTIES RUNTIME_OUTPUT_DIRECTORY_${config} ${CMAKE_SOURCE_DIR}/bin/Win)
endforeach ()

target_include_directories(WowClient
    PRIVATE
        ${CMAKE_SOURCE_DIR}
)

if (MSVC)
    target_link_options(WowClient PRIVATE "/INCREMENTAL:NO" "/ENTRY:start")
elseif (MINGW)
    target_link_options(WowClient PRIVATE "-Wl,-e,start")
    # ld de GNU hace una sola pasada sobre las ~40 estáticas: con dependencias
    # cruzadas quedan cientos de undefined. Se envuelven en grupo de reescaneo
    # (MSVC reescanea solo). El -end-group va tras las libs (ver abajo).
    target_link_options(WowClient PRIVATE "-Wl,--start-group")
endif ()

target_link_libraries(WowClient
    PRIVATE
        BLPFile
        Base
        BlizzardCore
        ComSat
        ConsoleBase
        Event
        FFX
        Frame
        FrameScript
        lua
        FrameXML
        Gx
        Gxu
        Images
        Model2
        Os
        Scrn
        Services
        ShaderEffect
        Tempest
        SoundEngine
        SteelseriesMouse
        Storm
        WoWCommon
        Battlenet
        Console
        ConsoleDevice
        DB
        Game
        Glue
        Magic
        Minigame
        Net
        Object
        ObjectAlloc
        ObjectMgrClient
        SoundInterface
        UIUtil
        Ui
        WorldClient
        LiquidSystem
        WowServices
        WowSvcs
        dbghelp
)

if (MINGW)
    # Cierre del grupo de reescaneo: va tras las estáticas (ver arriba).
    target_link_libraries(WowClient PRIVATE "-Wl,--end-group")

    # El exe necesita las DLLs de runtime MinGW junto a él para correr con Wine.
    # Se buscan con el compilador en uso y, si es Clang (sin runtime propio),
    # con el g++ de MinGW, cuyo libstdc++ usa Clang también.
    foreach (mingw_dll libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll)
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} -print-file-name=${mingw_dll}
            OUTPUT_VARIABLE MINGW_DLL_PATH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if (NOT EXISTS ${MINGW_DLL_PATH})
            execute_process(
                COMMAND x86_64-w64-mingw32-g++ -print-file-name=${mingw_dll}
                OUTPUT_VARIABLE MINGW_DLL_PATH
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
        endif ()
        if (EXISTS ${MINGW_DLL_PATH})
            add_custom_command(TARGET WowClient POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MINGW_DLL_PATH} ${CMAKE_SOURCE_DIR}/bin/Win/${mingw_dll}
            )
        endif ()
    endforeach ()
endif ()
