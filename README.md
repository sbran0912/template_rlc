# raylib C-Vorlage

Einfache Projekt-Vorlage für raylib 6 (C), vorkompiliert für **Wayland-pur**.

## Inhalt

| Datei | Zweck |
|---|---|
| `app/main.c` | Hier startet dein Programm |
| `lib/libraylib.a` | Statische raylib-Bibliothek (Wayland-Backend, OpenGL 3.3, GLFW eingebettet) |
| `lib/raylib.h` | Haupt-Header (inkludiert die Kern-API) |
| `lib/raymath.h` | Vektor-/Matrizen-Mathematik (Header-only) |
| `lib/rlgl.h` | Optionale Low-Level-OpenGL-API |
| `lib/rcamera.h` | Optionale Kamera-Hilfsfunktionen |
| `lib/rgestures.h` | Optionale Gestenerkennung |
| `lib/rlights.h` | Optionale Beleuchtungs-Helfer |
| `lib/external/glad.h` | Wird nur von `rlgl.h` benötigt |
| `Makefile` | Haupt-Build (gcc, inkrementell) |
| `CMakeLists.txt` | Alternativer Build mit CMake + Ninja (clang) |
| `.zed/`, `.vscode/` | Editor-/Debug-Konfiguration (Zed bzw. VS Code) |

> **Hinweis:** Die Wayland-Protokoll-Header (`wayland-client-protocol.h`, …) sind
> Build-Artefakte der Bibliothek und daher **nicht** enthalten – sie stecken
> bereits fertig kompiliert in `libraylib.a`.

## Schnellstart

1. `app/main.c` anlegen (oder ergänzen), z. B.:

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
make clean       # Build-Artefakte (obj/, bin/) entfernen
make debug       # Debug-Build mit -O0 -g3 (löscht vorher)
make run         # bauen (falls nötig) und starten
make init        # compile_commands.json erzeugen (für clangd)
```

Der Build ist inkrementell: Objektdateien liegen in `obj/`, das Programm in
`bin/demo`. `make debug` kompiliert mit `-O0 -g3`; da sich Release- und
Debug-Build die Verzeichnisse `obj/` und `bin/` teilen, wird dabei vorher
sauber gelöscht. Ein Wechsel also immer über `make clean` bzw. `make debug`.

## Alternative: CMake + Ninja (clang)

Als Ergänzung zu den Makefile-Zielen gibt es einen CMake-Build mit **clang**
und **Ninja**. Er ist **nicht** in das Makefile eingebunden und wird direkt
aufgerufen; alle Artefakte landen in `build/` (das Programm unter `build/demo`).

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

Nach Code-Änderungen genügt:

```bash
cmake --build build
```

Der Build-Typ ist standardmäßig `Release` (`-O2 -DNDEBUG`). Für einen
Debug-Build (`-O0 -g3`):

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

Aufräumen:

```bash
rm -rf build
```

> Hinweis: Der Compiler ist in `CMakeLists.txt` fest auf `clang` gesetzt. Ein
> bereits mit einem anderen Compiler konfiguriertes `build/` muss vorher
> gelöscht werden (`rm -rf build`). Überschreiben lässt sich der Compiler mit
> `-DCMAKE_C_COMPILER=...`.

## clangd (`compile_commands.json`)

`make init` erzeugt per `bear` eine `compile_commands.json` **im
Wurzelverzeichnis**. clangd findet sie dort automatisch (ein `.clangd` ist
nicht nötig).

> Der CMake-Build erzeugt seine Compile-Datenbank unter
> `build/compile_commands.json`. Da sie nicht im Wurzelverzeichnis liegt, wird
> sie von clangd nur gefunden, wenn man entsprechend darauf verweist.

## Manuelles Kompilieren (ohne Makefile)

GL und die Wayland-Bibliotheken stecken bereits in `libraylib.a` (bzw. werden
zur Laufzeit per `dlopen` geladen), daher genügen raylib und libm:

```bash
gcc app/main.c -Iapp -Ilib -Llib -lraylib -lm -o demo
```

## Wichtige Hinweise

- Die Bibliothek ist **Wayland-pur** gebaut (kein X11-Codepfad). Das System muss
  eine laufende Wayland-Session haben (`$WAYLAND_DISPLAY` gesetzt).
- `libwayland-client`, `libwayland-cursor`, `libwayland-egl` und `libxkbcommon`
  werden von raylib erst **zur Laufzeit** per `dlopen` geladen – sie müssen im
  System vorhanden sein (bei jeder Wayland-Desktop-Sitzung der Fall). Zur
  Link-Zeit sind sie daher **nicht** nötig.
- GLFW ist bereits in `libraylib.a` eingebettet, ein separates `-lglfw` bzw.
  `-lGL` ist nicht erforderlich. `libpthread`, `libdl` und `librt` sind in
  glibc ≥ 2.34 enthalten und müssen nicht extra gelinkt werden.
- Kompiliert wurde gegen `gcc`, `-std=c17`, OpenGL 3.3.
