#**************************************************************************************************
#
#   raylib C-Vorlage – Makefile
#
#   Nutzung:
#       make            -> kompiliert app/main.c zu "bin/demo"
#       make run        -> kompiliert (falls nötig) und startet das Programm
#       make clean      -> entfernt Build-Artefakte
#
#       make cmake-init -> CMake-Projekt konfigurieren (Ninja-Generator)
#       make cmake      -> alternativer Build mit CMake + Ninja (clang)
#       make cmake-run  -> CMake-Build und Programm starten
#       make cmake-clean-> CMake-Build-Artefakte entfernen
#
#   Optionen:
#       make BUILD_MODE=DEBUG     -> mit Debug-Informationen (-g -O0)
#
#   Voraussetzung: libraylib.a liegt im selben Ordner (Wayland-pur Build)
#
#**************************************************************************************************

CC       ?= gcc

# Name des erzeugten Programms
TARGET   ?= bin/demo

# Quellcode: hier die eigene Datei eintragen (oder main.c anlegen)
SRC      ?= app/main.c

# Build-Modus: RELEASE (Default) oder DEBUG
BUILD_MODE ?= RELEASE

ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS = -Wall -Wextra -std=c17 -D_DEFAULT_SOURCE -g -O0
else
    CFLAGS = -Wall -Wextra -std=c17 -D_DEFAULT_SOURCE -O2
endif

# raylib-Header liegen im aktuellen Ordner
INCLUDE_PATHS = -Iapp -Ilib

# Statische raylib-Lib plus System-Bibliotheken (Wayland-Backend)
LDLIBS = -Llib -lraylib -lGL -lm -lpthread -ldl -lrt \
         -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) -o $@ $(SRC) $(CFLAGS) $(INCLUDE_PATHS) -L. $(LDLIBS)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.o

# --- CMake/Ninja-Build (Alternative, clang) -------------------------------------------------------

CMAKE            ?= cmake
CMAKE_BUILD_DIR  ?= build

cmake: cmake-build

cmake-init:
	$(CMAKE) -S . -B $(CMAKE_BUILD_DIR) -G Ninja

cmake-build: cmake-init
	$(CMAKE) --build $(CMAKE_BUILD_DIR)

cmake-run: cmake-build
	./$(CMAKE_BUILD_DIR)/demo

cmake-clean:
	rm -rf $(CMAKE_BUILD_DIR)

.PHONY: all run clean cmake cmake-init cmake-build cmake-run cmake-clean
