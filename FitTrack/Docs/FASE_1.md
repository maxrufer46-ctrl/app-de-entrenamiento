# Fase 1 — Proyecto Xcode, arranque y Core Data

## Estado de la entrega

Implementación preparada para revisión: proyecto Xcode, arranque AppKit, ventana SwiftUI de Catalina, inyección de dependencias, esquema Core Data v1 completo y primer flujo persistente de perfil. **La aceptación nativa permanece pendiente:** el entorno de preparación es Linux y no tiene `xcodebuild`, los SDK de Apple ni el runtime de Catalina.

Se han ejecutado las comprobaciones estructurales indicadas abajo. No se afirma que exista un build sin warnings, pruebas XCTest aprobadas, cobertura medida ni un `.app` ya construido.

## Archivos creados o modificados

Todas las rutas son relativas a `FitTrack/`.

| Ruta | Implementación |
| --- | --- |
| `FitTrack.xcodeproj/project.pbxproj` | Proyecto formato 52, compatible con Xcode 12.4; grupos y referencias relativas; targets `FitTrack`, `FitTrackTests`, `FitTrackUITests`. |
| `FitTrack.xcodeproj/xcshareddata/xcschemes/FitTrack.xcscheme` | Esquema compartido con ambos targets de test y cobertura de la app. |
| `FitTrack.xcodeproj/project.xcworkspace/` | Workspace interno y configuración compartida. |
| `Config/Base.xcconfig`, `Debug.xcconfig`, `Release.xcconfig` | Deployment target 10.15, Swift 5, x86_64, Debug/Release y warnings tratados como errores. |
| `Config/Info.plist`, `Tests-Info.plist`, `FitTrack.entitlements` | Bundle de app/tests y sandbox con archivos seleccionados por el usuario. |
| `App/FitTrackApplication.swift` | Único `@main` con `static main()` y `NSApplication.run()`. No hay `main.swift` ni SwiftUI `App`. |
| `App/AppDelegate.swift` | Arranque, comandos, reapertura y cierre con guardado/reintento/cancelación. |
| `App/AppContainer.swift` | Propietario estable del stack, repositorio y ViewModel. |
| `App/MainWindowController.swift` | Ventana nativa con `NSHostingView`, tamaño mínimo, geometría y cierre coordinado. |
| `App/MenuBuilder.swift` | Menús AppKit de aplicación, Archivo, Edición y Ventana; Cmd+S/W/Q y edición estándar. |
| `App/LaunchConfiguration.swift` | Almacenes aislados de tests y fallo simulado de primer arranque, solo en Debug. |
| `Models/Persistence/CoreDataStack.swift` | Un `NSPersistentContainer`, apertura asíncrona/coalescida, modelo compilado, migración ligera y contextos privados. |
| `Models/Persistence/FitTrack.xcdatamodeld/` | Modelo v1 con 16 entidades, 28 extremos de relaciones inversas y constraints de UUID/singletons. |
| `Models/Domain/LocalProfile.swift`, `PersistenceError.swift` | Snapshot del perfil, validación de nombre y errores de dominio. |
| `Repositories/Protocols/ProfileRepository.swift` | Contrato con valores y callbacks en la cola principal. |
| `Repositories/CoreData/CoreDataProfileRepository.swift` | Lectura/actualización del perfil con identidad estable y rollback ante error. |
| `Services/PersistenceService.swift` | Contrato de lifecycle sin Core Data en el ViewModel. |
| `ViewModels/BootstrapViewModel.swift` | Estados de apertura/error/listo, validación, borrador, guardado y espera antes de salir. |
| `Views/Shell/BootstrapView.swift` | Pantalla de bienvenida, perfil y errores recuperables; indicador AppKit compatible. |
| `Resources/Localization/{es,en}.lproj/` | 46 claves de interfaz/errores/menús y nombres de bundle. |
| `Tests/Unit/`, `Tests/Integration/`, `Tests/UI/`, `Tests/Fixtures/` | 34 métodos XCTest, helpers y sustitutos de repositorio/almacén. |
| `Scripts/validate_project.py` | Validación estructural sin paquetes externos ni Xcode. |
| `Scripts/verify-macos.sh` | Builds Debug/Release y tests/cobertura en Catalina con Xcode 12.4. |
| `README.md`, documentación de estructura/fases/QA | Estado actualizado y comandos reales de apertura/verificación. |

Los `.gitkeep` se retiran de las carpetas que ya tienen contenido real. Las carpetas de módulos posteriores permanecen reservadas.

## Decisiones de implementación

El modelo se compila desde la fase **Sources** del target de app y se carga como `FitTrack.momd`; un modelo ausente se informa como error. No existe fallback a una base vacía ni borrado automático para sortear un error de apertura. Las entidades usan `NSManagedObject` sin generación automática; la conversión del perfil queda dentro del repositorio.

Se añade `scopeKey` único al perfil y `slotKey` único a la sesión activa para convertir las restricciones de singleton en reglas persistidas. Las colecciones futuras se guardan en `Binary Data` JSON explícito; no hay `Transformable`. Borrar rutinas o ejercicios conserva las referencias históricas mediante nullify y snapshots. Los tipos y repositorios del resto de entidades se implementan en fase 2.

