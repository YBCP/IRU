# Dashboard IRU - HTML/JavaScript

Dashboard interactivo desarrollado con HTML5, CSS3, JavaScript vanilla y Chart.js para visualizar y analizar el Índice de Revitalización Urbana (IRU) de sectores catastrales.

## Características

### Visualizaciones Incluidas

1. **Resumen General**
   - 4 tarjetas de métricas clave (Total sectores, IRU promedio, máximo, mínimo)
   - Histograma de distribución del IRU con 30 bins
   - Gráfico de barras con Top 10 sectores de mayor IRU
   - Aproximación de box plot para distribución por ejes (E1, E2, E3)

2. **Análisis por Ejes**
   - Gráfico de dispersión (scatter plot) E1 vs E2
   - Gráfico circular (doughnut) con promedios de ejes
   - Gráfico de barras comparativo para Top 20 sectores

3. **Ámbitos (A1-A10)**
   - Selector de sector con dropdown interactivo
   - Gráfico radar (spider chart) con los 10 ámbitos del sector seleccionado
   - Gráfico de barras con valores de ámbitos

4. **Rankings**
   - Tabla Top 10 sectores con mayor IRU (verde)
   - Tabla Top 10 sectores con menor IRU (amarillo)
   - Filtro por rango de IRU con sliders duales
   - Contador dinámico de sectores filtrados

5. **Explorar Datos**
   - Tabla interactiva con todos los datos (1002 sectores)
   - Búsqueda en tiempo real por código o nombre
   - Ordenamiento múltiple (IRU, Código, Nombre)
   - Paginación automática (20 items por página)
   - Función de exportación a CSV

## Tecnologías Utilizadas

- **HTML5**: Estructura semántica del dashboard
- **CSS3**: Estilos personalizados y animaciones
- **JavaScript (ES6+)**: Lógica de aplicación
- **Bootstrap 5.3.2**: Framework CSS responsivo
- **Chart.js 4.4.0**: Librería de visualización de datos
- **Font Awesome 6.4.0**: Iconos vectoriales

## Estructura del Proyecto

```
IRU/
├── index.html                    # Página principal del dashboard
├── css/
│   └── style.css                # Estilos personalizados
├── js/
│   └── app.js                   # Lógica principal de la aplicación
├── data/
│   ├── iru_data.json           # Datos de sectores (generado)
│   └── stats.json              # Estadísticas resumidas (generado)
├── convert_to_json.py          # Script para convertir DBF a JSON
├── IRUSCV3.dbf                 # Datos originales DBF
├── Indicadores.xlsx            # Información de indicadores
└── README_DASHBOARD_HTML.md    # Este archivo
```

## Instalación y Uso

### Opción 1: Servidor Local con Python

```bash
# En el directorio del proyecto
python3 -m http.server 8000
```

Luego abrir en el navegador: http://localhost:8000

### Opción 2: Servidor Local con Node.js

```bash
# Instalar http-server globalmente
npm install -g http-server

# Ejecutar servidor
http-server -p 8000
```

Luego abrir en el navegador: http://localhost:8000

### Opción 3: Live Server (VS Code)

1. Instalar extensión "Live Server" en VS Code
2. Hacer clic derecho en `index.html`
3. Seleccionar "Open with Live Server"

### Opción 4: Abrir directamente

Abrir `index.html` directamente en el navegador (puede tener limitaciones por políticas CORS)

## Conversión de Datos

Los datos DBF deben convertirse a JSON antes de usar el dashboard:

```bash
# Instalar dependencia (si no está instalada)
pip install dbfread

# Ejecutar script de conversión
python3 convert_to_json.py
```

Esto creará:
- `data/iru_data.json` - Datos completos de 1002 sectores
- `data/stats.json` - Estadísticas resumidas

## Características Técnicas

### Responsivo

El dashboard se adapta automáticamente a diferentes tamaños de pantalla:
- Desktop (>768px): Vista completa con múltiples columnas
- Tablet (768px-576px): Vista adaptada a 2 columnas
- Móvil (<576px): Vista de 1 columna con navegación optimizada

### Rendimiento

- Carga asíncrona de datos con `fetch` API
- Renderizado eficiente con paginación
- Gráficos optimizados con Chart.js
- Actualización dinámica sin recargar página

### Interactividad

