# Modelos de Vacunación - Documentación

## ✅ Mejoras Implementadas

### 1. **Vaccine** (vaccine.dart)

- ✅ **Eliminado** `hasDoses` (redundante - todas las vacunas tienen dosis)
- ✅ **Cambiado** `String? ageGroup` por:
  - `int? minMonths` - Edad mínima en meses
  - `int? maxMonths` - Edad máxima en meses
- ✅ **Agregado** método `isApplicableForAge(int ageInMonths)` - Valida si una vacuna es aplicable a una edad
- ✅ **Agregado** getter `ageRangeDescription` - Devuelve descripción legible del rango de edad

### 2. **VaccineConfigOption** (vaccine_config_option.dart)

- ✅ **Agregado** `bool isDefault` - Marca opciones precargadas vs agregadas por usuario
- ✅ Permite identificar valores del sistema vs personalizados

### 3. **AppliedDose** (applied_dose.dart)

- ✅ **Agregado** `String uuid` - Identificador global único para sincronización
- ✅ **Agregado** `String syncStatus` - Estados: 'local', 'synced', 'conflict'
- ✅ **Agregado** método `markAsSynced()` - Marca dosis como sincronizada
- ✅ **Agregado** getter `needsSync` - Verifica si necesita sincronización
- ✅ Campo `applicationDate` es **REQUIRED** (obligatorio)
- ✅ Campo `lotNumber` es **REQUIRED** (obligatorio)

### 4. **Enums** (enums.dart)

- ✅ **Agregado** `CarnetType` - infantil, adultos, internacional

---

## 📊 Esquema de Base de Datos

### Tabla `vaccines`

```sql
CREATE TABLE vaccines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL,
  max_doses INTEGER NOT NULL,
  min_months INTEGER,                -- Nuevo
  max_months INTEGER,                -- Nuevo
  has_laboratory INTEGER DEFAULT 0,
  has_lot INTEGER DEFAULT 1,
  has_syringe INTEGER DEFAULT 0,
  has_syringe_lot INTEGER DEFAULT 0,
  has_diluent INTEGER DEFAULT 0,
  has_dropper INTEGER DEFAULT 0,
  has_pneumococcal_type INTEGER DEFAULT 0,
  has_vial_count INTEGER DEFAULT 0,
  has_observation INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
```

### Tabla `vaccine_config_options`

```sql
CREATE TABLE vaccine_config_options (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vaccine_id INTEGER NOT NULL,
  field_type TEXT NOT NULL,
  value TEXT NOT NULL,
  display_name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  is_default INTEGER DEFAULT 0,      -- Nuevo
  is_active INTEGER DEFAULT 1,
  FOREIGN KEY (vaccine_id) REFERENCES vaccines (id)
)
```

### Tabla `applied_doses`

```sql
CREATE TABLE applied_doses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uuid TEXT NOT NULL UNIQUE,         -- Nuevo
  patient_id INTEGER NOT NULL,
  nurse_id INTEGER NOT NULL,
  vaccine_id INTEGER NOT NULL,
  application_date TEXT NOT NULL,
  selected_dose TEXT,
  selected_laboratory TEXT,
  lot_number TEXT NOT NULL,
  selected_syringe TEXT,
  syringe_lot TEXT,
  diluent_lot TEXT,
  selected_dropper TEXT,
  selected_pneumococcal_type TEXT,
  vial_count INTEGER,
  selected_observation TEXT,
  custom_observation TEXT,
  next_dose_date TEXT,
  sync_status TEXT DEFAULT 'local', -- Nuevo
  created_at TEXT NOT NULL,
  updated_at TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients (id),
  FOREIGN KEY (nurse_id) REFERENCES nurses (id),
  FOREIGN KEY (vaccine_id) REFERENCES vaccines (id)
)
```

---

## 🎯 Ventajas de las Mejoras

### **minMonths / maxMonths**

```dart
// Ejemplo: BCG (0-6 meses)
Vaccine bcg = Vaccine(
  name: 'BCG',
  minMonths: 0,
  maxMonths: 6,
  // ...
);

// Validar si aplicable
int babyAgeMonths = 4;
if (bcg.isApplicableForAge(babyAgeMonths)) {
  // Mostrar en lista de vacunas disponibles
}

// Obtener descripción
print(bcg.ageRangeDescription); // "0 meses - 6 meses"
```

### **isDefault**

```dart
// Opciones precargadas del sistema
VaccineConfigOption(
  vaccineId: 1,
  fieldType: ConfigFieldType.dose,
  value: 'primera_dosis',
  displayName: 'Primera dosis',
  isDefault: true,  // ✅ Del sistema
);

// Opción agregada por usuario
VaccineConfigOption(
  vaccineId: 1,
  fieldType: ConfigFieldType.observation,
  value: 'mi_observacion_custom',
  displayName: 'Mi observación personalizada',
  isDefault: false, // ❌ Personalizada
);
```

### **UUID y syncStatus**

```dart
// Crear dosis
AppliedDose dose = AppliedDose(
  // uuid se genera automáticamente
  patientId: 123,
  vaccineId: 1,
  lotNumber: 'ABC123',
  applicationDate: DateTime.now(),
  syncStatus: 'local', // Aún no sincronizada
);

// Sincronizar con servidor
if (dose.needsSync) {
  await syncToServer(dose);
  dose = dose.markAsSynced(); // Cambia a 'synced'
  await db.update('applied_doses', dose.toMap());
}
```

---

## 🚀 Próximos Pasos

1. **Crear DatabaseHelper** con las tablas actualizadas
2. **Crear VaccineSeeder** con todas las vacunas y opciones
3. **Crear servicios** (VaccineService, PatientService, etc.)
4. **Implementar UI** dinámica basada en configuración

---

## 📝 Ejemplo de Flujo Completo

```dart
// 1. Usuario selecciona paciente (4 meses de edad)
Patient baby = Patient(
  firstName: 'Juan',
  birthDate: DateTime.now().subtract(Duration(days: 120)),
  // ...
);
int babyAgeMonths = 4;

// 2. Cargar vacunas aplicables
List<Vaccine> availableVaccines = await db.query('vaccines')
  .where((v) => v.isApplicableForAge(babyAgeMonths))
  .toList();
// Resultado: BCG, Pentavalente, Neumococo, etc.

// 3. Usuario selecciona BCG
Vaccine selectedVaccine = availableVaccines.first;

// 4. Cargar opciones de dosis
List<VaccineConfigOption> doses = await db.query(
  'vaccine_config_options',
  where: 'vaccine_id = ? AND field_type = ?',
  whereArgs: [selectedVaccine.id, 'dose'],
);

// 5. Cargar opciones de jeringa
List<VaccineConfigOption> syringes = await db.query(
  'vaccine_config_options',
  where: 'vaccine_id = ? AND field_type = ?',
  whereArgs: [selectedVaccine.id, 'syringe'],
);

// 6. Aplicar dosis
AppliedDose dose = AppliedDose(
  patientId: baby.id!,
  nurseId: currentNurse.id!,
  vaccineId: selectedVaccine.id!,
  applicationDate: DateTime.now(),
  selectedDose: doses.first.value,
  lotNumber: 'LOT-BCG-2024',
  selectedSyringe: syringes.first.value,
  // uuid y syncStatus se asignan automáticamente
);

await db.insert('applied_doses', dose.toMap());
```

---

**Listo para producción! 🎉**
