# Modelo de datos propuesto

Contrato de fase 0. El modelo Core Data v1 se implementa en fase 1 y sus tipos/repositorios en fase 2. Todas las entidades persistidas tendrán `id: UUID`, `createdAt: Date` y `updatedAt: Date`; se documentarán las excepciones de snapshots inmutables.

## Entidades

| Entidad | Atributos principales | Relaciones y borrado |
| --- | --- | --- |
| `ExerciseEntity` | `catalogID?`, nombre ES/EN, técnica ES/EN, músculos primarios/secundarios, equipo, nivel, tipos, patrón, consejos, errores, variantes, progresiones/regresiones, URL opcional, `iconKey`, favorito, personalizado, oculto | Referencias opcionales desde prescripciones e historial; nullify al borrar. El historial conserva un snapshot. |
| `RoutineEntity` | Nombre, descripción, objetivo, nivel, minutos, frecuencia semanal, etiquetas, archivada, plantilla, `catalogID?` | Días: cascade. Las sesiones no dependen de esta relación para mostrar sus datos. |
| `RoutineDayEntity` | Nombre, posición, notas | Rutina obligatoria; ejercicios prescritos: cascade. |
| `RoutineExerciseEntity` | Posición, notas y snapshot mínimo del ejercicio | Día obligatorio, ejercicio opcional; prescripciones de series: cascade. |
| `SetPrescriptionEntity` | Posición, reps mín/máx, carga kg opcional, segundos/metros opcionales, RPE/RIR objetivo, tempo, descanso, tipo de serie y secuencia de drops | Ejercicio de rutina obligatorio; grupo opcional. Una prescripción representa una serie o etapa real. |
| `TrainingGroupEntity` | Tipo: superset, triserie, circuito, AMRAP o EMOM; posición, rondas y límite temporal | Pertenece a un día; prescripciones asociadas, con orden y rol explícitos. Borrar un grupo desagrupa sus miembros. |
| `WorkoutSessionEntity` | Inicio, fin, segundos activos, pausas acumuladas, estado, nombre/objetivo de rutina snapshot, día snapshot, referencia de rutina opcional | Ejercicios ejecutados y pausas: cascade. Una rutina eliminada no elimina sesiones. |
| `SessionExerciseEntity` | Posición, nombre ES/EN snapshot, músculos/equipo/tipo snapshot, `exerciseIDSnapshot`, ejercicio original opcional | Sesión obligatoria; series realizadas: cascade. |
| `WorkoutSetEntity` | `prescriptionIDSnapshot?`, orden, carga kg, reps, segundos, metros, tipo de carga, completada/omitida, fecha, RPE/RIR, notas, tempo y prescripción snapshot | Ejercicio ejecutado obligatorio. Etapas de drop sets se registran como series con un ID de grupo común. |
| `SessionPauseEntity` | Inicio y fin de la pausa | Sesión obligatoria. Una pausa abierta se recupera al relanzar. |
| `ActiveWorkoutStateEntity` | Índices actuales, estado previo, inicio de intervalo, descanso pendiente, vencimiento, snapshot del timer HIIT, instante del último guardado | Referencia a sesión activa; validación de unicidad lógica. Se elimina al terminar/descartar. |
| `PersonalRecordEntity` | Ejercicio identificado de forma estable, métrica, valor, fecha y valor anterior | Serie fuente opcional. Se recalcula al editar o eliminar resultados. |
| `BodyMeasurementEntity` | Fecha, peso kg, altura cm, grasa opcional, perímetros opcionales, notas | Adjuntos fotográficos: cascade, con limpieza coordinada de archivos. |
| `PhotoAttachmentEntity` | Identificador de archivo relativo, tipo de contenido, fecha | Medida propietaria. Sin rutas absolutas ni datos externos enlazados de forma frágil. |
| `ProfileEntity` | Edad/fecha de nacimiento opcional, altura, parámetros fisiológicos opcionales para fórmula, actividad, objetivo, metas y preferencias de privacidad | Perfil local único; no cuenta online. |
| `CatalogMetadataEntity` | Identificador del catálogo, versión de esquema y contenido, fecha de importación | Se actualiza solo si termina correctamente la importación completa. |

