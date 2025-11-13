# Dashboard IRU - Índice de Revitalización Urbana

Dashboard interactivo desarrollado en Python usando Dash y Plotly para visualizar y analizar el Índice de Revitalización Urbana (IRU) de sectores catastrales.

## Características

### Visualizaciones Incluidas

1. **Resumen General**
   - Tarjetas con métricas clave (Total sectores, IRU promedio, máximo y mínimo)
   - Histograma de distribución del IRU
   - Top 10 sectores con mayor IRU
   - Distribución por ejes (E1, E2, E3) con box plots

2. **Análisis por Ejes**
   - Gráfico 3D interactivo de relación entre los tres ejes
   - Matriz de correlación entre ejes e IRU
   - Comparación de valores de ejes para los top 20 sectores

3. **Ámbitos (A1-A10)**
   - Selector de sector interactivo
   - Gráfico radar con los 10 ámbitos del sector seleccionado
   - Gráfico de barras comparativo de ámbitos

4. **Rankings**
   - Tablas interactivas con top 10 y bottom 10 sectores
   - Filtro por rango de IRU con slider interactivo
   - Contador de sectores filtrados

5. **Explorar Datos**
   - Tabla interactiva con todos los datos
   - Funcionalidad de filtrado y ordenamiento
   - Paginación automática

## Requisitos

Las dependencias están listadas en `requirements.txt`:

```
pandas==2.1.4
openpyxl==3.1.2
dbfread==2.0.7
plotly==5.18.0
dash==2.14.2
dash-bootstrap-components==1.5.0
numpy==1.26.3
```

## Instalación

1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd IRU
```

2. Instalar dependencias

```bash
pip install -r requirements.txt
```

## Uso

### Ejecutar el Dashboard

```bash
python dashboard.py
```

El dashboard estará disponible en: http://127.0.0.1:8050

### Explorar los Datos

Para explorar la estructura de los datos antes de usar el dashboard:

```bash
python explore_data.py
```

## Estructura del Proyecto

```
IRU/
├── dashboard.py              # Aplicación principal del dashboard
├── data_processor.py         # Módulo de procesamiento de datos
├── explore_data.py          # Script para explorar datos
├── requirements.txt         # Dependencias del proyecto
├── IRUSCV3.dbf             # Datos de sectores catastrales
├── Indicadores.xlsx        # Información de indicadores
└── README_DASHBOARD_PYTHON.md  # Este archivo
```

## Arquitectura del Código

### `data_processor.py`

Clase `IRUDataProcessor` que gestiona la carga y procesamiento de datos:

- `load_data()`: Carga archivos DBF y Excel
- `get_sector_summary()`: Estadísticas resumidas
- `get_top_sectores()`: Top N sectores por métrica
- `get_bottom_sectores()`: Bottom N sectores por métrica
- `get_ejes_data()`: Datos de ejes E1, E2, E3
- `get_ambitos_data()`: Datos de ámbitos A1-A10
- `filter_by_iru_range()`: Filtrado por rango de IRU
- `get_correlation_matrix()`: Matriz de correlación

### `dashboard.py`

Aplicación Dash con diseño responsivo usando Bootstrap:

- Layout principal con 5 pestañas
- Callbacks interactivos para actualizar visualizaciones
- Gráficos con Plotly Express y Plotly Graph Objects
- Tablas interactivas con dash_table

## Datos Utilizados

### Archivo DBF (IRUSCV3.dbf)

Contiene información geoespacial y valores calculados para cada sector catastral:

- **CodSec**: Código del sector
- **SCaNombre**: Nombre del sector
- **E1, E2, E3**: Valores de los tres ejes principales
- **A1-A10**: Valores de los 10 ámbitos
- **IRU**: Índice de Revitalización Urbana calculado
- **AreaActual**: Área del sector en hectáreas
- **Rev_XXXX**: Múltiples indicadores de revitalización

### Archivo Excel (Indicadores.xlsx)

Contiene metadata y definiciones de los indicadores:

- Hojas con descripción de ejes y ámbitos
- Fichas metodológicas de indicadores
- Áreas temáticas y temas

## Métricas Principales

- **IRU (Índice de Revitalización Urbana)**: Valor entre 0 y 1 que representa el nivel de revitalización
- **E1, E2, E3**: Tres ejes principales que componen el IRU
- **A1-A10**: Diez ámbitos que detallan diferentes aspectos urbanos

## Personalización

### Cambiar el Puerto

Editar la última línea de `dashboard.py`:

```python
app.run_server(debug=True, host='0.0.0.0', port=8050)  # Cambiar 8050 por el puerto deseado
```

### Modificar Visualizaciones

Los callbacks en `dashboard.py` controlan cada visualización. Buscar el callback correspondiente y modificar el código de Plotly.

### Agregar Nuevas Pestañas

Agregar un nuevo `dbc.Tab` en el layout de `dashboard.py` y crear los callbacks necesarios.

## Solución de Problemas

### Error: ModuleNotFoundError

Asegurarse de instalar todas las dependencias:
```bash
pip install -r requirements.txt
```

### Error al leer archivos DBF

Verificar que el archivo `IRUSCV3.dbf` esté en el directorio correcto y tenga permisos de lectura.

### Dashboard no carga

1. Verificar que el puerto 8050 no esté en uso
2. Revisar la consola para mensajes de error
3. Confirmar que los archivos de datos existan

## Tecnologías Utilizadas

- **Python 3.x**: Lenguaje de programación
- **Dash**: Framework para dashboards interactivos
- **Plotly**: Biblioteca de visualización
- **Pandas**: Procesamiento de datos
- **Bootstrap**: Diseño responsivo

## Autor

Dashboard desarrollado para el análisis del Índice de Revitalización Urbana (IRU).

## Licencia

Este proyecto está bajo la licencia especificada en el repositorio principal.
