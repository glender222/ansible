#!/bin/bash
VAULT_ADDR="http://127.0.0.1:35013"
VAULT_TOKEN="root-token"
BACKUP_FILE="/home/glender/ansible-proyecto/vault/data/secrets-backup.json"

case "$1" in
  backup)
    echo "💾 Guardando secretos..."
    curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
      $VAULT_ADDR/v1/secret/data/vcenter > "$BACKUP_FILE"
    echo "✅ Secretos guardados"
    ;;
  
  restore)
    echo "📥 Restaurando secretos..."
    curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
      --request POST --data '{"type":"kv-v2"}' \
      $VAULT_ADDR/v1/sys/mounts/secret 2>/dev/null
    
    if [ -f "$BACKUP_FILE" ]; then
      PAYLOAD=$(python3 -c "import json; f=open('$BACKUP_FILE'); d=json.load(f); print(json.dumps({'data': d['data']['data']}))")
      curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
        --request POST --data "$PAYLOAD" \
        $VAULT_ADDR/v1/secret/data/vcenter > /dev/null
      echo "✅ Secretos restaurados"
    else
      echo "❌ No existe backup"
      exit 1
    fi
    ;;
  
  init)
    echo "🔐 Inicializando..."
    sleep 3
    curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
      --request POST --data '{"type":"kv-v2"}' \
      $VAULT_ADDR/v1/sys/mounts/secret 2>/dev/null
    curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
      --data '{"data":{"hostname":"168.121.48.254","port":"10107","username":"root","password":"qwe123$","validate_certs":"false","esxi_hostname_fqdn":"localhost.lim.upeu.edu.pe","datastore":"datastore1","datacenter":"ha-datacenter","default_portgroup":"VM Network","timeout":"300","state_change_timeout":"180"}}' \
      $VAULT_ADDR/v1/secret/data/vcenter > /dev/null
    echo "✅ Inicializado"
    ;;
  
  *) echo "Uso: $0 {backup|restore|init}"; exit 1;;
esac
