#**************************************************************************************************
#
#   raylib C-Vorlage – Makefile
#
#   Nutzung:
#       make            -> kompiliert main.c zu "program"
#       make run        -> kompiliert (falls nötig) und startet das Programm
#       make clean      -> entfernt Build-Artefakte
#
#   Optionen:
#       make BUILD_MODE=DEBUG     -> mit Debug-Informationen (-g -O0)
#
#   Voraussetzung: libraylib.a liegt im selben Ordner (Wayland-pur Build)
#
#**************************************************************************************************

CC       ?= gcc

# Name des erzeugten Programms
TARGET   ?= bin/app

# Quellcode: hier die eigene Datei eintragen (oder main.c anlegen)
SRC      ?= src/main.c

# Build-Modus: RELEASE (Default) oder DEBUG
BUILD_MODE ?= RELEASE

ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS = -Wall -Wextra -std=c17 -D_DEFAULT_SOURCE -g -O0
else
    CFLAGS = -Wall -Wextra -std=c17 -D_DEFAULT_SOURCE -O2
endif

# raylib-Header liegen im aktuellen Ordner
INCLUDE_PATHS = -Isrc -Ilib

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

.PHONY: all run clean
