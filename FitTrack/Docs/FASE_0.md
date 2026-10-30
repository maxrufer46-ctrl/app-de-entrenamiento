# Fase 0 — Arquitectura y base del repositorio

## Alcance entregado

Se establece la arquitectura de FitTrack y se crean sus carpetas dentro de `FitTrack/`. Esta fase es documental y estructural. Los 300 ejercicios, las 50 rutinas, la interfaz y el proyecto Xcode son criterios de fases posteriores, no resultados de esta entrega.

La raíz existente del repositorio conserva su `README.md`, `LICENSE` y `.gitignore`. No hay un repositorio Git anidado ni un proyecto web.

## Decisiones técnicas

| Área | Decisión | Motivo |
| --- | --- | --- |
| Compatibilidad | Deployment target `10.15`, Xcode 12.4 y código Swift 5.3 | Compilar con un SDK más nuevo no autoriza usar APIs posteriores al runtime mínimo. |
| Arranque | `FitTrackApplication.swift` con `@main`, `static main()` y un `AppDelegate` separado | Cumple el lifecycle AppKit y evita tanto SwiftUI `App` como el conflicto entre `@main` y un archivo `main.swift`. |
| Propiedad del estado | Un `AppContainer` retenido por `AppDelegate` crea servicios y ViewModels | `@ObservedObject` observa objetos estables; no se depende de `@StateObject`. |
| Presentación | SwiftUI para contenido; AppKit para ventana, toolbar, búsqueda, menús y paneles de archivos | Mantiene comportamiento de escritorio usando APIs disponibles en Catalina. |
| Navegación | Sidebar y selección explícita; `NavigationView` para maestro/detalle y adaptación AppKit para tres paneles | No se presupone que una API moderna de navegación o tres columnas funcione igual en SwiftUI 1.0. |
| Persistencia | Modelo Core Data versionado, un `NSPersistentContainer`, repositorios concretos ocultos tras protocolos | Separa almacenamiento y presentación, y permite sustitutos para pruebas. |
| Tipos | Structs de dominio y DTO `Codable`; entidades Core Data solo en la capa de persistencia | Evita propagar objetos administrados entre colas o convertirlos directamente en JSON. |
| Concurrencia | `context.perform`, colas privadas y Combine; publicaciones UI en la cola principal | Respeta el confinamiento de Core Data y el compilador requerido. |
| Temporizadores | Fecha de finalización persistida, reloj monotónico inyectable durante ejecución y notificación local programada | El contador no deriva de restar uno en cada tick ni depende de que una ventana siga abierta. |
| Gráficos | `Shape`/`Path`, selección con gesto y alternativa accesible en tabla | Evita Swift Charts y dependencias externas. |
| Preferencias | `SettingsService` sobre `UserDefaults`, inyectado y observable | Sustituye `@AppStorage` y facilita pruebas. |
| Catálogo | JSON versionado con IDs estables, importación idempotente y revisión editorial | Evita duplicar seeds o sobrescribir modificaciones del usuario. |
| Transporte de datos | JSON versionado y CSV; archivos mediante `NSOpenPanel`/`NSSavePanel` | Permite importar, exportar y respaldar sin acceso indiscriminado al disco. |
| Testing | XCTest unitario, integración Core Data y UI; reloj, repositorios y notificaciones sustituibles | Hace comprobables recuperación, transiciones y errores sin esperas reales. |

El diseño detallado está en [Arquitectura](ARQUITECTURA.md) y [Modelo de datos](MODELO_DATOS.md).

## Correcciones al brief

- **[NO VIABLE EN CATALINA] HealthKit local:** no se enlazará este framework. Se usarán medidas manuales y archivos JSON/CSV; una app acompañante de iOS sería un proyecto posterior separado.
- **[NO VIABLE EN CATALINA] Carga dinámica de SF Symbols:** `Image(systemName:)` y `NSImage(systemSymbolName:accessibilityDescription:)` requieren macOS 11. Se usarán recursos PDF vectoriales propios y las imágenes AppKit disponibles en Catalina.
- **[NO VIABLE CON XCODE 12.4] Generación DocC:** se mantendrán comentarios `///`, documentación Markdown y Quick Help. La generación DocC requiere herramientas posteriores.
- **Versión de referencia:** el brief indica 10.15.8; la matriz de prueba se define sobre Catalina 10.15.7 documentado por Apple y deployment target 10.15. Registrar `sw_vers` al validar.

Fuentes y consecuencias completas: [Compatibilidad](COMPATIBILIDAD.md).

## Archivos creados

| Ruta dentro de `FitTrack/` | Contenido |
| --- | --- |
| `README.md` | Entrada del proyecto, estado real y siguiente fase |
| `.gitignore` | Resultados de build, bases locales y configuración privada |
| `Docs/FASE_0.md` | Decisiones y cierre verificable de la fase |
| `Docs/ARQUITECTURA.md` | Capas, inyección, flujos y recuperación |
| `Docs/ESTRUCTURA.md` | Carpetas creadas y archivos que se crearán después |
| `Docs/MODELO_DATOS.md` | Entidades propuestas, relaciones y reglas de integridad |
| `Docs/COMPATIBILIDAD.md` | Restricciones, alternativas y enlaces oficiales |
| `Docs/PLAN_DE_FASES.md` | Entregables, comandos, verificación y riesgos por fase |
| `Docs/QA.md` | Matriz de pruebas y condiciones para afirmar compatibilidad |
| `Docs/BRIEF_ORIGINAL.md` | Requisitos originales, sin alterar |
| Carpetas con `.gitkeep` | Estructura reservada para implementación y tests |

## Comandos de revisión

Desde la raíz del checkout:

```bash
git status --short
git diff --check
git ls-files FitTrack
```

Después de incorporar los archivos al índice, `git diff --cached --stat` permite revisar lo que entrará en el commit. Mensaje de esta fase: `docs: define FitTrack phase 0 architecture`.

No se necesita instalar dependencias ni ejecutar Xcode para revisar esta fase. No se publican resultados de compilación, UI ni cobertura antes de ejecutar las herramientas correspondientes.

## Checklist manual

- [ ] Todas las incorporaciones están dentro de `FitTrack/`.
- [ ] Los enlaces relativos de la documentación abren los archivos indicados.
- [ ] La estructura diferencia carpetas reservadas y funcionalidades implementadas.
- [ ] Las decisiones usan AppKit, SwiftUI de Catalina, Core Data y Swift 5.3.
- [ ] Las incompatibilidades del brief están identificadas con su alternativa.
- [ ] Cada fase posterior tiene entregable, verificación y riesgo documentados.
- [ ] `git diff --check` no informa errores de espacios.

La fase 1 empezará por un proyecto realmente compilable. Su aceptación necesitará Xcode 12.4 en macOS; el entorno actual de preparación no incluye esas herramientas.
