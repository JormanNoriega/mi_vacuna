import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isPrimary;

  const ActionCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isSmallScreen = size.width < 400;
    final effectiveIconColor = iconColor ?? const Color(0xFF135BEC);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 16 : 20)),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF135BEC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(color: const Color(0xFFE4E7EB), width: 1.5),
            boxShadow: [
              if (isPrimary)
                BoxShadow(
                  color: const Color(0xFF135BEC).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              if (!isPrimary)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono
              Container(
                padding: EdgeInsets.all(
                  isTablet ? 16 : (isSmallScreen ? 12 : 14),
                ),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withOpacity(0.2)
                      : effectiveIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : effectiveIconColor,
                  size: isTablet ? 36 : (isSmallScreen ? 28 : 32),
                ),
              ),
              SizedBox(height: isTablet ? 16 : (isSmallScreen ? 8 : 12)),
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 16 : (isSmallScreen ? 14 : 15),
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : const Color(0xFF111318),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : (isSmallScreen ? 11 : 12),
                    color: isPrimary
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xFF616F89),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
