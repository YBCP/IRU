#!/bin/bash

# Script para iniciar servidor local del dashboard HTML/JS

echo "========================================"
echo "  Dashboard IRU - HTML/JavaScript"
echo "========================================"
echo ""

# Verificar si los datos JSON existen
if [ ! -f "data/iru_data.json" ]; then
    echo "Los datos JSON no existen. Generándolos..."
    python3 convert_to_json.py
    echo ""
fi

# Iniciar servidor
echo "Iniciando servidor local..."
echo ""
echo "Dashboard disponible en:"
echo "  → http://localhost:8000"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo "========================================"
echo ""

# Intentar con Python
if command -v python3 &> /dev/null; then
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    python -m http.server 8000
else
    echo "Error: Python no está instalado"
    echo "Por favor instala Python o usa otro servidor local"
    exit 1
fi
