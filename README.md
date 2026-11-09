# raylib C-Vorlage

Einfache Projekt-Vorlage für raylib 6 (C), vorkompiliert für **Wayland-pur**.

## Inhalt

| Datei | Zweck |
|---|---|
| `libraylib.a` | Statische raylib-Bibliothek (Wayland-Backend, OpenGL 3.3) |
| `raylib.h` | Haupt-Header (inkludiert die Kern-API) |
| `raymath.h` | Vektor-/Matrizen-Mathematik (Header-only) |
| `rlgl.h` | Optionale Low-Level-OpenGL-API |
| `rcamera.h` | Optionale Kamera-Hilfsfunktionen |
| `rgestures.h` | Optionale Gestenerkennung |
| `external/glad.h` | Wird nur von `rlgl.h` benötigt |
| `Makefile` | Build-Datei (gcc) |
| `CMakeLists.txt` | Alternativer Build mit CMake + Ninja (clang) |
| `CMakePresets.json` | Presets für Release-/Debug-Builds |
| `main.c` | Hier startet dein Programm |

> **Hinweis:** Die Wayland-Protokoll-Header (`wayland-client-protocol.h`, …) sind
> Build-Artefakte der Bibliothek und daher **nicht** enthalten – sie stecken
> bereits fertig kompiliert in `libraylib.a`.

## Schnellstart

1. `main.c` anlegen (oder ergänzen), z. B.:

   ```c
   #include "raylib.h"

   int main(void)
   {
       InitWindow(800, 600, "raylib C-Vorlage");

       while (!WindowShouldClose())
       {
           BeginDrawing();
           ClearBackground(RAYWHITE);
           DrawText("Hallo Wayland!", 190, 200, 20, LIGHTGRAY);
           EndDrawing();
       }

       CloseWindow();
       return 0;
   }
   ```

2. Kompilieren:

   ```bash
   make
   ```

3. Starten:

   ```bash
   make run        # oder direkt: bin/app
   ```

## Weitere Kommandos

```bash
make clean                  # Artefakte entfernen
make BUILD_MODE=DEBUG       # Debug-Build mit -g -O0
```

## Alternativer Build mit CMake + Ninja (clang)

Als Alternative zum Makefile gibt es einen CMake-Build, der **clang** als Compiler
und **Ninja** als Generator verwendet. Alle Build-Artefakte bleiben im Ordner
`build/`; `bin/` ist dem Makefile vorbehalten.

Mit den Presets landet das Programm unter `build/release/app` bzw.
`build/debug/app`, ohne Presets unter `build/app`.

```bash
# Release (Default)
cmake --preset release
cmake --build --preset release

# Debug (-g -O0)
cmake --preset debug
cmake --build --preset debug

# Starten
cmake --build --preset release --target run
```

Ohne Presets geht es auch direkt:

```bash
cmake -S . -B build -G Ninja -DCMAKE_C_COMPILER=clang
cmake --build build
cmake --build build --target run
```

> Wird kein Compiler explizit angegeben, wählt `CMakeLists.txt` automatisch
> `clang`, sofern vorhanden.

### `compile_commands.json`

CMake erzeugt die `compile_commands.json` nur, wenn `CMAKE_EXPORT_COMPILE_COMMANDS`
aktiviert ist – standardmäßig ist das aus. In `CMakeLists.txt` ist es daher
gesetzt, die Datei liegt anschließend im jeweiligen Build-Ordner, z. B.
`build/release/compile_commands.json`.

Zusätzlich legt CMake beim Konfigurieren automatisch einen relativen Symlink
`compile_commands.json` im Projektstamm auf die Datei des zuletzt konfigurierten
Build-Ordners an, damit `clangd` und IDEs sie ohne Zusatzkonfiguration finden.
Eine bereits vorhandene echte Datei wird dabei nicht überschrieben.

Zum Aufräumen genügt das Löschen des Build-Ordners:

```bash
rm -rf build
```

## Manuelles Kompilieren (ohne Makefile)

```bash
gcc main.c -I. -L. -lraylib -lGL -lm -lpthread -ldl -lrt \
  -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon -o program
```

## Wichtige Hinweise

- Die Bibliothek ist **Wayland-pur** gebaut (kein X11-Codepfad). Das System muss
  eine laufende Wayland-Session haben (`$WAYLAND_DISPLAY` gesetzt).
- `libwayland-client`, `libwayland-cursor`, `libwayland-egl` und `libxkbcommon`
  werden erst **zur Laufzeit** per `dlopen` geladen – sie müssen im System
  vorhanden sein (bei jeder Wayland-Desktop-Sitzung der Fall).
- Kompiliert wurde gegen `gcc`, `-std=c99`, OpenGL 3.3.
