# Paralleler Build mit gcc (Makefile) und clang (CMake).
CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c17 -D_DEFAULT_SOURCE -Iapp -Ilib
CFLAGS_DEBUG = -Wall -Wextra -O0 -g3 -std=c17 -D_DEFAULT_SOURCE -Iapp -Ilib

# Statische raylib-Lib plus System-Bibliotheken (Wayland-Backend)
LDLIBS = -Llib -lraylib -lGL -lm -lpthread -ldl -lrt \
         -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon

APPNAME = demo
SRCS = app/main.c
OBJDIR = obj
BINDIR = bin
OBJS = $(patsubst %.c,$(OBJDIR)/%.o,$(SRCS))
TARGET = $(BINDIR)/$(APPNAME)

.PHONY: all clean run debug init

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(OBJS) -o $(TARGET) $(LDLIBS)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf $(OBJDIR) $(BINDIR)

run: $(TARGET)
	./$(TARGET)

# Debug-Build mit gcc (-O0 -g3). Nutzt dieselben Verzeichnisse wie der
# Release-Build (obj/, bin/), deshalb wird vorher sauber geloescht:
# Wechsel zwischen Release und Debug immer ueber `make clean`.
debug: clean
	$(MAKE) all CFLAGS="$(CFLAGS_DEBUG)"

init: clean
	bear -- $(MAKE) -B $(OBJS) CFLAGS="$(CFLAGS) -fsyntax-only"
	@sed -i 's/"-fsyntax-only",//g' compile_commands.json
