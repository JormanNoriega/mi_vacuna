# Mi Vacuna - Estructura de Base de Datos

## 📋 Resumen

Este proyecto utiliza una arquitectura simplificada con **solo 2 tablas principales**:

1. **nurses** - Enfermeras/personal de salud
2. **vaccination_records** - Registros completos de vacunación

## 🗄️ Estructura de Tablas

### Tabla 1: nurses (Enfermeras)

Almacena la información del personal de salud autorizado para registrar vacunaciones.

**Campos:**

- `id` - ID único (autoincremental)
- `idType` - Tipo de identificación (CC, TI, etc.)
- `idNumber` - Número de identificación (único)
- `firstName` - Primer nombre
- `lastName` - Apellido
- `email` - Correo electrónico (único)
- `phone` - Teléfono
- `institution` - Institución de salud
- `password` - Contraseña (hasheada)
- `createdAt` - Fecha de creación

### Tabla 2: vaccination_records (Registros de Vacunación)

Almacena **TODA** la información del paciente y sus vacunas en un solo registro.

**Secciones de campos:**

#### 📝 Datos Básicos

- Consecutivo, fecha de atención
- Identificación del paciente
- Nombres y apellidos
- Fecha de nacimiento, edad (años, meses, días)
- Sexo, género, orientación sexual

#### 🏥 Datos Complementarios

- País de nacimiento y residencia
- Dirección completa y contacto
- Régimen de afiliación, aseguradora
- Condiciones especiales (desplazado, discapacitado, etc.)

#### 🩺 Antecedentes Médicos

- Contraindicaciones para vacunación
- Reacciones previas a biológicos

#### 🤰 Condición Usuaria

- Estado de gestación
- Fecha de última menstruación
- Embarazos previos

#### 📚 Histórico de Antecedentes

- Registros previos
- Tipo y descripción de antecedentes

#### 👩 Datos de la Madre

- Identificación completa
- Datos de contacto
- Información de afiliación

#### 👤 Datos del Cuidador

- Identificación completa
- Parentesco
- Datos de contacto

#### 💉 Esquema de Vacunación Completo

Todas las vacunas con sus respectivos campos:

- **COVID-19**: Dosis, laboratorio, lote, jeringa, diluyente
- **BCG**: Dosis, lote, jeringa, observaciones
- **Hepatitis B**: Dosis, lote, jeringa
- **Polio** (oral e inyectable): Dosis, lote, dispositivo
- **Pentavalente**: Dosis, lote, jeringa
- **Hexavalente**: Dosis, lote, jeringa
- **DPT/DTPa/TD**: Versiones pediátrica y adulta
- **Rotavirus**: Dosis, lote (oral)
- **Neumococo**: Tipo, dosis, lote, jeringa
- **Triple Viral (SRP)**: Dosis, lote, jeringa, diluyente
- **Sarampión-Rubéola**: Dosis, lote, jeringa
- **Fiebre Amarilla**: Dosis, lote, jeringa, diluyente
- **Hepatitis A Pediátrica**: Dosis, lote, jeringa
- **Varicela**: Dosis, lote, jeringa, diluyente
- **Toxoides**: TD adulto, dTpa adulto
- **Influenza**: Dosis, lote, jeringa
- **VPH**: Dosis, lote, jeringa
- **Antirrábica**: Vacuna y suero
- **Inmunoglobulinas**: Hepatitis B, antitetánica
- **Meningococo**: Dosis, lote, jeringa, diluyente

#### 🔧 Metadatos

- `createdAt` - Fecha de creación
- `updatedAt` - Fecha de última actualización
- `nurseId` - ID de la enfermera que registró (FK a nurses)

## 📦 Modelos

### NurseModel

Ubicación: `lib/app/models/nurse_model.dart`

```dart
NurseModel(
  idType: 'CC',
  idNumber: '123456789',
  firstName: 'María',
  lastName: 'García',
  email: 'maria@hospital.com',
  phone: '3001234567',
  institution: 'Hospital Central',
  password: 'hashedPassword',
)
```

### VaccinationRecordModel

Ubicación: `lib/app/models/vaccination_record_model.dart`

Modelo extenso con todos los campos mencionados arriba.

## 🔧 Servicios

### NurseService

Ubicación: `lib/app/services/nurse_service.dart`

**Métodos:**

- `createNurse()` - Crear enfermera
- `getNurseByEmail()` - Buscar por email
- `getNurseByIdNumber()` - Buscar por número de ID
- `getAllNurses()` - Listar todas
- `updateNurse()` - Actualizar
- `deleteNurse()` - Eliminar
- `emailExists()` - Verificar email
- `idNumberExists()` - Verificar ID

### VaccinationRecordService

Ubicación: `lib/app/services/vaccination_record_service.dart`

**Métodos:**

- `createRecord()` - Crear registro
- `getRecordById()` - Buscar por ID
- `getRecordsByIdNumber()` - Buscar por ID de paciente
- `getAllRecords()` - Listar todos
- `getRecordsByNurse()` - Registros por enfermera
- `getRecordsByDate()` - Registros por fecha
- `getRecordsByDateRange()` - Registros por rango
- `searchByName()` - Buscar por nombre
- `updateRecord()` - Actualizar
- `deleteRecord()` - Eliminar
- `getTotalRecordsCount()` - Contar registros
- `getVaccineStatistics()` - Estadísticas por vacuna
- `hasRecords()` - Verificar si existe

## 🚀 Uso

### Importar servicios y modelos:

```dart
import 'package:mi_vacuna/app/models/models.dart';
import 'package:mi_vacuna/app/services/services.dart';
```

### Crear un registro de vacunación:

```dart
final recordService = VaccinationRecordService();

final record = VaccinationRecordModel(
  tipoIdentificacion: 'TI',
  numeroIdentificacion: '987654321',
  primerNombre: 'Juan',
  primerApellido: 'Pérez',
  fechaNacimiento: DateTime(2020, 5, 15),
  sexo: 'M',
  paisNacimiento: 'Colombia',
  fechaAtencion: DateTime.now(),

  // Datos de vacunas
  bcgDosis: '1',
  bcgLote: 'BCG-2024-001',
  bcgJeringa: 'JER-001',

  // ID de la enfermera que registra
  nurseId: 1,
);

await recordService.createRecord(record);
```

### Buscar registros:

```dart
// Por número de identificación
final records = await recordService.getRecordsByIdNumber('987654321');

// Por nombre
final results = await recordService.searchByName('Juan');

// Por fecha
final today = await recordService.getRecordsByDate(DateTime.now());

// Por enfermera
final nurseRecords = await recordService.getRecordsByNurse(1);
```

## 📊 Base de Datos

**Archivo:** `mi_vacuna.db`
**Ubicación:** Directorio de bases de datos del dispositivo
**Versión:** 1

La base de datos se crea automáticamente al iniciar la aplicación por primera vez.

## ✅ Ventajas de esta Arquitectura

1. **Simplicidad**: Solo 2 tablas, fácil de mantener
2. **Rendimiento**: Sin joins complejos
3. **Integridad**: Toda la información del registro en un solo lugar
4. **Exportación**: Fácil de exportar a Excel/CSV
5. **Backup**: Sencillo de respaldar y restaurar
6. **Búsqueda**: Consultas rápidas sin relaciones complejas

## 🔄 Migraciones

La versión actual es **1**. Si en el futuro necesitas agregar campos:

1. Incrementa el número de versión en `database_helper.dart`
2. Implementa `onUpgrade` para las migraciones
3. Agrega los campos nuevos al modelo

---

**Última actualización:** Enero 2026
