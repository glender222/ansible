#!/bin/bash
# 🔐 Script para inicializar Vault con credenciales de vCenter

set -e

VAULT_ADDR="http://127.0.0.1:35013"
VAULT_TOKEN="root-token"

echo "🔐 Configurando Vault para Ansible..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Esperar a que Vault esté listo
echo "⏳ Esperando a que Vault esté listo..."
for i in {1..30}; do
    if curl -s $VAULT_ADDR/v1/sys/health > /dev/null 2>&1; then
        echo "✅ Vault está listo!"
        break
    fi
    echo "   Intento $i/30..."
    sleep 2
done

# Habilitar el motor KV v2
echo ""
echo "📦 Habilitando motor de secretos KV v2..."
curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"type":"kv-v2"}' \
    $VAULT_ADDR/v1/sys/mounts/secret 2>/dev/null || echo "   (puede que ya esté habilitado)"

# Guardar credenciales de vCenter
echo ""
echo "💾 Guardando credenciales de vCenter en Vault..."
curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{
        "data": {
            "hostname": "168.121.48.254",
            "port": "10107",
            "username": "root",
            "password": "qwe123$",
            "validate_certs": "false",
            "esxi_hostname_fqdn": "localhost.lim.upeu.edu.pe",
            "datastore": "datastore1",
            "datacenter": "ha-datacenter",
            "default_portgroup": "VM Network",
            "timeout": "300",
            "state_change_timeout": "180"
        }
    }' \
    $VAULT_ADDR/v1/secret/data/vcenter

echo ""
echo "🔍 Verificando secretos guardados..."
curl -s \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    $VAULT_ADDR/v1/secret/data/vcenter | jq -r '.data.data' 2>/dev/null || echo "   Secretos guardados (necesitas jq para verlos)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Vault configurado exitosamente!"
echo ""
echo "📋 Información de acceso:"
echo "   URL: $VAULT_ADDR"
echo "   Token: $VAULT_TOKEN"
echo "   UI: http://127.0.0.1:35013/ui"
echo ""
echo "🧪 Probar con:"
echo "   ansible-playbook test_vault_integration.yml -i inventory/localhost.ini"
