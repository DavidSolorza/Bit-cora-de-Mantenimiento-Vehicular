import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';

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
        color: AppColors.cardWhite.withOpacity(0.98),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.08),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 0: Home
              Expanded(
                child: InkWell(
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
                          fontSize: 12,
                          fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                          color: selectedIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 60), // Espacio libre para el FAB central (+)

              // Tab 1: Bitácora
              Expanded(
                child: InkWell(
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
                          fontSize: 12,
                          fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                          color: selectedIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Central FAB (+) Button para Nuevo Registro
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
