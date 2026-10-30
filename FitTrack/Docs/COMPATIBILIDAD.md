# Compatibilidad con Catalina

## Matriz objetivo

| Elemento | Decisión |
| --- | --- |
| Deployment target | `MACOSX_DEPLOYMENT_TARGET = 10.15` |
| Máquina de validación | Mac Intel con Catalina; registrar versión/build mediante `sw_vers` |
| Referencia inicial de Catalina | 10.15.7, versión documentada por Apple; el brief indica 10.15.8 y se conserva sin alterar |
| IDE | Xcode 12.4; Apple indica macOS 10.15.4 o posterior para ejecutarlo |
| SDK incluido | macOS 11.1; el uso de APIs queda limitado al deployment target |
| Swift | Sintaxis Swift 5.3; en Xcode `SWIFT_VERSION = 5.0` selecciona modo de lenguaje Swift 5, no la versión binaria del compilador |
| Arquitectura mínima | Intel `x86_64`, coherente con Catalina; soporte Apple silicon posterior no es criterio de esta fase |
| Dependencias runtime | AppKit, SwiftUI, Foundation, Combine, CoreData, UserNotifications y audio nativo |

La publicación en tiendas o notarización se comprobará por separado contra los requisitos vigentes al distribuir. La aceptación local de Catalina no implica que un binario construido con Xcode 12.4 sea admitido actualmente por App Store Connect.

## Restricciones y sustituciones

| Requisito o API | Estado en la base elegida | Alternativa prevista |
| --- | --- | --- |
| HealthKit/Apple Health | **[NO VIABLE EN CATALINA]** No hay lectura/escritura local de datos de salud para esta app macOS. | Registro manual y archivos; acompañante iOS fuera de alcance. |
| `Image(systemName:)` y `NSImage(systemSymbolName:accessibilityDescription:)` | **[NO VIABLE EN CATALINA]** Sus metadatos de disponibilidad macOS indican 11.0. | PDF vectoriales propios, assets por nombre e imágenes AppKit disponibles en 10.15. |
| DocC compilado | **[NO VIABLE CON XCODE 12.4]** La generación integrada aparece en Xcode 13. | Comentarios `///`, Markdown y Quick Help. |
| SwiftUI `App`, `@StateObject`, `@AppStorage`, `LazyVGrid`, `ProgressView`, `Label`, `.toolbar` | Fuera del baseline Catalina de este proyecto. | AppDelegate, propietarios estables, preferencias por servicio, stacks/listas, indicador propio e `NSToolbar`. |
| `NavigationStack`, `.searchable`, `.task`, `.refreshable`, `Grid`, `Table`, Swift Charts | Fuera del baseline. | Selección explícita, `NSSearchField`, callbacks Combine/Dispatch, listas AppKit y `Path`/`Shape`. |
| `async/await`, `Task`, actors, macros modernos | Fuera de Swift 5.3 y de las reglas del proyecto. | Callbacks, Combine y `DispatchQueue`. |
| `.onChange`, `.fileImporter`, `.fileExporter`, `.keyboardShortcut`, UTType moderno | No se usarán como atajos de implementación. | Suscripciones Combine, paneles AppKit, `NSMenuItem` y tipos de archivo compatibles con 10.15. |
| Tres columnas | Comprobar comportamiento de `NavigationView` en Catalina. | `NSSplitViewController` con vistas SwiftUI alojadas. |
| Drag & drop | Comprobar APIs concretas antes de incorporarlas. | Tabla/lista AppKit con pasteboard, más acciones de subir/bajar. |
| Dynamic Type | No asumir el sistema de tamaños de iOS en escritorio. | Fuentes semánticas del sistema, diseño redimensionable y escala de texto comprobable. |
| Notificaciones | UserNotifications disponible; autorización y entrega dependen del sistema. | Solicitud contextual, temporizador visible y recuperación al reactivar; sin prometer sonido mientras el Mac duerme. |

Las APIs prohibidas se evitarán también dentro de `if #available`: el código entregado seguirá el baseline elegido. Cada propiedad y modificador de SwiftUI requiere revisión individual; que el tipo principal exista en 10.15 no asegura que todos sus miembros existan.

## Persistencia, permisos y apariencia

App Sandbox activado. Core Data, fotos copiadas y preferencias permanecen en el contenedor. Importación/exportación mediante paneles y el entitlement de archivos seleccionados por el usuario. No se solicita acceso completo al disco ni HealthKit. Los vídeos externos se abren con `NSWorkspace`; reproducción remota integrada exigiría revisar su acceso de red en su fase.

Los temas se aplicarán con `NSAppearance` en ventanas/controladores y colores semánticos. Las opciones claro/oscuro/sistema se probarán en Catalina con contraste aumentado. Cambiar idioma reconstruirá la presentación desde un proveedor de localización, sin recurrir a intercambio dinámico de métodos de `Bundle` ni APIs modernas.

## Fuentes oficiales consultadas

- [Notas de Xcode 12.4](https://developer.apple.com/documentation/xcode-release-notes/xcode-12_4-release-notes): requisito del host y SDKs incluidos.
- [Descarga de Catalina 10.15.7](https://support.apple.com/en-sg/106386): versión de referencia del sistema.
- [Disponibilidad de datos HealthKit](https://developer.apple.com/documentation/healthkit/hkhealthstore/ishealthdataavailable()): restricciones en macOS.
- [SwiftUI Image.init(systemName:)](https://developer.apple.com/documentation/swiftui/image/init(systemname:)): disponibilidad del inicializador por plataforma.
- [Metadatos oficiales del inicializador SwiftUI](https://developer.apple.com/tutorials/data/documentation/swiftui/image/init(systemname:).json): `macOS`, `introducedAt: 11.0`.
- [NSImage.init(systemSymbolName:accessibilityDescription:)](https://developer.apple.com/documentation/appkit/nsimage/init(systemsymbolname:accessibilitydescription:)): carga de símbolos en AppKit.
- [Metadatos oficiales del inicializador AppKit](https://developer.apple.com/tutorials/data/documentation/appkit/nsimage/init(systemsymbolname:accessibilitydescription:).json): `macOS`, `introducedAt: 11.0`.
- [Ejemplo oficial de DocC](https://developer.apple.com/documentation/xcode/slothcreator-building-docc-documentation-in-xcode): requiere Xcode 13 para generar la documentación del ejemplo.
- [NSSplitViewController](https://developer.apple.com/documentation/appkit/nssplitviewcontroller): integración de paneles nativos.

Fecha de consulta: 29 de octubre de 2026. La fuente definitiva para cada API será su disponibilidad en el SDK de Xcode 12.4 y la ejecución en Catalina; consultar documentación no sustituye compilar.
