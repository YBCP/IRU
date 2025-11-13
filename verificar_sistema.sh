#!/bin/bash
# ==============================================================================
# VERIFICACIÓN DEL SISTEMA - Comprobar que todo está listo
# ==============================================================================

echo "======================================================================"
echo "        VERIFICACIÓN DEL SISTEMA IRU"
echo "======================================================================"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

errores=0
warnings=0

# Función de verificación
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1"
        ((errores++))
        return 1
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((warnings++))
}

# ============================================================================
# 1. VERIFICAR SOFTWARE
# ============================================================================

echo -e "${BLUE}[1] Verificando software instalado...${NC}"
echo ""

# R
command -v Rscript &> /dev/null
check "R está instalado"
if [ $? -eq 0 ]; then
    echo "    Versión: $(R --version | head -1)"
fi

# Python3
command -v python3 &> /dev/null
check "Python3 está instalado"
if [ $? -eq 0 ]; then
    echo "    Versión: $(python3 --version)"
fi

# Bash
command -v bash &> /dev/null
check "Bash está instalado"

echo ""

# ============================================================================
# 2. VERIFICAR ARCHIVOS DE DATOS
# ============================================================================

echo -e "${BLUE}[2] Verificando archivos de datos...${NC}"
echo ""

# DBF principal
if [ -f "IRUSCV3.dbf" ]; then
    size=$(ls -lh IRUSCV3.dbf | awk '{print $5}')
    echo -e "${GREEN}✓${NC} IRUSCV3.dbf (${size})"
else
    echo -e "${RED}✗${NC} IRUSCV3.dbf no encontrado"
    ((errores++))
fi

# Excel de indicadores
if [ -f "Indicadores.xlsx" ]; then
    size=$(ls -lh Indicadores.xlsx | awk '{print $5}')
    echo -e "${GREEN}✓${NC} Indicadores.xlsx (${size})"
else
    echo -e "${RED}✗${NC} Indicadores.xlsx no encontrado"
    ((errores++))
fi

# Shapefile
if [ -f "Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp" ]; then
    size=$(ls -lh "Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp" | awk '{print $5}')
    echo -e "${GREEN}✓${NC} SECTOR_URBANO.shp (${size})"

    # Verificar archivos auxiliares del shapefile
    required_shp_files=("dbf" "prj" "shx")
    for ext in "${required_shp_files[@]}"; do
        if [ -f "Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.$ext" ]; then
            echo -e "${GREEN}✓${NC} SECTOR_URBANO.$ext"
        else
            warn "SECTOR_URBANO.$ext no encontrado (puede causar problemas)"
        fi
    done
else
    echo -e "${RED}✗${NC} SECTOR_URBANO.shp no encontrado"
    ((errores++))
fi

echo ""

# ============================================================================
# 3. VERIFICAR SCRIPTS DEL SISTEMA
# ============================================================================

echo -e "${BLUE}[3] Verificando scripts del sistema...${NC}"
echo ""

