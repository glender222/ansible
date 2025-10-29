# 📋 GUÍA DE TESTING - MÓDULO 1: GESTIÓN DE USUARIOS

## 🎯 Objetivo

Validar que el Módulo 1 funciona correctamente antes de usar en producción.

---

## ✅ PRE-REQUISITOS

Antes de ejecutar el testing:

```bash
# 1. Vault debe estar corriendo
./vault-manager.sh status

# Si no está corriendo:
./vault-manager.sh start

# 2. Verificar que tienes VMs Linux en vCenter
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini

# 3. Asegurarte que los roles Galaxy están instalados
ansible-galaxy install -r requirements.yml
```

---

## 🧪 FASE 1: VALIDACIÓN DE SINTAXIS

### 1.1 Verificar sintaxis del playbook

```bash
cd /home/glender/ansible-proyecto

# Verificar sintaxis
ansible-playbook playbooks/user_management.yml --syntax-check
```

**Resultado esperado:** `playbook: playbooks/user_management.yml`

---

## 🧪 FASE 2: DRY-RUN (Simulación sin cambios)

```bash
ansible-playbook main.yml -e "mode=users" -i inventory/staging.ini --check
```

---

## 🧪 FASE 3: EJECUCIÓN EN STAGING

```bash
ansible-playbook main.yml -e "mode=users" -i inventory/staging.ini
```

---

## ✅ CHECKLIST DE VALIDACIÓN COMPLETA

- [ ] ✅ Sintaxis válida
- [ ] ✅ Dry-run sin errores críticos
- [ ] ✅ Ejecución exitosa en staging
- [ ] ✅ Usuarios creados correctamente
- [ ] ✅ Grupos creados correctamente
- [ ] ✅ Sudo configurado
- [ ] ✅ Reportes generados

Ver documentación completa en: roles/user_audit/README.md
