import 'package:flutter/material.dart';
import 'package:mi_vacuna/app/services/license_service.dart';
import 'package:mi_vacuna/app/theme/colors.dart';

class LicenseScreen extends StatefulWidget {
  final VoidCallback onLicenseVerified;

  const LicenseScreen({super.key, required this.onLicenseVerified});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _licenseService = LicenseService();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  Future<void> _verifyPassword() async {
    _clearError();

    final password = _passwordController.text;

    if (password.isEmpty) {
      _showError('Ingresa la contraseña');
      return;
    }

    setState(() => _isLoading = true);

    // Simular pequeño delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Verificar que la contraseña sea correcta usando el service
    if (_licenseService.verifyPassword(password)) {
      // Desbloquear la app
      await _licenseService.unlock();
      if (mounted) {
        widget.onLicenseVerified();
      }
    } else {
      _showError('Contraseña incorrecta');
      _passwordController.clear();
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  void _clearError() {
    setState(() => _errorMessage = null);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 48),

                /// ICONO
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// TITULO
                const Text(
                  'Desbloquear Aplicación',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ingresa la contraseña para acceder a la aplicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: textSecondary),
                  ),
                ),

                const SizedBox(height: 32),

                /// CAMPO DE CONTRASEÑA
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _verifyPassword(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    hintStyle: const TextStyle(color: textHint),
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    filled: true,
                    fillColor: inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: inputFocusBorder, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: errorColor, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// MENSAJE DE ERROR
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.1),
                      border: Border.all(color: errorColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: errorColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_errorMessage != null) const SizedBox(height: 24),

                /// BOTÓN DESBLOQUEAR
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _verifyPassword,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.lock_open),
                    label: Text(
                      _isLoading ? 'Desbloqueando...' : 'Desbloquear',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
