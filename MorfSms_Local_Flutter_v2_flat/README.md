# MorfSms Local

## Compilar APK
1. Instala Flutter estable.
2. Entra al proyecto.
3. Ejecuta:

```bash
flutter pub get
flutter build apk --release
```

## Package name actual
`com.codemorf.morfsmslocal`

## Qué hace
- Escanea QR del módulo Perfex.
- Se vincula por `pairing_token`.
- Heartbeat con estado online/offline.
- Consulta cola de SMS.
- Envía SMS por SIM.
- Sincroniza SMS entrantes.
