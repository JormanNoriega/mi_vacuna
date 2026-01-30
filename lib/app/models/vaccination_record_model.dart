class VaccinationRecordModel {
  int? id;

  // DATOS BÁSICOS
  String? consecutivo;
  DateTime? fechaAtencion;
  String tipoIdentificacion;
  String numeroIdentificacion;
  String primerNombre;
  String? segundoNombre;
  String primerApellido;
  String? segundoApellido;
  DateTime fechaNacimiento;
  int? anos;
  int? meses;
  int? dias;
  int? totalMeses;
  bool? esquemaCompleto;
  String sexo;
  String? genero;
  String? orientacionSexual;
  int? edadGestacional;

  // DATOS COMPLEMENTARIOS
  String paisNacimiento;
  String? estatusMigratorio;
  String? lugarAtencionParto;
  String? regimenAfiliacion;
  String? aseguradora;
  String? pertenenciaEtnica;
  bool? desplazado;
  bool? discapacitado;
  bool? fallecido;
  bool? victimaConflictoArmado;
  bool? estudiaActualmente;
  String? paisResidencia;
  String? departamentoResidencia;
  String? municipioResidencia;
  String? comunaLocalidad;
  String? area;
  String? direccion;
  String? telefonoFijo;
  String? celular;
  String? email;
  bool? autorizaLlamadas;
  bool? autorizaCorreo;

  // ANTECEDENTE MEDICO
  bool? contraIndicacionVacunacion;
  String? contraIndicacionCual;
  bool? reaccionBiologicosAnteriores;
  String? reaccionBiologicosCual;

  // HISTORICO DE ANTECEDENTE
  DateTime? fechaRegistroAntecedente;
  String? tipoAntecedente;
  String? descripcionAntecedente;
  String? observacionesEspeciales;

  // CONDICION USUARIA
  String? condicionUsuaria;
  DateTime? fechaUltimaMenstruacion;
  int? semanasGestacion;
  DateTime? fechaProbableParto;
  int? cantidadEmbarazosPrevios;

  // DATOS DE LA MADRE
  String? madreTipoIdentificacion;
  String? madreNumeroIdentificacion;
  String? madrePrimerNombre;
  String? madreSegundoNombre;
  String? madrePrimerApellido;
  String? madreSegundoApellido;
  String? madreEmail;
  String? madreTelefonoFijo;
  String? madreCelular;
  String? madreRegimenAfiliacion;
  String? madrePertenenciaEtnica;
  bool? madreDesplazado;

  // DATOS DEL CUIDADOR
  String? cuidadorTipoIdentificacion;
  String? cuidadorNumeroIdentificacion;
  String? cuidadorPrimerNombre;
  String? cuidadorSegundoNombre;
  String? cuidadorPrimerApellido;
  String? cuidadorSegundoApellido;
  String? cuidadorParentesco;
  String? cuidadorEmail;
  String? cuidadorTelefonoFijo;
  String? cuidadorCelular;

  // ESQUEMA DE VACUNACION
  String? tipoCarnet;

  // COVID-19
  String? covidDosis;
  String? covidLaboratorio;
  String? covidLote;
  String? covidJeringa;
  String? covidLoteJeringa;
  String? covidLoteDiluyente;

  // BCG
  String? bcgDosis;
  String? bcgLote;
  String? bcgJeringa;
  String? bcgLoteJeringa;
  String? bcgLoteDiluyente;
  String? bcgObservacion;

  // Hepatitis B
  String? hepatitisBDosis;
  String? hepatitisBLote;
  String? hepatitisBJeringa;
  String? hepatitisBLoteJeringa;
  String? hepatitisBObservacion;

  // Polio Inactivado (Vacuna inyectable)
  String? polioInactivadoDosis;
  String? polioInactivadoLote;
  String? polioInactivadoJeringa;
  String? polioInactivadoLoteJeringa;
  String? polioInactivadoObservacion;

  // Polio (Vacuna oral)
  String? polioOralDosis;
  String? polioOralLote;
  String? polioOralGotero;

  // Pentavalente
  String? pentavalenteDosis;
  String? pentavalenteLote;
  String? pentavalenteJeringa;
  String? pentavalenteLoteJeringa;
  String? pentavalenteObservacion;

  // Hexavalente
  String? hexavalenteDosis;
  String? hexavalenteLote;
  String? hexavalenteJeringa;
  String? hexavalenteLoteJeringa;

  // Difteria, Tos ferina y Tétanos - DPT
  String? dptDosis;
  String? dptLote;
  String? dptJeringa;
  String? dptLoteJeringa;

  // DTPa Pediátrico
  String? dtpaPediatricoDosis;
  String? dtpaPediatricoLote;
  String? dtpaPediatricoJeringa;
  String? dtpaPediatricoLoteJeringa;

  // TD Pediátrico
  String? tdPediatricoDosis;
  String? tdPediatricoLote;
  String? tdPediatricoJeringa;
  String? tdPediatricoLoteJeringa;

  // Rotavirus (vacuna oral)
  String? rotavirusDosis;
  String? rotavirusLote;

  // Neumococo
  String? neumococoTipo;
  String? neumococoDosis;
  String? neumococoLote;
  String? neumococoJeringa;
  String? neumococoLoteJeringa;

  // Triple viral - SRP
  String? srptDosis;
  String? srptLote;
  String? srptJeringa;
  String? srptLoteJeringa;
  String? srptLoteDiluyente;

  // Sarampión - Rubeola - SR Multidosis
  String? srMultidosisDosis;
  String? srMultidosisLote;
  String? srMultidosisJeringa;
  String? srMultidosisLoteJeringa;
  String? srMultidosisLoteDiluyente;

  // Fiebre amarilla
  String? fiebreAmarillaDosis;
  String? fiebreAmarillaLote;
  String? fiebreAmarillaJeringa;
  String? fiebreAmarillaLoteJeringa;
  String? fiebreAmarillaLoteDiluyente;

  // Hepatitis A pediátrica
  String? hepatitisAPediatricaDosis;
  String? hepatitisAPediatricaLote;
  String? hepatitisAPediatricaJeringa;
  String? hepatitisAPediatricaLoteJeringa;

  // Varicela
  String? varicelaDosis;
  String? varicelaLote;
  String? varicelaJeringa;
  String? varicelaLoteJeringa;
  String? varicelaLoteDiluyente;

  // Toxoide tetánico y diftérico de Adulto
  String? tdAdultoDosis;
  String? tdAdultoLote;
  String? tdAdultoJeringa;
  String? tdAdultoLoteJeringa;

  // dTpa adulto
  String? dtpaAdultoDosis;
  String? dtpaAdultoLote;
  String? dtpaAdultoJeringa;
  String? dtpaAdultoLoteJeringa;

  // Influenza
  String? influenzaDosis;
  String? influenzaLote;
  String? influenzaJeringa;
  String? influenzaLoteJeringa;
  String? influenzaObservacion;

  // VPH
  String? vphDosis;
  String? vphLote;
  String? vphJeringa;
  String? vphLoteJeringa;

  // Antirrábica Humana (vacuna)
  String? antirrabicaVacunaDosis;
  String? antirrabicaVacunaLote;
  String? antirrabicaVacunaJeringa;
  String? antirrabicaVacunaLoteJeringa;
  String? antirrabicaVacunaLoteDiluyente;
  String? antirrabicaVacunaObservacion;

  // Antirrábico Humano (suero)
  int? antirrabicaSueroNumFrascos;
  String? antirrabicaSueroLote;

  // Hepatitis B (Inmunoglobulina)
  int? hepatitisBInmunoglobulinaNumFrascos;
  String? hepatitisBInmunoglobulinaLote;
  String? hepatitisBInmunoglobulinaJeringa;
  String? hepatitisBInmunoglobulinaLoteJeringa;
  String? hepatitisBInmunoglobulinaObservacion;

  // INMUNOGLOBULINA ANTI TETANICA (Suero homólogo)
  int? inmunoglobulinaAntitetanicaNumFrascos;
  String? inmunoglobulinaAntitetanicaLote;
  String? inmunoglobulinaAntitetanicaJeringa;
  String? inmunoglobulinaAntitetanicaLoteJeringa;

  // ANTI TOXINA TETANICA (Suero heterólogo)
  int? antitoxinaTetanicaNumFrascos;
  String? antitoxinaTetanicaLote;
  String? antitoxinaTetanicaJeringa;
  String? antitoxinaTetanicaLoteJeringa;

  // Meningococo de los serogrupos A, C, W-135 e Y
  String? meningococoDosis;
  String? meningococoLote;
  String? meningococoJeringa;
  String? meningococoLoteJeringa;
  String? meningococoLoteDiluyente;

  // Metadatos
  DateTime createdAt;
  DateTime? updatedAt;
  int? nurseId; // Referencia a la enfermera que registró

  VaccinationRecordModel({
    this.id,
    // DATOS BÁSICOS
    this.consecutivo,
    this.fechaAtencion,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    required this.primerNombre,
    this.segundoNombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.fechaNacimiento,
    this.anos,
    this.meses,
    this.dias,
    this.totalMeses,
    this.esquemaCompleto,
    required this.sexo,
    this.genero,
    this.orientacionSexual,
    this.edadGestacional,
    // DATOS COMPLEMENTARIOS
    required this.paisNacimiento,
    this.estatusMigratorio,
    this.lugarAtencionParto,
    this.regimenAfiliacion,
    this.aseguradora,
    this.pertenenciaEtnica,
    this.desplazado,
    this.discapacitado,
    this.fallecido,
    this.victimaConflictoArmado,
    this.estudiaActualmente,
    this.paisResidencia,
    this.departamentoResidencia,
    this.municipioResidencia,
    this.comunaLocalidad,
    this.area,
    this.direccion,
    this.telefonoFijo,
    this.celular,
    this.email,
    this.autorizaLlamadas,
    this.autorizaCorreo,
    // ANTECEDENTES MEDICOS
    this.contraIndicacionVacunacion,
    this.contraIndicacionCual,
    this.reaccionBiologicosAnteriores,
    this.reaccionBiologicosCual,
    // CONDICION USUARIA
    this.condicionUsuaria,
    this.fechaUltimaMenstruacion,
    this.semanasGestacion,
    this.fechaProbableParto,
    this.cantidadEmbarazosPrevios,
    // HISTORICO DE ANTECEDENTES
    this.fechaRegistroAntecedente,
    this.tipoAntecedente,
    this.descripcionAntecedente,
    this.observacionesEspeciales,
    // DATOS DE LA MADRE
    this.madreTipoIdentificacion,
    this.madreNumeroIdentificacion,
    this.madrePrimerNombre,
    this.madreSegundoNombre,
    this.madrePrimerApellido,
    this.madreSegundoApellido,
    this.madreEmail,
    this.madreTelefonoFijo,
    this.madreCelular,
    this.madreRegimenAfiliacion,
    this.madrePertenenciaEtnica,
    this.madreDesplazado,
    // DATOS DEL CUIDADOR
    this.cuidadorTipoIdentificacion,
    this.cuidadorNumeroIdentificacion,
    this.cuidadorPrimerNombre,
    this.cuidadorSegundoNombre,
    this.cuidadorPrimerApellido,
    this.cuidadorSegundoApellido,
    this.cuidadorParentesco,
    this.cuidadorEmail,
    this.cuidadorTelefonoFijo,
    this.cuidadorCelular,
    // ESQUEMA DE VACUNACION
    this.tipoCarnet,
    this.covidDosis,
    this.covidLaboratorio,
    this.covidLote,
    this.covidJeringa,
    this.covidLoteJeringa,
    this.covidLoteDiluyente,
    this.bcgDosis,
    this.bcgLote,
    this.bcgJeringa,
    this.bcgLoteJeringa,
    this.bcgLoteDiluyente,
    this.bcgObservacion,
    this.hepatitisBDosis,
    this.hepatitisBLote,
    this.hepatitisBJeringa,
    this.hepatitisBLoteJeringa,
    this.hepatitisBObservacion,
    this.polioInactivadoDosis,
    this.polioInactivadoLote,
    this.polioInactivadoJeringa,
    this.polioInactivadoLoteJeringa,
    this.polioInactivadoObservacion,
    this.polioOralDosis,
    this.polioOralLote,
    this.polioOralGotero,
    this.pentavalenteDosis,
    this.pentavalenteLote,
    this.pentavalenteJeringa,
    this.pentavalenteLoteJeringa,
    this.pentavalenteObservacion,
    this.hexavalenteDosis,
    this.hexavalenteLote,
    this.hexavalenteJeringa,
    this.hexavalenteLoteJeringa,
    this.dptDosis,
    this.dptLote,
    this.dptJeringa,
    this.dptLoteJeringa,
    this.dtpaPediatricoDosis,
    this.dtpaPediatricoLote,
    this.dtpaPediatricoJeringa,
    this.dtpaPediatricoLoteJeringa,
    this.tdPediatricoDosis,
    this.tdPediatricoLote,
    this.tdPediatricoJeringa,
    this.tdPediatricoLoteJeringa,
    this.rotavirusDosis,
    this.rotavirusLote,
    this.neumococoTipo,
    this.neumococoDosis,
    this.neumococoLote,
    this.neumococoJeringa,
    this.neumococoLoteJeringa,
    this.srptDosis,
    this.srptLote,
    this.srptJeringa,
    this.srptLoteJeringa,
    this.srptLoteDiluyente,
    this.srMultidosisDosis,
    this.srMultidosisLote,
    this.srMultidosisJeringa,
    this.srMultidosisLoteJeringa,
    this.srMultidosisLoteDiluyente,
    this.fiebreAmarillaDosis,
    this.fiebreAmarillaLote,
    this.fiebreAmarillaJeringa,
    this.fiebreAmarillaLoteJeringa,
    this.fiebreAmarillaLoteDiluyente,
    this.hepatitisAPediatricaDosis,
    this.hepatitisAPediatricaLote,
    this.hepatitisAPediatricaJeringa,
    this.hepatitisAPediatricaLoteJeringa,
    this.varicelaDosis,
    this.varicelaLote,
    this.varicelaJeringa,
    this.varicelaLoteJeringa,
    this.varicelaLoteDiluyente,
    this.tdAdultoDosis,
    this.tdAdultoLote,
    this.tdAdultoJeringa,
    this.tdAdultoLoteJeringa,
    this.dtpaAdultoDosis,
    this.dtpaAdultoLote,
    this.dtpaAdultoJeringa,
    this.dtpaAdultoLoteJeringa,
    this.influenzaDosis,
    this.influenzaLote,
    this.influenzaJeringa,
    this.influenzaLoteJeringa,
    this.influenzaObservacion,
    this.vphDosis,
    this.vphLote,
    this.vphJeringa,
    this.vphLoteJeringa,
    this.antirrabicaVacunaDosis,
    this.antirrabicaVacunaLote,
    this.antirrabicaVacunaJeringa,
    this.antirrabicaVacunaLoteJeringa,
    this.antirrabicaVacunaLoteDiluyente,
    this.antirrabicaVacunaObservacion,
    this.antirrabicaSueroNumFrascos,
    this.antirrabicaSueroLote,
    this.hepatitisBInmunoglobulinaNumFrascos,
    this.hepatitisBInmunoglobulinaLote,
    this.hepatitisBInmunoglobulinaJeringa,
    this.hepatitisBInmunoglobulinaLoteJeringa,
    this.hepatitisBInmunoglobulinaObservacion,
    this.inmunoglobulinaAntitetanicaNumFrascos,
    this.inmunoglobulinaAntitetanicaLote,
    this.inmunoglobulinaAntitetanicaJeringa,
    this.inmunoglobulinaAntitetanicaLoteJeringa,
    this.antitoxinaTetanicaNumFrascos,
    this.antitoxinaTetanicaLote,
    this.antitoxinaTetanicaJeringa,
    this.antitoxinaTetanicaLoteJeringa,
    this.meningococoDosis,
    this.meningococoLote,
    this.meningococoJeringa,
    this.meningococoLoteJeringa,
    this.meningococoLoteDiluyente,
    // Metadatos
    DateTime? createdAt,
    this.updatedAt,
    this.nurseId,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // DATOS BÁSICOS
      'consecutivo': consecutivo,
      'fechaAtencion': fechaAtencion?.toIso8601String(),
      'tipoIdentificacion': tipoIdentificacion,
      'numeroIdentificacion': numeroIdentificacion,
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'primerApellido': primerApellido,
      'segundoApellido': segundoApellido,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'anos': anos,
      'meses': meses,
      'dias': dias,
      'totalMeses': totalMeses,
      'esquemaCompleto': esquemaCompleto == null
          ? null
          : (esquemaCompleto! ? 1 : 0),
      'sexo': sexo,
      'genero': genero,
      'orientacionSexual': orientacionSexual,
      'edadGestacional': edadGestacional,
      // DATOS COMPLEMENTARIOS
      'paisNacimiento': paisNacimiento,
      'estatusMigratorio': estatusMigratorio,
      'lugarAtencionParto': lugarAtencionParto,
      'regimenAfiliacion': regimenAfiliacion,
      'aseguradora': aseguradora,
      'pertenenciaEtnica': pertenenciaEtnica,
      'desplazado': desplazado == null ? null : (desplazado! ? 1 : 0),
      'discapacitado': discapacitado == null ? null : (discapacitado! ? 1 : 0),
      'fallecido': fallecido == null ? null : (fallecido! ? 1 : 0),
      'victimaConflictoArmado': victimaConflictoArmado == null
          ? null
          : (victimaConflictoArmado! ? 1 : 0),
      'estudiaActualmente': estudiaActualmente == null
          ? null
          : (estudiaActualmente! ? 1 : 0),
      'paisResidencia': paisResidencia,
      'departamentoResidencia': departamentoResidencia,
      'municipioResidencia': municipioResidencia,
      'comunaLocalidad': comunaLocalidad,
      'area': area,
      'direccion': direccion,
      'telefonoFijo': telefonoFijo,
      'celular': celular,
      'email': email,
      'autorizaLlamadas': autorizaLlamadas == null
          ? null
          : (autorizaLlamadas! ? 1 : 0),
      'autorizaCorreo': autorizaCorreo == null
          ? null
          : (autorizaCorreo! ? 1 : 0),
      // ANTECEDENTE MEDICO
      'contraIndicacionVacunacion': contraIndicacionVacunacion == null
          ? null
          : (contraIndicacionVacunacion! ? 1 : 0),
      'contraIndicacionCual': contraIndicacionCual,
      'reaccionBiologicosAnteriores': reaccionBiologicosAnteriores == null
          ? null
          : (reaccionBiologicosAnteriores! ? 1 : 0),
      'reaccionBiologicosCual': reaccionBiologicosCual,

      // HISTORICO DE ANTECEDENTE
      'fechaRegistroAntecedente': fechaRegistroAntecedente?.toIso8601String(),
      'tipoAntecedente': tipoAntecedente,
      'descripcionAntecedente': descripcionAntecedente,
      'observacionesEspeciales': observacionesEspeciales,

      // CONDICION USUARIA
      'condicionUsuaria': condicionUsuaria,
      'fechaUltimaMenstruacion': fechaUltimaMenstruacion?.toIso8601String(),
      'semanasGestacion': semanasGestacion,
      'fechaProbableParto': fechaProbableParto?.toIso8601String(),
      'cantidadEmbarazosPrevios': cantidadEmbarazosPrevios,
      
      // DATOS DE LA MADRE
      'madreTipoIdentificacion': madreTipoIdentificacion,
      'madreNumeroIdentificacion': madreNumeroIdentificacion,
      'madrePrimerNombre': madrePrimerNombre,
      'madreSegundoNombre': madreSegundoNombre,
      'madrePrimerApellido': madrePrimerApellido,
      'madreSegundoApellido': madreSegundoApellido,
      'madreEmail': madreEmail,
      'madreTelefonoFijo': madreTelefonoFijo,
      'madreCelular': madreCelular,
      'madreRegimenAfiliacion': madreRegimenAfiliacion,
      'madrePertenenciaEtnica': madrePertenenciaEtnica,
      'madreDesplazado': madreDesplazado == null
          ? null
          : (madreDesplazado! ? 1 : 0),
      // DATOS DEL CUIDADOR
      'cuidadorTipoIdentificacion': cuidadorTipoIdentificacion,
      'cuidadorNumeroIdentificacion': cuidadorNumeroIdentificacion,
      'cuidadorPrimerNombre': cuidadorPrimerNombre,
      'cuidadorSegundoNombre': cuidadorSegundoNombre,
      'cuidadorPrimerApellido': cuidadorPrimerApellido,
      'cuidadorSegundoApellido': cuidadorSegundoApellido,
      'cuidadorParentesco': cuidadorParentesco,
      'cuidadorEmail': cuidadorEmail,
      'cuidadorTelefonoFijo': cuidadorTelefonoFijo,
      'cuidadorCelular': cuidadorCelular,

      // ESQUEMA DE VACUNACION
      'tipoCarnet': tipoCarnet,
      'covidDosis': covidDosis,
      'covidLaboratorio': covidLaboratorio,
      'covidLote': covidLote,
      'covidJeringa': covidJeringa,
      'covidLoteJeringa': covidLoteJeringa,
      'covidLoteDiluyente': covidLoteDiluyente,
      'bcgDosis': bcgDosis,
      'bcgLote': bcgLote,
      'bcgJeringa': bcgJeringa,
      'bcgLoteJeringa': bcgLoteJeringa,
      'bcgLoteDiluyente': bcgLoteDiluyente,
      'bcgObservacion': bcgObservacion,
      'hepatitisBDosis': hepatitisBDosis,
      'hepatitisBLote': hepatitisBLote,
      'hepatitisBJeringa': hepatitisBJeringa,
      'hepatitisBLoteJeringa': hepatitisBLoteJeringa,
      'hepatitisBObservacion': hepatitisBObservacion,
      'polioInactivadoDosis': polioInactivadoDosis,
      'polioInactivadoLote': polioInactivadoLote,
      'polioInactivadoJeringa': polioInactivadoJeringa,
      'polioInactivadoLoteJeringa': polioInactivadoLoteJeringa,
      'polioInactivadoObservacion': polioInactivadoObservacion,
      'polioOralDosis': polioOralDosis,
      'polioOralLote': polioOralLote,
      'polioOralGotero': polioOralGotero,
      'pentavalenteDosis': pentavalenteDosis,
      'pentavalenteLote': pentavalenteLote,
      'pentavalenteJeringa': pentavalenteJeringa,
      'pentavalenteLoteJeringa': pentavalenteLoteJeringa,
      'pentavalenteObservacion': pentavalenteObservacion,
      'hexavalenteDosis': hexavalenteDosis,
      'hexavalenteLote': hexavalenteLote,
      'hexavalenteJeringa': hexavalenteJeringa,
      'hexavalenteLoteJeringa': hexavalenteLoteJeringa,
      'dptDosis': dptDosis,
      'dptLote': dptLote,
      'dptJeringa': dptJeringa,
      'dptLoteJeringa': dptLoteJeringa,
      'dtpaPediatricoDosis': dtpaPediatricoDosis,
      'dtpaPediatricoLote': dtpaPediatricoLote,
      'dtpaPediatricoJeringa': dtpaPediatricoJeringa,
      'dtpaPediatricoLoteJeringa': dtpaPediatricoLoteJeringa,
      'tdPediatricoDosis': tdPediatricoDosis,
      'tdPediatricoLote': tdPediatricoLote,
      'tdPediatricoJeringa': tdPediatricoJeringa,
      'tdPediatricoLoteJeringa': tdPediatricoLoteJeringa,
      'rotavirusDosis': rotavirusDosis,
      'rotavirusLote': rotavirusLote,
      'neumococoTipo': neumococoTipo,
      'neumococoDosis': neumococoDosis,
      'neumococoLote': neumococoLote,
      'neumococoJeringa': neumococoJeringa,
      'neumococoLoteJeringa': neumococoLoteJeringa,
      'srptDosis': srptDosis,
      'srptLote': srptLote,
      'srptJeringa': srptJeringa,
      'srptLoteJeringa': srptLoteJeringa,
      'srptLoteDiluyente': srptLoteDiluyente,
      'srMultidosisDosis': srMultidosisDosis,
      'srMultidosisLote': srMultidosisLote,
      'srMultidosisJeringa': srMultidosisJeringa,
      'srMultidosisLoteJeringa': srMultidosisLoteJeringa,
      'srMultidosisLoteDiluyente': srMultidosisLoteDiluyente,
      'fiebreAmarillaDosis': fiebreAmarillaDosis,
      'fiebreAmarillaLote': fiebreAmarillaLote,
      'fiebreAmarillaJeringa': fiebreAmarillaJeringa,
      'fiebreAmarillaLoteJeringa': fiebreAmarillaLoteJeringa,
      'fiebreAmarillaLoteDiluyente': fiebreAmarillaLoteDiluyente,
      'hepatitisAPediatricaDosis': hepatitisAPediatricaDosis,
      'hepatitisAPediatricaLote': hepatitisAPediatricaLote,
      'hepatitisAPediatricaJeringa': hepatitisAPediatricaJeringa,
      'hepatitisAPediatricaLoteJeringa': hepatitisAPediatricaLoteJeringa,
      'varicelaDosis': varicelaDosis,
      'varicelaLote': varicelaLote,
      'varicelaJeringa': varicelaJeringa,
      'varicelaLoteJeringa': varicelaLoteJeringa,
      'varicelaLoteDiluyente': varicelaLoteDiluyente,
      'tdAdultoDosis': tdAdultoDosis,
      'tdAdultoLote': tdAdultoLote,
      'tdAdultoJeringa': tdAdultoJeringa,
      'tdAdultoLoteJeringa': tdAdultoLoteJeringa,
      'dtpaAdultoDosis': dtpaAdultoDosis,
      'dtpaAdultoLote': dtpaAdultoLote,
      'dtpaAdultoJeringa': dtpaAdultoJeringa,
      'dtpaAdultoLoteJeringa': dtpaAdultoLoteJeringa,
      'influenzaDosis': influenzaDosis,
      'influenzaLote': influenzaLote,
      'influenzaJeringa': influenzaJeringa,
      'influenzaLoteJeringa': influenzaLoteJeringa,
      'influenzaObservacion': influenzaObservacion,
      'vphDosis': vphDosis,
      'vphLote': vphLote,
      'vphJeringa': vphJeringa,
      'vphLoteJeringa': vphLoteJeringa,
      'antirrabicaVacunaDosis': antirrabicaVacunaDosis,
      'antirrabicaVacunaLote': antirrabicaVacunaLote,
      'antirrabicaVacunaJeringa': antirrabicaVacunaJeringa,
      'antirrabicaVacunaLoteJeringa': antirrabicaVacunaLoteJeringa,
      'antirrabicaVacunaLoteDiluyente': antirrabicaVacunaLoteDiluyente,
      'antirrabicaVacunaObservacion': antirrabicaVacunaObservacion,
      'antirrabicaSueroNumFrascos': antirrabicaSueroNumFrascos,
      'antirrabicaSueroLote': antirrabicaSueroLote,
      'hepatitisBInmunoglobulinaNumFrascos':
          hepatitisBInmunoglobulinaNumFrascos,
      'hepatitisBInmunoglobulinaLote': hepatitisBInmunoglobulinaLote,
      'hepatitisBInmunoglobulinaJeringa': hepatitisBInmunoglobulinaJeringa,
      'hepatitisBInmunoglobulinaLoteJeringa':
          hepatitisBInmunoglobulinaLoteJeringa,
      'hepatitisBInmunoglobulinaObservacion':
          hepatitisBInmunoglobulinaObservacion,
      'inmunoglobulinaAntitetanicaNumFrascos':
          inmunoglobulinaAntitetanicaNumFrascos,
      'inmunoglobulinaAntitetanicaLote': inmunoglobulinaAntitetanicaLote,
      'inmunoglobulinaAntitetanicaJeringa': inmunoglobulinaAntitetanicaJeringa,
      'inmunoglobulinaAntitetanicaLoteJeringa':
          inmunoglobulinaAntitetanicaLoteJeringa,
      'antitoxinaTetanicaNumFrascos': antitoxinaTetanicaNumFrascos,
      'antitoxinaTetanicaLote': antitoxinaTetanicaLote,
      'antitoxinaTetanicaJeringa': antitoxinaTetanicaJeringa,
      'antitoxinaTetanicaLoteJeringa': antitoxinaTetanicaLoteJeringa,
      'meningococoDosis': meningococoDosis,
      'meningococoLote': meningococoLote,
      'meningococoJeringa': meningococoJeringa,
      'meningococoLoteJeringa': meningococoLoteJeringa,
      'meningococoLoteDiluyente': meningococoLoteDiluyente,
      // Metadatos
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'nurseId': nurseId,
    };
  }

  // Crear desde Map de SQLite
  factory VaccinationRecordModel.fromMap(Map<String, dynamic> map) {
    return VaccinationRecordModel(
      id: map['id'],
      // DATOS BÁSICOS
      consecutivo: map['consecutivo'],
      fechaAtencion: map['fechaAtencion'] != null
          ? DateTime.parse(map['fechaAtencion'])
          : null,
      tipoIdentificacion: map['tipoIdentificacion'],
      numeroIdentificacion: map['numeroIdentificacion'],
      primerNombre: map['primerNombre'],
      segundoNombre: map['segundoNombre'],
      primerApellido: map['primerApellido'],
      segundoApellido: map['segundoApellido'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']),
      anos: map['anos'],
      meses: map['meses'],
      dias: map['dias'],
      totalMeses: map['totalMeses'],
      esquemaCompleto: map['esquemaCompleto'] != null
          ? map['esquemaCompleto'] == 1
          : null,
      sexo: map['sexo'],
      genero: map['genero'],
      orientacionSexual: map['orientacionSexual'],
      edadGestacional: map['edadGestacional'],
      // DATOS COMPLEMENTARIOS
      paisNacimiento: map['paisNacimiento'],
      estatusMigratorio: map['estatusMigratorio'],
      lugarAtencionParto: map['lugarAtencionParto'],
      regimenAfiliacion: map['regimenAfiliacion'],
      aseguradora: map['aseguradora'],
      pertenenciaEtnica: map['pertenenciaEtnica'],
      desplazado: map['desplazado'] != null ? map['desplazado'] == 1 : null,
      discapacitado: map['discapacitado'] != null
          ? map['discapacitado'] == 1
          : null,
      fallecido: map['fallecido'] != null ? map['fallecido'] == 1 : null,
      victimaConflictoArmado: map['victimaConflictoArmado'] != null
          ? map['victimaConflictoArmado'] == 1
          : null,
      estudiaActualmente: map['estudiaActualmente'] != null
          ? map['estudiaActualmente'] == 1
          : null,
      paisResidencia: map['paisResidencia'],
      departamentoResidencia: map['departamentoResidencia'],
      municipioResidencia: map['municipioResidencia'],
      comunaLocalidad: map['comunaLocalidad'],
      area: map['area'],
      direccion: map['direccion'],
      telefonoFijo: map['telefonoFijo'],
      celular: map['celular'],
      email: map['email'],
      autorizaLlamadas: map['autorizaLlamadas'] != null
          ? map['autorizaLlamadas'] == 1
          : null,
      autorizaCorreo: map['autorizaCorreo'] != null
          ? map['autorizaCorreo'] == 1
          : null,
      // ANTECEDENTES MEDICOS
      contraIndicacionVacunacion: map['contraIndicacionVacunacion'] != null
          ? map['contraIndicacionVacunacion'] == 1
          : null,
      contraIndicacionCual: map['contraIndicacionCual'],
      reaccionBiologicosAnteriores: map['reaccionBiologicosAnteriores'] != null
          ? map['reaccionBiologicosAnteriores'] == 1
          : null,
      reaccionBiologicosCual: map['reaccionBiologicosCual'],
      // CONDICION USUARIA
      condicionUsuaria: map['condicionUsuaria'],
      fechaUltimaMenstruacion: map['fechaUltimaMenstruacion'] != null
          ? DateTime.parse(map['fechaUltimaMenstruacion'])
          : null,
      semanasGestacion: map['semanasGestacion'],
      fechaProbableParto: map['fechaProbableParto'] != null
          ? DateTime.parse(map['fechaProbableParto'])
          : null,
      cantidadEmbarazosPrevios: map['cantidadEmbarazosPrevios'],
      // HISTORICO DE ANTECEDENTES
      fechaRegistroAntecedente: map['fechaRegistroAntecedente'] != null
          ? DateTime.parse(map['fechaRegistroAntecedente'])
          : null,
      tipoAntecedente: map['tipoAntecedente'],
      descripcionAntecedente: map['descripcionAntecedente'],
      observacionesEspeciales: map['observacionesEspeciales'],
      // DATOS DE LA MADRE
      madreTipoIdentificacion: map['madreTipoIdentificacion'],
      madreNumeroIdentificacion: map['madreNumeroIdentificacion'],
      madrePrimerNombre: map['madrePrimerNombre'],
      madreSegundoNombre: map['madreSegundoNombre'],
      madrePrimerApellido: map['madrePrimerApellido'],
      madreSegundoApellido: map['madreSegundoApellido'],
      madreEmail: map['madreEmail'],
      madreTelefonoFijo: map['madreTelefonoFijo'],
      madreCelular: map['madreCelular'],
      madreRegimenAfiliacion: map['madreRegimenAfiliacion'],
      madrePertenenciaEtnica: map['madrePertenenciaEtnica'],
      madreDesplazado: map['madreDesplazado'] != null
          ? map['madreDesplazado'] == 1
          : null,
      // DATOS DEL CUIDADOR
      cuidadorTipoIdentificacion: map['cuidadorTipoIdentificacion'],
      cuidadorNumeroIdentificacion: map['cuidadorNumeroIdentificacion'],
      cuidadorPrimerNombre: map['cuidadorPrimerNombre'],
      cuidadorSegundoNombre: map['cuidadorSegundoNombre'],
      cuidadorPrimerApellido: map['cuidadorPrimerApellido'],
      cuidadorSegundoApellido: map['cuidadorSegundoApellido'],
      cuidadorParentesco: map['cuidadorParentesco'],
      cuidadorEmail: map['cuidadorEmail'],
      cuidadorTelefonoFijo: map['cuidadorTelefonoFijo'],
      cuidadorCelular: map['cuidadorCelular'],
      // ESQUEMA DE VACUNACION
      tipoCarnet: map['tipoCarnet'],
      covidDosis: map['covidDosis'],
      covidLaboratorio: map['covidLaboratorio'],
      covidLote: map['covidLote'],
      covidJeringa: map['covidJeringa'],
      covidLoteJeringa: map['covidLoteJeringa'],
      covidLoteDiluyente: map['covidLoteDiluyente'],
      bcgDosis: map['bcgDosis'],
      bcgLote: map['bcgLote'],
      bcgJeringa: map['bcgJeringa'],
      bcgLoteJeringa: map['bcgLoteJeringa'],
      bcgLoteDiluyente: map['bcgLoteDiluyente'],
      bcgObservacion: map['bcgObservacion'],
      hepatitisBDosis: map['hepatitisBDosis'],
      hepatitisBLote: map['hepatitisBLote'],
      hepatitisBJeringa: map['hepatitisBJeringa'],
      hepatitisBLoteJeringa: map['hepatitisBLoteJeringa'],
      hepatitisBObservacion: map['hepatitisBObservacion'],
      polioInactivadoDosis: map['polioInactivadoDosis'],
      polioInactivadoLote: map['polioInactivadoLote'],
      polioInactivadoJeringa: map['polioInactivadoJeringa'],
      polioInactivadoLoteJeringa: map['polioInactivadoLoteJeringa'],
      polioInactivadoObservacion: map['polioInactivadoObservacion'],
      polioOralDosis: map['polioOralDosis'],
      polioOralLote: map['polioOralLote'],
      polioOralGotero: map['polioOralGotero'],
      pentavalenteDosis: map['pentavalenteDosis'],
      pentavalenteLote: map['pentavalenteLote'],
      pentavalenteJeringa: map['pentavalenteJeringa'],
      pentavalenteLoteJeringa: map['pentavalenteLoteJeringa'],
      pentavalenteObservacion: map['pentavalenteObservacion'],
      hexavalenteDosis: map['hexavalenteDosis'],
      hexavalenteLote: map['hexavalenteLote'],
      hexavalenteJeringa: map['hexavalenteJeringa'],
      hexavalenteLoteJeringa: map['hexavalenteLoteJeringa'],
      dptDosis: map['dptDosis'],
      dptLote: map['dptLote'],
      dptJeringa: map['dptJeringa'],
      dptLoteJeringa: map['dptLoteJeringa'],
      dtpaPediatricoDosis: map['dtpaPediatricoDosis'],
      dtpaPediatricoLote: map['dtpaPediatricoLote'],
      dtpaPediatricoJeringa: map['dtpaPediatricoJeringa'],
      dtpaPediatricoLoteJeringa: map['dtpaPediatricoLoteJeringa'],
      tdPediatricoDosis: map['tdPediatricoDosis'],
      tdPediatricoLote: map['tdPediatricoLote'],
      tdPediatricoJeringa: map['tdPediatricoJeringa'],
      tdPediatricoLoteJeringa: map['tdPediatricoLoteJeringa'],
      rotavirusDosis: map['rotavirusDosis'],
      rotavirusLote: map['rotavirusLote'],
      neumococoTipo: map['neumococoTipo'],
      neumococoDosis: map['neumococoDosis'],
      neumococoLote: map['neumococoLote'],
      neumococoJeringa: map['neumococoJeringa'],
      neumococoLoteJeringa: map['neumococoLoteJeringa'],
      srptDosis: map['srptDosis'],
      srptLote: map['srptLote'],
      srptJeringa: map['srptJeringa'],
      srptLoteJeringa: map['srptLoteJeringa'],
      srptLoteDiluyente: map['srptLoteDiluyente'],
      srMultidosisDosis: map['srMultidosisDosis'],
      srMultidosisLote: map['srMultidosisLote'],
      srMultidosisJeringa: map['srMultidosisJeringa'],
      srMultidosisLoteJeringa: map['srMultidosisLoteJeringa'],
      srMultidosisLoteDiluyente: map['srMultidosisLoteDiluyente'],
      fiebreAmarillaDosis: map['fiebreAmarillaDosis'],
      fiebreAmarillaLote: map['fiebreAmarillaLote'],
      fiebreAmarillaJeringa: map['fiebreAmarillaJeringa'],
      fiebreAmarillaLoteJeringa: map['fiebreAmarillaLoteJeringa'],
      fiebreAmarillaLoteDiluyente: map['fiebreAmarillaLoteDiluyente'],
      hepatitisAPediatricaDosis: map['hepatitisAPediatricaDosis'],
      hepatitisAPediatricaLote: map['hepatitisAPediatricaLote'],
      hepatitisAPediatricaJeringa: map['hepatitisAPediatricaJeringa'],
      hepatitisAPediatricaLoteJeringa: map['hepatitisAPediatricaLoteJeringa'],
      varicelaDosis: map['varicelaDosis'],
      varicelaLote: map['varicelaLote'],
      varicelaJeringa: map['varicelaJeringa'],
      varicelaLoteJeringa: map['varicelaLoteJeringa'],
      varicelaLoteDiluyente: map['varicelaLoteDiluyente'],
      tdAdultoDosis: map['tdAdultoDosis'],
      tdAdultoLote: map['tdAdultoLote'],
      tdAdultoJeringa: map['tdAdultoJeringa'],
      tdAdultoLoteJeringa: map['tdAdultoLoteJeringa'],
      dtpaAdultoDosis: map['dtpaAdultoDosis'],
      dtpaAdultoLote: map['dtpaAdultoLote'],
      dtpaAdultoJeringa: map['dtpaAdultoJeringa'],
      dtpaAdultoLoteJeringa: map['dtpaAdultoLoteJeringa'],
      influenzaDosis: map['influenzaDosis'],
      influenzaLote: map['influenzaLote'],
      influenzaJeringa: map['influenzaJeringa'],
      influenzaLoteJeringa: map['influenzaLoteJeringa'],
      influenzaObservacion: map['influenzaObservacion'],
      vphDosis: map['vphDosis'],
      vphLote: map['vphLote'],
      vphJeringa: map['vphJeringa'],
      vphLoteJeringa: map['vphLoteJeringa'],
      antirrabicaVacunaDosis: map['antirrabicaVacunaDosis'],
      antirrabicaVacunaLote: map['antirrabicaVacunaLote'],
      antirrabicaVacunaJeringa: map['antirrabicaVacunaJeringa'],
      antirrabicaVacunaLoteJeringa: map['antirrabicaVacunaLoteJeringa'],
      antirrabicaVacunaLoteDiluyente: map['antirrabicaVacunaLoteDiluyente'],
      antirrabicaVacunaObservacion: map['antirrabicaVacunaObservacion'],
      antirrabicaSueroNumFrascos: map['antirrabicaSueroNumFrascos'],
      antirrabicaSueroLote: map['antirrabicaSueroLote'],
      hepatitisBInmunoglobulinaNumFrascos:
          map['hepatitisBInmunoglobulinaNumFrascos'],
      hepatitisBInmunoglobulinaLote: map['hepatitisBInmunoglobulinaLote'],
      hepatitisBInmunoglobulinaJeringa: map['hepatitisBInmunoglobulinaJeringa'],
      hepatitisBInmunoglobulinaLoteJeringa:
          map['hepatitisBInmunoglobulinaLoteJeringa'],
      hepatitisBInmunoglobulinaObservacion:
          map['hepatitisBInmunoglobulinaObservacion'],
      inmunoglobulinaAntitetanicaNumFrascos:
          map['inmunoglobulinaAntitetanicaNumFrascos'],
      inmunoglobulinaAntitetanicaLote: map['inmunoglobulinaAntitetanicaLote'],
      inmunoglobulinaAntitetanicaJeringa:
          map['inmunoglobulinaAntitetanicaJeringa'],
      inmunoglobulinaAntitetanicaLoteJeringa:
          map['inmunoglobulinaAntitetanicaLoteJeringa'],
      antitoxinaTetanicaNumFrascos: map['antitoxinaTetanicaNumFrascos'],
      antitoxinaTetanicaLote: map['antitoxinaTetanicaLote'],
      antitoxinaTetanicaJeringa: map['antitoxinaTetanicaJeringa'],
      antitoxinaTetanicaLoteJeringa: map['antitoxinaTetanicaLoteJeringa'],
      meningococoDosis: map['meningococoDosis'],
      meningococoLote: map['meningococoLote'],
      meningococoJeringa: map['meningococoJeringa'],
      meningococoLoteJeringa: map['meningococoLoteJeringa'],
      meningococoLoteDiluyente: map['meningococoLoteDiluyente'],
      // Metadatos
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      nurseId: map['nurseId'],
    );
  }

  // Obtener nombre completo del paciente
  String get nombreCompleto {
    final nombre = [
      primerNombre,
      segundoNombre,
      primerApellido,
      segundoApellido,
    ].where((n) => n != null && n.isNotEmpty).join(' ');
    return nombre;
  }

  @override
  String toString() {
    return 'VaccinationRecordModel{id: $id, paciente: $nombreCompleto, fecha: $fechaAtencion}';
  }
}
