import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?>? onChanged;

  const DropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFDBDFE6)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          icon: const Icon(Icons.expand_more),
          menuMaxHeight: 300,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