scripts=(
    "analisis_acp_clustering.R"
    "convertir_shapefile.py"
    "dashboard_iru.R"
    "ejecutar_analisis_completo.sh"
    "ejecutar_solo_analisis.sh"
    "ejecutar_dashboard.sh"
    "instalar_dependencias.R"
    "instalar_dependencias.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ] || [[ "$script" == *.R ]]; then
            echo -e "${GREEN}✓${NC} $script"
        else
            warn "$script existe pero no tiene permisos de ejecución"
            echo "    Ejecute: chmod +x $script"
        fi
    else
        echo -e "${RED}✗${NC} $script no encontrado"
        ((errores++))
    fi
done

echo ""

# ============================================================================
# 4. VERIFICAR LIBRERÍAS DE PYTHON
# ============================================================================

echo -e "${BLUE}[4] Verificando librerías de Python...${NC}"
echo ""

python_libs=("dbfread" "pandas" "openpyxl" "geopandas" "shapely" "json")

for lib in "${python_libs[@]}"; do
    python3 -c "import $lib" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $lib"
    else
        echo -e "${RED}✗${NC} $lib no instalado"
        ((errores++))
    fi
done

echo ""

# ============================================================================
# 5. VERIFICAR LIBRERÍAS DE R (muestra)
# ============================================================================

echo -e "${BLUE}[5] Verificando librerías principales de R...${NC}"
echo ""

r_libs=("foreign" "readxl" "dplyr" "FactoMineR" "pcaPP" "cluster" "shiny" "leaflet" "plotly" "jsonlite")

for lib in "${r_libs[@]}"; do
    Rscript -e "library($lib)" 2>/dev/null 1>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $lib"
    else
        echo -e "${RED}✗${NC} $lib no instalado"
        ((errores++))
    fi
done

echo ""

# ============================================================================
# 6. VERIFICAR RESULTADOS PREVIOS (si existen)
# ============================================================================

echo -e "${BLUE}[6] Verificando resultados previos...${NC}"
echo ""

if [ -d "resultados" ]; then
    echo -e "${GREEN}✓${NC} Directorio 'resultados/' existe"

    result_files=(
        "resultados_acp.json"
        "resultados_clustering.json"
        "datos_con_clusters.csv"
        "sectores_clusters.csv"
        "sectores_geojson.json"
    )

    found_results=0
    for file in "${result_files[@]}"; do
        if [ -f "resultados/$file" ]; then
            ((found_results++))
        fi
    done

    if [ $found_results -eq ${#result_files[@]} ]; then
        echo -e "${GREEN}✓${NC} Resultados de análisis previo encontrados ($found_results archivos)"
        echo "    Puede ejecutar solo el dashboard con: ./ejecutar_dashboard.sh"
    elif [ $found_results -gt 0 ]; then
        warn "Resultados parciales encontrados ($found_results de ${#result_files[@]} archivos)"
        echo "    Se recomienda ejecutar el análisis completo de nuevo"
    else
        echo "    No se encontraron resultados previos (es normal si es la primera vez)"
    fi
else
    echo "    Directorio 'resultados/' no existe (se creará al ejecutar el análisis)"
fi

echo ""

# ============================================================================
# RESUMEN FINAL
# ============================================================================

echo "======================================================================"
echo "                        RESUMEN"
echo "======================================================================"
echo ""

if [ $errores -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✓ SISTEMA LISTO PARA EJECUTAR${NC}"
    echo ""
    echo "Todo está configurado correctamente. Puede ejecutar:"
    echo "  ./ejecutar_analisis_completo.sh"
    echo ""
elif [ $errores -eq 0 ] && [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠ SISTEMA LISTO CON ADVERTENCIAS${NC}"
    echo ""
    echo "Encontradas $warnings advertencia(s)."
    echo "El sistema debería funcionar, pero revise las advertencias arriba."
    echo ""
    echo "Puede intentar ejecutar:"
    echo "  ./ejecutar_analisis_completo.sh"
    echo ""
else
    echo -e "${RED}✗ SISTEMA NO ESTÁ LISTO${NC}"
    echo ""
    echo "Encontrados $errores error(es) que deben corregirse."
    echo ""

    if command -v python3 &> /dev/null && command -v Rscript &> /dev/null; then
        echo "Soluciones sugeridas:"
        echo "  1. Instalar dependencias: ./instalar_dependencias.sh"
        echo "  2. Verificar que los archivos de datos están presentes"
        echo "  3. Dar permisos de ejecución: chmod +x *.sh"
    else
        echo "Soluciones sugeridas:"
        echo "  1. Instalar R desde: https://www.r-project.org/"
        echo "  2. Instalar Python3 desde: https://www.python.org/"
        echo "  3. Ejecutar: ./instalar_dependencias.sh"
    fi
    echo ""
fi

echo "======================================================================"

exit $errores
