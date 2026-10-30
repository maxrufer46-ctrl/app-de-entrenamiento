# Plan de calidad y evidencia

## Estado actual

Fase 0: documentación y estructura. No hay código Swift ni proyecto Xcode que compilar. Cobertura: **no medida**. Pruebas unitarias/UI: **todavía no implementadas**. La preparación se realiza en Linux, donde no están disponibles AppKit, SwiftUI macOS ni `xcodebuild`.

La validación de esta fase revisa rutas, enlaces, separación de fases y cambios limitados a `FitTrack/`. Los comandos siguientes son el procedimiento de aceptación futuro, no resultados ya obtenidos.

## Matriz de pruebas

| Nivel | Casos relevantes | Aceptación |
| --- | --- | --- |
| Modelos | Unidades, tipos de carga, rangos, fórmulas, enums y DTO versionados | Casos válidos y límites inválidos; sin pérdida en ida/vuelta. |
| ViewModels | Carga/vacío/error, filtros combinados, validación, selección y cambios persistidos | Doubles deterministas; publicaciones en cola principal y sin guardar entradas inválidas. |
| Sesión/timers | Completar doble, fallo de guardado, pausar/reanudar, +15/+30, salto, suspensión y recuperación | Sin duplicar series/PR; reloj falso, sin esperas reales. |
| Core Data | SQLite temporal, integridad, borrado, reapertura, transacciones y versiones | Datos equivalentes después de cerrar/reabrir; fallo no elimina el almacén. |
| Catálogo | Counts, unicidad, ES/EN, prescripciones por modalidad, referencias y seed repetido | ≥300 ejercicios y ≥50 rutinas, sin duplicación ni contenido requerido vacío. |
| Historial/progreso | Rachas, medianoche/DST, agregados, PR y edición/borrado retroactivo | Resultados iguales a fixtures calculadas de forma independiente. |
| Archivos | JSON/CSV, backup con fotos, conflictos, versión futura, archivo corrupto y cancelación | Comparación semántica tras restaurar; importación fallida deja intacto el estado anterior. |
| UI | Flujo principal, navegación, formularios, teclado y enfoque | XCTest UI en Catalina y comprobación visual nativa. |
| Accesibilidad | VoiceOver, orden de foco, contraste, resize y alternativas de gráficos | Acciones y datos accesibles sin depender del color o del ratón. |
| Compatibilidad | Debug/Release con Xcode 12.4 y runtime real 10.15 | Sin errores ni warnings; no se acepta solo compilar en un Mac moderno. |

## Comandos en Mac, desde fase 1

Desde `app-de-entrenamiento/FitTrack`, con Xcode 12.4 instalado en la ruta indicada:

```bash
export DEVELOPER_DIR=/Applications/Xcode_12.4.app/Contents/Developer
sw_vers
xcodebuild -version
xcrun swift --version
xcodebuild -list -project FitTrack.xcodeproj
xcodebuild -project FitTrack.xcodeproj -scheme FitTrack -configuration Debug -destination 'platform=macOS' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project FitTrack.xcodeproj -scheme FitTrack -configuration Release -destination 'platform=macOS' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project FitTrack.xcodeproj -scheme FitTrack -configuration Debug -destination 'platform=macOS' -derivedDataPath DerivedData -enableCodeCoverage YES -resultBundlePath TestResults/FitTrack.xcresult test
xcrun xccov view --report --json TestResults/FitTrack.xcresult
```

Crear previamente `TestResults/` y usar un nombre nuevo de `.xcresult` en cada ejecución; Xcode no sobrescribe un result bundle existente. Si Xcode tiene otro nombre, ajustar únicamente `DEVELOPER_DIR`. Los build sin firma comprueban compilación; no certifican firma, ejecución bajo sandbox ni notarización.

El esquema compartido incluirá targets de app, unit/integration y UI con cobertura de app. Se archivará el reporte real y se calculará por separado la cobertura de líneas ejecutables de `Models/` y `ViewModels/`: suma de líneas cubiertas / suma de líneas ejecutables en cada grupo. El objetivo ≥60% se exige a ambos grupos, sin inflar la cifra con archivos generados. El parser se verificará contra la salida de `xccov` de Xcode 12.4.

La cobertura no sustituye las pruebas de invariantes ni se rellenará con tests que repliquen implementaciones. Los errores relevantes deberán producir casos de regresión.

## Checklist de entrega final

- [ ] Registrar versiones exactas de macOS, Xcode y Swift, y revisión Git probada.
- [ ] Builds Debug/Release sin errores ni warnings, conservando logs completos.
- [ ] Unit/integration/UI en verde, reporte de cobertura y revisión manual.
- [ ] Reabrir base SQLite y recuperar una sesión interrumpida.
- [ ] Comprobar notificaciones autorizadas/denegadas, sonido y suspensión del Mac.
- [ ] Verificar ES/EN, kg/lb, cm/in, temas y accesibilidad.
- [ ] Revisar ≥300 ejercicios y ≥50 rutinas técnica y estructuralmente.
- [ ] Probar backup/restore con fotos, conflictos y corrupción sin pérdida de datos.
- [ ] Verificar permisos sandbox y firma por separado con identidad del propietario.
- [ ] README de instalación, atajos, uso y limitaciones coherente con la app entregada.