Core Data abre SQLite de forma asíncrona. Las peticiones simultáneas comparten el intento de apertura, y un fallo permite otro intento. El repositorio trabaja en contextos privados, publica valores y confirma éxito después de guardar. El perfil mantiene UUID y fecha de creación al editarse.

Al cerrar una ventana o salir con Cmd+Q, se termina la edición activa y se guarda el borrador antes de autorizar el cierre. Una escritura en curso se espera; un borrador más reciente también se guarda. Si falla, la app permite reintentar, seguir editando o salir descartando expresamente los cambios pendientes. La base existente permanece intacta.

La firma de desarrollo incluida es **ad hoc local** (`CODE_SIGN_IDENTITY = -`, sin equipo incrustado). Release activa Hardened Runtime. Esto no constituye una firma Developer ID, notarización ni validación de distribución. El identificador editable es `com.maxrufer46.FitTrack`.

## Abrir y verificar en Mac

Desde `app-de-entrenamiento/FitTrack`:

```bash
export DEVELOPER_DIR=/Applications/Xcode_12.4.app/Contents/Developer
open FitTrack.xcodeproj
```

Seleccionar esquema **FitTrack**, destino **My Mac**, Cmd+R para ejecutar y Cmd+U para tests. En Catalina, ejecutar la comprobación con logs:

```bash
bash Scripts/verify-macos.sh
```

El script exige Catalina y Xcode 12.4, comprueba los archivos, compila Debug/Release, ejecuta ambos targets XCTest y conserva el `.xcresult`, los logs, las versiones de herramientas y `coverage.json` en una carpeta nueva bajo `TestResults/`. No instala paquetes ni necesita XcodeGen/SwiftPM.

Para revisar solo la estructura en cualquier equipo con Python 3:

```bash
python3 Scripts/validate_project.py
```

## Comprobaciones ejecutadas en esta entrega

| Comprobación | Resultado y límite |
| --- | --- |
| Proyecto OpenStep | Leído por el validador y por un parser independiente; referencias, rutas y pertenencia a targets comprobadas. No equivale a `xcodebuild -list`. |
| Modelo y plists | XML válido, versión activa existente, 16 entidades, 28 extremos inversos, reglas de borrado y unicidad. Falta compilar el modelo con `momc`. |
| Recursos e idiomas | ES/EN con las mismas 46 claves y referencias de interfaz resueltas. |
| Swift | 22 archivos examinados con parser gramatical y escaneo de APIs prohibidas. No comprueba tipos, enlace ni toda la disponibilidad del SDK. |
| Scripts | Validador ejecutado y sintaxis Bash comprobada. El script nativo rechaza Linux de forma explícita. |
| Pruebas XCTest | 34 métodos preparados; sin ejecutar en este entorno. |
| Git | Revisión de espacios y cambios limitados a `FitTrack/`. |

El parser auxiliar Swift tiene una limitación con el literal válido `()` en `Result.success(())`; se normalizó a `Void()` únicamente en la entrada del parser. No se modificó el código Swift por esa limitación ni se interpreta el resultado como compilación.

## Checklist manual de aceptación pendiente

- [ ] Xcode 12.4 abre el proyecto y muestra sus tres targets y el esquema compartido.
- [ ] Builds Debug y Release sin errores ni warnings con los SDK de Xcode 12.4.
- [ ] En Catalina aparece la ventana, se puede redimensionar y los menús de edición funcionan.
- [ ] Escribir un nombre, Guardar/Cmd+S, salir y reabrir conserva el nombre.
- [ ] Editar y salir con Cmd+Q sin pulsar Guardar conserva el último borrador.
- [ ] Un nombre vacío, demasiado largo o con controles se rechaza sin modificar el perfil guardado.
- [ ] El primer error de apertura simulado permite reintentar y llegar al perfil.
- [ ] Probar la recuperación ante fallo de escritura: reintento/cancelación no pierde el borrador.
- [ ] Cmd+W pasa por el mismo guardado antes de salir.
- [ ] XCTest unitario/integración/UI pasa y se conserva el reporte de cobertura real.
- [ ] Idioma ES/EN y VoiceOver permiten acceder al campo, acciones y estados.
- [ ] El almacén se crea en el contenedor de la app con sandbox activado.

## Riesgos y límites de Catalina

La disponibilidad de cada API y los warnings del SDK se confirmarán con la compilación nativa. Los modificadores de accesibilidad usados son los de SwiftUI 1.0; no se sustituyen por sus versiones modernas. No hay carga de SF Symbols, HealthKit, DocC compilado, concurrencia Swift moderna ni SwiftUI lifecycle.

Los tests UI necesitan una sesión gráfica de Mac y que Xcode tenga la autorización del sistema que requiera la automatización. Las opciones `--ui-testing`, `--ui-test-store-id <UUID>` y `--ui-test-fail-first-open` existen solo en Debug: usan SQLite temporal aislado, y un UUID inválido usa memoria en vez de los datos personales. Los tests unitarios hospedados usan memoria. Release ignora estas opciones.

El objetivo de cobertura ≥60% de modelos/ViewModels pertenece a la aceptación final; en esta entrega todavía no está medido. Catálogos, edición de entrenamientos, temporizadores y estadísticas siguen en las fases indicadas en el plan.
