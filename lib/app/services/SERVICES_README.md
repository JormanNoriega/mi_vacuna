# 📋 SERVICES - Capa de Acceso a Datos

Esta carpeta contiene los **servicios** que gestionan todas las operaciones CRUD y consultas a la base de datos SQLite local.

## 🏗️ Arquitectura

```
lib/app/
├── data/
│   ├── database_helper.dart      ← Singleton de BD, migraciones, seeder
│   └── vaccine_seeder.dart       ← Pre-carga de 27 vacunas
├── models/
│   ├── patient_model.dart        ← Paciente completo (100+ campos)
│   ├── vaccine.dart              ← Catálogo de vacunas
│   ├── vaccine_config_option.dart← Opciones dinámicas por vacuna
│   └── applied_dose.dart         ← Registro de vacunación aplicada
└── services/                     ← ✨ ESTAMOS AQUÍ
    ├── vaccine_service.dart      ← Consultas sobre vacunas del catálogo
    ├── patient_service.dart      ← CRUD de pacientes
    └── applied_dose_service.dart ← CRUD de dosis aplicadas
```

---

## 📦 Servicios Disponibles

### 1️⃣ **VaccineService** - Catálogo de Vacunas

Gestiona el acceso al catálogo de las **27 vacunas** precargadas por el `VaccineSeeder`.

#### **Características principales:**

- ✅ Consultas de vacunas activas, por categoría, por edad
- ✅ Obtención de opciones dinámicas (dosis, laboratorios, jeringas, etc.)
- ✅ Búsqueda y filtrado avanzado
- ✅ Estadísticas del catálogo

#### **Métodos clave:**

```dart
// Consultas básicas
getAllActiveVaccines()               // Todas las vacunas activas
getVaccinesByCategory(category)      // Por categoría ("PAI", "Especial")
getVaccinesForAge(ageInMonths)       // Vacunas aplicables a edad específica
getVaccineById(id)                   // Por ID
getVaccineByCode(code)               // Por código único

// Opciones de configuración
getDoses(vaccineId)                  // Dosis disponibles (1ª, 2ª, 3ª, Refuerzo, etc.)
getLaboratories(vaccineId)           // Laboratorios disponibles
getSyringes(vaccineId)               // Jeringas disponibles
getObservations(vaccineId)           // Observaciones predefinidas
getDefaultOption(vaccineId, fieldType) // Opción marcada como default

// Búsqueda y filtros
searchByName(searchTerm)             // Búsqueda por nombre
filterVaccines(...)                  // Filtro multi-criterio

// Estadísticas
countActiveVaccines()                // Total de vacunas activas
countByCategory()                    // Conteo por categoría
getAllCategories()                   // Lista de categorías únicas
```

#### **Ejemplo de uso:**

```dart
final vaccineService = VaccineService();

// Obtener vacunas para bebé de 2 meses
final vaccines = await vaccineService.getVaccinesForAge(2);

// Obtener dosis de COVID-19
final covidVaccine = await vaccineService.getVaccineByCode('COVID');
final doses = await vaccineService.getDoses(covidVaccine!.id!);

// Buscar vacunas de Hepatitis
final hepatitisVaccines = await vaccineService.searchByName('Hepatitis');
```

---

### 2️⃣ **PatientService** - Gestión de Pacientes

CRUD completo de pacientes con búsquedas avanzadas y estadísticas.

#### **Características principales:**

- ✅ CRUD completo (Create, Read, Update, Delete)
- ✅ Búsquedas por documento, nombre, enfermera, edad
- ✅ Filtros avanzados (sexo, régimen, etnia, condiciones especiales)
- ✅ Consultas con información de dosis aplicadas
- ✅ Estadísticas demográficas

#### **Métodos clave:**

```dart
// CRUD básico
createPatient(patient)               // Crear nuevo paciente
getPatientById(id)                   // Obtener por ID
getAllPatients({limit, offset})      // Listar todos (con paginación)
updatePatient(patient)               // Actualizar datos
deletePatient(id)                    // Eliminar (⚠️ elimina también sus dosis)

// Búsquedas
getPatientByIdNumber(idNumber)       // Por número de documento
searchPatients(searchTerm)           // Por nombre/apellido/documento
getPatientsByNurse(nurseId)          // Pacientes de una enfermera
getPatientsByDateRange(start, end)   // Por rango de fechas
getPatientsByAgeRange(min, max)      // Por edad en meses

// Filtros avanzados
filterPatients({                     // Multi-criterio
  sex, affiliationRegime, ethnicity,
  displaced, disabled, deceased,
  userCondition, nurseId
})
getPatientsWithCompleteScheme()      // Con esquema completo
getPatientsWithContraindication()    // Con contraindicaciones
getPatientsWithPreviousReactions()   // Con reacciones previas

// Relaciones con dosis
getPatientWithDoses(patientId)       // Paciente + todas sus dosis
getPatientsWithDoseCount({nurseId, limit}) // Pacientes + conteo de dosis

// Estadísticas
countAllPatients()                   // Total de pacientes
countPatientsByNurse(nurseId)        // Por enfermera
countBySex()                         // Distribución por sexo
countByAffiliationRegime()           // Por régimen de afiliación
getLastRegisteredPatient()           // Último registrado

// Validaciones
existsByIdNumber(idNumber)           // Verificar si existe documento
hasDoses(patientId)                  // Verificar si tiene dosis aplicadas
```

