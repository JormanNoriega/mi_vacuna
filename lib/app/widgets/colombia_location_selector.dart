import 'package:flutter/material.dart';
import '../services/colombia_location_service.dart';
import '../models/location_models.dart';
import 'form_fields.dart';

class ColombiaLocationSelector extends StatefulWidget {
  final TextEditingController departamentoController;
  final TextEditingController municipioController;
  final String? departamentoInicial;
  final String? municipioInicial;
  final Function(String departamento, String municipio)? onLocationChanged;

  const ColombiaLocationSelector({
    Key? key,
    required this.departamentoController,
    required this.municipioController,
    this.departamentoInicial,
    this.municipioInicial,
    this.onLocationChanged,
  }) : super(key: key);

  @override
  State<ColombiaLocationSelector> createState() =>
      _ColombiaLocationSelectorState();
}

class _ColombiaLocationSelectorState extends State<ColombiaLocationSelector> {
  final ColombiaLocationService _locationService =
      ColombiaLocationService.instance;

  List<Departamento> _departamentos = [];
  List<String> _municipios = [];

  String? _selectedDepartamento;
  String? _selectedMunicipio;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  Future<void> _loadDepartamentos() async {
    setState(() => _isLoading = true);

    final departamentos = await _locationService.getDepartamentos();

    setState(() {
      _departamentos = departamentos;
      _isLoading = false;

      // Si hay valores iniciales, cargarlos
      if (widget.departamentoInicial != null &&
          widget.departamentoInicial!.isNotEmpty) {
        _selectedDepartamento = widget.departamentoInicial;
        widget.departamentoController.text = widget.departamentoInicial!;
        _loadMunicipios(widget.departamentoInicial!);

        if (widget.municipioInicial != null &&
            widget.municipioInicial!.isNotEmpty) {
          _selectedMunicipio = widget.municipioInicial;
          widget.municipioController.text = widget.municipioInicial!;
        }
      }
    });
  }

  void _loadMunicipios(String departamento) {
    final ciudades = _locationService.getCiudadesByDepartamento(departamento);
    setState(() {
      _municipios = ciudades;
      // Limpiar municipio seleccionado si no está en la nueva lista
      if (_selectedMunicipio != null &&
          !_municipios.contains(_selectedMunicipio)) {
        _selectedMunicipio = null;
        widget.municipioController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // Dropdown de Departamento
        FormFields.buildDropdownField(
          label: 'Departamento de Residencia',
          value: _selectedDepartamento ?? '',
          items: _departamentos.map((dept) => dept.nombre).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDepartamento = newValue;
              _selectedMunicipio = null;

              widget.departamentoController.text = newValue ?? '';
              widget.municipioController.clear();

              if (newValue != null && newValue.isNotEmpty) {
                _loadMunicipios(newValue);
              } else {
                _municipios = [];
              }

              if (widget.onLocationChanged != null) {
                widget.onLocationChanged!(newValue ?? '', '');
              }
            });
          },
          required: true,
        ),

        // Dropdown de Municipio
        FormFields.buildDropdownField(
          label: 'Municipio de Residencia',
          value: _selectedMunicipio ?? '',
          items: _municipios,
          onChanged: (String? newValue) {
            if (_selectedDepartamento == null ||
                _selectedDepartamento!.isEmpty) {
              return;
            }
            setState(() {
              _selectedMunicipio = newValue;
              widget.municipioController.text = newValue ?? '';

              if (widget.onLocationChanged != null &&
                  _selectedDepartamento != null) {
                widget.onLocationChanged!(
                  _selectedDepartamento!,
                  newValue ?? '',
                );
              }
            });
          },
          required: true,
        ),
      ],
    );
  }
}
