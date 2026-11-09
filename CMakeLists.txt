#**************************************************************************************************
#
#   raylib C-Vorlage – CMake-Build (Alternative zum Makefile)
#
#   Nutzung (Ninja + Clang):
#       cmake -S . -B build -G Ninja
#       cmake --build build
#       cmake --build build --target run      # kompiliert (falls nötig) und startet das Programm
#
#   Oder bequem über die Presets:
#       cmake --preset release && cmake --build --preset release
#       cmake --preset debug   && cmake --build --preset debug
#
#   Das Programm landet im Build-Ordner (build/app bzw. build/<preset>/app);
#   bin/ ist dem Makefile vorbehalten.
#
#   Voraussetzung: libraylib.a liegt in lib/ (Wayland-pur Build)
#
#**************************************************************************************************

cmake_minimum_required(VERSION 3.20)

# Clang als Compiler verwenden, sofern nicht explizit ein anderer gesetzt wurde.
# (muss vor project() passieren)
if(NOT DEFINED CMAKE_C_COMPILER)
    find_program(CLANG_EXECUTABLE NAMES clang)
    if(CLANG_EXECUTABLE)
        set(CMAKE_C_COMPILER "${CLANG_EXECUTABLE}" CACHE FILEPATH "C-Compiler")
    endif()
endif()

project(raylib_template C)

# Standard-Build-Typ, falls keiner angegeben wurde (analog zum Makefile: RELEASE)
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build-Typ" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release)
endif()

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)   # entspricht -std=c17

# Name des erzeugten Programms
set(TARGET app)

# Build-Artefakte bleiben im Build-Ordner (bin/ ist dem Makefile vorbehalten)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

# compile_commands.json für clangd/IDE-Tooling erzeugen
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Symlink im Projektstamm auf die compile_commands.json des Build-Ordners anlegen,
# damit clangd/IDEs sie ohne Zusatzkonfiguration finden. Ein bereits vorhandener
# Symlink wird aktualisiert; eine echte Datei wird nicht überschrieben.
set(COMPILE_COMMANDS_LINK "${CMAKE_SOURCE_DIR}/compile_commands.json")
if(IS_SYMLINK "${COMPILE_COMMANDS_LINK}")
    file(REMOVE "${COMPILE_COMMANDS_LINK}")
endif()
if(NOT EXISTS "${COMPILE_COMMANDS_LINK}")
    file(RELATIVE_PATH COMPILE_COMMANDS_REL
        "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/compile_commands.json")
    file(CREATE_LINK "${COMPILE_COMMANDS_REL}" "${COMPILE_COMMANDS_LINK}" SYMBOLIC)
endif()

# Statische raylib-Bibliothek als importiertes Target
add_library(raylib STATIC IMPORTED)
set_target_properties(raylib PROPERTIES
    IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/lib/libraylib.a"
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_SOURCE_DIR}/lib"
)

add_executable(${TARGET} src/main.c)

target_compile_options(${TARGET} PRIVATE
    -Wall -Wextra -D_DEFAULT_SOURCE
    $<$<CONFIG:Debug>:-g;-O0>
    $<$<CONFIG:Release>:-O2>
)

# Statische raylib-Lib plus System-Bibliotheken (Wayland-Backend), analog zum Makefile
target_link_libraries(${TARGET} PRIVATE
    raylib
    GL m pthread dl rt
    wayland-client wayland-cursor wayland-egl xkbcommon
)

# "run"-Target analog zu "make run"
add_custom_target(run
    COMMAND $<TARGET_FILE:${TARGET}>
    DEPENDS ${TARGET}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    USES_TERMINAL
)
