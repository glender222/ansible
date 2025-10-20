# Ansible Provisioning con Galaxy Roles

## 📋 Descripción

Proyecto de automatización con Ansible que utiliza roles de Galaxy Community para:
- ✅ Aprovisionamiento de servidores
- ✅ Gestión de usuarios
- ✅ Configuración de servicios

## 🎯 Objetivos Cumplidos

1. **Rol de Aprovisionamiento**: `geerlingguy.nginx`
2. **Rol de Gestión de Usuarios**: `robertdebock.users`
3. **Rol de Procesos y Servicios**: `robertdebock.service`

## 📦 Requisitos

- Ansible 2.9+
- Python 3.8+
- pip y virtualenv

## 🚀 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/glender222/ansible-proyecto.git
cd ansible-proyecto

# Crear virtualenv
python3 -m venv venv
source venv/bin/activate

# Instalar Ansible
pip install ansible

# Descargar roles de Galaxy
ansible-galaxy install -r requirements.yml
```

## ▶️ Uso

Ejecutar el playbook principal:

```bash
ansible-playbook -i inventory.ini site.yml -v -K
```

## 📂 Estructura del Proyecto

```
ansible-proyecto/
├── requirements.yml          # Roles de Galaxy a descargar
├── inventory.ini             # Inventario de hosts
├── site.yml                  # Playbook principal
├── provision_vms.yml         # Playbook para vCenter
├── group_vars/               # Variables por grupo
├── host_vars/                # Variables por host
└── roles/                    # Roles locales (si los hay)
```

## 📊 Resultados

Nginx Status: ✅ active (running)
Usuarios: ✅ Configurados
Servicios: ✅ Activos

## 👨‍💻 Autor

glender222

## 📄 Licencia

MIT
