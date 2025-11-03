# 🪟 GUÍA: PROVISIONING WINDOWS CON ANSIBLE

## 📋 **¿QUÉ ES?**

Esta infraestructura permite configurar automáticamente VMs Windows usando Ansible, similar a como hacemos con Linux, pero usando WinRM en lugar de SSH.

---

## ⚙️ **ESTADO ACTUAL**

✅ **Infraestructura preparada pero NO ACTIVA**

- Archivos creados y configurados
- Variables definidas (comentadas)
- Scripts de setup listos
- **NO se ejecuta automáticamente**

---

## 🚀 **CÓMO ACTIVAR WINDOWS PROVISIONING**

### **Paso 1: Preparar la VM Windows**

1. Crea o arranca una VM Windows
2. Abre PowerShell **como Administrador**
3. Ejecuta este script:

```powershell
# Copiar el contenido de docs/setup_winrm.ps1 y ejecutarlo
```

O descarga el script desde el proyecto y ejecútalo:
```powershell
.\setup_winrm.ps1
```

### **Paso 2: Configurar Variables**

Edita `inventory/group_vars/windows.yml`:

1. **Descomenta** las VMs que quieres crear:
```yaml
vms_windows:
  - name: windows-desktop-01
    os: windows
    profile: windows_desktop
    memory: 4096
    cpus: 2
    disk: 60
    ip: 192.168.100.20
```

2. **Configura credenciales** en el vault:
```bash
ansible-vault edit vault/credentials.yml
```

Agrega:
```yaml
vault_windows_password: "TuPasswordSeguro123!"
```

3. **Descomenta** las credenciales en `windows.yml`:
```yaml
ansible_user: Administrator
ansible_password: "{{ vault_windows_password }}"
```

### **Paso 3: Agregar a Inventory**

Edita `inventory/staging.ini`, agrega:

```ini
[windows]
windows-desktop-01 ansible_host=192.168.100.20

[windows:vars]
ansible_connection=winrm
ansible_port=5985
```

### **Paso 4: Ejecutar Provisioning**

```bash
cd /home/glender/ansible-proyecto
source venv/bin/activate

# Solo provisionar Windows
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini \
  --tags windows

# O provisionar todo (Linux + Windows)
ansible-playbook playbooks/provisioning_management.yml \
  -i inventory/staging.ini
```

---

## 🎯 **PERFILES DISPONIBLES**

### **windows_desktop**
- Software básico de escritorio
- Navegadores (Chrome, Firefox)
- Herramientas (7zip, Notepad++, VLC)

### **windows_server**
- Windows Server con IIS
- Herramientas administrativas
- Git, Python

### **windows_developer**
- Estación de desarrollo completa
- VSCode, Git, Python, Node.js
- Docker Desktop, Postman
- GitHub Desktop

---

## 📦 **SOFTWARE QUE SE INSTALA**

Todo se instala vía **Chocolatey** (gestor de paquetes Windows):

```yaml
# Personaliza en windows.yml
windows_base_packages:
  - git
  - 7zip
  - notepadplusplus
  - googlechrome
  - firefox
  - vlc
  - python
  - nodejs
```

---

## 🔒 **SEGURIDAD**

### **Para Desarrollo/Testing:**
- WinRM con autenticación básica (OK)
- Tráfico sin encriptar (OK para red privada)

### **Para Producción:**
⚠️ **CAMBIAR A:**
- WinRM con HTTPS (puerto 5986)
- Certificados SSL
- Autenticación Kerberos o NTLM

Edita en `windows.yml`:
```yaml
ansible_winrm_transport: certificate  # o kerberos
ansible_port: 5986
ansible_winrm_server_cert_validation: validate
```

---

## 🧪 **PROBAR CONEXIÓN**

```bash
# Ping a la VM Windows
ansible windows -i inventory/staging.ini -m win_ping

# Ejecutar comando PowerShell
ansible windows -i inventory/staging.ini -m win_shell -a "Get-ComputerInfo"

# Ver información del sistema
ansible windows -i inventory/staging.ini -m setup
```

---

## 📊 **COMPARACIÓN: LINUX vs WINDOWS**

| Aspecto | Linux | Windows |
|---------|-------|---------|
| Conexión | SSH (22) | WinRM (5985/5986) |
| Gestor paquetes | apt/yum | Chocolatey |
| Módulos | ansible.builtin | ansible.windows |
| Shell | bash | PowerShell |
| Complejidad | ⭐⭐ | ⭐⭐⭐⭐ |

---

## ❓ **TROUBLESHOOTING**

### **Error: "Connection timeout"**
- Verifica que WinRM esté corriendo: `winrm quickconfig`
- Verifica firewall: puerto 5985 debe estar abierto
- Verifica que la VM tenga IP accesible

### **Error: "Authentication failed"**
- Verifica usuario/password en vault
- Asegúrate que el usuario sea Administrador

### **Error: "pywinrm not installed"**
```bash
source venv/bin/activate
pip install pywinrm
```

---

## 📝 **EJEMPLOS DE USO**

### **Crear usuario Windows**
```yaml
- name: Crear usuario developer
  win_user:
    name: developer
    password: "{{ vault_dev_password }}"
    groups:
      - Administrators
    state: present
```

### **Instalar software**
```yaml
- name: Instalar Git
  win_chocolatey:
    name: git
    state: present
```

### **Configurar firewall**
```yaml
- name: Abrir puerto 80
  win_firewall_rule:
    name: "HTTP"
    localport: 80
    action: allow
    direction: in
    protocol: tcp
    state: present
    enabled: yes
```

---

## 🎯 **SIGUIENTE PASO**

Una vez configurado Windows, puedes aplicar los módulos anteriores:

1. Provisioning (Módulo 4) ← Estás aquí
2. Usuarios Windows (adaptación Módulo 1)
3. Seguridad Windows (adaptación Módulo 2)
4. Automatización Windows (adaptación Módulo 3)

---

## 📚 **RECURSOS**

- [Ansible Windows Documentation](https://docs.ansible.com/ansible/latest/os_guide/windows.html)
- [Chocolatey Packages](https://community.chocolatey.org/packages)
- [WinRM Configuration](https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html)

---

**NOTA:** Por ahora, esta funcionalidad está **DESACTIVADA**. Actívala cuando la necesites siguiendo los pasos de arriba.
