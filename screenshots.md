# Capturas de pantalla

## Vista previa del README

La imagen `docs/assets/focnotes-preview.png` se generó renderizando `NoteView` fuera de pantalla. Este método evita capturar el escritorio y produce una imagen reproducible con el aspecto real de la aplicación.

La vista se creó con un tamaño lógico de `480 x 400` puntos y macOS produjo un PNG Retina de `960 x 800` píxeles. El README la muestra con un ancho de `480` píxeles.

### Proceso utilizado

1. Se añadió temporalmente un argumento `--export-preview` antes de iniciar `NSApplication` en `main.swift`.
2. El exportador creó una `NoteView` con Markdown de ejemplo dentro de una ventana sin bordes.
3. Se ejecutaron el layout y el dibujado de la vista sin mostrarla en pantalla.
4. `bitmapImageRepForCachingDisplay` y `cacheDisplay` generaron la representación Retina.
5. El PNG temporal se guardó en `.screenshots/`, carpeta excluida mediante `.gitignore`.
6. La imagen elegida se convirtió y copió a `docs/assets/` para versionarla.
7. El código temporal de exportación se eliminó después de generar la captura.

El comando de generación usado fue equivalente a:

```sh
mkdir -p .screenshots
swift run Focnotes --export-preview .screenshots/focnotes-preview.png
```

La copia final se preparó con:

```sh
sips -s format png .screenshots/focnotes-preview.png \
  --out docs/assets/focnotes-preview.png
```

### Markdown de ejemplo

````markdown
# Ideas para hoy

Escribe `foc notas.md` para abrir una nota.

```swift
let idea = "Siempre a la vista"
print(idea)
```

- [x] Mantener el enfoque
- [ ] Anotar la próxima idea
````

La captura definitiva debe permanecer en `docs/assets/`; solo los archivos de trabajo deben guardarse en `.screenshots/`.
