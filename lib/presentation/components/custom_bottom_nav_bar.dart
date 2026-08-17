import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onAddTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón Home / Dashboard
              InkWell(
                onTap: () => onItemTapped(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: selectedIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        color: selectedIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Espacio central para el botón flotante
              // Botón Bitácora / Historial
              InkWell(
                onTap: () => onItemTapped(1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_edu,
                      color: selectedIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bitácora',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        color: selectedIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Botón Central Flotante para Añadir Registro
          Positioned(
            top: 8,
            child: FloatingActionButton(
              onPressed: onAddTapped,
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: AppColors.onPrimary, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
