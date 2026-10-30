# Plan de implementación por fases

**Estado:** fase 0 entregada; [fase 1](FASE_1.md) implementada en código, con aceptación nativa pendiente en Catalina/Xcode 12.4. Las fases 2–11 siguen pendientes. Cada fase incluye código completo de sus archivos, instrucciones, checklist y riesgos observados. No se declara terminado un módulo porque exista su carpeta.

## Entregables y verificación

Todas las rutas son relativas a `FitTrack/`. `build` y `test` se refieren a los comandos de [QA](QA.md), desde un Mac con Xcode 12.4. El proyecto existe desde la fase 1; sus builds y tests nativos aún deben ejecutarse.

| Fase | Archivos que se crearán o modificarán | Verificación y comandos | Riesgo a resolver |
| --- | --- | --- | --- |
| **0 — Arquitectura** | `README.md`, `.gitignore`, `Docs/*.md`, carpetas reservadas | Revisar enlaces, alcance y decisiones; `git diff --check` | Diferenciar requisito original y alternativa compatible. |
| **1 — Proyecto y persistencia** | `FitTrack.xcodeproj`, `App/*.swift`, `Config/*`, stack y modelo Core Data v1, esquema compartido, targets tests | `xcodebuild -list`, build Debug/Release; abrir/cerrar ventana; guardar, reabrir y simular fallo del almacén | `@main` sin `main.swift`, formato del proyecto, APIs 10.15 y permisos sandbox. |
| **2 — Modelos, repositorios y seeds** | `Models/Domain/*`, entidades y mapeos, `Repositories/*`, `SeedService`, JSON y validador en `Scripts/`, fixtures/tests | Test de CRUD, importación repetida y rollback; ≥300 ejercicios y ≥50 rutinas completas con referencias válidas | Calidad editorial, programación de progresiones, nombres bilingües y migración de seeds sin perder cambios. |
| **3 — Diseño y shell** | `DesignSystem/*`, `Views/Shell/*`, assets e idiomas iniciales, toolbar/menús básicos | Build y prueba visual en Catalina: paneles, resize, temas, teclado, VoiceOver y alto contraste | SF Symbols dinámicos no disponibles; iconos propios, tamaños de ventana y tres columnas. |
| **4 — Ejercicios** | ViewModel, vistas de biblioteca/detalle/editor y pruebas | Búsqueda acento-insensible; combinar músculo/equipo/nivel/tipo; ordenar; crear/editar/favorito; reabrir app | Debounce, validación y borrado con referencias. |
| **5 — Rutinas** | ViewModel, editor y repositorio de rutina; formato JSON; pruebas | Crear/editar/duplicar/archivar/borrar; ordenar días y ejercicios; round-trip JSON | Supersets, triseries, drop sets, fallo, AMRAP, EMOM, circuitos y pirámides necesitan datos y comportamiento verificables. |
| **6 — Sesión** | `WorkoutSessionService`, timers, PR/notificaciones, vistas/ViewModel y tests | Rutina o sesión libre → series → descanso → terminar; recuperar tras cerrar; ajustar +15/+30, saltar, pausa, enfoque/full screen | Doble clic, pérdida de datos, sonido condicionado por permisos y suspensión del Mac. |
| **7 — Historial** | Lista, calendario mensual, detalle/editor, filtros y exportación de sesiones | Consultar fechas, editar series, borrar y exportar CSV/JSON; comparar con registro original | Zonas horarias, cambios de día y recalcular PR/agregados tras editar. |
| **8 — Estadísticas** | `StatisticsService`, ViewModel, gráficos y tablas accesibles | Contrastar con fixtures: volumen temporal/muscular, frecuencia, rachas, tiempo, ejercicios distintos, adherencia, 1RM y objetivos | Separar magnitudes, evitar PR por empate y no falsear rachas o denominadores. |
| **9 — Medidas y herramientas** | `MeasurementService`, medidas/fotos, calculadoras, HIIT y cronómetro independiente | CRUD y evolución; unidades; Epley/Brzycki; discos por lado; IMC, Mifflin/Harris-Benedict, TDEE/macros | Entradas imposibles, redondeo, inventario limitado de discos y estimaciones correctamente identificadas. |
| **10 — Ajustes e intercambio** | Preferencias, onboarding/perfil, temas, ES/EN completo, backup/restore, Acerca de/feedback, comandos | Cambiar unidades/tema/idioma; denegar notificaciones; backup con fotos → restaurar → comparar; fichero corrupto no daña datos | Cambiar idioma sin APIs modernas, paneles sandbox y restauración transaccional. |
| **11 — QA y entrega** | Tests finales, `.swiftlint.yml`, scripts, README de build/uso, guía de GitHub y registro de validación | Unit/integration/UI, cobertura ≥60% en modelos/ViewModels, lint, Debug/Release sin warnings, smoke test Catalina | No declarar compatibilidad, firma ni cobertura sin resultados reales de las herramientas. |

Los tests de lógica se incorporan junto con cada funcionalidad; la fase 11 completa la auditoría, no posterga toda la verificación hasta el final. SwiftLint será herramienta de desarrollo opcional hasta fijar y probar una versión compatible con Catalina; nunca se instalará automáticamente su versión más reciente.

## Catálogo previsto

La fase 2 entregará la totalidad de los seeds, no únicamente una muestra. La revisión de contenido y las pruebas deben cubrir:

| Catálogo | Cobertura mínima |
| --- | --- |
| Ejercicios | 300 únicos con técnica ES/EN, músculos primarios/secundarios, equipo, nivel, modalidad, patrón, consejos, errores, variantes y progresiones/regresiones. URL de vídeo opcional y `iconKey` compatible. |
| Grupos | Pecho, espalda, hombros, bíceps, tríceps, antebrazo, core, glúteos, cuádriceps, isquiotibiales, gemelos y cuello. |
| Modalidades | Fuerza, hipertrofia, resistencia, movilidad, cardio, calistenia, pliometría e isométricos; prescripción por reps, tiempo o distancia cuando proceda. |
| Equipo/patrón | Cobertura de los equipos y patrones enumerados en el brief; filtros combinables sobre códigos estables. |
| Rutinas | 50 completas: Full Body por nivel, PPL, Torso/Pierna, Weider, 5×5, 5/3/1, GZCLP, PHUL/PHAT, calistenia, kettlebell, HIIT/cardio, movilidad, glúteos, bajo impacto y deportes específicos. |
| Adaptaciones | Plantillas de movilidad/rehabilitación de hombro, rodilla y espalda con revisión profesional antes de etiquetarlas como tales. No prometer adaptación clínica automática. |

Cada rutina tendrá días, orden, series, objetivos, descanso y reglas de progresión explícitas cuando correspondan. Se conservará la distinción entre programas inspirados en una familia y reproducciones exactas de métodos con nombre propio.

## Cierre por fase

Cada entrega registrará: archivos completos creados/modificados, comandos realmente ejecutados, resultado de los checks, checklist manual y riesgos abiertos. Los Conventional Commits describirán el cambio concreto, por ejemplo `feat: add Core Data persistence stack`, sin reescribir el historial previo.

El flujo de aceptación final será: abrir → onboarding → elegir rutina → iniciar sesión → registrar series y descansos → finalizar → consultar historial y estadísticas → cerrar y reabrir → exportar/restaurar. Debe conservar datos y referencias en cada paso.
