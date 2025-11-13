# Sistema de Análisis IRU - Índice de Revitalización Urbana

Sistema completo de análisis de componentes principales robusto, clustering no supervisado y visualización interactiva para indicadores de revitalización urbana.

## 📋 Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Componentes del Sistema](#componentes-del-sistema)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Estructura de Archivos](#estructura-de-archivos)
- [Metodología](#metodología)
- [Resultados](#resultados)
- [Preguntas Frecuentes](#preguntas-frecuentes)

## 🎯 Descripción General

Este sistema realiza un análisis multivariado completo de indicadores urbanos (variables Rev_) para:

1. **Reducir dimensionalidad** mediante Análisis de Componentes Principales (ACP) robusto
2. **Identificar patrones** a través de clustering no supervisado
3. **Visualizar resultados** en un dashboard interactivo con mapas

### Características Principales

- ✅ ACP robusto (método Hubert) resistente a valores atípicos
- ✅ Selección automática del número óptimo de clusters (>50% varianza)
- ✅ Dashboard interactivo con tres pestañas especializadas
- ✅ Mapas interactivos con caracterización de clusters
- ✅ Exportación de resultados en múltiples formatos (CSV, JSON, PNG)
- ✅ Completamente automatizado y reproducible

## 🔧 Componentes del Sistema

### 1. Análisis ACP y Clustering (`analisis_acp_clustering.R`)

Script principal que realiza:
- Carga de datos del archivo IRUSCV3.dbf
- Selección de variables Rev_
- ACP robusto con método Hubert
- Clustering K-means con selección automática de k
- Caracterización de clusters
- Generación de visualizaciones
- Exportación de resultados

### 2. Conversión de Shapefile (`convertir_shapefile.py`)

Script Python que:
- Convierte shapefile de sectores catastrales a GeoJSON
- Integra resultados de clustering con datos espaciales
- Enriquece geometrías con información de caracterización
- Reproyecta a WGS84 para compatibilidad web

### 3. Dashboard Interactivo (`dashboard_iru.R`)

Aplicación Shiny con tres pestañas:

#### Pestaña 1: Resultados del Análisis
- Métricas resumen (sectores, clusters, varianza)
- Gráfico de varianza explicada por componentes
- Distribución de sectores por cluster
- Biplot del ACP (PC1 vs PC2)
- Caracterización detallada de cada cluster

#### Pestaña 2: Información Técnica
- Metodología del análisis
- Tabla de varianza por componente
- Tamaños y distribución de clusters
- Loadings de variables principales
- Gráficos de métodos de selección de k

#### Pestaña 3: Mapa Interactivo
- Visualización espacial de clusters
- Click en sectores para información detallada
- Leyenda con distribución de clusters
- Popup con variables características

## 📦 Requisitos

### Software Necesario

- **R** (versión ≥ 4.0.0)
- **Python 3** (versión ≥ 3.7)
- **Bash** (para scripts de ejecución)

### Librerías de R

El sistema instalará automáticamente las siguientes librerías:
```r
foreign, readxl, tidyverse, FactoMineR, factoextra, pcaPP,
cluster, NbClust, jsonlite, scales, ggrepel, shiny,
shinydashboard, leaflet, plotly, DT
```

### Librerías de Python

```bash
dbfread, pandas, openpyxl, geopandas, shapely
```

### Archivos de Datos Requeridos

- `IRUSCV3.dbf` - Datos de indicadores urbanos
- `Indicadores.xlsx` - Metadatos de indicadores (hoja "Indicadores")
- `Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp` - Shapefile de sectores

## 🚀 Instalación

### 1. Clonar o descargar el repositorio

```bash
cd /ruta/al/directorio/IRU
```

### 2. Instalar dependencias de Python

```bash
pip3 install dbfread pandas openpyxl geopandas shapely
```

### 3. Verificar instalación de R

```bash
R --version
```

Las librerías de R se instalarán automáticamente al ejecutar los scripts.

## 💻 Uso

### Opción 1: Análisis Completo + Dashboard (Recomendado)

Ejecuta todo el proceso y lanza el dashboard:

```bash
./ejecutar_analisis_completo.sh
```

Este script:
1. Verifica dependencias
2. Ejecuta análisis ACP y clustering
3. Convierte shapefile a GeoJSON
4. Lanza el dashboard interactivo

### Opción 2: Solo Análisis (sin dashboard)

Para generar solo los resultados sin visualización:

```bash
./ejecutar_solo_analisis.sh
```

Los resultados se guardarán en el directorio `resultados/`

### Opción 3: Solo Dashboard (requiere análisis previo)

Si ya ejecutó el análisis y solo quiere ver el dashboard:

```bash
./ejecutar_dashboard.sh
```

### Opción 4: Ejecutar componentes individuales

**Solo análisis ACP y clustering:**
```bash
Rscript analisis_acp_clustering.R
```

**Solo conversión de shapefile:**
```bash
python3 convertir_shapefile.py
```

**Solo dashboard:**
```bash
Rscript dashboard_iru.R
```

## 📁 Estructura de Archivos

```
IRU/
├── IRUSCV3.dbf                          # Datos de entrada
├── Indicadores.xlsx                     # Metadatos de indicadores
├── Sectores Catastrales/
│   └── SECTOR_URBANO/
│       ├── SECTOR_URBANO.shp           # Shapefile de sectores
│       ├── SECTOR_URBANO.dbf
│       ├── SECTOR_URBANO.prj
│       └── ...
├── analisis_acp_clustering.R           # Script de análisis
├── convertir_shapefile.py              # Script de conversión
├── dashboard_iru.R                     # Dashboard interactivo
├── ejecutar_analisis_completo.sh       # Script maestro
├── ejecutar_solo_analisis.sh           # Solo análisis
├── ejecutar_dashboard.sh               # Solo dashboard
├── README_SISTEMA.md                   # Este archivo
└── resultados/                         # Directorio de salida
    ├── datos_con_clusters.csv          # Datos + clusters asignados
    ├── resultados_acp.json             # Resultados ACP
    ├── resultados_clustering.json      # Resultados clustering
    ├── sectores_clusters.csv           # Asignación de clusters
    ├── sectores_geojson.json           # GeoJSON para mapa
    ├── resumen_clusters.json           # Resumen de clusters
    ├── grafico_varianza_explicada.png  # Visualizaciones
    ├── biplot_acp.png
    ├── metodo_codo.png
    ├── silueta.png
    ├── varianza_entre_grupos.png
    └── heatmap_clusters.png
```

## 📊 Metodología

### Análisis de Componentes Principales Robusto

El ACP robusto utiliza el **método de Hubert** (PcaHubert), que es resistente a valores atípicos mediante:
- Proyección robusta de datos
- Estimación robusta de covarianzas
- Menor sensibilidad a observaciones extremas

**Criterio de selección de componentes:**
- Se seleccionan los componentes que explican al menos el **70% de la varianza** total

### Clustering No Supervisado

**Algoritmo:** K-means sobre las componentes principales seleccionadas

**Criterio de selección de k (número de clusters):**
1. **Criterio principal:** Varianza entre grupos > 50%
2. **Criterios secundarios:**
   - Coeficiente de silueta (calidad de asignación)
   - Método del codo (suma de cuadrados intra-cluster)

**Caracterización de clusters:**
- Se identifican las 5 variables Rev_ con mayor valor medio en cada cluster
- Se vinculan con metadatos del archivo Indicadores.xlsx
- Se generan descripciones en términos de ejes y ámbitos urbanos

## 📈 Resultados

### Archivos CSV

- **datos_con_clusters.csv**: Dataset completo con cluster asignado a cada sector
- **sectores_clusters.csv**: Tabla simple de sector-cluster

### Archivos JSON

- **resultados_acp.json**: Varianza explicada, loadings, número óptimo de componentes
- **resultados_clustering.json**: k óptimo, varianzas, centroides, caracterización
- **sectores_geojson.json**: GeoJSON con geometrías y propiedades de clusters
- **resumen_clusters.json**: Descripción resumida de cada cluster

### Visualizaciones PNG

- **grafico_varianza_explicada.png**: Scree plot del ACP
- **biplot_acp.png**: Distribución de sectores en PC1 vs PC2
- **metodo_codo.png**: Determinación de k por método del codo
- **silueta.png**: Coeficiente de silueta por k
- **varianza_entre_grupos.png**: Varianza explicada por número de clusters
- **heatmap_clusters.png**: Perfil de clusters por variables

## 🗺️ Dashboard Interactivo

### Características del Mapa

- **Tecnología:** Leaflet (compatible con cualquier navegador)
- **Proyección:** WGS84 (EPSG:4326)
- **Interactividad:**
  - Click en sector → información detallada en panel lateral
  - Hover → nombre del sector
  - Popup → caracterización completa del cluster
  - Zoom y pan ilimitados

### Información en Popup del Mapa

Cada sector muestra:
- Nombre y código del sector
- Cluster asignado
- Descripción del cluster
- Top 3 variables características con valores
- Eje y ámbito de cada variable

### Leyenda Dinámica

- Muestra todos los clusters identificados
- Código de color para cada cluster
- Número y porcentaje de sectores por cluster

## ❓ Preguntas Frecuentes

### ¿Qué hago si el análisis falla?

1. Verificar que todos los archivos de datos existen
2. Revisar la consola para mensajes de error específicos
3. Asegurarse de tener permisos de escritura en el directorio

### ¿Puedo cambiar el criterio de selección de clusters?

Sí, en el archivo `analisis_acp_clustering.R`:
- Línea ~180-200: Modificar el umbral de varianza (actualmente 50%)
- Línea ~190: Cambiar el método de selección (silueta, codo, etc.)

### ¿Cómo interpretar los clusters?

Cada cluster representa un grupo de sectores urbanos con características similares:
- Variables con valores altos indican fortalezas
- Variables con valores bajos indican áreas de mejora
- El eje y ámbito contextualizan las variables

### ¿Puedo usar solo algunas variables Rev_?

Sí, en `analisis_acp_clustering.R` línea ~50:
```r
# Filtrar variables específicas
cols_rev <- grep("^Rev_(2526|2638|...)", names(datos_iru), value = TRUE)
```

### ¿El dashboard funciona sin conexión a internet?

Sí, excepto por el mapa base de OpenStreetMap que requiere conexión. Para uso offline:
- Usar tiles locales
- Modificar `dashboard_iru.R` línea ~600 para cambiar el proveedor de tiles

### ¿Puedo exportar el mapa?

El GeoJSON generado (`sectores_geojson.json`) es compatible con:
- QGIS
- ArcGIS
- Mapbox
- Cualquier herramienta que soporte GeoJSON

### ¿Cuánto tiempo toma el análisis?

Depende del número de sectores:
- <1000 sectores: ~2-5 minutos
- 1000-5000 sectores: ~5-15 minutos
- >5000 sectores: ~15-30 minutos

## 📝 Notas Técnicas

### Manejo de Valores Faltantes

- Se imputan con la mediana (método robusto)
- Variables con varianza cero se eliminan automáticamente

### Estandarización

- Todas las variables se estandarizan (media=0, SD=1)
- Evita que variables con escalas grandes dominen el ACP

### Reproducibilidad

- El clustering usa `set.seed(123)` para resultados reproducibles
- Modificar la semilla en línea ~200 de `analisis_acp_clustering.R`

## 🤝 Soporte

Para problemas o preguntas:
1. Revisar mensajes de error en la consola
2. Verificar que los archivos de datos tienen el formato correcto
3. Consultar la sección de Preguntas Frecuentes

## 📄 Licencia

Este sistema fue desarrollado para análisis de indicadores de revitalización urbana.

---

**Versión del Sistema:** 1.0
**Última actualización:** 2025
**Desarrollado con:** R, Python, Shiny, Leaflet, Plotly