Enums de dominio se guardan como códigos de texto estables y no como etiquetas traducidas. Colecciones de texto de catálogo se codifican explícitamente como `Data` JSON UTF-8 y se validan al leer; no se usa `Transformable` con archivado arbitrario. Días, ejercicios y series se ordenan por `position`, con UUID como desempate.

## Integridad

| Regla | Aplicación prevista |
| --- | --- |
| Identificadores únicos | Constraints Core Data para UUID y validación de `catalogID` antes de importar. |
| Una sesión activa | Operaciones serializadas por servicio y validación transaccional al iniciar/recuperar. |
| Series idempotentes | Un ID por serie; repetir «completar» no duplica volumen, PR ni descansos. |
| Rangos | Sin NaN/infinito; reps y tiempos coherentes; rango min ≤ max; RPE 1–10 y RIR ≥ 0 si se proporcionan. |
| Unidad canónica | Kg, cm, segundos y metros en almacenamiento; conversión solo al entrar/salir. No guardar lb como si fueran kg. |
| Peso corporal/asistencia | Tipos de carga diferenciados; no usar kg negativos ambiguos. La asistencia se guarda positiva con su tipo. |
| Mutaciones del historial | Recalcular récords y agregados al editar o borrar una sesión; no conservar PR desactualizados. |
| Catálogo eliminado | Ocultar/archivar los ejercicios con referencias; ofrecer borrado de personalizados conservando snapshots históricos. |
| Errores | `Result`/`throws`; un error de decodificación no convierte datos en valores cero silenciosos. |

## Reglas de estadísticas

Volumen externo = suma de carga externa kg × repeticiones de series completadas compatibles; no sumar segundos, metros ni ejercicios sin carga como si fueran kg. Las dominadas asistidas y el peso corporal mostrarán métricas separadas o una definición explícita, sin mezclar magnitudes.

Se calculan 1RM estimados con Epley y Brzycki solo para series con carga positiva y un rango de repeticiones definido y visible; Brzycki rechaza denominadores no positivos. Son estimaciones, no máximos medidos. Un PR se compara con datos anteriores a la serie actual y no se concede repetidamente por un empate.

La frecuencia y las rachas agrupan por fecha local con `Calendar` y zona horaria explícitos; la racha actual reconoce ayer cuando todavía no se ha entrenado hoy. La adherencia usa sesiones planificadas por semana como denominador, sin contar sesiones canceladas como completadas. No se guardan agregados sin una política de invalidación.

## Semillas y revisión del contenido

Los JSON llevarán `schemaVersion`, `contentVersion`, códigos independientes del idioma e IDs estables. El validador comprobará al menos 300 ejercicios únicos, 50 rutinas completas, referencias existentes, campos ES/EN, secuencias ordenadas y parámetros coherentes por modalidad. Contar variaciones de nombre sin contenido técnico distinto no satisface el catálogo.

Las plantillas se importan como catálogo de solo lectura y se copian al personalizarlas. Una actualización cambia contenido de catálogo, mantiene favoritos por ID y respeta rutinas personalizadas. No se rellenará el número de rutinas con combinaciones aleatorias. Las familias 5×5, 5/3/1, GZCLP, PHUL/PHAT y las demás del brief necesitan reglas de progresión explícitas y revisión del contenido antes de presentarse como programas completos. Las rutinas de rehabilitación requieren revisión profesional específica; se distinguirán de tratamientos personalizados.

## JSON, CSV y backup

El JSON de rutinas incluye su grafo completo y definiciones de ejercicios personalizados referenciados. El JSON de historial incluye snapshots suficientes para abrirlo sin catálogo. Las fechas usan ISO 8601 y las unidades se declaran en el formato, independientemente de la configuración visible.

La importación valida versión, tamaño, tipos, límites y referencias antes de escribir. La vista previa resuelve conflictos de IDs sin sobrescribir silenciosamente. Un backup completo contiene un manifiesto versionado, datos, preferencias y fotos en una carpeta/paquete autocontenido seleccionado con panel AppKit. Restaurar exige validar primero un almacén temporal y mantener el anterior hasta completar el intercambio.

El CSV escapa comillas, separadores y saltos de línea; ofrece formato explícito para hojas de cálculo y trata como texto los campos que podrían interpretarse como fórmulas. Las pruebas de ida/vuelta comprobarán equivalencia de datos y no solo que se genere un archivo.
