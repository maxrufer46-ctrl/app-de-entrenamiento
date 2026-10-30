# FitTrack

Aplicación nativa de macOS para planificar y registrar entrenamientos, consultar el historial y seguir el progreso. Proyecto contenido íntegramente en `FitTrack/`, dentro de [app-de-entrenamiento](https://github.com/maxrufer46-ctrl/app-de-entrenamiento).

## Estado de la entrega

**Fase 1 implementada en código; aceptación nativa pendiente.** Ya existe `FitTrack.xcodeproj`, con arranque AppKit, ventana SwiftUI, Core Data y un perfil local que permite guardar y recargar un nombre. Incluye esquema compartido, firma local configurable y 34 métodos XCTest preparados.

Las comprobaciones estructurales pasan en el entorno de preparación. **No se ha compilado ni ejecutado en Xcode 12.4/Catalina**, por lo que la compatibilidad real, los resultados de XCTest y la cobertura siguen pendientes. Los módulos de entrenamiento y los catálogos de 300 ejercicios/50 rutinas pertenecen a las fases siguientes.

| Decisión | Base del proyecto |
| --- | --- |
| Runtime mínimo | macOS 10.15; validación de referencia en Catalina 10.15.7 |
| Herramientas | Xcode 12.4, sintaxis compatible con Swift 5.3 |
| Interfaz | SwiftUI disponible en Catalina, con integración AppKit |
| Entrada | `@main` con `static main()` y `NSApplicationDelegate`; sin lifecycle SwiftUI `App` |
| Persistencia | Core Data y `NSPersistentContainer`, almacenamiento local |
| Arquitectura | MVVM, repositorios por protocolo y servicios inyectables |
| Concurrencia | DispatchQueue y Combine |
| Idiomas | Español e inglés mediante archivos `.strings` |
| Dependencias de ejecución | Solo frameworks de Apple |

El texto original solicita «Catalina 10.15.8». Se conserva en el [brief](Docs/BRIEF_ORIGINAL.md); la matriz inicial usa la versión 10.15.7 documentada por Apple. Véanse las demás correcciones en [Compatibilidad](Docs/COMPATIBILIDAD.md).

## Documentación

- [Fase 0: decisiones, archivos y verificación](Docs/FASE_0.md).
- [Fase 1: archivos, apertura en Xcode y checklist](Docs/FASE_1.md).
- [Arquitectura y responsabilidades](Docs/ARQUITECTURA.md).
- [Estructura de carpetas y archivos previstos](Docs/ESTRUCTURA.md).
- [Modelo de datos e invariantes](Docs/MODELO_DATOS.md).
- [Compatibilidad y alternativas para Catalina](Docs/COMPATIBILIDAD.md).
- [Fases 1–11 y criterios de aceptación](Docs/PLAN_DE_FASES.md).
- [Pruebas, cobertura y comprobación en Mac](Docs/QA.md).

## Obtener esta entrega

Mientras la fase 1 está en revisión, su código está en la rama `codex/fittrack-phase-1`:

```bash
git clone --branch codex/fittrack-phase-1 https://github.com/maxrufer46-ctrl/app-de-entrenamiento.git
cd app-de-entrenamiento/FitTrack
open FitTrack.xcodeproj
```

En Xcode 12.4, seleccionar el esquema **FitTrack**, destino **My Mac** y ejecutar con **Cmd+R**. La configuración incluida usa firma local ad hoc (`-`); para distribución habrá que elegir una identidad propia. El esquema de pruebas se ejecuta con **Cmd+U**.

Para la comprobación completa en Catalina:

```bash
export DEVELOPER_DIR=/Applications/Xcode_12.4.app/Contents/Developer
bash Scripts/verify-macos.sh
```

Ajustar `DEVELOPER_DIR` si la aplicación Xcode tiene otro nombre. El script conserva logs y cobertura bajo `TestResults/`. Sin Xcode también se pueden revisar estructura y recursos con `python3 Scripts/validate_project.py`; ese comando no compila Swift.

Las carpetas reservadas que todavía llevan `.gitkeep` no son módulos implementados. La [fase 1](Docs/FASE_1.md) identifica los archivos reales y las comprobaciones pendientes.

## Próximo entregable

Fase 2: modelos de dominio del entrenamiento, repositorios de ejercicios/rutinas/sesiones, importación idempotente y catálogo validado con al menos 300 ejercicios y 50 rutinas. Antes de aceptar la fase 1, ejecutar también su verificación nativa en Catalina.

## Licencia

Se aplica la [licencia CC0 del repositorio](../LICENSE). Los contenidos y recursos que se incorporen posteriormente deberán documentar su procedencia. No se copiarán código, marca ni recursos de SmartGym.
