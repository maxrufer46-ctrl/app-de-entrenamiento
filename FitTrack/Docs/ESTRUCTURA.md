# Estructura del proyecto

Todas las rutas de esta página son relativas a `FitTrack/`. Las carpetas existen desde la fase 0 con `.gitkeep`. Los archivos Swift, Xcode, JSON y assets enumerados son entregables previstos, todavía no implementados.

| Carpeta creada | Archivos o contenido previstos | Fase |
| --- | --- | --- |
| `App/` | `FitTrackApplication.swift`, `AppDelegate.swift`, `AppContainer.swift`, `MainWindowController.swift`, `MenuBuilder.swift` | 1; comandos completos en 10 |
| `Config/` | `Info.plist`, `FitTrack.entitlements`, `Debug.xcconfig`, `Release.xcconfig` | 1 |
| `Models/Domain/` | `Exercise.swift`, `Routine.swift`, `WorkoutSession.swift`, `WorkoutSet.swift`, `BodyMeasurement.swift`, tipos y errores | 2 y fases de cada módulo |
| `Models/Persistence/` | `CoreDataStack.swift`, `FitTrack.xcdatamodeld`, entidades `*Entity` y mapeos | 1–2 |
| `Repositories/Protocols/` | Contratos de ejercicio, rutina, sesión, medidas y perfil | 2 |
| `Repositories/CoreData/` | Implementaciones Core Data de esos contratos | 2 y fases de cada módulo |
| `Repositories/InMemory/` | Implementaciones sustituibles para previews y pruebas | 2 |
| `Services/` | Servicios de catálogo, sesión, timer, notificaciones, PR, estadísticas, exportación, importación y ajustes | 2–10 |
| `ViewModels/` | ViewModels por módulo, coordinados por `AppContainer` | 4–10 |
| `Views/Shell/` | Sidebar, selección, estados de carga/error y adaptadores AppKit | 3 |
| `Views/Exercises/` | Búsqueda, filtros, listado, detalle y editor de ejercicios | 4 |
| `Views/Routines/` | Listado, editor de días, prescripciones y reordenamiento | 5 |
| `Views/Session/` | Sesión, registro de series, descanso y enfoque | 6 |
| `Views/History/` | Lista, calendario, detalle y editor de sesiones pasadas | 7 |
| `Views/Statistics/` | KPIs, gráficos y selección de rangos | 8 |
| `Views/Measurements/` | Registro de medidas, fotos y evolución | 9 |
| `Views/Tools/` | Temporizadores y calculadoras | 9 |
| `Views/Settings/` | Preferencias, importación/exportación, Acerca de | 10 |
| `Views/Onboarding/` | Perfil y objetivos de primer inicio | 10 |
| `DesignSystem/Components/` | Formularios, badges, estados vacíos, gráficos y controles reutilizables | 3 y 8 |
| `DesignSystem/Icons/` | Registro semántico de iconos compatible con Catalina | 3 |
| `Resources/Seeds/` | `exercises.v1.json`, `routines.v1.json`, metadatos de revisión y versión | 2 |
| `Resources/Icons/` | PDF vectoriales propios; no carga dinámica de SF Symbols | 3 |
| `Resources/Localization/es.lproj/` | `Localizable.strings`, `InfoPlist.strings`, plurales cuando proceda | Desde 3; auditoría en 10 |
| `Resources/Localization/en.lproj/` | Equivalentes en inglés | Desde 3; auditoría en 10 |
| `Tests/Unit/` | Modelos, servicios y ViewModels con doubles | Desde 2 |
| `Tests/Integration/` | Persistencia, seeds, importación, exportación y migraciones | Desde 1 |
| `Tests/UI/` | Arranque, flujo principal, teclado y módulos | Desde 3 |
| `Tests/Fixtures/` | Catálogo mínimo, backups y sesiones deterministas | Desde 2 |
| `Scripts/` | Validación de catálogo, build/test y cobertura compatibles con las herramientas elegidas | 2 y 11 |
| `Docs/` | Arquitectura, fases, QA y documentación de usuario | 0–11 |

En la fase 1 se añadirá `FitTrack.xcodeproj/` directamente aquí. El `.xcodeproj` usará un formato legible por Xcode 12.4, grupos que reflejen rutas físicas y un esquema compartido `FitTrack`. No se requiere XcodeGen, Tuist, CocoaPods ni un manifiesto SwiftPM para arrancar la app.

Targets previstos: `FitTrack` (app macOS), `FitTrackTests` (unitarios e integración) y `FitTrackUITests` (UI). Las fixtures pertenecen al bundle de tests y los seeds al bundle de la app. No habrá referencias absolutas al ordenador de desarrollo en el proyecto Xcode.

Los `.gitkeep` se eliminarán de cada carpeta al incorporar su primer archivo real. No se reservarán falsos `.xcassets` ni `.xcdatamodeld` vacíos: se crearán con su contenido válido en su fase.
