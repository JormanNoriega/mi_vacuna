import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  const PasswordField({Key? key, this.controller, this.label, this.hintText})
    : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? 'Contraseña',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: !visible,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '••••••••',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  visible = !visible;
                });
              },
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
