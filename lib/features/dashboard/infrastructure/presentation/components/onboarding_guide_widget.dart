import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';

class OnboardingGuideWidget extends StatefulWidget {
  final String vehicleId;
  final VoidCallback onCompleted;
  const OnboardingGuideWidget({
    super.key,
    required this.vehicleId,
    required this.onCompleted,
  });

  @override
  State<OnboardingGuideWidget> createState() => _OnboardingGuideWidgetState();
}

class _OnboardingGuideWidgetState extends State<OnboardingGuideWidget> {
  final PageController _pageController = PageController();
  
  // Controladores de Texto para Formulario Inicial
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placaController = TextEditingController(text: 'BXY-492');
  final TextEditingController _marcaController = TextEditingController(text: 'Renault');
  final TextEditingController _modeloController = TextEditingController(text: 'Sandero Stepway');
  final TextEditingController _odometroController = TextEditingController(text: '45280');

  int _currentPage = 0;
  String? _errorText;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _odometroController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      final name = _nameController.text.trim();
      final placa = _placaController.text.trim();
      final marca = _marcaController.text.trim();
      final modelo = _modeloController.text.trim();
      final odometroText = _odometroController.text.trim();

      if (name.isEmpty) {
        setState(() {
          _errorText = 'Por favor, ingresa tu primer nombre';
        });
        return;
      }
      if (placa.isEmpty || odometroText.isEmpty || marca.isEmpty || modelo.isEmpty) {
        setState(() {
          _errorText = 'Por favor, completa todos los campos del vehículo';
        });
        return;
      }

      final int km = int.tryParse(odometroText) ?? 45280;
      final firstName = name.split(' ').first;

      // 1. Guardar apodo del conductor en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('driver_nickname', firstName);

      // 2. Persistir/Actualizar los datos del vehículo inicial en SQLite
      try {
        final db = await SqliteDatabaseHelper.instance.database;
        final res = await db.query('vehicles');
        if (res.isNotEmpty) {
          final targetId = res.first['id'] as String;
          await db.update(
            'vehicles',
            {
              'brand': marca,
              'model': modelo,
              'license_plate': placa,
              'current_odometer_km': km,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [targetId],
          );
        }
      } catch (e) {
        debugPrint('Error actualizando vehículo en onboarding: $e');
      }

      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 480, // Centrado y óptimo para tablets
          height: 600, // Altura incrementada para scroll cómodo en el formulario
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              )
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              children: [
                // Cabecera Premium
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.directions_car_filled_rounded, color: AppColors.onPrimary, size: 40),
                      SizedBox(height: 6),
                      Text(
                        'Registro de Configuración Inicial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildStep(
                        icon: Icons.auto_awesome,
                        title: 'Gestión Inteligente & Predictiva',
                        description:
                            'La aplicación Bitácora Stepway realiza un seguimiento continuo de tu vehículo. Su motor inteligente analiza el odómetro actual y calcula el nivel de combustible en tiempo real.\n\nSi tu autonomía es baja, la app te sugerirá gasolineras cercanas basándose en tu ubicación.',
                      ),
                      _buildStep(
                        icon: Icons.add_circle,
                        title: '¿Cómo ingresar tus datos?',
                        description:
                            'Es muy sencillo. Presiona el botón "+" central de la barra inferior de navegación en cualquier momento para agregar un Tanqueo de Gasolina, gastos de mantenimiento en talleres (taller), lavado del carro o seguros.\n\nLa bitácora calculará de inmediato la salud general del vehículo.',
                      ),
                      _buildFormStep(),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _nextPage,
                        child: Text(
                          _currentPage == 2 ? 'Comenzar' : 'Siguiente',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 54, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configura tu Ficha de Conductor y Vehículo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa los datos del carro de tu papá para configurar la bitácora.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 16),

          // Campo Nombre Conductor
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre del Conductor',
              hintText: 'Ej: Carlos',
              prefixIcon: const Icon(Icons.person, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          // Fila Marca y Modelo
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _marcaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: const Icon(Icons.directions_car, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _modeloController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila Placa y Kilometraje
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _placaController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: const Icon(Icons.badge, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _odometroController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kilometraje',
                    prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
