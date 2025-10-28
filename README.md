# 🔐 Ansible vCenter - HashiCorp Vault

Gestión de infraestructura VMware con credenciales centralizadas en Vault.

---

## 🎯 Flujo de Trabajo

```
1. Levantar Vault          →  2. Vault restaura secretos  →  3. Ejecutar playbooks
   ./vault-manager.sh start    (automático)                    ansible-playbook...
```

**Primera vez:**
```bash
./vault-manager.sh start     # Levanta Vault e inicializa secretos
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini
```

**Uso diario:**
```bash
./vault-manager.sh start                    # Levantar (restaura secretos)
ansible-playbook create_vm_esxi.yml ...     # Trabajar
./vault-manager.sh stop                     # Detener (guarda secretos)
```

---

## ⚡ Comandos Rápidos

### Operaciones con Vault

```bash
# Iniciar Vault
./vault-manager.sh start

# Detener Vault
./vault-manager.sh stop

# Ver estado
./vault-manager.sh status

# Ver logs
./vault-manager.sh logs
```

### Operaciones con VMs

```bash
# Listar todas las VMs
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini

# Crear VM con nombre por defecto (ubuntu-24-test)
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini

# Crear VM personalizada
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=web-server-01"

# Crear VM con ISO específica
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=debian-test iso_path=[datastore1] debian-12.iso"
```

### Verificación

```bash
# Ver secretos en Vault
curl --header "X-Vault-Token: root-token" http://127.0.0.1:35013/v1/secret/data/vcenter

# Verificar sintaxis de playbook
ansible-playbook main.yml --syntax-check

# Modo dry-run (simular sin ejecutar)
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini --check
```

---

## 🚀 Inicio Rápido

### 1. Levantar Vault (con persistencia automática)

```bash
./vault-manager.sh start
```

**⚠️ Si es la primera vez o no hay secretos:**
```bash
./vault/scripts/persist-secrets.sh init
```

Verificar que los secretos estén guardados:
```bash
curl --header "X-Vault-Token: root-token" http://127.0.0.1:35013/v1/secret/data/vcenter
```

```bash
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini
```

---

## 📋 Comandos

### Listar VMs

```bash
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini
```

### Crear VM

```bash
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini
```

### Crear VM personalizada

```bash
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=mi-servidor"
```

---

## 🔍 Cómo Funciona

```
1. Playbook ejecuta
2. Obtiene credenciales desde Vault (lookup)
3. Conecta a vCenter con credenciales
4. Ejecuta operaciones (listar, crear VMs, etc.)
```

**Flujo:**
```
Ansible → Vault (http://127.0.0.1:35013) → Credenciales → vCenter
```

---

## 🔐 Gestión de Vault

### Ver secretos

```bash
curl --header "X-Vault-Token: root-token" http://127.0.0.1:35013/v1/secret/data/vcenter | jq
```

### Cambiar password

```bash
curl --header "X-Vault-Token: root-token" --request POST \
  --data '{"data":{"password":"nuevo_password"}}' \
  http://127.0.0.1:35013/v1/secret/data/vcenter
```

### Vault UI

- URL: http://127.0.0.1:35013/ui
- Token: `root-token`

---

## 📖 Ejemplos de Uso Completo

### Ejemplo 1: Listar VMs del día a día

```bash
# 1. Asegurar que Vault esté corriendo
./vault-manager.sh status

# 2. Si no está corriendo, levantarlo
./vault-manager.sh start

# 3. Listar VMs
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini
```

### Ejemplo 2: Crear una nueva VM

```bash
# VM con nombre por defecto
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini

# VM con nombre específico
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=app-server"
```

### Ejemplo 3: Ciclo completo de trabajo

```bash
# Mañana
./vault-manager.sh start
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini

# Trabajar
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=vm-01"
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -e "vm_name=vm-02"

# Tarde
./vault-manager.sh stop
```

---

## 🔧 Troubleshooting

**Vault no responde:**
```bash
./vault-manager.sh status
./vault-manager.sh restart
```

**Credenciales perdidas:**
```bash
# Verificar backup
ls -lh vault/data/secrets-backup.json

# Restaurar
./vault-manager.sh start
```

**Error al crear VM:**
```bash
# Ver logs con verbose
ansible-playbook create_vm_esxi.yml -i inventory/localhost.ini -vv
```

---

## 🐳 Docker

```bash
# Levantar Vault (recomendado)
./vault-manager.sh start

# Detener Vault (guarda secretos automáticamente)
./vault-manager.sh stop

# Reiniciar Vault
./vault-manager.sh restart

# Ver logs
./vault-manager.sh logs

# Ver estado
./vault-manager.sh status

# Backup manual
./vault-manager.sh backup
```

**⚠️ Importante:** Usa siempre `./vault-manager.sh` en lugar de `docker-compose` directamente para mantener la persistencia de secretos.

---

## 📂 Estructura

```
main.yml              # Router principal
create_vm_esxi.yml    # Crear VMs
playbooks/
  └── vmware.yml      # Gestión vCenter
inventory/
  └── group_vars/
      └── all.yml     # Variables (sin passwords)
```

---

## ⚙️ Configuración

**Vault:** Puerto 8200  
**Token:** root-token  
**Path:** secret/data/vcenter  

**vCenter:** 168.121.48.254:10107  
**Datastore:** datastore1  

---

## 🆘 Problemas

**Vault no funciona:**
```bash
docker ps | grep vault
docker logs vault_dev
```

**Credenciales incorrectas:**
```bash
curl --header "X-Vault-Token: root-token" \
  http://127.0.0.1:35013/v1/secret/data/vcenter | jq .data.data
```

---

**Versión:** 2.0.0 (100% Vault)  
**Docs:** VAULT_INTEGRATION.md
