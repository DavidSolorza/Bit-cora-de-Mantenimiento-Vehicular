# 🗄️ Especificación y Script de Migración SQL (PostgreSQL & SQLite)

## 1. Sentencias SQL para Ejecutar en el Servidor (PostgreSQL - `proyecto_b`)

### 1.1. Tabla de Usuarios (`users`)
```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    google_id VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    picture TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
```

### 1.2. Columnas Predictivas de Combustible y Foto en `vehicles`
```sql
-- 1. Agregar columna para la foto del vehículo (Local o remota)
ALTER TABLE vehicles 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Agregar capacidad del tanque en litros (por defecto 50.0 L para Renault Sandero Stepway)
ALTER TABLE vehicles 
ADD COLUMN IF NOT EXISTS tank_capacity_liters NUMERIC(5, 2) DEFAULT 50.0 NOT NULL CHECK (tank_capacity_liters > 0);

-- 3. Agregar rendimiento promedio por litro (por defecto 12.5 km/L)
ALTER TABLE vehicles 
ADD COLUMN IF NOT EXISTS fuel_efficiency_km_l NUMERIC(5, 2) DEFAULT 12.5 NOT NULL CHECK (fuel_efficiency_km_l > 0);

-- 4. Agregar umbral de alerta de reserva en kilómetros (por defecto 40.0 km)
ALTER TABLE vehicles 
ADD COLUMN IF NOT EXISTS reserve_threshold_km NUMERIC(5, 2) DEFAULT 40.0 NOT NULL CHECK (reserve_threshold_km >= 0);
```

---

## 2. Script DDL SQL SQLite Local (`active_sessions`)

```sql
CREATE TABLE IF NOT EXISTS active_sessions (
    id TEXT PRIMARY KEY NOT NULL,
    jwt_token TEXT NOT NULL,
    refresh_token TEXT,
    user_id TEXT NOT NULL,
    user_email TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_picture TEXT,
    created_at TEXT NOT NULL
);
```

---

## 3. Diccionario de Datos Exhaustivo

| Tabla | Nombre de Columna | Tipo de Datos Exacto | Restricciones | Regla de Negocio / Descripción Detallada |
| :--- | :--- | :--- | :--- | :--- |
| `users` | `id` | `UUID` | `PRIMARY KEY, NOT NULL` | Identificador único del usuario en PostgreSQL. |
| `users` | `google_id` | `VARCHAR(255)` | `NOT NULL, UNIQUE` | Identificador `sub` de Google obtenido en el `id_token`. |
| `users` | `email` | `VARCHAR(255)` | `NOT NULL, UNIQUE` | Correo electrónico verificado por Google. |
| `users` | `name` | `VARCHAR(150)` | `NOT NULL` | Nombre completo del usuario. |
| `users` | `picture` | `TEXT` | `NULLABLE` | Foto de perfil de Google. |
| `active_sessions` | `jwt_token` | `TEXT` | `NOT NULL` | JWT emitido por nuestro backend propio para autenticación offline/online. |
