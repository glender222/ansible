# 🚀 Ansible Automation - vCenter Edition

Proyecto profesional de automatización con Ansible usando **Main Router Pattern**, **Galaxy Roles** (versiones validadas) y mejores prácticas de infraestructura.

## 📋 Descripción

Automatización centralizada de infraestructura vCenter con gestión de VMs Linux/Windows, provisioning, monitoreo y seguridad.

## 🎯 Características

- ✅ **Main Router** - Punto de entrada centralizado (`main.yml`)
- ✅ **Múltiples Modos** - vmware, provisioning, monitoring, maintenance, backup, security
- ✅ **Galaxy Roles** - Reutilización de roles probados de la comunidad (versiones validadas)
- ✅ **Vault Encriptado** - Credenciales seguras
- ✅ **Multi-ambiente** - Production, Staging, Development
- ✅ **Inventarios Dinámicos** - Descubrimiento automático de VMs
- ✅ **Roles Personalizados** - vcenter-api, vm-deployment, disk-management, user-management, service-management, monitoring

## 🏗️ Estructura

## 📁 Estructura del proyecto

```bash
ansible-proyecto/
├── main.yml                        # 🚀 Playbook principal (router de ejecución)
├── ansible.cfg                     # ⚙️ Configuración general de Ansible
├── requirements.yml                # 📦 Roles y collections (versiones validadas)
├── vault.yml                       # 🔒 Secretos cifrados (Ansible Vault)
│
├── inventory/
│   ├── production.ini              # 🌐 Inventario de servidores de producción
│   ├── staging.ini                 # 🧪 Inventario de entornos de prueba
│   └── group_vars/
│       ├── all.yml                 # Variables globales
│       ├── vms_linux.yml           # Variables específicas para VMs Linux
│       └── vms_windows.yml         # Variables específicas para VMs Windows
│
├── playbooks/
│   ├── vmware.yml                  # ☁️ Gestión de ESXi / vCenter (community.vmware)
│   ├── provisioning.yml            # ⚙️ Aprovisionamiento inicial de VMs
│   ├── monitoring.yml              # 📊 Monitoreo y alertas
│   ├── maintenance.yml             # 🧰 Tareas de mantenimiento programado
│   ├── backup.yml                  # 💾 Respaldos automáticos
│   └── security.yml                # 🔐 Endurecimiento de seguridad (geerlingguy.security)
│
├── roles/                          # Roles personalizados + Galaxy
│   ├── vcenter-api/                # API interna para integración con vCenter
│   ├── vm-deployment/              # Despliegue automatizado de máquinas virtuales
│   ├── disk-management/            # Gestión de discos y particiones (linux-system-roles.storage)
│   ├── user-management/            # Usuarios y permisos (robertdebock.users)
│   ├── service-management/         # Servicios y demonios (robertdebock.service)
│   └── monitoring/                 # Integración con Prometheus / Grafana
│
├── templates/                      # 🧩 Plantillas Jinja2 (.j2)
├── files/                          # 📂 Archivos estáticos o binarios
└── docs/                           # 🧾 Documentación y diagramas de arquitectura