- **Tarjetas de estadísticas**: Efecto hover con elevación
- **Gráficos**: Tooltips informativos al pasar el mouse
- **Tablas**: Ordenamiento y búsqueda en tiempo real
- **Filtros**: Actualización instantánea con sliders
- **Selector de sector**: Actualización inmediata de gráficos radar y barras

## Funcionalidades Principales

### 1. Visualización de Datos

Todos los gráficos se crean dinámicamente con Chart.js:

```javascript
// Ejemplo: Histograma de IRU
const ctx = document.getElementById('iruHistogram').getContext('2d');
new Chart(ctx, {
    type: 'bar',
    data: { ... },
    options: { ... }
});
```

### 2. Búsqueda y Filtrado

```javascript
// Búsqueda en tiempo real
document.getElementById('searchInput').addEventListener('input', function(e) {
    const filtered = iruData.filter(d =>
        d.CodSec.includes(e.target.value) ||
        d.SCaNombre.includes(e.target.value)
    );
    renderDataTable(filtered);
});
```

### 3. Exportación a CSV

```javascript
function exportToCSV() {
    // Genera archivo CSV con todos los datos
    // Incluye: CodSec, SCaNombre, E1, E2, E3, IRU, AreaActual
}
```

## Personalización

### Cambiar Colores

Editar `css/style.css`:

```css
/* Colores principales */
.stat-card-primary { border-left: 4px solid #TU-COLOR; }
```

### Modificar Visualizaciones

Editar `js/app.js`:

```javascript
// Buscar la función del gráfico a modificar
function createIRUHistogram() {
    // Modificar configuración de Chart.js
}
```

### Agregar Nuevas Pestañas

1. Agregar tab en `index.html`:
```html
<li class="nav-item">
    <button class="nav-link" data-bs-target="#nueva-tab">Nueva Pestaña</button>
</li>
```

2. Agregar contenido:
```html
<div class="tab-pane fade" id="nueva-tab">
    <!-- Contenido aquí -->
</div>
```

3. Inicializar en `js/app.js`:
```javascript
function initializeNuevaTab() {
    // Lógica de inicialización
}
```

## Navegadores Compatibles

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Opera 76+

## Datos Visualizados

### Campos Principales

- **CodSec**: Código del sector catastral (6 dígitos)
- **SCaNombre**: Nombre del sector
- **E1**: Eje 1 - Hábitat (0-1)
- **E2**: Eje 2 - Funcionalidad (0-1)
- **E3**: Eje 3 - Sostenibilidad (0-1)
- **A1-A10**: Ámbitos del 1 al 10 (0-1)
- **IRU**: Índice de Revitalización Urbana (0-1)
- **AreaActual**: Área del sector en hectáreas

### Estadísticas del Dataset

```
Total de sectores: 1002
IRU promedio: 0.468
IRU máximo: 0.585
IRU mínimo: 0.311
```

## Solución de Problemas

### Los datos no cargan

1. Verificar que `data/iru_data.json` existe
2. Ejecutar `python3 convert_to_json.py`
3. Verificar que el servidor local esté corriendo
4. Revisar la consola del navegador (F12) para errores

### Error CORS

Si abres el archivo directamente (file://), puede haber errores CORS. Solución:
- Usar un servidor local (Python, Node.js, Live Server)

### Los gráficos no se muestran

1. Verificar conexión a internet (Chart.js se carga desde CDN)
2. Revisar consola del navegador
3. Verificar que Chart.js se cargó correctamente

### La tabla está vacía

1. Verificar que los datos se cargaron correctamente
2. Revisar filtros de búsqueda (limpiar búsqueda)
3. Verificar página actual de paginación

## Optimizaciones Futuras

- [ ] Agregar gráfico de mapa con sectores geográficos
- [ ] Implementar comparación entre múltiples sectores
- [ ] Agregar filtros avanzados por ejes y ámbitos
- [ ] Implementar modo oscuro (dark mode)
- [ ] Agregar más opciones de exportación (PDF, Excel)
- [ ] Implementar almacenamiento local (localStorage) para preferencias
- [ ] Agregar gráficos interactivos 3D con Three.js

## Licencia

Este proyecto está bajo la licencia especificada en el repositorio principal.

## Autor

Dashboard desarrollado para el análisis del Índice de Revitalización Urbana (IRU).

## Soporte

Para reportar problemas o sugerir mejoras, crear un issue en el repositorio del proyecto.
