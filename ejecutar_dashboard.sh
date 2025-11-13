#!/bin/bash
# ==============================================================================
# LANZAR SOLO EL DASHBOARD (requiere haber ejecutado el análisis previamente)
# ==============================================================================

echo "======================================================================"
echo "                  DASHBOARD IRU - VISUALIZACIÓN"
echo "======================================================================"
echo ""

# Verificar que existen los resultados
if [ ! -d "resultados" ]; then
    echo "✗ Error: No se encontró el directorio 'resultados/'"
    echo "  Debe ejecutar primero el análisis con:"
    echo "  ./ejecutar_solo_analisis.sh"
    exit 1
fi

if [ ! -f "resultados/resultados_acp.json" ] || [ ! -f "resultados/resultados_clustering.json" ]; then
    echo "✗ Error: Archivos de resultados no encontrados"
    echo "  Debe ejecutar primero el análisis con:"
    echo "  ./ejecutar_solo_analisis.sh"
    exit 1
fi

echo "Lanzando dashboard..."
echo ""
echo "El dashboard se abrirá en su navegador web."
echo "Para detenerlo, presione Ctrl+C en esta terminal."
echo ""

Rscript dashboard_iru.R
