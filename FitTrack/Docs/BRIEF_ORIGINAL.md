# ROL
Actúa como un equipo senior de desarrollo macOS compuesto por: un Arquitecto de Software Apple, un Ingeniero Senior de Swift/SwiftUI, un Especialista en AppKit, un Diseñador de Producto UX/UI para macOS, un Experto en Ciencias del Deporte y Entrenamiento de Fuerza, y un QA Engineer especializado en compatibilidad de versiones de macOS.

# MISIÓN
Construir desde cero una aplicación de escritorio nativa para macOS llamada "FitTrack" (nombre tentativo, editable), inspirada en SmartGym, que sea un gestor profesional de entrenamientos de fuerza, hipertrofia, cardio, movilidad y calistenia, con seguimiento de progreso, temporizadores, historial, estadísticas y rutinas predefinidas de nivel comercial.

# ENTORNO TÉCNICO OBLIGATORIO (NO NEGOCIABLE)
- Sistema operativo destino: macOS Catalina 10.15.8
- IDE: Xcode 12.4 (última versión que soporta Catalina)
- Lenguaje: Swift 5.3
- Framework UI: SwiftUI 1.0 (versión de Catalina — SIN APIs de Big Sur+, SIN @StateObject, SIN LazyVGrid, SIN .task, SIN AppStorage moderno, SIN NavigationStack, SIN .searchable)
- Framework complementario: AppKit para menús, ventanas, toolbar, atajos de teclado y todo lo que SwiftUI 1.0 no cubra
- Ciclo de vida: AppKit App Delegate + @main (NO SwiftUI App lifecycle)
- Persistencia: Core Data (compatible con Catalina) con NSPersistentContainer
- Gestión de estado: ObservableObject + @Published + @ObservedObject + @State + @Binding + @EnvironmentObject
- Concurrencia: DispatchQueue y Combine (NO async/await, NO Task, NO actors)
- Gráficos: Swift Charts NO existe en Catalina → usar Path/Shape de SwiftUI o integrar la librería "SwiftUICharts" (tercero) o Core Plot
- Testing: XCTest con Unit Tests + UI Tests
- Localización: español (base) + inglés (secundario)
- Arquitectura: MVVM estricto con capas Repository + Service
- Control de versiones: Git con Conventional Commits

# STACK DE LIBRERÍAS PERMITIDAS
- Solo frameworks nativos de Apple o paquetes SwiftPM compatibles con Catalina
- Nada que requiera macOS 11+
- Evitar dependencias pesadas; priorizar código propio

# ALCANCE FUNCIONAL — MÓDULOS COMPLETOS

## 1. MÓDULO DE EJERCICIOS (BIBLIOTECA)
- Base de datos seed con MÍNIMO 300 ejercicios profesionales organizados por:
  - Grupo muscular primario: pecho, espalda, hombros, bíceps, tríceps, antebrazo, core/abdomen, glúteos, cuádriceps, isquiotibiales, gemelos, cuello
  - Grupo muscular secundario
  - Tipo: fuerza, hipertrofia, resistencia, movilidad, cardio, calistenia, pliometría, isométrico
  - Equipamiento: barra, mancuernas, kettlebell, máquina, polea, peso corporal, banda elástica, TRX, balón medicinal, neumático, saco, otros
  - Nivel: principiante, intermedio, avanzado
  - Patrón de movimiento: empuje horizontal/vertical, tracción horizontal/vertical, sentadilla, bisagra de cadera, cargada, transporte, rotación, anti-rotación, anti-extensión, anti-flexión lateral
- Cada ejercicio debe incluir: nombre (ES/EN), descripción técnica paso a paso, músculos trabajados, equipamiento, nivel, video URL opcional, imagen/SF Symbol, tips de ejecución, errores comunes, variantes y progresiones/regresiones
- Búsqueda por texto, filtros múltiples combinables (grupo + equipamiento + nivel + tipo), ordenamiento
- Favoritos y ejercicios personalizados creados por el usuario

