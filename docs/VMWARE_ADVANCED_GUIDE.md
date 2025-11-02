# 🚀 Guía Avanzada: Ansible + VMware ESXi/vCenter

## 📚 Tabla de Contenidos
1. [Módulos Esenciales](#módulos-esenciales)
2. [Gestión Completa de VMs](#gestión-completa-de-vms)
3. [Storage & Discos](#storage--discos)
4. [Networking Avanzado](#networking-avanzado)
5. [Snapshots & Clones](#snapshots--clones)
6. [Templates & Customization](#templates--customization)
7. [Monitoreo & Info](#monitoreo--info)
8. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 🎯 Módulos Esenciales

### Gestión de VMs
```yaml
# Módulo principal - Gestión completa de VMs
community.vmware.vmware_guest

# Información de VMs
community.vmware.vmware_guest_info

# Control de estado (power on/off/reset)
community.vmware.vmware_guest_powerstate

# Disco virtual
community.vmware.vmware_guest_disk

# Configuración de red
community.vmware.vmware_guest_network

# Snapshots
community.vmware.vmware_guest_snapshot

# Customización de SO
community.vmware.vmware_guest_custom_attributes
```

### Gestión de Infraestructura
```yaml
# Datastore
community.vmware.vmware_datastore_info
community.vmware.vmware_datastore_cluster

# Networking
community.vmware.vmware_portgroup
community.vmware.vmware_vswitch

# Hosts ESXi
community.vmware.vmware_host_info
community.vmware.vmware_host_service

# vCenter
community.vmware.vmware_vcenter_settings
community.vmware.vmware_folder
```

---

## 🖥️ Gestión Completa de VMs

### 1. Crear VM con todas las opciones

```yaml
- name: Crear VM completa con todas las opciones
  community.vmware.vmware_guest:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    cluster: "Cluster01"
    folder: "/vm/production"
    name: "web-server-01"
    state: poweredon
    guest_id: ubuntu64Guest
    
    # Hardware
    hardware:
      memory_mb: 16384
      num_cpus: 8
      num_cpu_cores_per_socket: 2
      scsi: paravirtual
      hotadd_cpu: true
      hotadd_memory: true
      boot_firmware: efi
      nested_virt: true
    
    # Discos
    disk:
      - size_gb: 100
        type: thin
        datastore: "datastore1"
        controller_type: paravirtual
        controller_number: 0
        unit_number: 0
      - size_gb: 500
        type: thick
        datastore: "datastore2"
        controller_type: paravirtual
        controller_number: 0
        unit_number: 1
    
    # Networks
    networks:
      - name: "VM Network"
        device_type: vmxnet3
        start_connected: true
        connected: true
      - name: "DMZ Network"
        device_type: vmxnet3
        start_connected: false
    
    # CD-ROM
    cdrom:
      - type: iso
        iso_path: "[datastore1] ISO/ubuntu-24.04.iso"
        controller_number: 0
        unit_number: 0
    
    # Opciones avanzadas
    customization:
      hostname: web-server-01
      dns_servers:
        - 8.8.8.8
        - 8.8.4.4
      domain: example.com
    
    wait_for_ip_address: yes
    wait_for_customization: yes
```

### 2. Clonar desde Template

```yaml
- name: Clonar VM desde template
  community.vmware.vmware_guest:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    name: "app-server-{{ item }}"
    template: "ubuntu-24-template"
    datacenter: "ha-datacenter"
    folder: "/vm/staging"
    state: poweredon
    
    # Customización de red
    networks:
      - name: "VM Network"
        ip: "192.168.1.{{ 100 + item }}"
        netmask: "255.255.255.0"
        gateway: "192.168.1.1"
        device_type: vmxnet3
    
    customization:
      hostname: "app-{{ item }}"
      domain: example.com
  
  loop: "{{ range(1, 6) | list }}"  # Crear 5 VMs
```

---

## 💾 Storage & Discos

### 1. Añadir disco a VM existente

```yaml
- name: Añadir nuevo disco de 200GB
  community.vmware.vmware_guest_disk:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "web-server-01"
    disk:
      - size_gb: 200
        type: thin
        datastore: "datastore1"
        state: present
        scsi_controller: 0
        unit_number: 2
```

### 2. Expandir disco existente

```yaml
- name: Expandir disco de 100GB a 200GB
  community.vmware.vmware_guest_disk:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "database-server"
    disk:
      - size_gb: 200
        scsi_controller: 0
        unit_number: 0
        state: present
```

### 3. Gestionar múltiples discos

```yaml
- name: Configurar almacenamiento completo
  community.vmware.vmware_guest_disk:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "storage-server"
    disk:
      # Disco OS
      - size_gb: 100
        type: thin
        datastore: "ssd-datastore"
        scsi_controller: 0
        unit_number: 0
        state: present
      
      # Disco datos 1
      - size_gb: 500
        type: thick
        datastore: "data-datastore"
        scsi_controller: 0
        unit_number: 1
        state: present
      
      # Disco datos 2
      - size_gb: 500
        type: thick
        datastore: "data-datastore"
        scsi_controller: 0
        unit_number: 2
        state: present
```

---

## 🌐 Networking Avanzado

### 1. Configurar múltiples NICs

```yaml
- name: Configurar networking completo
  community.vmware.vmware_guest_network:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "firewall-vm"
    network_name: "{{ item.network }}"
    device_type: vmxnet3
    start_connected: true
    state: present
  loop:
    - { network: "WAN", mac: "00:50:56:00:00:01" }
    - { network: "LAN", mac: "00:50:56:00:00:02" }
    - { network: "DMZ", mac: "00:50:56:00:00:03" }
```

### 2. Cambiar portgroup dinámicamente

```yaml
- name: Mover VM a otra VLAN
  community.vmware.vmware_guest_network:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    name: "production-server"
    network_name: "Production-VLAN100"
    label: "Network adapter 1"
    state: present
```

---

## 📸 Snapshots & Clones

### 1. Crear snapshot antes de cambios

```yaml
- name: Crear snapshot pre-actualización
  community.vmware.vmware_guest_snapshot:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    folder: "/vm"
    name: "production-server"
    state: present
    snapshot_name: "pre-update-{{ ansible_date_time.iso8601_basic_short }}"
    description: "Snapshot antes de actualización del {{ ansible_date_time.date }}"
    memory_dump: yes
    quiesce: yes
```

### 2. Revertir a snapshot

```yaml
- name: Revertir a snapshot si algo falla
  community.vmware.vmware_guest_snapshot:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "production-server"
    state: revert
    snapshot_name: "pre-update-20241031"
```

### 3. Eliminar snapshots antiguos

```yaml
- name: Limpiar snapshots viejos
  community.vmware.vmware_guest_snapshot:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "{{ item.vm }}"
    state: absent
    snapshot_name: "{{ item.snapshot }}"
  loop:
    - { vm: "web-01", snapshot: "old-snapshot-1" }
    - { vm: "web-02", snapshot: "old-snapshot-2" }
```

---

## 📋 Templates & Customization

### 1. Convertir VM a Template

```yaml
- name: Convertir VM a template
  community.vmware.vmware_guest:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    name: "ubuntu-24-base"
    is_template: yes
    state: present
```

### 2. Desplegar desde template con customización

```yaml
- name: Desplegar VM personalizada desde template
  community.vmware.vmware_guest:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    name: "app-server-prod"
    template: "ubuntu-24-template"
    datacenter: "ha-datacenter"
    folder: "/vm/production"
    state: poweredon
    
    customization:
      hostname: app-server-prod
      domain: production.local
      dns_servers:
        - 192.168.1.10
        - 192.168.1.11
      dns_suffix:
        - production.local
        - example.com
    
    networks:
      - name: "Production-VLAN"
        ip: 192.168.10.50
        netmask: 255.255.255.0
        gateway: 192.168.10.1
        domain: production.local
    
    wait_for_customization: yes
    wait_for_ip_address: yes
```

---

## 📊 Monitoreo & Info

### 1. Obtener información completa de VM

```yaml
- name: Obtener info detallada de VM
  community.vmware.vmware_guest_info:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    datacenter: "ha-datacenter"
    name: "production-server"
    schema: vsphere
  register: vm_info

- name: Mostrar información clave
  debug:
    msg:
      - "Estado: {{ vm_info.instance.hw_power_status }}"
      - "CPU: {{ vm_info.instance.hw_processor_count }}"
      - "RAM: {{ vm_info.instance.hw_memtotal_mb }} MB"
      - "IP: {{ vm_info.instance.ipv4 }}"
      - "Guest OS: {{ vm_info.instance.hw_guest_full_name }}"
```

### 2. Listar todas las VMs de un datacenter

```yaml
- name: Listar todas las VMs
  community.vmware.vmware_vm_info:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
  register: all_vms

- name: Generar reporte de VMs
  template:
    src: vm_report.j2
    dest: "/tmp/vm_inventory_{{ ansible_date_time.date }}.html"
```

### 3. Monitorear recursos de ESXi

```yaml
- name: Obtener info del host ESXi
  community.vmware.vmware_host_info:
    hostname: "{{ vcenter_hostname }}"
    username: "{{ vcenter_username }}"
    password: "{{ vcenter_password }}"
    validate_certs: no
    esxi_hostname: "esxi-host-01.local"
  register: esxi_info

- name: Mostrar recursos disponibles
  debug:
    msg:
      - "CPU Total: {{ esxi_info.hosts[esxi_hostname].cpu_model }}"
      - "RAM Total: {{ esxi_info.hosts[esxi_hostname].memory_mb }} MB"
      - "Estado: {{ esxi_info.hosts[esxi_hostname].state }}"
```

---

## 🔥 Ejemplos Prácticos Completos

### Ejemplo 1: Despliegue Completo Web + DB

```yaml
---
- name: Desplegar stack Web + Database
  hosts: localhost
  gather_facts: no
  collections: [community.vmware]
  
  vars_files:
    - vault_credentials.yml
  
  tasks:
    # 1. Crear VM Web Server
    - name: Crear Web Server
      community.vmware.vmware_guest:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "web-prod-01"
        template: "ubuntu-24-nginx-template"
        datacenter: "DC1"
        folder: "/vm/production/web"
        state: poweredon
        hardware:
          memory_mb: 8192
          num_cpus: 4
        networks:
          - name: "Web-VLAN"
            ip: "192.168.10.10"
            netmask: "255.255.255.0"
            gateway: "192.168.10.1"
        wait_for_ip_address: yes
      register: web_vm
    
    # 2. Crear VM Database Server
    - name: Crear Database Server
      community.vmware.vmware_guest:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "db-prod-01"
        template: "ubuntu-24-postgresql-template"
        datacenter: "DC1"
        folder: "/vm/production/database"
        state: poweredon
        hardware:
          memory_mb: 32768
          num_cpus: 8
        networks:
          - name: "DB-VLAN"
            ip: "192.168.20.10"
            netmask: "255.255.255.0"
            gateway: "192.168.20.1"
        wait_for_ip_address: yes
      register: db_vm
    
    # 3. Añadir disco extra para base de datos
    - name: Añadir disco de datos a DB
      community.vmware.vmware_guest_disk:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "db-prod-01"
        datacenter: "DC1"
        disk:
          - size_gb: 1000
            type: thick
            datastore: "ssd-datastore"
            scsi_controller: 0
            unit_number: 1
    
    # 4. Crear snapshot inicial
    - name: Snapshot post-despliegue
      community.vmware.vmware_guest_snapshot:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "{{ item }}"
        datacenter: "DC1"
        state: present
        snapshot_name: "initial-deploy"
        description: "Snapshot inicial post-despliegue"
      loop:
        - "web-prod-01"
        - "db-prod-01"
```

### Ejemplo 2: Mantenimiento Programado

```yaml
---
- name: Mantenimiento programado - Actualización de VMs
  hosts: localhost
  gather_facts: no
  collections: [community.vmware]
  
  tasks:
    # 1. Snapshot antes de actualización
    - name: Crear snapshot pre-mantenimiento
      community.vmware.vmware_guest_snapshot:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "{{ item }}"
        datacenter: "DC1"
        state: present
        snapshot_name: "pre-maintenance-{{ ansible_date_time.date }}"
        memory_dump: yes
      loop: "{{ vms_to_update }}"
    
    # 2. Actualizar VMs (delegado a las VMs)
    - name: Actualizar sistema operativo
      delegate_to: "{{ item }}"
      apt:
        update_cache: yes
        upgrade: dist
        autoremove: yes
      loop: "{{ vms_to_update }}"
    
    # 3. Reiniciar VMs
    - name: Reiniciar VMs
      community.vmware.vmware_guest_powerstate:
        hostname: "{{ vcenter.hostname }}"
        username: "{{ vcenter.username }}"
        password: "{{ vcenter.password }}"
        validate_certs: no
        name: "{{ item }}"
        state: reboot-guest
      loop: "{{ vms_to_update }}"
    
    # 4. Esperar que vuelvan online
    - name: Esperar conectividad
      wait_for:
        host: "{{ item }}"
        port: 22
        delay: 30
        timeout: 300
      loop: "{{ vms_to_update }}"
    
    # 5. Verificar servicios
    - name: Verificar servicios críticos
      delegate_to: "{{ item }}"
      systemd:
        name: "{{ service_name }}"
        state: started
      loop: "{{ vms_to_update }}"
```

---

## 🎓 Próximos Pasos

1. **Actualizar collection**: `ansible-galaxy collection install community.vmware:>=5.9.0 --force`
2. **Crear roles personalizados** para:
   - Aprovisionamiento de VMs
   - Gestión de snapshots
   - Disaster Recovery
3. **Integrar con roles de Galaxy** para configuración post-despliegue
4. **Automatizar tareas** de tu archivo `porhacer`

---

## 📚 Recursos

- [community.vmware Documentation](https://docs.ansible.com/ansible/latest/collections/community/vmware/)
- [VMware Guest Module](https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
