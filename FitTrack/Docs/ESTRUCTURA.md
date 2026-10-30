# Estructura del proyecto

Todas las rutas de esta página son relativas a `FitTrack/`. Las carpetas se reservaron en fase 0; la [fase 1](FASE_1.md) incorpora el proyecto Xcode, arranque, persistencia, perfil y pruebas. Los archivos de las fases 2–11 enumerados aquí siguen previstos y sus carpetas pueden conservar `.gitkeep`.

| Carpeta creada | Archivos o contenido previstos | Fase |
| --- | --- | --- |
| `App/` | `FitTrackApplication.swift`, `AppDelegate.swift`, `AppContainer.swift`, `MainWindowController.swift`, `MenuBuilder.swift` | 1; comandos completos en 10 |
| `Config/` | `Info.plist`, `FitTrack.entitlements`, `Debug.xcconfig`, `Release.xcconfig` | 1 |
| `Models/Domain/` | Ya existen `LocalProfile.swift` y `PersistenceError.swift`; ejercicio, rutina, sesión, series y medidas se añadirán después | 1–2 y fases de cada módulo |
| `Models/Persistence/` | `CoreDataStack.swift`, `FitTrack.xcdatamodeld`, entidades `*Entity` y mapeos | 1–2 |
| `Repositories/Protocols/` | Ya existe `ProfileRepository.swift`; los demás contratos se añadirán en fase 2 | 1–2 |
| `Repositories/CoreData/` | Ya existe `CoreDataProfileRepository.swift`; los demás repositorios se añadirán después | 1–2 y fases de cada módulo |
| `Repositories/InMemory/` | Implementaciones sustituibles para previews y pruebas | 2 |
| `Services/` | Ya existe `PersistenceService.swift`; los servicios de entrenamiento se añadirán después | 1–10 |
| `ViewModels/` | Ya existe `BootstrapViewModel.swift`; ViewModels por módulo después | 1 y 4–10 |
| `Views/Shell/` | Ya existe `BootstrapView.swift`; sidebar, selección y shell completo después | 1 y 3 |
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
| `Resources/Localization/es.lproj/` | Ya existen `Localizable.strings` e `InfoPlist.strings`; ampliar con cada módulo | Desde 1; auditoría en 10 |
| `Resources/Localization/en.lproj/` | Equivalentes en inglés | Desde 1; auditoría en 10 |
| `Tests/Unit/` | Modelos, servicios y ViewModels con doubles | Desde 1 |
| `Tests/Integration/` | Persistencia, seeds, importación, exportación y migraciones | Desde 1 |
| `Tests/UI/` | Arranque, perfil persistido, reintento y cierre; ampliar con cada módulo | Desde 1 |
| `Tests/Fixtures/` | Ya existen `TestSupport.swift` y `TestDoubles.swift`; fixtures de catálogo/backup después | Desde 1 |
| `Scripts/` | Ya existen `validate_project.py` y `verify-macos.sh`; validador de catálogos y cobertura específica después | Desde 1 |
| `Docs/` | Arquitectura, fases, QA y documentación de usuario | 0–11 |

`FitTrack.xcodeproj/` ya existe directamente aquí, en formato legible por Xcode 12.4, con grupos de carpetas, referencias relativas y esquema compartido `FitTrack`. No se requiere XcodeGen, Tuist, CocoaPods ni un manifiesto SwiftPM para arrancar la app.

Targets creados: `FitTrack` (app macOS), `FitTrackTests` (unitarios e integración) y `FitTrackUITests` (UI). Las fixtures pertenecen al target de tests y los seeds futuros al bundle de la app. El proyecto no contiene referencias absolutas al ordenador de desarrollo.

Los `.gitkeep` se eliminarán de cada carpeta al incorporar su primer archivo real. No se reservarán falsos `.xcassets` ni `.xcdatamodeld` vacíos: se crearán con su contenido válido en su fase.
