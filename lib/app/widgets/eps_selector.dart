import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../theme/colors.dart';

class EPSSelector extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final bool required;
  final Function(String)? onChanged;

  const EPSSelector({
    super.key,
    required this.controller,
    this.label = 'Aseguradora (EPS)',
    this.placeholder = 'Seleccione una EPS',
    this.required = false,
    this.onChanged,
  });

  @override
  State<EPSSelector> createState() => _EPSSelectorState();
}

class _EPSSelectorState extends State<EPSSelector> {
  // Lista completa de EPS de Colombia
  static const List<String> epsList = [
    'Coosalud EPS-S',
    'Nueva EPS',
    'Mutual SER EPS',
    'Salud MIA EPS',
    'Aliansalud EPS',
    'Salud Total EPS',
    'Sanitas EPS',
    'EPS Sura',
    'Famisanar EPS',
    'Servicio Occidental de Salud (SOS)',
    'Comfenalco Valle EPS',
    'Compensar EPS',
    'EPM EPS',
    'Fondo de Pasivo Social de Ferrocarriles Nacionales de Colombia',
    'Cajacopi Atlántico EPS',
    'Capresoca EPS',
    'Comfachocó EPS',
    'Comfaoriente EPS',
    'EPS Familiar de Colombia',
    'Asmet Salud EPS',
    'Emssanar E.S.S.',
    'Capital Salud EPS-S',
    'Savia Salud EPS',
    'Dusakawi EPSI',
    'Asociación Indígena del Cauca EPSI',
    'Anas Wayuu EPSI',
    'Mallamas EPSI',
    'Pijaos Salud EPSI',
    'Otros',
  ];

  late FocusNode _focusNode;
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Verificar si el valor actual es "Otros"
    _showCustomInput = widget.controller.text == 'Otros' || 
                      (!epsList.contains(widget.controller.text) && 
                       widget.controller.text.isNotEmpty);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Dropdown para seleccionar EPS
          DropdownButtonFormField2<String>(
            value: epsList.contains(widget.controller.text)
                ? widget.controller.text
                : (widget.controller.text.isEmpty ? null : 'Otros'),
            isExpanded: true,
            items: epsList.map((eps) {
              return DropdownMenuItem<String>(
                value: eps,
                child: Text(eps),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _showCustomInput = value == 'Otros';
                  if (value == 'Otros') {
                    widget.controller.clear();
                  } else {
                    widget.controller.text = value;
                  }
                });
                widget.onChanged?.call(value);
              }
            },
            decoration: InputDecoration(
              hintText: widget.placeholder,
              filled: true,
              fillColor: inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: widget.required
                ? (value) {
                    if (_showCustomInput && widget.controller.text.isEmpty) {
                      return 'Por favor ingrese la EPS';
                    }
                    if (!_showCustomInput && value == null) {
                      return 'Por favor seleccione una EPS';
                    }
                    return null;
                  }
                : null,
          ),

          // Campo de texto editable para "Otros"
          if (_showCustomInput) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Ingrese el nombre de la EPS',
                filled: true,
                fillColor: inputBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (value) {
                widget.onChanged?.call(value);
              },
              validator: widget.required
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre de la EPS';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
