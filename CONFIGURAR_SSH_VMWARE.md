# 🔧 CONFIGURAR SSH PARA ANSIBLE EN VMs DE VMWARE

## 📋 SITUACIÓN

Tienes VMs en VMware/vCenter y necesitas que Ansible pueda conectarse a ellas por SSH.

---

## ✅ PASO 1: OBTENER IPs DE TUS VMs

### Opción A: Desde vCenter Web UI

1. Abrir navegador: `https://168.121.48.254:10107`
2. Login con tu usuario
3. Ir a "Virtual Machines"
4. Ver columna "IP Address" de cada VM

### Opción B: Desde la consola de la VM

1. Abrir consola de la VM en vCenter
2. Hacer login en la VM
3. Ejecutar:
   ```bash
   ip addr show
   # O
   hostname -I
   ```

### Opción C: Desde tu terminal (si conoces el hostname)

```bash
ping ubuntu-24-test-prueba2-glender.lim.upeu.edu.pe
```

---

## ✅ PASO 2: VERIFICAR SSH ESTÁ ACTIVO EN LAS VMs

### 2.1 Desde la consola de la VM:

```bash
# Ver si SSH está corriendo
sudo systemctl status ssh
# O en algunas distros:
sudo systemctl status sshd

# Si no está activo, iniciarlo:
sudo systemctl start ssh
sudo systemctl enable ssh
```

### 2.2 Verificar puerto SSH:

```bash
# Debe mostrar puerto 22
sudo netstat -tulpn | grep :22
# O
sudo ss -tlnp | grep :22
```

---

## ✅ PASO 3: PROBAR CONEXIÓN SSH DESDE TU MÁQUINA

### 3.1 Desde tu terminal local:

```bash
# Reemplaza IP_DE_LA_VM con la IP real
ssh root@IP_DE_LA_VM

# Ejemplo:
ssh root@192.168.1.100
```

### 3.2 Si te pide password:
- Ingresa el password de root de la VM
- Deberías poder conectarte

### 3.3 Si da error "Connection refused":
```bash
# La VM no tiene SSH activo, ve al Paso 2
```

### 3.4 Si da error "Permission denied":
```bash
# El usuario no tiene permisos o password incorrecto
# Verifica el usuario y password
```

---

## ✅ PASO 4: CONFIGURAR INVENTARIO DE ANSIBLE

### 4.1 Editar archivo de inventario:

```bash
cd /home/glender/ansible-proyecto
nano inventory/staging.ini
```

### 4.2 Agregar tus VMs con sus IPs:

```ini
# 📋 INVENTARIO STAGING

[all:vars]
ansible_python_interpreter=/usr/bin/python3
environment=staging
ansible_user=root
ansible_ssh_pass=TU_PASSWORD_AQUI    # Solo para testing, mejor usar SSH keys

[localhost]
localhost ansible_connection=local

[vcenter]
vcenter_server ansible_host=localhost ansible_connection=local

[vms_linux]
# Agrega tus VMs aquí con sus IPs reales
ubuntu-test ansible_host=192.168.1.100 ansible_user=root
gateway-api ansible_host=192.168.1.101 ansible_user=root
faas-server ansible_host=192.168.1.102 ansible_user=root

[vms_windows]
# VMs Windows (si tienes)

[vms_all:children]
vms_linux
vms_windows
```

### 4.3 IMPORTANTE - Opciones de autenticación:

**OPCIÓN A: Con password (rápido para testing):**
```ini
[vms_linux]
vm1 ansible_host=192.168.1.100 ansible_user=root ansible_ssh_pass=tu_password
```

**OPCIÓN B: Con SSH key (MÁS SEGURO - RECOMENDADO):**
```ini
[vms_linux]
vm1 ansible_host=192.168.1.100 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**OPCIÓN C: Usar vars globales:**
```ini
[all:vars]
ansible_user=root
ansible_ssh_pass=tu_password_global

[vms_linux]
vm1 ansible_host=192.168.1.100
vm2 ansible_host=192.168.1.101
```

---

## ✅ PASO 5: PROBAR CONEXIÓN CON ANSIBLE

### 5.1 Test de conectividad (ping):

```bash
cd /home/glender/ansible-proyecto

# Probar una VM específica
ansible ubuntu-test -i inventory/staging.ini -m ping

# Probar todas las VMs Linux
ansible vms_linux -i inventory/staging.ini -m ping

# Probar TODAS las VMs
ansible all -i inventory/staging.ini -m ping
```

### 5.2 Resultado esperado:

```
ubuntu-test | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 5.3 Si falla:

