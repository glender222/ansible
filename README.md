# Ansible vCenter & Multi-OS Automation

Este proyecto utiliza Ansible para automatizar la gestión de una infraestructura de VMware vCenter, incluyendo el aprovisionamiento de máquinas virtuales, la configuración de usuarios, la seguridad, y más. Está diseñado para gestionar tanto sistemas operativos Linux (Mint) como Windows (10).

La automatización se basa en un `main.yml` que actúa como un enrutador, permitiendo ejecutar diferentes módulos de gestión de forma independiente. Los secretos, como las credenciales de vCenter, se gestionan de forma segura a través de HashiCorp Vault.

## 🚀 Requisitos Previos

Antes de empezar, asegúrate de tener instalado el siguiente software:

- **Python 3.x**
- **Docker** y **Docker Compose**
- **Tailscale** (o cualquier otra VPN que te dé acceso a la red de vCenter)

## ⚙️ Guía de Instalación

Sigue estos pasos para configurar tu entorno de desarrollo y dejarlo listo para ejecutar los playbooks.

### 1. Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd <NOMBRE_DEL_REPOSITORIO>
```

### 2. Configurar el Entorno Virtual de Python

Para evitar conflictos con las dependencias del sistema, usaremos un entorno virtual de Python.

```bash
# Crear el entorno virtual
python3 -m venv venv2

# Activar el entorno virtual (opcional, los scripts lo usan directamente)
# source venv2/bin/activate
```

### 3. Instalar Ansible y Dependencias

El proyecto utiliza `ansible` y varias colecciones de Ansible Galaxy.

```bash
# Instalar Ansible y dependencias de Python
venv2/bin/pip install ansible hvac passlib pyvmomi

# Instalar roles y colecciones de Ansible Galaxy
venv2/bin/ansible-galaxy install -r requirements.yml --force
```

### 4. Iniciar y Configurar Vault

Los secretos se gestionan con HashiCorp Vault, que se ejecuta en un contenedor de Docker.

```bash
# Iniciar el contenedor de Vault
./vault-manager.sh start
```

La primera vez que inicies Vault, necesitarás inicializar los secretos. **Asegúrate de tener tus credenciales de vCenter a mano.**

```bash
# Inicializar los secretos (solo la primera vez)
./vault/scripts/persist-secrets.sh init

# Sigue las instrucciones para introducir las credenciales de vCenter.
```

Para verificar que los secretos se han guardado correctamente, puedes ejecutar:

```bash
curl --header "X-Vault-Token: root-token" http://127.0.0.1:35013/v1/secret/data/vcenter
```

## Usage

Todos los playbooks se ejecutan a través del `main.yml`, utilizando la variable `mode` para seleccionar el módulo a ejecutar.

### Módulo 1: Gestión de Usuarios (`mode=users`)

Este módulo gestiona la creación de usuarios y grupos tanto en Linux como en Windows.

```bash
# Ejecutar el playbook de gestión de usuarios
venv2/bin/ansible-playbook main.yml -e "mode=users"
```

### Módulo 2: Seguridad y Firewall (`mode=security` y `mode=security_windows`)

Este módulo aplica configuraciones de seguridad a tus VMs.

```bash
# Aplicar hardening de seguridad en VMs Linux
venv2/bin/ansible-playbook main.yml -e "mode=security"

# Configurar el firewall en VMs Windows
venv2/bin/ansible-playbook main.yml -e "mode=security_windows"
```

### Módulo 3: Automatización (`mode=automation`)

Este módulo configura tareas de automatización, como actualizaciones automáticas y tareas programadas.

```bash
# Ejecutar el playbook de automatización
venv2/bin/ansible-playbook main.yml -e "mode=automation"
```

### Módulo 4: Aprovisionamiento de Software (`mode=provisioning`)

Este módulo instala software base en tus VMs.

```bash
# Aprovisionar software en VMs Linux y Windows
venv2/bin/ansible-playbook main.yml -e "mode=provisioning"
```

### Módulo 5: Procesos y Servicios (`mode=services`)

Este módulo gestiona y reporta el estado de los servicios.

```bash
# Ejecutar el playbook de gestión de servicios
venv2/bin/ansible-playbook main.yml -e "mode=services"
```

### Módulo 6: Almacenamiento (`mode=storage`)

Este módulo gestiona el almacenamiento y genera informes.

```bash
# Ejecutar el playbook de gestión de almacenamiento
venv2/bin/ansible-playbook main.yml -e "mode=storage"
```

### Cómo Crear Nuevas VMs con IP Estática (Método Cloud-init)

Este es el método recomendado y más robusto para desplegar nuevas máquinas. Permite clonar una VM y asignarle una IP estática, un nombre de host y otras configuraciones en el primer arranque, eliminando la necesidad de un servidor DHCP.

#### Paso 1: Preparar la Plantilla "Maestra" con Cloud-init (Una sola vez)

Sigue estos pasos en tu VM base (ej. Linux Mint) antes de convertirla en plantilla:

1.  **Instalar Paquetes Esenciales:**
    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y openssh-server open-vm-tools-desktop cloud-init
    ```

