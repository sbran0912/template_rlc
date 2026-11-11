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
   make run        # oder direkt: bin/demo
   ```

## Weitere Kommandos

```bash
make clean                  # Artefakte entfernen
make BUILD_MODE=DEBUG       # Debug-Build mit -g -O0
```

Der CMake-Build lässt sich ebenfalls über das Makefile steuern:

```bash
make cmake-init                     # CMake-Projekt konfigurieren (Ninja)
make cmake                          # CMake-Build (clang)
make cmake-run                      # CMake-Build und Programm starten
make cmake-clean                    # build/ entfernen
```

## Alternativer Build mit CMake + Ninja (clang)

Als Alternative zum Makefile gibt es einen CMake-Build, der **clang** als Compiler
und **Ninja** als Generator verwendet. Alle Build-Artefakte bleiben im Ordner
`build/`; `bin/` ist dem Makefile vorbehalten.

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

Das entspricht genau dem Makefile-Target `make cmake-init` (Konfigurieren)
gefolgt von `make cmake-build` (Bauen).

Das Programm liegt danach unter `build/demo`.

Nach Code-Änderungen genügt:

```bash
cmake --build build
```

Neu konfigurieren (`cmake -S . -B build -G Ninja`) muss man nur, wenn sich
`CMakeLists.txt` ändert, neue Dateien hinzukommen oder `build/` gelöscht wurde.

> Hinweis: Der Compiler ist in `CMakeLists.txt` fest auf `clang` gesetzt. Ein
> bereits mit einem anderen Compiler konfiguriertes `build/` muss vorher
> gelöscht werden (`rm -rf build`). Überschreiben lässt sich der Compiler mit
> `-DCMAKE_C_COMPILER=...`.

### `compile_commands.json`

CMake erzeugt die `compile_commands.json` nur, wenn `CMAKE_EXPORT_COMPILE_COMMANDS`
aktiviert ist – standardmäßig ist das aus. In `CMakeLists.txt` ist es daher
gesetzt, die Datei liegt anschließend unter `build/compile_commands.json`.
clangd findet sie über den Eintrag `CompilationDatabase: build` in `.clangd`.

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
