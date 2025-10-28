#!/bin/bash
# 🔐 Gestor de Vault con persistencia automática

COMPOSE_FILE="docker-compose-vault.yml"
SCRIPT_DIR="vault/scripts"

case "$1" in
  start|up)
    echo "🚀 Levantando Vault..."
    docker-compose -f $COMPOSE_FILE up -d
    sleep 5
    echo "⏳ Esperando a Vault..."
    sleep 3
    echo "📥 Restaurando/Inicializando secretos..."
    ./$SCRIPT_DIR/persist-secrets.sh restore 2>/dev/null || ./$SCRIPT_DIR/persist-secrets.sh init
    echo "✅ Vault listo con secretos"
    ;;
  
  stop|down)
    echo "💾 Guardando secretos antes de detener..."
    ./$SCRIPT_DIR/persist-secrets.sh backup
    echo "🛑 Deteniendo Vault..."
    docker-compose -f $COMPOSE_FILE down
    echo "✅ Vault detenido (secretos guardados)"
    ;;
  
  restart)
    $0 stop
    sleep 2
    $0 start
    ;;
  
  backup)
    echo "💾 Guardando backup de secretos..."
    ./$SCRIPT_DIR/persist-secrets.sh backup
    ;;
  
  status)
    docker ps | grep vault || echo "❌ Vault no está corriendo"
    ;;
  
  logs)
    docker logs -f ansible_vault_dev
    ;;
  
  *)
    echo "Uso: $0 {start|stop|restart|backup|status|logs}"
    echo ""
    echo "  start   - Levantar Vault y restaurar secretos"
    echo "  stop    - Guardar secretos y detener Vault"
    echo "  restart - Reiniciar con persistencia"
    echo "  backup  - Hacer backup manual de secretos"
    echo "  status  - Ver estado de Vault"
    echo "  logs    - Ver logs de Vault"
    exit 1
    ;;
esac
