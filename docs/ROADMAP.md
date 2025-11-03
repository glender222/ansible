MÓDULO 1: USUARIOS Y PERMISOS

Crear usuarios: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Crear grupos: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Asignar grupos a usuarios: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Configurar sudo: Galaxy Role linux-system-roles.sudo — ¿Necesita Custom? NO
Configurar permisos sudo avanzados: Galaxy Role robertdebock.users (sudo_options) — ¿Necesita Custom? NO
SSH keys (authorized_keys): Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Password policies: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Expiración de cuentas: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Cron allow/deny: Galaxy Role robertdebock.users — ¿Necesita Custom? NO
Ocultar usuarios en login: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)
Auditoría/Reporte TXT: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)

Resultado: 70% Galaxy + 30% Custom (VMware específico)

MÓDULO 2: SEGURIDAD Y FIREWALL

✅ Fail2ban: Galaxy Role geerlingguy.security — ¿Necesita Custom? NO
✅ SSH hardening: Galaxy Role geerlingguy.security — ¿Necesita Custom? NO
✅ Auto-updates (apt/yum): Galaxy Role geerlingguy.security — ¿Necesita Custom? NO
✅ Configurar sudoers: Galaxy Role geerlingguy.security — ¿Necesita Custom? NO
✅ Firewall (iptables/firewalld): Galaxy Role geerlingguy.firewall — ¿Necesita Custom? SI (instalar este rol)
✅ Gestión NICs VMware: NO EXISTE — ¿Necesita Custom? SI (community.vmware)
✅ Reglas ESXi host: NO EXISTE — ¿Necesita Custom? SI (community.vmware)
✅ Reportes seguridad TXT: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)

Resultado: 70% Galaxy + 30% Custom (VMware específico)

MÓDULO 3: AUTOMATIZACIÓN

Auto-updates Linux: Galaxy Role geerlingguy.security — ¿Necesita Custom? NO
Gestión servicios systemd: Galaxy Role robertdebock.service — ¿Necesita Custom? NO
Cron jobs (hora específica): Galaxy Role community.general.cron — ¿Necesita Custom? NO (módulo)
Apagado programado: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)
Optimización Linux: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)

Resultado: 50% Galaxy/Modules + 50% Custom (tareas específicas)

MÓDULO 4: PROVISIONING VMs

Crear VMs VMware: Ya tienes create_vm_esxi.yml — ¿Necesita Custom? NO
Instalar Docker: Galaxy Role geerlingguy.docker — ¿Necesita Custom? NO
Instalar Nginx: Galaxy Role geerlingguy.nginx — ¿Necesita Custom? NO
Software base Linux: Galaxy Role Combo de roles Galaxy — ¿Necesita Custom? NO
Windows provisioning: Galaxy Role ansible.windows collection — ¿Necesita Custom? NO (módulos)
Orchestración completa: NO EXISTE — ¿Necesita Custom? SI (Custom wrapper)

Resultado: 80% Galaxy + 20% Custom (wrapper orquestador)

MÓDULO 5: PROCESOS Y SERVICIOS

Gestión servicios: Galaxy Role robertdebock.service — ¿Necesita Custom? NO
Monitoreo procesos (top/ps): Galaxy Role community.general.service_facts — ¿Necesita Custom? NO (módulo)
Reportes TXT: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)

Resultado: 70% Galaxy/Modules + 30% Custom (reportes)

MÓDULO 6: STORAGE

Particionado discos: Galaxy Role linux-system-roles.storage — ¿Necesita Custom? NO
LVM: Galaxy Role linux-system-roles.storage — ¿Necesita Custom? NO
Filesystems: Galaxy Role linux-system-roles.storage — ¿Necesita Custom? NO
Montaje: Galaxy Role linux-system-roles.storage — ¿Necesita Custom? NO
Reportes TXT: NO EXISTE — ¿Necesita Custom? SI (Custom ligero)

Resultado: 90% Galaxy + 10% Custom (reportes)





ESTO ES LO QUE TENEMOS QUE HACER  , NO CAMBIAR ESTE MD MAS PODER UN CHECK CUANDO SE COMPLETO