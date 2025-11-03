# 🚀 MÓDULO 4: PROVISIONING Y CONFIGURACIÓN DE VMs

## 📋 **¿QUÉ HACE ESTE MÓDULO?**

Provisiona y configura automáticamente VMs Linux **que ya tienen SO instalado** utilizando perfiles predefinidos.

**NO crea VMs nuevas** (para eso usa `create_vm_complete.yml` por separado).

---

## 🎯 **PERFILES DISPONIBLES**

### **1. web_server** 🌐
Servidor web con Nginx listo para producción.

**Instala:**
- Nginx
- Certbot (SSL/HTTPS)
- Configuración básica de seguridad

**Puertos abiertos:** 80, 443

**Uso ideal:** Sitios web, APIs REST, reverse proxy

---

### **2. docker_host** 🐳
Host completo para ejecutar contenedores Docker.

**Instala:**
- Docker Engine
- Docker Compose
- Agrega usuario a grupo docker

**Puertos:** Los que configures en tus contenedores

**Uso ideal:** Microservicios, aplicaciones containerizadas

---

### **3. database_server** 🗄️
Servidor de base de datos PostgreSQL.

**Instala:**
- PostgreSQL
- Cliente psql
- Python psycopg2

**Puerto:** 5432

**Uso ideal:** Bases de datos relacionales

---

### **4. development** 💻
Ambiente de desarrollo completo.

**Instala:**
- Python 3 + pip + venv
- Node.js + npm
- Java JDK + Maven
- Herramientas globales (yarn, typescript, nodemon)

**Uso ideal:** Estaciones de desarrollo, CI/CD

---

### **5. monitoring** 📊
Stack de monitoreo con Prometheus y Grafana.

**Instala:**
- Prometheus
- Grafana

**Puertos:** 9090 (Prometheus), 3000 (Grafana)

**Uso ideal:** Monitoreo de infraestructura

---

### **6. minimal** ⚡
Solo software base, sin servicios adicionales.

**Instala:**
- git, curl, wget, vim, htop, tree, etc.

**Uso ideal:** Servidores simples, plantillas base

---

## 📦 **SOFTWARE BASE (en TODOS los perfiles)**

```yaml
- git
- curl
- wget
- vim
- nano
- htop
- tree
- unzip
- net-tools
- build-essential
```

---

## 🚀 **CÓMO USAR**

### **Paso 1: Configura tus VMs en el inventory**

Edita `inventory/staging.ini`:

```ini
[vms_linux]
mi-vm-01 ansible_host=192.168.100.10 ansible_user=admin vm_profile=web_server
mi-vm-02 ansible_host=192.168.100.11 ansible_user=admin vm_profile=docker_host
mi-vm-03 ansible_host=192.168.100.12 ansible_user=admin vm_profile=database_server
```

O usa el archivo de variables `inventory/group_vars/provisioning.yml`:

```yaml
vms_to_provision:
  - name: mi-vm-01
    ip: 192.168.100.10
    profile: web_server
    ansible_user: admin
    
  - name: mi-vm-02
    ip: 192.168.100.11
    profile: docker_host
    ansible_user: admin
```

### **Paso 2: Ejecuta el playbook**

```bash
# Activar venv
cd /home/glender/ansible-proyecto
source venv/bin/activate

# Provisionar TODAS las VMs Linux
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini

# Provisionar solo UNA VM
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini \
  --limit linuxmint-vm-02

# Provisionar sin generar reporte
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini \
  --skip-tags report
```

---

## 📊 **REPORTES**

El módulo genera reportes automáticos en: `reports/provisioning/`

Contiene:
- ✅ Información de cada VM
- 📦 Software instalado
- 🔧 Servicios configurados
- 💻 Recursos (CPU, RAM, Disco)
- 🌐 Configuración de red
- 📈 Estadísticas generales

---

## ⚙️ **OPCIONES AVANZADAS**

### **Cambiar comportamiento**

Edita `inventory/group_vars/provisioning.yml`:

```yaml
provisioning_settings:
  reboot_if_required: false     # No reiniciar automáticamente
  generate_report: true         # Generar reporte
  verify_services: true         # Verificar servicios
  cleanup_after: true           # Limpiar archivos temporales

provisioning_security:
  update_system: true           # Actualizar paquetes
  enable_firewall: true         # Configurar firewall
```

### **Crear perfil personalizado**

Edita `inventory/group_vars/provisioning.yml`:

```yaml
provisioning_profiles:
  mi_perfil_custom:
    description: "Mi configuración personalizada"
    packages:
      - apache2
      - php
      - mysql-server
    services:
      - name: apache2
        state: started
        enabled: yes
    ports:
      - 80
      - 3306
```

