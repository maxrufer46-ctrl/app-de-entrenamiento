# FitTrack

Aplicación nativa de macOS para planificar y registrar entrenamientos, consultar el historial y seguir el progreso. Proyecto contenido íntegramente en `FitTrack/`, dentro de [app-de-entrenamiento](https://github.com/maxrufer46-ctrl/app-de-entrenamiento).

## Estado de la entrega

**Fase 0 completada: arquitectura, estructura y plan de implementación.** Todavía no existe un proyecto `.xcodeproj`, código de aplicación ni un ejecutable. Se crearán en la fase 1; esta entrega no afirma que la app compile ni que sus módulos estén implementados.

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
- [Arquitectura y responsabilidades](Docs/ARQUITECTURA.md).
- [Estructura de carpetas y archivos previstos](Docs/ESTRUCTURA.md).
- [Modelo de datos e invariantes](Docs/MODELO_DATOS.md).
- [Compatibilidad y alternativas para Catalina](Docs/COMPATIBILIDAD.md).
- [Fases 1–11 y criterios de aceptación](Docs/PLAN_DE_FASES.md).
- [Pruebas, cobertura y comprobación en Mac](Docs/QA.md).

## Obtener el proyecto

```bash
git clone https://github.com/maxrufer46-ctrl/app-de-entrenamiento.git
cd app-de-entrenamiento/FitTrack
```

Las carpetas reservadas llevan `.gitkeep` para que Git las conserve. No son módulos implementados. Los comandos de compilación de [QA](Docs/QA.md) se podrán ejecutar a partir de la fase 1, en un Mac con Xcode 12.4.

## Próximo entregable

Fase 1: `FitTrack.xcodeproj`, esquema compartido `FitTrack`, arranque AppKit, ventana con `NSHostingView`, inyección de dependencias, modelo Core Data v1, errores de apertura recuperables y targets XCTest. La compilación y ejecución deberán verificarse en Catalina; una revisión desde Linux no sustituye esa comprobación.

## Licencia

Se aplica la [licencia CC0 del repositorio](../LICENSE). Los contenidos y recursos que se incorporen posteriormente deberán documentar su procedencia. No se copiarán código, marca ni recursos de SmartGym.
