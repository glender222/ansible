# Proyecto de Automatización con Ansible para VMware

## 1. Resumen General

Este es un proyecto de Infraestructura como Código (IaC) que utiliza **Ansible** para automatizar la configuración y gestión de un entorno de virtualización **VMware ESXi**. El sistema está diseñado para ser modular, seguro y extensible, utilizando **HashiCorp Vault** para la gestión de secretos y aprovechando roles de la comunidad de **Ansible Galaxy** para acelerar el desarrollo.

El punto de entrada principal es `main.yml`, que funciona como un **enrutador estático**, ejecutando diferentes módulos de gestión (usuarios, seguridad, etc.) basados en una variable de entrada (`mode`).

## 2. Características Principales

*   **Gestión Centralizada:** Orquesta tareas complejas en máquinas virtuales Linux y Windows desde un único punto de control.
*   **Arquitectura Modular:** El playbook `main.yml` direcciona la ejecución a playbooks específicos para cada función (`user_management.yml`, `security.yml`, etc.), manteniendo el código organizado y fácil de mantener.
*   **Gestión de Secretos Segura:** Integrado con **HashiCorp Vault**, que se ejecuta en un contenedor de Docker gestionado por el script `vault-manager.sh`. Esto evita almacenar credenciales en texto plano.
*   **Descubrimiento Dinámico y Lógica Inteligente:** Los playbooks se conectan a vCenter para descubrir las máquinas virtuales activas, las filtran y las añaden a un inventario en memoria. La lógica de conexión es capaz de seleccionar la IP de gestión correcta e ignorar VMs que no deben ser configuradas (como appliances de red), basándose en la configuración de `inventory/group_vars/all.yml`.
*   **Basado en Roles de la Comunidad:** Reutiliza roles probados de Ansible Galaxy para tareas comunes como la gestión de usuarios (`robertdebock.users`), seguridad (`geerlingguy.security`) y servicios.

## 3. Flujo de Trabajo para Ejecutar un Playbook

Sigue estos pasos para ejecutar cualquier módulo del proyecto.

### Paso 1: Preparar el Entorno

Antes de lanzar cualquier comando de Ansible, asegúrate de hacer estas dos cosas:

1.  **Iniciar el Contenedor de Vault:**
    ```bash
    ./vault-manager.sh start
    ```
2.  **Activar el Entorno Virtual de Python:**
    ```bash
    source venv2/bin/activate
    ```

### Paso 2: Ejecutar el Playbook

Utiliza el playbook principal `main.yml` con la variable `mode` para seleccionar la tarea a realizar y especifica el inventario correspondiente.

```bash
ansible-playbook main.yml -e "mode=<nombre_del_modulo>" -i <ruta_al_inventario>
```

**Ejemplos de Comandos:**

*   **Gestionar usuarios:**
    ```bash
    ansible-playbook main.yml -e "mode=users" -i inventory/staging.ini
    ```
*   **Aplicar configuraciones de seguridad en Linux:**
    ```bash
    ansible-playbook main.yml -e "mode=security" -i inventory/staging.ini
    ```
*   **Interactuar con VMware (ej. listar VMs):**
    ```bash
    ansible-playbook main.yml -e "mode=vmware" -i inventory/localhost.ini
    ```

### Paso 3: Finalizar el Entorno

Cuando termines de trabajar, detén Vault para asegurar los secretos y desactiva el entorno virtual.

1.  **Detener el Contenedor de Vault:**
    ```bash
    ./vault-manager.sh stop
    ```
2.  **Desactivar el Entorno Virtual:**
    ```bash
    deactivate
    ```

## 4. Guía de Verificación en la VM

Una vez que un playbook se ha ejecutado, puedes conectarte a una de las VMs y usar estos comandos para verificar que la configuración se ha aplicado correctamente.

### Módulo: `users`
*   **Verificar si un usuario existe:** `id <nombre_de_usuario>`
*   **Comprobar permisos `sudo`:** `sudo -l`
*   **Revisar claves SSH:** `cat /home/<nombre_de_usuario>/.ssh/authorized_keys`

### Módulo: `security`
*   **Verificar estado del firewall (UFW):** `sudo ufw status verbose`
*   **Comprobar configuración de SSH:** `sudo grep "PermitRootLogin" /etc/ssh/sshd_config`
*   **Revisar estado de Fail2ban:** `sudo systemctl status fail2ban`

### Módulo: `provisioning`
*   **Verificar instalación de un paquete (ej. Nginx):** `dpkg -s nginx`
*   **Comprobar estado de Docker:** `sudo systemctl status docker`
*   **Probar si Nginx responde:** `curl -I http://localhost`

### Módulo: `storage`
*   **Listar discos y particiones:** `lsblk`
*   **Verificar espacio en disco:** `df -hT`
*   **Inspeccionar `fstab` para montajes permanentes:** `cat /etc/fstab`

---
*Este `README.md` ha sido generado y actualizado por el asistente de IA.*
