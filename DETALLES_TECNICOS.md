# Detalles Técnicos del Sistema IRU

## Metodología Estadística Detallada

### 1. Análisis de Componentes Principales Robusto

#### ¿Por qué ACP Robusto?

El ACP robusto (método Hubert - `PcaHubert`) se utiliza en lugar del ACP clásico porque:

1. **Resistencia a outliers**: Los datos urbanos suelen contener valores atípicos que pueden distorsionar el análisis clásico
2. **Estimación robusta de covarianzas**: Utiliza la Minimum Covariance Determinant (MCD)
3. **Proyección robusta**: Los scores se calculan de manera que minimizan la influencia de observaciones extremas

#### Parámetros del ACP

```r
PcaHubert(
  datos_scaled,                    # Datos estandarizados
  k = min(10, ncol(datos_scaled)), # Máximo 10 componentes
  kmax = min(10, ncol(datos_scaled))
)
```

#### Criterio de Selección de Componentes

- **Umbral**: Se seleccionan componentes que expliquen ≥70% de varianza acumulada
- **Justificación**: Balance entre reducción de dimensionalidad y retención de información
- **Alternativas**: Puedes modificar este umbral en `analisis_acp_clustering.R` línea ~150

### 2. Clustering K-means

#### Criterios de Selección del Número Óptimo de Clusters

El sistema evalúa **tres métodos** simultáneamente:

##### A. Varianza Entre Grupos (Criterio Principal)

```r
varianza_entre = betweenss / totss * 100
```

- **Objetivo**: Encontrar k donde varianza_entre > 50%
- **Interpretación**: Los clusters explican más de la mitad de la variabilidad total
- **Ventaja**: Garantiza clusters bien diferenciados

##### B. Coeficiente de Silueta

```r
sil_scores = mean(silhouette(cluster_assignment, distances))
```

- **Rango**: [-1, 1]
- **Interpretación**:
  - > 0.7: Estructura fuerte
  - 0.5-0.7: Estructura razonable
  - 0.25-0.5: Estructura débil
  - < 0.25: Sin estructura clara

##### C. Método del Codo (Elbow Method)

```r
WSS = sum(within_sum_of_squares)
```

- **Criterio**: Buscar el "codo" donde WSS deja de decrecer significativamente
- **Visual**: Gráfico en `resultados/metodo_codo.png`

#### Parámetros del K-means

```r
kmeans(
  datos_clustering,  # Componentes principales seleccionadas
  centers = k,       # Número de clusters
  nstart = 50        # 50 inicializaciones aleatorias (robustez)
)
```

### 3. Caracterización de Clusters

#### Metodología

Para cada cluster k:

1. **Calcular medias** de todas las variables Rev_ en ese cluster
2. **Identificar top 5** variables con valores más altos
3. **Vincular con metadatos** del archivo Indicadores.xlsx:
   - Nombre descriptivo
   - Siglas
   - Eje temático
   - Ámbito
4. **Generar descripción** en lenguaje natural

#### Estructura de Caracterización

```json
{
  "Cluster_1": {
    "n_sectores": 150,
    "porcentaje": 15.0,
    "variables_caracteristicas": {
      "Rev_2526": {
        "codigo": "2526",
        "nombre": "Densidad poblacional",
        "valor_medio": 0.823,
        "eje": "Hábitat",
        "ambito": "Espacio público"
      },
      ...
    }
  }
}
```

### 4. Conversión Espacial

#### Proceso de Conversión Shapefile → GeoJSON

1. **Lectura**: `geopandas.read_file()` con encoding UTF-8
2. **Reproyección**: Transformación a WGS84 (EPSG:4326) para compatibilidad web
3. **Merge**: Unión con resultados de clustering por código de sector
4. **Enriquecimiento**: Añadir propiedades de caracterización
5. **Exportación**: Formato GeoJSON con estructura FeatureCollection

#### Estructura GeoJSON

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {...},
      "properties": {
        "codigo": "SECTOR_001",
        "nombre": "Nombre del sector",
        "cluster": 1,
        "cluster_nombre": "Cluster 1",
        "cluster_color": "#e41a1c",
        "variables_caracteristicas": [...]
      }
    }
  ]
}
```

## Arquitectura del Dashboard

### Tecnologías Utilizadas

- **Framework**: Shiny (R)
- **Layout**: shinydashboard
- **Mapas**: Leaflet
- **Gráficos**: Plotly
- **Tablas**: DT (DataTables)

### Estructura del Código

```
dashboard_iru.R
├── UI (Interfaz de Usuario)
│   ├── Header (Título)
│   ├── Sidebar (Deshabilitada)
│   └── Body
│       ├── TabPanel 1: Resultados
│       ├── TabPanel 2: Info Técnica
│       └── TabPanel 3: Mapa
│
└── Server (Lógica)
    ├── Métricas reactivas
    ├── Gráficos Plotly
    ├── Tablas DT
    └── Mapa Leaflet
