cmake_minimum_required(VERSION 3.16)

# Fester Compiler: clang. (Der parallele Makefile-Build kompiliert mit gcc.)
# Achtung: greift nur beim ersten Konfigurieren - ein bereits mit gcc
# konfiguriertes build/ muss vorher geloescht werden.
set(CMAKE_C_COMPILER clang)

project(raylib_template C)

# Standard-Build-Typ, falls beim Konfigurieren keiner angegeben wurde.
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Optimierung/Debug-Infos je Build-Typ (statt fest verdrahtetem -O2).
#   Debug   -> -O0 -g3   (volles Debugging)
#   Release -> -O2 -DNDEBUG
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")

# Gleiche Sprachversion wie im Makefile: striktes C17 (-std=c17).
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Beim Konfigurieren compile_commands.json fuer clangd erzeugen.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(demo app/main.c)

target_include_directories(demo PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

target_compile_options(demo PRIVATE -Wall -Wextra -D_DEFAULT_SOURCE)

# Statische raylib-Lib plus System-Bibliotheken (Wayland-Backend),
# analog zum Makefile
target_link_directories(demo PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lib)
target_link_libraries(demo PRIVATE
    raylib
    GL m pthread dl rt
    wayland-client wayland-cursor wayland-egl xkbcommon
)