#### **Ejemplo de uso:**

```dart
final patientService = PatientService();

// Crear paciente
final newPatient = Patient(
  nurseId: currentNurseId,
  attentionDate: DateTime.now(),
  idType: 'RC',
  idNumber: '1234567890',
  firstName: 'Juan',
  lastName: 'Pérez',
  birthDate: DateTime(2023, 1, 15),
  sex: 'Masculino',
  birthCountry: 'Colombia',
  // ... más campos
);
final patientId = await patientService.createPatient(newPatient);

// Buscar paciente por documento
final patient = await patientService.getPatientByIdNumber('1234567890');

// Obtener paciente con sus dosis
final patientData = await patientService.getPatientWithDoses(patientId);
print('Paciente: ${patientData['patient']}');
print('Dosis aplicadas: ${patientData['doses'].length}');

// Filtrar pacientes desplazados
final displacedPatients = await patientService.filterPatients(displaced: true);
```

---

### 3️⃣ **AppliedDoseService** - Registro de Vacunación

Gestiona el historial de vacunación aplicada con información enriquecida y control offline.

#### **Características principales:**

- ✅ CRUD completo de dosis aplicadas
- ✅ Consultas por paciente, vacuna, enfermera y fechas
- ✅ Información enriquecida con JOIN (paciente + vacuna + enfermera)
- ✅ Control de sincronización offline (uuid + syncStatus)
- ✅ Validación de esquemas completos
- ✅ Estadísticas de vacunación

#### **Métodos clave:**

```dart
// CRUD básico
createDose(dose)                     // Registrar nueva aplicación
getDoseById(id)                      // Por ID
getDoseByUuid(uuid)                  // Por UUID único
getAllDoses({limit, offset})         // Listar todas (con paginación)
updateDose(dose)                     // Actualizar registro
deleteDose(id)                       // Eliminar

// Consultas por relaciones
getDosesByPatient(patientId)         // Todas las dosis de un paciente
getDosesByVaccine(vaccineId)         // Aplicaciones de una vacuna
getDosesByNurse(nurseId)             // Dosis aplicadas por una enfermera
getDosesByDateRange(start, end)      // Por rango de fechas
getDosesByPatientAndVaccine(pId, vId)// Dosis específicas paciente+vacuna

// Información enriquecida (con JOINs)
getDosesWithVaccineInfo({            // Con datos de vacuna, paciente, enfermera
  patientId, nurseId, limit
})
getDoseDetail(doseId)                // Detalle completo de una dosis

// Filtros
filterDoses({                        // Multi-criterio
  patientId, vaccineId, nurseId,
  startDate, endDate, syncStatus
})
getDosesByLotNumber(lotNumber)       // Por número de lote

// Sincronización offline
getDosesNeedingSync()                // Pendientes de sincronizar
markAsSynced(doseId)                 // Marcar como sincronizada
markMultipleAsSynced(doseIds)        // Marcar múltiples
countDosesNeedingSync()              // Contar pendientes

// Estadísticas
countAllDoses()                      // Total de dosis aplicadas
countDosesByNurse(nurseId)           // Por enfermera
countDosesByVaccine()                // Distribución por vacuna
countDosesByDateRange(start, end)    // Por rango de fechas
getLatestDoses(limit)                // Últimas dosis aplicadas

// Validaciones y control
hasCompletedVaccineScheme(pId, vId)  // ¿Completó esquema de vacuna?
countDosesForPatientVaccine(pId, vId)// Contar dosis aplicadas
getLastDoseForPatientVaccine(pId, vId)// Última dosis aplicada
```

#### **Ejemplo de uso:**

```dart
final doseService = AppliedDoseService();

// Registrar dosis aplicada
final dose = AppliedDose(
  patientId: patient.id!,
  nurseId: currentNurse.id!,
  vaccineId: vaccine.id!,
  applicationDate: DateTime.now(),
  selectedDose: '1ª Dosis',
  selectedLaboratory: 'Pfizer',
  lotNumber: 'LOT-2024-001',
  // ... más campos
);
final doseId = await doseService.createDose(dose);

// Obtener historial de vacunación de un paciente
final doses = await doseService.getDosesByPatient(patient.id!);

// Verificar si completó esquema de COVID
final hasCompleted = await doseService.hasCompletedVaccineScheme(
  patient.id!,
  covidVaccine.id!,
);

// Obtener dosis con información completa
final enrichedDoses = await doseService.getDosesWithVaccineInfo(
  patientId: patient.id!,
);
for (var dose in enrichedDoses) {
  print('${dose['vaccine_name']} - ${dose['application_date']}');
  print('Paciente: ${dose['patient_first_name']} ${dose['patient_last_name']}');
}

// Sincronización offline
final pendingDoses = await doseService.getDosesNeedingSync();
// ... enviar a servidor
await doseService.markMultipleAsSynced(pendingDoses.map((d) => d.id!).toList());
```

