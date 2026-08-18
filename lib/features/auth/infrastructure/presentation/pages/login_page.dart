import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/bloc/auth_event.dart';
import '../../../application/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Esferas decorativas de luz ambiental en tono claro/azul
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Anillo de Logotipo Animado con Opacidad y Deslizamiento
                    AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: AnimatedSlide(
                        offset: _visible ? Offset.zero : const Offset(0, -0.2),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icon/iconostepway.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.directions_car_rounded,
                                  size: 46,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título Principal Animado
                    AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedSlide(
                        offset: _visible ? Offset.zero : const Offset(0, -0.15),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        child: Column(
                          children: const [
                            Text(
                              'Bitácora Stepway',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gestión vehicular inteligente, control de combustible y diagnósticos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tarjeta Principal Limpia Animada
                    AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: AnimatedSlide(
                        offset: _visible ? Offset.zero : const Offset(0, 0.2),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Iniciar Sesión',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Selecciona una cuenta para continuar:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bloc Consumer para estado Auth
                              BlocConsumer<AuthBloc, AuthState>(
                                listener: (context, state) {
                                  if (state is UnauthenticatedState && state.mensajeError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.mensajeError!),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  if (state is AuthLoadingState) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      // Botón Google Principal
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context.read<AuthBloc>().add(
                                                  const SolicitarLoginConGoogleEvent(),
                                                );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF0F172A),
                                            elevation: 0,
                                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                               Container(
                                                 width: 24,
                                                 height: 24,
                                                 decoration: const BoxDecoration(
                                                   color: Color(0xFF4285F4),
                                                   shape: BoxShape.circle,
                                                 ),
                                                 alignment: Alignment.center,
                                                 child: const Text(
                                                   'G',
                                                   style: TextStyle(
                                                     color: Colors.white,
                                                     fontWeight: FontWeight.w900,
                                                     fontSize: 14,
                                                   ),
                                                 ),
                                               ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Continuar con Google',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Botón Invitado / Demo
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.read<AuthBloc>().add(
                                                  const SolicitarLoginConGoogleEvent(),
                                                );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2563EB),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(Icons.person_outline, size: 20),
                                          label: const Text(
                                            'Ingresar como Conductor Invitado',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Garantía de persistencia
                    AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 900),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.offline_pin_rounded,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Modo Offline-First • SQLite Local Activo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
