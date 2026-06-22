# Deploy a Cloud Run

## Autenticación: Local vs Cloud Run

El middleware (`routes/_middleware.dart`) se adapta automáticamente al entorno:

| Entorno | Detección | Credenciales |
|---|---|---|
| **Local** | `GOOGLE_APPLICATION_CREDENTIALS` existe en `.env` | Usa `Credential.fromServiceAccount(File)` con el `service-account.json` local |
| **Cloud Run** | La variable NO existe | Usa `Credential.fromApplicationDefaultCredentials()` — detecta la cuenta de servicio asignada al servicio Cloud Run |

`PROJECT_ID` se busca primero en `.env`, luego en variables de entorno del sistema.

## Variables de entorno requeridas en Cloud Run

| Variable | Valor |
|---|---|
| `PROJECT_ID` | `catalogo-virtual-app` |

No se necesita `GOOGLE_APPLICATION_CREDENTIALS` ni `service-account.json`. La cuenta de servicio del Cloud Run se configura desde la consola de GCP y debe tener los roles:
- `Cloud Datastore User` (Firestore)
- `Storage Object Admin` (Cloud Storage)

## Datos en Firestore

El bot lee la configuración multi-tenant desde la colección `whatsapp_settings` en Firestore. Cada documento debe contener:

```
businessId (id del documento)
├── phoneId: "900387823150921"
├── apiToken: "EAAWn8..."
├── verifyToken: "97937849"
├── aiApiKey: "sk-ant-api03..."
├── brandName: "Mi Negocio"
├── catalogUrl: "https://..."
├── businessType: "restaurante"
├── toneStyle: "profesional"
└── botName: "Boty"
```

## Dockerfile

El `Dockerfile` actual:
- Construye el binario con `dart compile exe`
- Usa `debian:stable-slim` como runtime (trae `ca-certificates` para HTTPS)
- NO incluye secrets ni archivos de configuración
- Expone puerto `8081` (Cloud Run lo sobreescribe con `PORT=8080` automáticamente)

## Deploy desde Cloud Console

1. Ve a https://console.cloud.google.com/run
2. Crea servicio → "Implementar desde un repositorio"
3. Conecta GitHub `Andzzio/boty_frog_whatsapp` (branch `main`)
4. Dockerfile se detecta automáticamente
5. Puerto: `8081`
6. Variables: `PROJECT_ID=catalogo-virtual-app`
7. Cuenta de servicio con roles Firestore + Storage
8. Permitir invocaciones no autenticadas

## Webhook de WhatsApp

Una vez deployado, en el Meta Developer Dashboard configura el webhook como:
- URL: `https://<nombre>-<hash>.uc.r.appspot.com/webhook`
- Token de verificación: el `verifyToken` que tengas en Firestore