---

## 🔄 Flujo de Trabajo Típico

### **Registrar nueva vacunación:**

```dart
// 1. Obtener servicios
final vaccineService = VaccineService();
final patientService = PatientService();
final doseService = AppliedDoseService();

// 2. Buscar o crear paciente
Patient? patient = await patientService.getPatientByIdNumber('1234567890');
if (patient == null) {
  patient = Patient(/* datos completos */);
  final patientId = await patientService.createPatient(patient);
  patient = patient.copyWith(id: patientId); // Asignar ID generado
}

// 3. Seleccionar vacuna
final vaccines = await vaccineService.getVaccinesForAge(patient.totalMonths ?? 0);
final selectedVaccine = vaccines.first;

// 4. Obtener opciones de configuración
final doses = await vaccineService.getDoses(selectedVaccine.id!);
final laboratories = await vaccineService.getLaboratories(selectedVaccine.id!);

// 5. Registrar aplicación
final dose = AppliedDose(
  patientId: patient.id!,
  nurseId: currentNurse.id!,
  vaccineId: selectedVaccine.id!,
  applicationDate: DateTime.now(),
  selectedDose: doses.first.value,
  selectedLaboratory: laboratories.first.value,
  lotNumber: 'LOT-XYZ-123',
);
await doseService.createDose(dose);

// 6. Verificar progreso del esquema
final completedScheme = await doseService.hasCompletedVaccineScheme(
  patient.id!,
  selectedVaccine.id!,
);
if (completedScheme) {
  print('✅ Esquema de ${selectedVaccine.name} completado');
}
```

---

## 🗂️ Esquema de Base de Datos (Versión 2)

### **Tablas:**

1. **nurses** - Enfermeras (gestionado por `AuthController`)
2. **vaccines** - Catálogo de 27 vacunas (precargado por `VaccineSeeder`)
3. **vaccine_config_options** - Opciones dinámicas por vacuna (dosis, labs, jeringas)
4. **patients** - Pacientes (100+ campos demográficos y médicos)
5. **applied_doses** - Registro de vacunación aplicada

### **Relaciones:**

```
nurses ──┐
         ├──< patients ──< applied_doses >── vaccines
         │                                         │
         └─────────────────────────────────────────┘
                                                   │
                                     vaccine_config_options
```

### **Índices creados:**

- `idx_config_vaccine`, `idx_config_type`, `idx_config_active`
- `idx_dose_patient`, `idx_dose_vaccine`, `idx_dose_nurse`, `idx_dose_date`, `idx_dose_sync`
- `idx_patient_id_number`, `idx_patient_nurse`, `idx_patient_attention_date`, `idx_patient_name`

---

## ⚠️ Consideraciones Importantes

### **🔒 Integridad referencial:**

- Eliminar un paciente **eliminará en cascada** todas sus dosis (`ON DELETE CASCADE`)
- Eliminar una vacuna eliminará sus opciones de configuración
- Las enfermeras no se pueden eliminar si tienen pacientes asociados

### **📱 Offline-first:**

- Todos los datos se almacenan localmente (SQLite)
- El campo `uuid` en `applied_doses` permite sincronización futura
- El campo `syncStatus` controla el estado de sincronización:
  - `'local'` = pendiente de sincronizar
  - `'synced'` = sincronizado con servidor

### **🔄 Migraciones:**

- La versión actual de la BD es **2**
- `DatabaseHelper` maneja automáticamente la migración desde v1
- Al actualizar de v1 a v2, se crean las nuevas tablas y se ejecuta el seeder

### **📊 Performance:**

- Los índices están optimizados para consultas frecuentes
- Usa paginación (`limit`, `offset`) para listas grandes
- Los métodos con JOINs devuelven `Map<String, dynamic>` en lugar de modelos

---

## 🚀 Próximos Pasos

Con los servicios implementados, ahora puedes:

1. **Actualizar Controllers** para usar los servicios en lugar de acceder directamente a la BD
2. **Crear UI** que consuma estos servicios a través de GetX controllers
3. **Implementar sincronización** con servidor usando los métodos de sync
4. **Agregar validaciones** adicionales a nivel de negocio
5. **Crear reportes** usando los métodos de estadísticas

---

## 📚 Recursos Adicionales

- **Modelos:** Ver `lib/app/models/MODELS_README.md`
- **Database:** Ver `DATABASE_README.md` (raíz del proyecto)
- **Seeder:** Ver `lib/app/data/vaccine_seeder.dart` (1099 líneas)

---

**✨ Arquitectura completada con éxito**
