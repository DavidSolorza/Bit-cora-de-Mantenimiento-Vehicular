# 📄 Especificación de API REST: Bitácora Stepway Fleet Manager

Este documento define la especificación técnica completa y exhaustiva del backend RESTful de la aplicación **Bitácora Stepway Fleet Manager**, cumpliendo con los estándares de comunicación HTTP nativos.

---

## 🌐 URL de Producción & Conexión

* **URL Pública (Cloudflare):** `https://dashboard.servidor.blog`
* **URL Local / Desarrollo:** `http://localhost:5000`
* **Ruta Base de Autenticación:** `/api/auth`
* **Ruta Base de Mantenimiento:** `/api/mantenimiento`

---

## 🔑 Autenticación & Headers Globales

Todas las peticiones enviadas al servidor backend requieren la inyección de la clave de autorización configurada:

* **Header:** `Authorization: Bearer <JWT_TOKEN>` (Inyectado automáticamente por `NativeHttpClient` cuando hay una sesión activa, con fallback a `Bearer core_backend_secret_key_2026` para peticiones iniciales/túneles).
* **Header alternativo:** `X-API-Key: core_backend_secret_key_2026`
* **Content-Type:** `application/json`
* **Accept:** `application/json`

---

## 🔐 Módulo de Autenticación (`/api/auth`)

### `POST /api/auth/google`
* **Descripción:** Recibe el `id_token` emitiendo por Google Sign-In desde la aplicación móvil. El backend verifica criptográficamente la firma del token con las claves públicas de Google, registra o actualiza el usuario en la base de datos PostgreSQL (`users`) y devuelve un JWT de sesión propio firmado por nuestro servidor.
* **Payload JSON de Entrada:**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFiY2RlZjEyMzQ1Njc4OTAiLCJ0eXAiOiJKV1QifQ..."
}
```

* **Respuesta de Éxito (`200 OK` / `201 Created`):**
```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDBjYzMxNWMtYWQ2Zi00NDllLThlMTYtNDhjNTU2NGJkYzI3IiwiZW1haWwiOiJ1c3VhcmlvQGV4YW1wbGUuY29tIiwiaWF0IjoxNzA4MDc2ODAwLCJleHAiOjE3MDg2ODE2MDB9...",
    "token_type": "Bearer",
    "expires_in": 604800,
    "user": {
      "id": "40cc315c-ad6f-449e-8e16-48c5564bdc27",
      "email": "usuario@example.com",
      "name": "Conductor Stepway",
      "picture": "https://lh3.googleusercontent.com/a/photo.jpg"
    }
  }
}
```

* **Respuesta de Error de Verificación (`401 Unauthorized`):**
```json
{
  "status": "error",
  "code": 401,
  "message": "Token de Google inválido, expirado o firma criptográfica no verificable con certs de Google."
}
```

---

## 🌐 Endpoints de Mantenimiento & Vehículos

### `GET /api/mantenimiento/dashboard`
* **Descripción:** Retorna el resumen consolidado de la flota: total de vehículos, costo acumulado de mantenimientos, alertas por kilometraje y salud de componentes.
* **Headers:** `Authorization: Bearer core_backend_secret_key_2026`