2.  **Limpiar la VM para Clonación:**
    ```bash
    sudo apt clean
    sudo rm -rf /var/log/*
    sudo truncate -s 0 /etc/machine-id
    sudo rm /var/lib/dbus/machine-id
    sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
    history -c && history -w
    ```

3.  **Apagar y Convertir en Plantilla:**
    *   Apaga la VM con `sudo shutdown now`.
    *   En vCenter, haz clic derecho sobre la VM y selecciona `Clonar` -> `Clonar a Plantilla`.
    *   Dale un nombre significativo, por ejemplo: `plantilla-mint-cloudinit`.

#### Paso 2: Clonar y Configurar con Ansible

Usa el playbook `clone_with_cloudinit.yml` para desplegar tus VMs. Debes pasarle las variables de red como parámetros.

```bash
# Ejemplo de comando para desplegar un nuevo servidor web
venv2/bin/ansible-playbook playbooks/provisioning/clone_with_cloudinit.yml \
  -e "template_name=plantilla-mint-cloudinit" \
  -e "new_vm_name=servidor-web-01" \
  -e "static_ip=192.168.100.50/24" \
  -e "gateway=192.168.100.1" \
  -e "dns_servers=['192.168.100.1', '8.8.8.8']"
```

**¿Qué hace este playbook?**
1.  Clona la VM desde tu plantilla.
2.  Inyecta la configuración de red que le pasaste (IP estática, gateway, DNS) usando Cloud-init.
3.  Enciende la VM.
4.  Espera a que el puerto SSH esté disponible en la nueva IP estática.
5.  Te notifica que la VM está lista para ser gestionada.

## 🔐 Gestión de Secretos (Vault)

El script `vault-manager.sh` simplifica la interacción con Vault.

- **Iniciar Vault:** `./vault-manager.sh start`
- **Detener Vault:** `./vault-manager.sh stop`
- **Ver logs de Vault:** `./vault-manager.sh logs`
- **Hacer backup de secretos:** `./vault-manager.sh backup`

Puedes acceder a la UI de Vault en `http://127.0.0.1:35013/ui` con el token `root-token`.

## 📂 Estructura del Proyecto

```
.
├── main.yml                # Playbook principal que actúa como enrutador
├── requirements.yml        # Dependencias de Ansible Galaxy (roles y colecciones)
├── playbooks/              # Directorio que contiene los playbooks modulares
│   ├── provisioning/       # Playbooks relacionados con el aprovisionamiento
│   │   └── create_vm.yml   # Playbook para crear VMs
│   ├── user_management.yml # Módulo de gestión de usuarios
│   ├── security.yml        # Módulo de seguridad para Linux
│   └── ...                 # Otros módulos
├── roles/                  # Roles de Ansible (instalados desde Galaxy)
├── inventory/              # Inventarios de Ansible
├── reports/                # Informes generados por los playbooks
└── vault/                  # Configuración y scripts de Vault
```

## 🔧 Troubleshooting

- **Error de `venv2/bin/ansible-playbook: No such file or directory`:** Asegúrate de haber creado y configurado correctamente el entorno virtual de Python.
- **Errores de "módulo no encontrado":** Ejecuta `venv2/bin/ansible-galaxy install -r requirements.yml --force` para asegurarte de que todas las colecciones estén instaladas.
- **La creación de VMs falla:** Revisa los logs de Ansible (`-vvv`) para ver mensajes de error detallados de la API de vCenter. Asegúrate de que tu VPN esté conectada y que las credenciales en Vault sean correctas.