```bash
# Probar con verbosidad para ver el error
ansible ubuntu-test -i inventory/staging.ini -m ping -vvv
```

---

## ✅ PASO 6: EJECUTAR MÓDULO 1 EN LAS VMs

### 6.1 Dry-run primero (simular):

```bash
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini --check
```

### 6.2 Ejecutar en UNA VM específica:

```bash
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini --limit ubuntu-test
```

### 6.3 Ejecutar en TODAS las VMs Linux:

```bash
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini
```

---

## 🔐 OPCIÓN AVANZADA: CONFIGURAR SSH KEYS (RECOMENDADO)

### ¿Por qué usar SSH keys?
- ✅ Más seguro que passwords
- ✅ No necesitas escribir password cada vez
- ✅ Mejor práctica en producción

### Paso a paso:

#### 1. Generar SSH key en tu máquina (si no tienes):

```bash
ssh-keygen -t rsa -b 4096 -C "ansible@tu-dominio.com"
# Presiona Enter para todo (ubicación por defecto)
```

#### 2. Copiar la key a cada VM:

```bash
# Método automático
ssh-copy-id root@IP_DE_LA_VM

# Ejemplo:
ssh-copy-id root@192.168.1.100
```

#### 3. Probar conexión sin password:

```bash
ssh root@192.168.1.100
# Debería conectar SIN pedir password
```

#### 4. Actualizar inventario para usar keys:

```ini
[vms_linux]
ubuntu-test ansible_host=192.168.1.100 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

#### 5. Eliminar passwords del inventario (más seguro):

```ini
[vms_linux]
ubuntu-test ansible_host=192.168.1.100 ansible_user=root
# Ya no necesitas ansible_ssh_pass
```

---

## 🐛 TROUBLESHOOTING

### Error: "Connection refused"
```bash
# SSH no está activo en la VM
# Solución: Entrar a la consola de la VM y ejecutar:
sudo systemctl start ssh
sudo systemctl enable ssh
```

### Error: "Permission denied (publickey,password)"
```bash
# Opción 1: Password incorrecto
# Verifica el password de root

# Opción 2: SSH no acepta password authentication
# En la VM, editar /etc/ssh/sshd_config:
sudo nano /etc/ssh/sshd_config
# Buscar y cambiar:
PasswordAuthentication yes
# Reiniciar SSH:
sudo systemctl restart ssh
```

### Error: "Host key verification failed"
```bash
# Eliminar la entrada antigua:
ssh-keygen -R IP_DE_LA_VM

# O desactivar verificación (solo para testing):
# Agregar a ansible.cfg:
[defaults]
host_key_checking = False
```

### Error: "No route to host"
```bash
# Problema de red
# Verificar:
ping IP_DE_LA_VM

# Si no hace ping, verifica:
# - Firewall de la VM
# - Red de VMware (misma red que tu máquina)
# - Gateway configurado en la VM
```

---

## 📝 EJEMPLO COMPLETO PASO A PASO

### Escenario: Tienes ubuntu-24-test-prueba2-glender con IP 192.168.1.150

#### 1. Verificar IP:
```bash
# Desde consola de la VM
ip addr show
```

#### 2. Probar SSH:
```bash
ssh root@192.168.1.150
# Ingresar password cuando pida
```

#### 3. Editar inventario:
```bash
nano inventory/staging.ini
```

Agregar:
```ini
[vms_linux]
ubuntu-glender ansible_host=192.168.1.150 ansible_user=root ansible_ssh_pass=tu_password
```

#### 4. Test con Ansible:
```bash
ansible ubuntu-glender -i inventory/staging.ini -m ping
```

#### 5. Ejecutar Módulo 1:
```bash
ansible-playbook playbooks/user_management.yml -i inventory/staging.ini --limit ubuntu-glender
```

#### 6. Ver reporte:
```bash
cat reports/users/user_audit_ubuntu-glender_*.txt
```

---

## ✅ CHECKLIST FINAL

Antes de ejecutar el Módulo 1:

- [ ] Conozco las IPs de mis VMs
- [ ] Puedo hacer SSH a las VMs desde terminal
- [ ] He configurado inventory/staging.ini
- [ ] `ansible all -i inventory/staging.ini -m ping` funciona
- [ ] He probado con dry-run: `--check`
- [ ] Estoy listo para ejecutar

---

**Fecha:** 2024-10-29  
**Versión:** 1.0  
**Estado:** ✅ Guía completa

