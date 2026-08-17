# 📐 Arquitectura de Software: Bitácora Stepway Fleet Manager

## 1. Resumen Ejecutivo
El sistema **Bitácora Stepway Fleet Manager** está diseñado bajo los principios de **Clean Architecture** (Arquitectura Limpia) y el patrón **BLoC (Business Logic Component)** en Flutter. La aplicación garantiza una estrategia **Offline-First**, permitiendo a los usuarios registrar mantenimientos, consultar métricas del vehículo (kilometraje, nivel de combustible, alertas de salud) sin depender de conectividad a internet inmediata, sincronizando los datos con la API REST nativa cuando la red esté disponible.

---

## 2. Diagrama de Componentes Macro (Mermaid)

```mermaid
graph TD
    subgraph Presentation Layer [Presentation Layer (Flutter UI & BLoC)]
        DashboardPage["DashboardPage (View)"]
        Components["Components (HeaderCard, StatMetricCard, PriorityServiceCard, HealthCard)"]
        MantenimientoBloc["MantenimientoBloc"]
        AuthBloc["AuthBloc (Session State)"]
    end

    subgraph Domain Layer [Domain Layer (Core Business Rules)]
        GetDashboardDataUseCase["GetDashboardDataUseCase"]
        IniciarSesionConGoogleUseCase["IniciarSesionConGoogleUseCase"]
        VehiculoEntity["Vehiculo (Entity)"]
        MantenimientoEntity["Mantenimiento (Entity)"]
        AuthTokenEntity["AuthToken (Entity)"]
        IMantenimientoRepository["IMantenimientoRepository"]
        IAuthRepository["IAuthRepository"]
    end

    subgraph Data Layer [Data Layer (Infrastructure & Data Sources)]
        AuthRepositoryImpl["AuthRepositoryImpl"]
        GoogleAuthDataSource["GoogleAuthDataSource (Google OAuth2 SDK)"]
        AuthRemoteDataSource["AuthRemoteDataSource (Native REST Client)"]
        AuthLocalDataSource["AuthLocalDataSource (SQLite Secure Storage)"]
    end

    DashboardPage --> Components
    DashboardPage --> MantenimientoBloc
    DashboardPage --> AuthBloc
    AuthBloc --> IniciarSesionConGoogleUseCase
    IniciarSesionConGoogleUseCase --> IAuthRepository
    IAuthRepository <|.. AuthRepositoryImpl
    AuthRepositoryImpl --> GoogleAuthDataSource
    AuthRepositoryImpl --> AuthRemoteDataSource
    AuthRepositoryImpl --> AuthLocalDataSource
    AuthLocalDataSource --> SQLiteDB["Local SQLite DB (Offline-First Session)"]
    AuthRemoteDataSource --> CloudflareTunnel["Cloudflare Tunnel (https://dashboard.servidor.blog)"]
    CloudflareTunnel --> BackendOwn["Backend Propio (Node.js/Python + PostgreSQL)"]
```

---

## 3. Diagrama de Secuencia: Flujo de Autenticación Google Sign-In (Cero BaaS)

```mermaid
sequenceDiagram
    autonumber
    actor User as Usuario (Driver)
    participant FlutterApp as App Flutter (BLoC)
    participant GoogleOAuth as Google Auth Servers
    participant LocalSQLite as Local SQLite DB
    participant Cloudflare as Cloudflare Tunnel
    participant Backend as Backend Propio (Node/Python)
    participant Postgres as PostgreSQL DB

    User->>FlutterApp: Toca "Iniciar Sesión con Google"
    FlutterApp->>GoogleOAuth: Request Google Sign-In (OAuth 2.0)
    GoogleOAuth-->>FlutterApp: Retorna Google `id_token` (JWT firmado por Google)
    FlutterApp->>Cloudflare: POST /api/auth/google { "id_token": "..." }
    Cloudflare->>Backend: Forward request a Servidor Propio
    Backend->>GoogleOAuth: Consulta claves públicas (Certs) de Google
    GoogleOAuth-->>Backend: Devuelve Google Public Keys
    Backend->>Backend: Verificación Criptográfica de la firma del `id_token` y `aud`
    Backend->>Postgres: SELECT / INSERT user en tabla `users`
    Postgres-->>Backend: User registrado / actualizado
    Backend->>Backend: Genera JWT Propio de Sesión (HS256 / RS256)
    Backend-->>Cloudflare: 200 OK { access_token: "JWT_PROPIO", user: {...} }
    Cloudflare-->>FlutterApp: Recibe JWT y datos de perfil
    FlutterApp->>LocalSQLite: Guarda JWT en `active_sessions` (Offline Persistence)
    FlutterApp-->>User: Navega a Dashboard (Sesión Activa)

    Note over User, LocalSQLite: Modo Offline Posterior (Reinicie la App Sin Internet)
    User->>FlutterApp: Abre la aplicación sin conexión
    FlutterApp->>LocalSQLite: SELECT token FROM active_sessions
    LocalSQLite-->>FlutterApp: Retorna JWT local persistido
    FlutterApp-->>User: Acceso directo al Dashboard sin pedir login nuevamente
```

---

## 4. Registro de Decisiones de Arquitectura (ADR)

### ADR 001: Adopción de Clean Architecture + BLoC
* **Estado:** Aprobado
* **Decisión:** Dividir el proyecto en tres capas fundamentales (`domain`, `data`, `presentation`) y utilizar `flutter_bloc` para la gestión de estados reactivos.

### ADR 002: Estrategia Offline-First con Cliente HTTP Nativo
* **Estado:** Aprobado
* **Decisión:** `MantenimientoRepositoryImpl` y `AuthRepositoryImpl` consultarán primero la persistencia local en SQLite.

### ADR 003: Autenticación Cero BaaS (No Firebase, No Supabase)
* **Estado:** Aprobado
* **Contexto:** Se requiere independencia total de proveedores comerciales BaaS (Firebase Auth / Supabase Auth).
* **Decisión:** Obtener el `idToken` en la app móvil y validarlo criptográficamente en nuestro backend propio exponiéndolo a través del Túnel de Cloudflare (`https://dashboard.servidor.blog`). El servidor verifica las firmas de Google con las claves públicas de Google y emite un JWT firmado por nuestro servidor.
* **Consecuencias:** Control absoluto de la seguridad, privacidad de datos y cero costos por usuario activo.
