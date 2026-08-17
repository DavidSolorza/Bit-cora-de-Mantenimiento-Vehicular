import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart';
import 'features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/application/usecases/get_dashboard_summary_usecase.dart';
import 'features/dashboard/application/bloc/dashboard_bloc.dart';
import 'features/dashboard/infrastructure/presentation/pages/dashboard_page.dart';

import 'features/mantenimiento/infrastructure/datasources/mantenimiento_local_datasource.dart';
import 'features/mantenimiento/infrastructure/repositories/mantenimiento_repository_impl.dart';
import 'features/mantenimiento/application/usecases/get_historial_mantenimientos_usecase.dart';
import 'features/mantenimiento/application/usecases/agregar_registro_mantenimiento_usecase.dart';
import 'features/mantenimiento/application/bloc/mantenimiento_historial_bloc.dart';

import 'features/combustible/application/bloc/fuel_predictive_bloc.dart';
import 'features/combustible/application/bloc/fuel_predictive_event.dart';

import 'features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/iniciar_sesion_con_google_usecase.dart';
import 'features/auth/domain/usecases/obtener_sesion_local_usecase.dart';
import 'features/auth/domain/usecases/cerrar_sesion_usecase.dart';
import 'features/auth/application/bloc/auth_bloc.dart';
import 'features/auth/application/bloc/auth_event.dart';
import 'features/auth/application/bloc/auth_state.dart';
import 'features/auth/infrastructure/presentation/pages/login_page.dart';

import 'core/services/notification_service.dart';
import 'core/config/currency_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Error al inicializar servicio de notificaciones: $e');
  }
  try {
    await CurrencyManager.init();
  } catch (e) {
    debugPrint('Error al inicializar gestor de moneda: $e');
  }

  // Inyección de dependencias para Dashboard
  final dashboardLocalDS = DashboardLocalDataSourceImpl();
  final dashboardRemoteDS = DashboardRemoteDataSourceImpl();
  final dashboardRepo = DashboardRepositoryImpl(
    localDataSource: dashboardLocalDS,
    remoteDataSource: dashboardRemoteDS,
  );
  final getDashboardSummaryUseCase = GetDashboardSummaryUseCase(dashboardRepo);

  // Inyección de dependencias para Mantenimiento & Bitácora
  final mantenimientoLocalDS = MantenimientoLocalDataSourceImpl();
  final mantenimientoRepo = MantenimientoRepositoryImpl(localDataSource: mantenimientoLocalDS);
  final getHistorialUseCase = GetHistorialMantenimientosUseCase(mantenimientoRepo);
  final agregarRegistroUseCase = AgregarRegistroMantenimientoUseCase(mantenimientoRepo);

  // Inyección de dependencias para Autenticación
  final authRepo = AuthRepositoryImpl();
  final iniciarSesionConGoogleUseCase = IniciarSesionConGoogleUseCase(authRepo);
  final obtenerSesionLocalUseCase = ObtenerSesionLocalUseCase(authRepo);
  final cerrarSesionUseCase = CerrarSesionUseCase(authRepo);

  runApp(
    BitacoraStepwayApp(
      getDashboardSummaryUseCase: getDashboardSummaryUseCase,
      getHistorialUseCase: getHistorialUseCase,
      agregarRegistroUseCase: agregarRegistroUseCase,
      iniciarSesionConGoogleUseCase: iniciarSesionConGoogleUseCase,
      obtenerSesionLocalUseCase: obtenerSesionLocalUseCase,
      cerrarSesionUseCase: cerrarSesionUseCase,
    ),
  );
}

class BitacoraStepwayApp extends StatelessWidget {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetHistorialMantenimientosUseCase getHistorialUseCase;
  final AgregarRegistroMantenimientoUseCase agregarRegistroUseCase;
  final IniciarSesionConGoogleUseCase iniciarSesionConGoogleUseCase;
  final ObtenerSesionLocalUseCase obtenerSesionLocalUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;

  const BitacoraStepwayApp({
    super.key,
    required this.getDashboardSummaryUseCase,
    required this.getHistorialUseCase,
    required this.agregarRegistroUseCase,
    required this.iniciarSesionConGoogleUseCase,
    required this.obtenerSesionLocalUseCase,
    required this.cerrarSesionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            iniciarSesionConGoogleUseCase: iniciarSesionConGoogleUseCase,
            obtenerSesionLocalUseCase: obtenerSesionLocalUseCase,
            cerrarSesionUseCase: cerrarSesionUseCase,
          )..add(const VerificarSesionInicialEvent()),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(
            getDashboardSummaryUseCase: getDashboardSummaryUseCase,
          ),
        ),
        BlocProvider(
          create: (context) => MantenimientoHistorialBloc(
            getHistorialUseCase: getHistorialUseCase,
            agregarRegistroUseCase: agregarRegistroUseCase,
          ),
        ),
        BlocProvider(
          create: (context) => FuelPredictiveBloc()
            ..add(const EvaluarAutonomiaEvent(nivelCombustibleRatio: 0.75)),
        ),
      ],
      child: MaterialApp(
        title: 'Bitácora Stepway Fleet Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Manrope',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            surfaceContainerLow: AppColors.background,
            surface: AppColors.cardWhite,
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return const DashboardPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
