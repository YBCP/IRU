# 🚀 Inicio Rápido - Sistema IRU

Esta guía te ayudará a ejecutar el sistema de análisis IRU en menos de 5 minutos.

## ⚡ Pasos Rápidos

### 1. Instalar Dependencias (solo la primera vez)

```bash
./instalar_dependencias.sh
```

Esto instalará automáticamente:
- Librerías de Python (dbfread, pandas, geopandas, etc.)
- Librerías de R (shiny, leaflet, plotly, FactoMineR, etc.)

⏱️ **Tiempo estimado:** 5-10 minutos

### 2. Ejecutar Análisis Completo + Dashboard

```bash
./ejecutar_analisis_completo.sh
```

Esto ejecutará:
1. ✅ Análisis de Componentes Principales robusto
2. ✅ Clustering no supervisado con k automático
3. ✅ Conversión de shapefile a GeoJSON
4. ✅ Dashboard interactivo en tu navegador

⏱️ **Tiempo estimado:** 2-5 minutos (dependiendo del tamaño de datos)

### 3. Ver Resultados

El dashboard se abrirá automáticamente en tu navegador con tres pestañas:

- **📊 Resultados del Análisis:** Gráficos y métricas del ACP y clustering
- **ℹ️ Información Técnica:** Metodología y detalles del análisis
- **🗺️ Mapa de Clusters:** Visualización espacial interactiva

## 🎯 Flujos de Trabajo Alternativos

### Solo ejecutar análisis (sin dashboard)

```bash
./ejecutar_solo_analisis.sh
```

Los resultados se guardarán en `resultados/` y podrás abrir el dashboard después con:

```bash
./ejecutar_dashboard.sh
```

### Ver solo el dashboard (si ya ejecutaste el análisis)

```bash
./ejecutar_dashboard.sh
```

## 📂 ¿Dónde están los resultados?

Todos los resultados se guardan en el directorio `resultados/`:

```
resultados/
├── datos_con_clusters.csv          ← Datos completos con clusters
├── sectores_clusters.csv           ← Tabla sector-cluster
├── resultados_acp.json             ← Resultados del ACP
├── resultados_clustering.json      ← Resultados del clustering
├── sectores_geojson.json           ← Mapa en formato GeoJSON
├── resumen_clusters.json           ← Descripción de clusters
└── *.png                           ← Gráficos estáticos
```

## 🔍 Verificar que todo está listo

Antes de ejecutar, verifica que tienes estos archivos:

- ✅ `IRUSCV3.dbf` - Datos de indicadores
- ✅ `Indicadores.xlsx` - Metadatos
- ✅ `Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp` - Shapefile

## ❗ Solución Rápida de Problemas

### Error: "R no está instalado"
➡️ Instala R desde: https://www.r-project.org/

### Error: "Python3 no está instalado"
➡️ Instala Python3 desde: https://www.python.org/downloads/

### Error: "Archivo no encontrado"
➡️ Verifica que estás en el directorio correcto y que los archivos de datos existen

### El dashboard no se abre automáticamente
➡️ Abre manualmente tu navegador y ve a: http://127.0.0.1:XXXX
   (el puerto se mostrará en la consola)

### Error de permisos
➡️ Asegúrate de dar permisos de ejecución a los scripts:
```bash
chmod +x *.sh
```

## 📖 Más Información

Para documentación completa, ver: `README_SISTEMA.md`

## 🎉 ¡Listo!

Ejecuta el sistema y explora tus resultados de análisis urbano.

---

**¿Preguntas?** Consulta el README_SISTEMA.md o revisa los comentarios en los scripts.
