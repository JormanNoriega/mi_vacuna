import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isSmallScreen = size.width < 400;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 12 : 16)),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : (isSmallScreen ? 10 : 12)),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isTablet ? 32 : (isSmallScreen ? 24 : 28),
            ),
          ),
          SizedBox(width: isTablet ? 16 : (isSmallScreen ? 10 : 12)),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Valor
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 36 : (isSmallScreen ? 24 : 28),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111318),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : (isSmallScreen ? 11 : 13),
                    color: const Color(0xFF616F89),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