```

### Componentes Reactivos

```r
# Ejemplo de componente reactivo
output$plot_varianza_explicada <- renderPlotly({
  # Código que se ejecuta cuando cambian los datos
})
```

## Optimizaciones y Consideraciones

### Rendimiento

1. **Caché de resultados**: Los resultados se guardan en JSON/CSV para reutilización
2. **K-means con múltiples inicializaciones**: `nstart=50` para evitar mínimos locales
3. **Vectorización en R**: Uso de `apply()` y funciones vectorizadas
4. **Lazy loading**: El dashboard solo carga datos cuando son necesarios

### Escalabilidad

**Límites aproximados**:
- Sectores: Hasta ~10,000 sin problemas
- Variables: Hasta ~100 variables Rev_
- Clusters: Automático, típicamente 3-10

**Para datasets más grandes**:
- Considerar muestreo estratificado
- Usar PCA incremental
- Implementar clustering jerárquico

### Reproducibilidad

```r
set.seed(123)  # Fija semilla aleatoria
```

Todos los resultados son reproducibles debido a:
1. Semilla fija para K-means
2. Mismos parámetros de ACP
3. Proceso determinístico de caracterización

## Validación del Análisis

### Checks Automáticos

El código incluye validaciones automáticas:

```r
# Verificar valores faltantes
na_count <- colSums(is.na(datos))

# Verificar varianza cero
var_cols <- apply(datos, 2, var) > 0

# Verificar número de componentes
if (n_componentes_70 > ncol(datos)) {
  stop("Número de componentes excede dimensionalidad")
}
```

### Métricas de Calidad

1. **Varianza explicada**: Debe ser >70% con componentes seleccionadas
2. **Varianza entre clusters**: Debe ser >50%
3. **Tamaño de clusters**: Ningún cluster debe tener <1% de observaciones
4. **Coeficiente de silueta**: Idealmente >0.5

## Interpretación de Resultados

### Componentes Principales

**PC1** (Primera componente):
- Captura la mayor variabilidad
- Suele representar un "factor general"
- Valores altos/bajos indican sectores con características urbanas intensas/débiles

**PC2** (Segunda componente):
- Captura variabilidad ortogonal a PC1
- Suele representar un contraste o dimensión complementaria

### Clusters

**Interpretación**:
- Clusters con valores altos en variables de infraestructura → Sectores desarrollados
- Clusters con valores altos en variables ambientales → Sectores con calidad ambiental
- Clusters mixtos → Perfiles urbanos específicos

### Mapa

**Patrones espaciales**:
- Clusters contiguos → Procesos de segregación/homogeneización espacial
- Clusters dispersos → Heterogeneidad urbana
- Gradientes → Transiciones urbanas (centro-periferia)

## Extensiones Posibles

### Análisis Adicionales

1. **Clustering jerárquico**: Para dendrogramas y estructura anidada
2. **DBSCAN**: Para clusters de forma arbitraria
3. **Análisis discriminante**: Para identificar variables más importantes
4. **Regresión espacial**: Para modelar autocorrelación espacial

### Mejoras del Dashboard

1. **Filtros interactivos**: Filtrar por eje, ámbito, rango de valores
2. **Comparación temporal**: Si hay datos de múltiples años
3. **Exportación de reportes**: PDF automático con resultados
4. **API REST**: Para integración con otros sistemas

## Solución de Problemas Técnicos

### Error: "No se puede encontrar la función 'PcaHubert'"

**Solución**:
```r
install.packages("pcaPP")
library(pcaPP)
```

### Error: "Geometrías inválidas en shapefile"

**Solución**:
```python
gdf = gdf[gdf.is_valid]  # Filtrar geometrías válidas
```

### Warning: "Convergencia de K-means no alcanzada"

**Solución**:
- Aumentar `nstart` (línea ~200)
- Aumentar `iter.max` en kmeans

### Dashboard no carga el mapa

**Posibles causas**:
1. GeoJSON no generado → ejecutar `convertir_shapefile.py`
2. Archivo GeoJSON corrupto → verificar validez JSON
3. Problemas de proyección → verificar EPSG:4326

## Referencias Metodológicas

### ACP Robusto
- Hubert, M., Rousseeuw, P.J., & Vanden Branden, K. (2005). "ROBPCA: A new approach to robust principal component analysis". Technometrics, 47(1), 64-79.

### Clustering
- Hartigan, J.A., & Wong, M.A. (1979). "Algorithm AS 136: A K-Means Clustering Algorithm". Journal of the Royal Statistical Society, Series C, 28(1), 100-108.

### Silueta
- Rousseeuw, P.J. (1987). "Silhouettes: a Graphical Aid to the Interpretation and Validation of Cluster Analysis". Computational and Applied Mathematics, 20, 53-65.

## Contacto y Soporte

Para preguntas técnicas, consultar:
- Documentación de R: https://www.r-project.org/
- Documentación de Shiny: https://shiny.rstudio.com/
- Geopandas: https://geopandas.org/

---

**Versión**: 1.0
**Última actualización**: 2025
