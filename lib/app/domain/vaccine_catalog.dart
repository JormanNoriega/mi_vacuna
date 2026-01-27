import 'vaccine_type.dart';
import 'dose_config.dart';
import 'vaccine_config.dart';

/// Catálogo completo de vacunas del PAI Colombia
class VaccineCatalog {
  static const Map<VaccineType, VaccineConfig> vaccines = {
    // COVID-19
    VaccineType.covid19: VaccineConfig(
      type: VaccineType.covid19,
      name: 'COVID-19',
      code: 'COVID',
      hasLaboratory: true,
      laboratories: [
        'PFIZER',
        'ASTRAZENECA',
        'MODERNA 0,25',
        'MODERNA 0,5',
        'SINOVAC',
        'JANSSEN',
      ],
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringa23G1ConvencionalCovid19,
        ApplicationDevice.jeringa22G1MediaPulgConvencionalCovid19,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 0),
        DoseConfig(doseNumber: 2, doseName: 'Segunda dosis', ageMonthsMin: 1),
      ],
    ),
    // BCG
    VaccineType.bcg: VaccineConfig(
      type: VaccineType.bcg,
      name: 'BCG - Tuberculosis',
      code: 'BCG',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      hasObservation: true,
      observations: [
        'POBLACION INDIGENA Y RURAL DISPERSA',
        'CONTACTOS DE HANSEN',
      ],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable26GTresOctavosAD,
        ApplicationDevice.jeringaDesechable26GTresOctavosConvencional,
        ApplicationDevice.jeringaDesechable27GTresOctavos,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Única',
          ageMonthsMin: 0,
          ageMonthsMax: 12,
        ),
      ],
    ),
    // Hepatitis B
    VaccineType.hepatitisB: VaccineConfig(
      type: VaccineType.hepatitisB,
      name: 'Hepatitis B',
      code: 'HepB',
      hasLot: true,
      hasSyringeLot: true,
      hasObservation: true,
      observations: [
        'ANTES DE 12 HORAS',
        'DESPÚES DE 12 HORAS',
        '(ICBF)',
        'RESOLUCION. 0459/2012 y Circular 031/14',
        'HOMBRES QUE TIENEN SEXO CON HOMBRES. PRIO',
        'PERSONAS QUE EJERCEN ACTIVIDADES SEXUALES PAGAS. PRIO',
        'MUJERES TRANSGENERO. PRIO',
        'PERSONAS QUE SE INYECTAN DROGAS. PRIO',
        'HABITANTES DE CALLE. PRIO',
        'INDIGENAS. PRIO',
      ],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'RECIEN NACIDO',
          ageMonthsMin: 0,
          ageMonthsMax: 0,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 18,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Adicional', ageMonthsMin: 0),
      ],
    ),
    // Polio Inactivado (Inyectable)
    VaccineType.polioInactivado: VaccineConfig(
      type: VaccineType.polioInactivado,
      name: 'Polio Inactivado (Vacuna inyectable)',
      code: 'IPV',
      hasLot: true,
      hasSyringeLot: true,
      hasObservation: true,
      observations: ['AUTORIZADAS POR EL MINISTERIO'],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 4,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // Polio Oral
    VaccineType.polioOral: VaccineConfig(
      type: VaccineType.polioOral,
      name: 'Polio (Vacuna oral)',
      code: 'VOP',
      hasLot: true,
      hasSyringeLot: false,
      allowedDevices: [ApplicationDevice.goteroDesechado],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // Pentavalente
    VaccineType.pentavalente: VaccineConfig(
      type: VaccineType.pentavalente,
      name: 'Pentavalente',
      code: 'PENTA',
      hasLot: true,
      hasSyringeLot: true,
      hasObservation: true,
      observations: ['AUTORIZADAS POR EL MINISTERIO'],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 4,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // Hexavalente
    VaccineType.hexavalente: VaccineConfig(
      type: VaccineType.hexavalente,
      name: 'Hexavalente',
      code: 'HEXA',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
      ],
    ),
    // DPT
    VaccineType.dpt: VaccineConfig(
      type: VaccineType.dpt,
      name: 'Difteria, Tos ferina y Tétanos - DPT',
      code: 'DPT',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 4,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // DTPa Pediátrico
    VaccineType.dtpaPediatrico: VaccineConfig(
      type: VaccineType.dtpaPediatrico,
      name: 'DTPa Pediátrico',
      code: 'DTPa-P',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 4,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // TD Pediátrico
    VaccineType.tdPediatrico: VaccineConfig(
      type: VaccineType.tdPediatrico,
      name: 'TD Pediátrico',
      code: 'TD-P',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          ageMonthsMax: 18,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 4,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // Rotavirus
    VaccineType.rotavirus: VaccineConfig(
      type: VaccineType.rotavirus,
      name: 'Rotavirus (vacuna oral)',
      code: 'ROTA',
      hasLot: true,
      hasSyringeLot: false,
      allowedDevices: [ApplicationDevice.goteroDesechado],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
      ],
    ),
    // Neumococo
    VaccineType.neumococo: VaccineConfig(
      type: VaccineType.neumococo,
      name: 'Neumococo',
      code: 'NEUM',
      hasLot: true,
      hasSyringeLot: true,
      hasPneumococcalType: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 2,
          ageMonthsMax: 4,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          ageMonthsMax: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 12,
          ageMonthsMax: 18,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Única', ageMonthsMin: 12),
      ],
    ),
    // Triple Viral - SRP
    VaccineType.tripleViral: VaccineConfig(
      type: VaccineType.tripleViral,
      name: 'Triple viral - SRP',
      code: 'SRP',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 12,
          ageMonthsMax: 18,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // Sarampión-Rubéola SR
    VaccineType.sarampionRubeola: VaccineConfig(
      type: VaccineType.sarampionRubeola,
      name: 'Sarampión - Rubeola - SR Multidosis',
      code: 'SR',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Única', ageMonthsMin: 12),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Cero',
          ageMonthsMin: 0,
          ageMonthsMax: 11,
        ),
      ],
    ),
    // Fiebre Amarilla
    VaccineType.fiebreAmarilla: VaccineConfig(
      type: VaccineType.fiebreAmarilla,
      name: 'Fiebre amarilla',
      code: 'FA',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Única',
          ageMonthsMin: 18,
          ageMonthsMax: 24,
        ),
      ],
    ),
    // Hepatitis A Pediátrica
    VaccineType.hepatitisAPediatrica: VaccineConfig(
      type: VaccineType.hepatitisAPediatrica,
      name: 'Hepatitis A pediátrica',
      code: 'HepA-P',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Única',
          ageMonthsMin: 12,
          ageMonthsMax: 24,
        ),
      ],
    ),
    // Varicela
    VaccineType.varicela: VaccineConfig(
      type: VaccineType.varicela,
      name: 'Varicela',
      code: 'VAR',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 12,
          ageMonthsMax: 18,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Refuerzo',
          ageMonthsMin: 60,
          ageMonthsMax: 72,
        ),
      ],
    ),
    // TD Adulto
    VaccineType.tdAdulto: VaccineConfig(
      type: VaccineType.tdAdulto,
      name: 'Toxoide tetánico y diftérico de Adulto',
      code: 'TD-A',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 120),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 120,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 120,
          daysFromPrevious: 180,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Cuarta dosis', ageMonthsMin: 120),
        DoseConfig(doseNumber: 5, doseName: 'Quinta dosis', ageMonthsMin: 120),
        DoseConfig(
          doseNumber: 6,
          doseName: 'Primer Refuerzo',
          ageMonthsMin: 120,
        ),
        DoseConfig(
          doseNumber: 7,
          doseName: 'Segundo Refuerzo',
          ageMonthsMin: 120,
        ),
        DoseConfig(
          doseNumber: 8,
          doseName: 'Tercer Refuerzo',
          ageMonthsMin: 120,
        ),
        DoseConfig(
          doseNumber: 9,
          doseName: 'Cuarto Refuerzo',
          ageMonthsMin: 120,
        ),
      ],
    ),
    // dTpa Adulto
    VaccineType.dtpaAdulto: VaccineConfig(
      type: VaccineType.dtpaAdulto,
      name: 'dTpa adulto',
      code: 'DTPa-A',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 120),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 120,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 120,
          daysFromPrevious: 180,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Cuarta dosis', ageMonthsMin: 120),
        DoseConfig(doseNumber: 5, doseName: 'Quinta dosis', ageMonthsMin: 120),
        DoseConfig(doseNumber: 6, doseName: 'Única', ageMonthsMin: 120),
      ],
    ),
    // Influenza
    VaccineType.influenza: VaccineConfig(
      type: VaccineType.influenza,
      name: 'Influenza',
      code: 'FLU',
      hasLot: true,
      hasSyringeLot: true,
      hasObservation: true,
      observations: [
        'DIAGNÓSTICO DE RIESGO',
        'Poblaciones autorizadas MSPS',
        'TALENTO HUMANO EN SALUD',
      ],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 6),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 6,
          daysFromPrevious: 30,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Única 0,25',
          ageMonthsMin: 6,
          ageMonthsMax: 35,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Única 0,5', ageMonthsMin: 36),
      ],
    ),
    // VPH
    VaccineType.vph: VaccineConfig(
      type: VaccineType.vph,
      name: 'VPH - Virus Papiloma Humano',
      code: 'VPH',
      hasLot: true,
      hasSyringeLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(
          doseNumber: 1,
          doseName: 'Primera dosis',
          ageMonthsMin: 108,
          ageMonthsMax: 204,
        ),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 108,
          ageMonthsMax: 210,
          daysFromPrevious: 180,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 108,
          ageMonthsMax: 210,
        ),
      ],
    ),
    // Antirrábica Humana (Vacuna)
    VaccineType.antirrabicaHumana: VaccineConfig(
      type: VaccineType.antirrabicaHumana,
      name: 'Antirrábica Humana (vacuna)',
      code: 'RAB-V',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      hasObservation: true,
      observations: [
        'PRE EXPOSICIÓN OPCION 1 (I.D.)',
        'PRE EXPOSICIÓN OPCION 2 (I.M.)',
        'POS EXPOSICIÓN NORMAL',
      ],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 0),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Primera dosis y Segunda dosis',
          ageMonthsMin: 0,
        ),
        DoseConfig(doseNumber: 3, doseName: 'Segunda dosis', ageMonthsMin: 0),
        DoseConfig(doseNumber: 4, doseName: 'Tercera dosis', ageMonthsMin: 0),
        DoseConfig(
          doseNumber: 5,
          doseName: 'Tercera dosis y Cuarta dosis',
          ageMonthsMin: 0,
        ),
        DoseConfig(doseNumber: 6, doseName: 'Cuarta dosis', ageMonthsMin: 0),
      ],
    ),
    // Antirrábico Humano (Suero)
    VaccineType.antirrabicoSuero: VaccineConfig(
      type: VaccineType.antirrabicoSuero,
      name: 'Antirrábico Humano (suero)',
      code: 'RAB-S',
      hasLot: true,
      hasSyringeLot: false,
      usesVialCount: true,
      allowedDevices: [],
      doses: [DoseConfig(doseNumber: 1, doseName: 'Única', ageMonthsMin: 0)],
    ),
    // Hepatitis B (Inmunoglobulina)
    VaccineType.hepatitisBInmunoglobulina: VaccineConfig(
      type: VaccineType.hepatitisBInmunoglobulina,
      name: 'Hepatitis B (Inmunoglobulina)',
      code: 'HepB-IG',
      hasLot: true,
      hasSyringeLot: true,
      usesVialCount: true,
      hasObservation: true,
      observations: [
        'ANTES DE 12 HORAS',
        'DESPÚES DE 12 HORAS',
        'RESOLUCION 0459/2012- circular 031/14',
      ],
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [DoseConfig(doseNumber: 1, doseName: 'Única', ageMonthsMin: 0)],
    ),
    // Inmunoglobulina Anti Tetánica
    VaccineType.inmunoglobulinaAntiTetanica: VaccineConfig(
      type: VaccineType.inmunoglobulinaAntiTetanica,
      name: 'INMUNOGLOBULINA ANTI TETANICA (Suero homólogo)',
      code: 'TET-IG',
      hasLot: true,
      hasSyringeLot: true,
      usesVialCount: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
        ApplicationDevice.jeringaDesechable26GTresOctavosAD,
        ApplicationDevice.jeringaDesechable26GTresOctavosConvencional,
        ApplicationDevice.jeringaDesechable27GTresOctavos,
      ],
      doses: [DoseConfig(doseNumber: 1, doseName: 'Única', ageMonthsMin: 0)],
    ),
    // Anti Toxina Tetánica
    VaccineType.antiToxinaTetanica: VaccineConfig(
      type: VaccineType.antiToxinaTetanica,
      name: 'ANTI TOXINA TETANICA (Suero heterólogo)',
      code: 'TET-AT',
      hasLot: true,
      hasSyringeLot: true,
      usesVialCount: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable22G1MediaPulgAD,
        ApplicationDevice.jeringaDesechable22G1MediaPulgConvencional,
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
        ApplicationDevice.jeringaDesechable25GCincoOctavosAD,
        ApplicationDevice.jeringaDesechable25GCincoOctavosConvencional,
        ApplicationDevice.jeringaDesechable26GTresOctavosAD,
        ApplicationDevice.jeringaDesechable26GTresOctavosConvencional,
        ApplicationDevice.jeringaDesechable27GTresOctavos,
      ],
      doses: [DoseConfig(doseNumber: 1, doseName: 'Única', ageMonthsMin: 0)],
    ),
    // Meningococo
    VaccineType.meningococo: VaccineConfig(
      type: VaccineType.meningococo,
      name: 'Meningococo de los serogrupos A, C, W-135 e Y',
      code: 'MENING',
      hasLot: true,
      hasSyringeLot: true,
      hasDiluentLot: true,
      allowedDevices: [
        ApplicationDevice.jeringaDesechable23G1PulgAD,
        ApplicationDevice.jeringaDesechable23G1PulgConvencional,
      ],
      doses: [
        DoseConfig(doseNumber: 1, doseName: 'Primera dosis', ageMonthsMin: 2),
        DoseConfig(
          doseNumber: 2,
          doseName: 'Segunda dosis',
          ageMonthsMin: 4,
          daysFromPrevious: 60,
        ),
        DoseConfig(
          doseNumber: 3,
          doseName: 'Tercera dosis',
          ageMonthsMin: 6,
          daysFromPrevious: 60,
        ),
        DoseConfig(doseNumber: 4, doseName: 'Única', ageMonthsMin: 12),
      ],
    ),
  };
  // Métodos helper
  static VaccineConfig? getByType(VaccineType type) => vaccines[type];
  static VaccineConfig? getByCode(String code) {
    try {
      return vaccines.values.firstWhere((v) => v.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<VaccineConfig> getAll() => vaccines.values.toList();
  static List<VaccineConfig> getByAgeMonths(int ageMonths) {
    return vaccines.values.where((v) {
      return v.doses.any(
        (d) =>
            ageMonths >= d.ageMonthsMin &&
            (d.ageMonthsMax == null || ageMonths <= d.ageMonthsMax!),
      );
    }).toList();
  }
}