## 2. MÓDULO DE RUTINAS
- Crear, editar, duplicar, archivar y eliminar rutinas
- Cada rutina contiene: nombre, descripción, objetivo (fuerza/hipertrofia/pérdida de grasa/resistencia/movilidad/rehabilitación), nivel, duración estimada, días por semana, etiquetas
- Cada rutina tiene N días (Día A, Día B, ...) y cada día tiene ejercicios ordenables con drag & drop
- Cada ejercicio dentro de la rutina define: series, repeticiones (rango), peso objetivo, RPE/RIR, tempo (excéntrica-pausa-concéntrica-pausa), tiempo de descanso entre series, notas
- Soporte para supersets, triseries, drop sets, series al fallo, AMRAP, EMOM, circuitos, pirámides
- Rutinas predefinidas profesionales incluidas de fábrica, agrupadas por categoría:
  - Full Body principiante / intermedio / avanzado
  - Push / Pull / Legs (PPL)
  - Torso / Pierna (Upper/Lower)
  - Weider split (pecho+tríceps, espalda+bíceps, hombro+trapecio, pierna)
  - Fuerza 5x5 (StrongLifts-like)
  - 5/3/1 de Wendler
  - GZCLP
  - PHUL y PHAT
  - Peso corporal / calistenia (principiante a avanzado: pull-ups, dips, pistol squat, muscle-up progresiones)
  - Kettlebell
  - HIIT y cardio
  - Movilidad y estiramientos
  - Rehabilitación (hombro, rodilla, espalda baja)
  - Mujer / glúteo-focus
  - Adulto mayor / bajo impacto
  - Deportes específicos (fútbol, running, natación, ciclismo, artes marciales)
- Importar/exportar rutinas en JSON

## 3. MÓDULO DE SESIÓN DE ENTRENAMIENTO (CORE)
- Iniciar sesión a partir de rutina o entrenamiento libre
- Pantalla principal de sesión con:
  - Ejercicio actual en grande con instrucciones
  - Serie actual (indicador "Serie 2 de 4")
  - Campo de peso (kg/lb, configurable) y reps realizadas
  - Marcar serie completada con un tap
  - Cronómetro de descanso automático entre series con cuenta atrás visible, sonido y notificación local (UserNotifications)
  - Temporizador de descanso ajustable en caliente
  - Botón "Saltar descanso" y "Añadir 15s / 30s"
  - Notas por serie
  - Registro de RPE/RIR percibido
  - Botón de "Siguiente ejercicio" y "Finalizar sesión"
  - Barra de progreso global de la sesión
- Reproducción de audio de referencia opcional
- Integración con Apple Health NO disponible en Catalina para Watch, pero sí para datos básicos vía HealthKit si el usuario lo autoriza
- Detección de récords personales (PR) en tiempo real: al completar una serie, comparar contra histórico y mostrar badge si es PR
- Modo enfoque (oculta distracciones) y modo pantalla completa

## 4. MÓDULO DE HISTORIAL
- Registro completo de todas las sesiones con fecha, duración, rutina, ejercicios, series, peso, reps, RPE, notas
- Vista calendario mensual con indicadores de días entrenados
- Vista lista cronológica con filtros
- Detalle de sesión con todas las series
- Edición de sesiones pasadas
- Exportación a CSV y JSON

## 5. MÓDULO DE ESTADÍSTICAS Y PROGRESO
- Gráficos interactivos (con SwiftUI Path o SwiftUICharts) de:
  - Volumen total por semana/mes/año (kg levantados)
  - Volumen por grupo muscular
  - Frecuencia de entrenamiento
  - Peso corporal a lo largo del tiempo
  - Progresión por ejercicio (peso máximo, 1RM estimado por fórmula de Epley y Brzycki, volumen)
  - Récords personales por ejercicio
- KPIs: racha actual, racha máxima, sesiones totales, tiempo total entrenado, ejercicios distintos realizados
- Predicción de 1RM y comparativa con objetivos
- Gráfico de adherencia a la rutina

## 6. MÓDULO DE MEDIDAS CORPORALES
- Registro de peso, altura, % grasa, medidas (pecho, cintura, cadera, brazos, muslos, gemelos, cuello), fotos opcionales
- Gráficos de evolución
- IMC, TMB (Mifflin-St Jeor y Harris-Benedict), TDEE estimado
- Objetivos: ganancia muscular, pérdida de grasa, mantenimiento, fuerza, rendimiento

## 7. MÓDULO DE TEMPORIZADORES Y HERRAMIENTAS
- Temporizador de descanso independiente
- Cronómetro de sesión
- Temporizador HIIT configurable (trabajo/descanso/rondas)
- Calculadora de 1RM
- Calculadora de discos (qué discos cargar por lado)
- Calculadora de IMC/TMB/TDEE
- Calculadora de macros

## 8. MÓDULO DE AJUSTES
- Unidades: kg/lb, cm/in
- Tema: sistema/claro/oscuro
- Sonidos y notificaciones
- Idioma ES/EN
- Copia de seguridad y restauración (export/import completo)
- Acerca de, licencia, feedback

