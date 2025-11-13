#!/bin/bash
# ==============================================================================
# SCRIPT MAESTRO - ANÁLISIS COMPLETO IRU
# ==============================================================================
# Este script ejecuta todo el proceso de análisis en el orden correcto:
# 1. Análisis de Componentes Principales (ACP) robusto y clustering
# 2. Conversión de shapefile a GeoJSON
# 3. Lanzamiento del dashboard interactivo
# ==============================================================================

echo "======================================================================"
echo "     ANÁLISIS COMPLETO IRU - ÍNDICE DE REVITALIZACIÓN URBANA"
echo "======================================================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# 1. VERIFICAR DEPENDENCIAS
# ------------------------------------------------------------------------------

echo -e "${BLUE}[1/4] Verificando dependencias...${NC}"

# Verificar R
if ! command -v Rscript &> /dev/null; then
    echo -e "${RED}✗ R no está instalado. Por favor instale R antes de continuar.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ R está instalado${NC}"
fi

# Verificar Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 no está instalado. Por favor instale Python3 antes de continuar.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Python3 está instalado${NC}"
fi

# Verificar archivos necesarios
if [ ! -f "IRUSCV3.dbf" ]; then
    echo -e "${RED}✗ Archivo IRUSCV3.dbf no encontrado${NC}"
    exit 1
fi

if [ ! -f "Indicadores.xlsx" ]; then
    echo -e "${RED}✗ Archivo Indicadores.xlsx no encontrado${NC}"
    exit 1
fi

if [ ! -f "Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp" ]; then
    echo -e "${RED}✗ Shapefile de sectores catastrales no encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Todos los archivos necesarios están presentes${NC}"
echo ""

# ------------------------------------------------------------------------------
# 2. EJECUTAR ANÁLISIS ACP Y CLUSTERING
# ------------------------------------------------------------------------------

echo -e "${BLUE}[2/4] Ejecutando Análisis de Componentes Principales y Clustering...${NC}"
echo ""

Rscript analisis_acp_clustering.R

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error en el análisis ACP y clustering${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Análisis ACP y clustering completado${NC}"
echo ""

# ------------------------------------------------------------------------------
# 3. CONVERTIR SHAPEFILE A GEOJSON
# ------------------------------------------------------------------------------

echo -e "${BLUE}[3/4] Convirtiendo shapefile a GeoJSON...${NC}"
echo ""

python3 convertir_shapefile.py

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error en la conversión de shapefile${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Conversión de shapefile completada${NC}"
echo ""

# ------------------------------------------------------------------------------
# 4. LANZAR DASHBOARD
# ------------------------------------------------------------------------------

echo -e "${BLUE}[4/4] Lanzando dashboard interactivo...${NC}"
echo ""
echo -e "${YELLOW}El dashboard se abrirá en su navegador web.${NC}"
echo -e "${YELLOW}Para detenerlo, presione Ctrl+C en esta terminal.${NC}"
echo ""

Rscript dashboard_iru.R

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error al iniciar el dashboard${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}======================================================================"
echo -e "                 ANÁLISIS COMPLETADO EXITOSAMENTE"
echo -e "======================================================================${NC}"
