#!/bin/bash

# Script para ejecutar el Dashboard IRU

echo "========================================"
echo "  Dashboard IRU - Python/Dash"
echo "========================================"
echo ""

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 no está instalado"
    exit 1
fi

# Verificar si las dependencias están instaladas
echo "Verificando dependencias..."
if ! python3 -c "import dash" &> /dev/null; then
    echo "Instalando dependencias..."
    pip install -r requirements.txt
fi

echo ""
echo "Iniciando dashboard..."
echo "Accede en: http://127.0.0.1:8050"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo ""

# Ejecutar el dashboard
python3 dashboard.py
