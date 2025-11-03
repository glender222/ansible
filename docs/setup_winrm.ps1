---
# ════════════════════════════════════════════════════════════════════════════
# 📜 SCRIPT DE CONFIGURACIÓN WINRM PARA WINDOWS
# ════════════════════════════════════════════════════════════════════════════
# Ejecutar este script en PowerShell (como Administrador) en la VM Windows
# para habilitarla para Ansible
# ════════════════════════════════════════════════════════════════════════════

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🪟 CONFIGURANDO WINRM PARA ANSIBLE" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Habilitar WinRM
Write-Host "1️⃣ Habilitando WinRM..." -ForegroundColor Yellow
winrm quickconfig -q -force

# Paso 2: Configurar autenticación básica
Write-Host "2️⃣ Configurando autenticación básica..." -ForegroundColor Yellow
winrm set winrm/config/service/auth '@{Basic="true"}'

# Paso 3: Permitir tráfico sin encriptar (solo para dev/staging)
Write-Host "3️⃣ Permitiendo tráfico sin encriptar..." -ForegroundColor Yellow
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Paso 4: Configurar TrustedHosts
Write-Host "4️⃣ Configurando TrustedHosts..." -ForegroundColor Yellow
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Paso 5: Configurar reglas de firewall
Write-Host "5️⃣ Configurando firewall..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

# Paso 6: Verificar configuración
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Verificando configuración WinRM:" -ForegroundColor Cyan
winrm enumerate winrm/config/listener
Write-Host ""

# Paso 7: Mostrar IP
Write-Host "IP de esta máquina:" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*"} | Select-Object IPAddress, InterfaceAlias | Format-Table

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📝 PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Anota la IP de arriba" -ForegroundColor White
Write-Host "2. En ansible-proyecto/inventory/group_vars/windows.yml" -ForegroundColor White
Write-Host "   descomenta las variables" -ForegroundColor White
Write-Host "3. Ejecuta el playbook de provisioning con --tags windows" -ForegroundColor White
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Green