# REQUISITOS UX/UI PROFESIONALES
- Estilo visual: nativo macOS, limpio, tipo app de productividad Apple (referencia: Things 3, MindNode, Fitness de Apple en su versión macOS)
- Uso intensivo de SF Symbols
- Sidebar con NavigationView en 3 columnas (sidebar + lista + detalle) cuando aplique
- Toolbar con botones primarios, búsqueda y acciones contextuales
- Atajos de teclado completos (Cmd+N nueva rutina, Cmd+S guardar, Cmd+F buscar, Cmd+R iniciar sesión, espacio marcar serie, etc.)
- Soporte de menús del sistema vía AppKit (MenuBar) con comandos
- Accesibilidad: VoiceOver, Dynamic Type (donde aplique), contraste alto, labels semánticos
- Animaciones sutiles y profesionales (no llamativas)
- Drag & drop nativo para reordenar ejercicios y días
- Estados vacíos cuidados, loaders, error states
- Onboarding de primer inicio con configuración de perfil y objetivo
- Modo "enfoque" a pantalla completa para la sesión activa

# ARQUITECTURA Y CÓDIGO
- Estructura del proyecto:
  /App (AppDelegate, main)
  /Models (entidades Core Data + structs)
  /Repositories (acceso a datos)
  /Services (WorkoutSessionService, RestTimerService, PRDetectionService, StatisticsService, ExportService, NotificationService)
  /ViewModels
  /Views (agrupadas por módulo)
  /DesignSystem (colores, tipografía, componentes reutilizables)
  /Resources (JSON seeds de ejercicios y rutinas, assets, localizaciones)
  /Tests (Unit + UI)
- Clean code: nombres descriptivos, funciones cortas, sin force unwraps, manejo de errores con Result/throws
- Documentación con DocC comments
- SwiftLint configurado
- Uso de `// MARK:` para navegación
- Sin dependencias externas innecesarias
- Compilación limpia sin warnings en Xcode 12.4

# CRITERIOS DE ACEPTACIÓN (DEFINITION OF DONE)
1. El proyecto compila sin errores ni warnings en Xcode 12.4 sobre macOS Catalina 10.15.8
2. Se ejecuta como app nativa macOS (.app) firmable y no sandbox-breaking
3. Todos los módulos del alcance están implementados y navegables
4. La base de datos seed contiene al menos 300 ejercicios y 50 rutinas profesionales funcionales
5. El flujo completo "abrir app → elegir rutina → entrenar → registrar series → ver progreso → consultar estadísticas" funciona de punta a punta
6. Los datos persisten tras cerrar y reabrir la app (Core Data)
7. Export/import JSON funcional
8. Notificaciones locales de descanso disparan correctamente
9. Atajos de teclado documentados y funcionando
10. Al menos 60% de cobertura de tests en modelos y ViewModels
11. README.md en español con instrucciones de build, estructura y roadmap
12. Historial de Git limpio con commits convencionales

# FORMATO DE ENTREGA (CÓMO QUIERO LA RESPUESTA)
Entrégame el proyecto por fases, en el siguiente orden y con todo el código completo listo para copiar y pegar en Xcode:

FASE 0 — Plan de arquitectura y estructura de carpetas + decisiones técnicas justificadas
FASE 1 — Configuración del proyecto Xcode + AppDelegate + Core Data stack + esquema de entidades
FASE 2 — Models + Repositories + seeds JSON (con muestra representativa de ejercicios y rutinas)
FASE 3 — Design System + componentes UI reutilizables
FASE 4 — Módulo de Ejercicios completo
FASE 5 — Módulo de Rutinas completo
FASE 6 — Módulo de Sesión de Entrenamiento completo (con timer de descanso y PR detection)
FASE 7 — Módulo de Historial + Calendario
FASE 8 — Módulo de Estadísticas con gráficos
FASE 9 — Módulo de Medidas corporales + calculadoras
FASE 10 — Ajustes + export/import + localización
FASE 11 — Tests + SwiftLint + README + instrucciones de subida a GitHub

Al final de cada fase, indica:
- Qué archivos se crean o modifican
- Comandos de Terminal necesarios (si aplica)
- Cómo verificar que la fase funciona (checklist manual)
- Riesgos o incompatibilidades con Catalina detectadas

# REGLAS ESTRICTAS
- NO uses APIs posteriores a macOS 10.15. Si dudas, elige la versión más antigua compatible o implementa la funcionalidad manualmente.
- NO uses async/await, Task, actors, @StateObject, NavigationStack, .task, .searchable, LazyVGrid, Grid, .refreshable ni nada de Big Sur en adelante.
- NO inventes frameworks inexistentes. Si una librería no existe o no es compatible con Catalina, dilo y propone alternativa.
- Si algo del alcance es técnicamente inviable en Catalina, márcalo explícitamente con la etiqueta [NO VIABLE EN CATALINA] y explica por qué + alternativa.
- Prioriza código compilable sobre pseudocódigo. Cuando no puedas escribir todo, escribe el esqueleto funcional completo del archivo.
- Cada archivo debe ir con su ruta (ej: `FitTrack/Models/Exercise.swift`) y bloque de código Swift completo.

Empieza por la FASE 0 ahora.