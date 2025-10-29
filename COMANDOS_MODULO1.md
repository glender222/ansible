# 📋 COMANDOS PARA USAR EL MÓDULO 1

## ✅ TESTING COMPLETADO

Se ha validado:
- ✅ Sintaxis correcta de todos los archivos
- ✅ Vault funcionando
- ✅ Roles Galaxy instalados
- ✅ 4 VMs Linux disponibles en vCenter
- ✅ Configuración de usuarios lista

---

## 🚀 COMANDOS PARA USAR EL MÓDULO 1

### 📌 COMANDO PRINCIPAL (Ejecución directa)

```bash
# Ejecutar en localhost (tu máquina)
ansible-playbook playbooks/user_management.yml -i inventory/localhost.ini

# Ejecutar en staging  
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini

# Ejecutar en production
ansible-playbook playbooks/user_management.yml -i inventory/production.ini
```

---

### 🧪 MODO DRY-RUN (Simular sin cambios)

```bash
# Simular ejecución sin hacer cambios reales
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini --check
```

---

### 🔍 CON VERBOSIDAD (Para debugging)

```bash
# Nivel 1 (básico)
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -v

# Nivel 2 (detallado)
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -vv

# Nivel 3 (muy detallado)
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -vvv
```

---

### 🎯 CON TAGS (Ejecutar solo partes específicas)

```bash
# Solo crear usuarios y grupos (sin reportes)
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -t users,groups

# Solo configurar sudo
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -t sudo

# Solo generar reportes de auditoría
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini -t audit,reports
```

---

### 📊 VER REPORTES GENERADOS

```bash
# Listar reportes
ls -lh reports/users/

# Ver último reporte
cat reports/users/user_audit_*.txt | tail -100

# Ver reporte específico
cat reports/users/user_audit_hostname_timestamp.txt
```

---

### ⚙️ PERSONALIZAR USUARIOS

Editar archivo de configuración:
```bash
nano inventory/group_vars/users.yml
```

O con tu editor favorito:
```bash
code inventory/group_vars/users.yml
vim inventory/group_vars/users.yml
```

---

### 🔄 FLUJO COMPLETO RECOMENDADO

```bash
# 1. Verificar sintaxis
ansible-playbook playbooks/user_management.yml --syntax-check

# 2. Modo dry-run (simular)
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini --check

# 3. Ejecutar en staging
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini

# 4. Ver reporte generado
ls -lh reports/users/
cat reports/users/user_audit_*.txt

# 5. Si todo OK, ejecutar en production
ansible-playbook playbooks/user_management.yml -i inventory/production.ini
```

---

## 🔧 CONFIGURAR INVENTARIO ANTES DE EJECUTAR

El playbook requiere que las VMs estén definidas en el inventario.

### Opción A: Editar inventory/staging.ini

```bash
nano inventory/staging.ini
```

Agregar tus VMs:
```ini
[vms_linux]
ubuntu-24-test-prueba2-glender ansible_host=IP_DE_LA_VM ansible_user=root
Machine01 ansible_host=IP_DE_LA_VM ansible_user=root
```

### Opción B: Usar dynamic inventory (avanzado)

Crear script para obtener VMs automáticamente desde vCenter.

---

## ⚠️ IMPORTANTE ANTES DE EJECUTAR

1. ✅ Asegúrate que Vault está corriendo:
   ```bash
   ./vault-manager.sh status
   ```

2. ✅ Verifica que puedes conectarte a las VMs por SSH:
   ```bash
   ssh root@IP_VM
   ```

3. ✅ Revisa la configuración de usuarios:
   ```bash
   cat inventory/group_vars/users.yml
   ```

4. ✅ Haz backup si es producción

---

## 🐛 TROUBLESHOOTING

### Error: "No such file or directory"
```bash
# Verificar que los archivos existen
ls -lh playbooks/user_management.yml
ls -lh inventory/group_vars/users.yml
```

### Error: "Connection refused"
```bash
# Verificar conectividad SSH
ansible all -i inventory/staging.ini -m ping
```

### Error: "Role not found"
```bash
# Reinstalar roles Galaxy
ansible-galaxy install -r requirements.yml --force
```

---

## 📖 DOCUMENTACIÓN ADICIONAL

- **README del rol:** `roles/user_audit/README.md`
- **Testing completo:** `TESTING_MODULE1.md`
- **Configuración:** `inventory/group_vars/users.yml`

---

## 🎯 EJEMPLO REAL DE USO

```bash
# 1. Levantar Vault
./vault-manager.sh start

# 2. Verificar VMs disponibles
ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini

# 3. Editar usuarios si necesitas
nano inventory/group_vars/users.yml

# 4. Ejecutar Módulo 1 en staging
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini

# 5. Ver reporte
cat reports/users/user_audit_*.txt

# 6. Detener Vault cuando termines
./vault-manager.sh stop
```

---

**Fecha de creación:** 2024-10-29
**Versión Módulo 1:** 1.0.0
**Estado:** ✅ Listo para usar

