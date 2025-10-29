# Ansible Role: user_audit

## Descripción

Rol custom ligero para generar reportes de auditoría de usuarios en sistemas Linux.

Este rol **NO gestiona usuarios**, solo genera reportes. La gestión de usuarios se hace con `robertdebock.users`.

## Funcionalidades

- ✅ Recopila información de usuarios del sistema
- ✅ Recopila información de grupos
- ✅ Analiza configuración sudo
- ✅ Detecta SSH keys configuradas
- ✅ Genera reporte TXT detallado
- ✅ Incluye justificación de configuraciones
- ✅ Proporciona comandos de validación

## Requisitos

- Ansible >= 2.12
- Sistema operativo Linux (Debian/Ubuntu/RHEL/CentOS)
- Privilegios sudo

## Variables

### Variables por defecto (defaults/main.yml)

```yaml
user_audit_enabled: true
user_audit_report_path: "reports/users"
user_audit_include_justification: true
user_audit_include_ssh_keys: true
user_audit_include_sudo_config: true
```

### Variables requeridas

```yaml
system_users: []      # Lista de usuarios gestionados
system_groups: []     # Lista de grupos gestionados
```

## Uso

### Incluir en un playbook

```yaml
- hosts: linux_servers
  roles:
    - role: user_audit
      vars:
        user_audit_report_path: "reports/users"
```

### Ejecutar con tags

```bash
ansible-playbook playbook.yml -t audit
```

## Salida

Genera un archivo de reporte en:
```
reports/users/user_audit_<hostname>_<timestamp>.txt
```

### Contenido del reporte

- Resumen general del sistema
- Lista de usuarios gestionados con:
  - UID, GID, grupos
  - Permisos sudo
  - SSH keys configuradas
  - Políticas de password
- Grupos del sistema
- Configuración sudo detectada
- SSH keys encontradas
- Justificación de configuraciones
- Validaciones recomendadas
- Comandos útiles de verificación

## Dependencias

Ninguna. Es un rol standalone.

## Ejemplo Completo

```yaml
---
- name: Auditoría de usuarios
  hosts: all
  become: yes
  
  vars:
    system_users:
      - name: admin1
        uid: 1001
        group: admins
        sudo_options: "ALL=(ALL) NOPASSWD: ALL"
    
    system_groups:
      - name: admins
        gid: 2001
  
  roles:
    - role: user_audit
```

## Licencia

MIT

## Autor

Ansible Proyecto - 2024
