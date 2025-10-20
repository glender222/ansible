#!/bin/bash

echo "=== VERIFICAR ANSIBLE ==="
echo ""
echo "1️⃣ Versión de Ansible:"
ansible --version
echo ""

echo "2️⃣ Roles instalados:"
ansible-galaxy role list
echo ""

echo "3️⃣ Sintaxis del playbook:"
ansible-playbook -i inventory.ini site.yml --syntax-check
echo ""

echo "4️⃣ Conexión a localhost:"
ansible -i inventory.ini localhost -m ping
echo ""

echo "5️⃣ Nginx status:"
sudo systemctl status nginx
echo ""

echo "6️⃣ Estructura del proyecto:"
find ~/ansible-proyecto -type f -not -path '*/venv/*' -not -path '*/.git/*' | sort
echo ""

echo "✅ VERIFICACIÓN COMPLETADA"
