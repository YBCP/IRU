#!/bin/bash
# ==============================================================================
# INSTALACIÓN COMPLETA DE DEPENDENCIAS
# ==============================================================================

echo "======================================================================"
echo "   INSTALACIÓN DE DEPENDENCIAS - SISTEMA IRU"
echo "======================================================================"
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Verificar Python
echo -e "${BLUE}[1/3] Verificando Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 no está instalado${NC}"
    echo "  Instale Python3 desde: https://www.python.org/downloads/"
    exit 1
else
    echo -e "${GREEN}✓ Python3 está instalado${NC}"
    python3 --version
fi

# 2. Instalar librerías de Python
echo ""
echo -e "${BLUE}[2/3] Instalando librerías de Python...${NC}"
pip3 install dbfread pandas openpyxl geopandas shapely --quiet

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Librerías de Python instaladas${NC}"
else
    echo -e "${RED}✗ Error al instalar librerías de Python${NC}"
    exit 1
fi

# 3. Verificar R
echo ""
echo -e "${BLUE}[3/3] Verificando R...${NC}"
if ! command -v Rscript &> /dev/null; then
    echo -e "${RED}✗ R no está instalado${NC}"
    echo "  Instale R desde: https://www.r-project.org/"
    exit 1
else
    echo -e "${GREEN}✓ R está instalado${NC}"
    R --version | head -1
fi

# 4. Instalar librerías de R
echo ""
echo -e "${BLUE}Instalando librerías de R...${NC}"
echo "(Esto puede tomar varios minutos)"
echo ""
Rscript instalar_dependencias.R

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}======================================================================"
    echo "   ✓ INSTALACIÓN COMPLETADA EXITOSAMENTE"
    echo "======================================================================${NC}"
    echo ""
    echo "Ya puede ejecutar el sistema con:"
    echo "  ./ejecutar_analisis_completo.sh"
    echo ""
else
    echo -e "${RED}✗ Hubo errores en la instalación de librerías de R${NC}"
    exit 1
fi