Luego crea `roles/provisioning/tasks/profiles/mi_perfil_custom.yml` con las tareas.

---

## 🔧 **VERIFICACIÓN**

### **Verificar que funcionó:**

```bash
# Para web_server:
curl http://192.168.100.10
# Deberías ver una página de bienvenida

# Para docker_host:
ssh prueba1@192.168.100.10 "docker --version"

# Para database_server:
ssh prueba1@192.168.100.10 "sudo systemctl status postgresql"
```

---

## 🔥 **FIREWALL**

El módulo configura UFW automáticamente según el perfil:

```bash
# Ver estado del firewall
ssh prueba1@192.168.100.10 "sudo ufw status"

# Resultado esperado:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       Anywhere
# 80/tcp                     ALLOW       Anywhere  (web_server)
# 443/tcp                    ALLOW       Anywhere  (web_server)
```

---

## 📝 **EJEMPLOS PRÁCTICOS**

### **Ejemplo 1: Servidor web simple**

```bash
# 1. Agregar VM al inventory
echo "web-01 ansible_host=192.168.100.20 ansible_user=admin vm_profile=web_server" >> inventory/staging.ini

# 2. Provisionar
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini \
  --limit web-01

# 3. Verificar
curl http://192.168.100.20
```

### **Ejemplo 2: Cluster Docker**

```yaml
# En provisioning.yml
vms_to_provision:
  - name: docker-node-01
    ip: 192.168.100.21
    profile: docker_host
  - name: docker-node-02
    ip: 192.168.100.22
    profile: docker_host
  - name: docker-node-03
    ip: 192.168.100.23
    profile: docker_host
```

```bash
ansible-playbook playbooks/provisioning_management.yml -i inventory/staging.ini
```

---

## ❓ **TROUBLESHOOTING**

### **Error: "Unable to connect"**
- Verifica que la VM esté encendida
- Verifica SSH: `ssh usuario@IP`
- Verifica que tengas la clave SSH configurada

### **Error: "Package not found"**
```bash
# Actualizar cache de APT manualmente
ssh usuario@IP "sudo apt update"
```

### **Error: "Permission denied"**
- Asegúrate que el usuario tenga permisos sudo
- Verifica en la VM: `sudo whoami` (debe retornar "root")

### **Servicio no arranca**
```bash
# Ver logs del servicio
ssh usuario@IP "sudo journalctl -u nombre_servicio -n 50"
```

---

## 🔗 **INTEGRACIÓN CON OTROS MÓDULOS**

Este módulo trabaja bien con:

- **Módulo 1 (Usuarios):** Provisiona después de crear usuarios
- **Módulo 2 (Seguridad):** Aplica seguridad antes de provisionar
- **Módulo 3 (Automatización):** Programa tareas después de provisionar

**Orden recomendado:**
1. Módulo 2 (Seguridad)
2. Módulo 1 (Usuarios)
3. **Módulo 4 (Provisioning)** ← Tú estás aquí
4. Módulo 3 (Automatización)

---

## 📚 **ARCHIVOS DEL MÓDULO**

```
ansible-proyecto/
├── playbooks/
│   └── provisioning_management.yml      # Playbook principal
├── roles/
│   └── provisioning/
│       ├── tasks/
│       │   ├── main.yml                 # Tareas principales
│       │   ├── check_requirements.yml   # Verificar recursos
│       │   ├── configure_firewall.yml   # Configurar UFW
│       │   ├── verify_services.yml      # Verificar servicios
│       │   ├── cleanup.yml              # Limpieza
│       │   └── profiles/                # Perfiles
│       │       ├── web_server.yml
│       │       ├── docker_host.yml
│       │       ├── database_server.yml
│       │       ├── development.yml
│       │       └── monitoring.yml
│       ├── templates/
│       │   ├── nginx_default.j2         # Configuración Nginx
│       │   └── provisioning_report.txt.j2
│       ├── handlers/
│       │   └── main.yml
│       └── defaults/
│           └── main.yml
├── inventory/
│   └── group_vars/
│       └── provisioning.yml             # Variables del módulo
└── reports/
    └── provisioning/                    # Reportes generados
```

---

## ✅ **CHECKLIST DE PROVISIONING**

- [ ] VM creada y con SO instalado
- [ ] SSH configurado con clave pública
- [ ] Usuario con permisos sudo
- [ ] VM agregada al inventory con `vm_profile`
- [ ] Ejecutar playbook
- [ ] Verificar servicios
- [ ] Revisar reporte
- [ ] Probar funcionalidad (curl, docker, etc.)

---

**¡Listo!** Tu VM está provisionada y lista para usar. 🎉
