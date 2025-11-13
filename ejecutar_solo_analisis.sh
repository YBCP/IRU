#!/bin/bash
# ==============================================================================
# EJECUTAR SOLO EL ANÁLISIS (sin lanzar dashboard)
# ==============================================================================

echo "======================================================================"
echo "           ANÁLISIS ACP ROBUSTO Y CLUSTERING - IRU"
echo "======================================================================"
echo ""

# Ejecutar análisis
echo "[1/2] Ejecutando análisis..."
Rscript analisis_acp_clustering.R

if [ $? -ne 0 ]; then
    echo "✗ Error en el análisis"
    exit 1
fi

echo ""
echo "[2/2] Convirtiendo shapefile a GeoJSON..."
python3 convertir_shapefile.py

if [ $? -ne 0 ]; then
    echo "✗ Error en la conversión"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  ✓ ANÁLISIS COMPLETADO"
echo "  Los resultados están disponibles en el directorio 'resultados/'"
echo "======================================================================"
echo ""
echo "Para visualizar los resultados en el dashboard, ejecute:"
echo "  Rscript dashboard_iru.R"
echo ""
