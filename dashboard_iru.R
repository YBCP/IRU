# ==============================================================================
# DASHBOARD INTERACTIVO - ANÁLISIS IRU
# ==============================================================================
# Dashboard con tres pestañas para visualización de resultados del ACP robusto
# y clustering de indicadores urbanos (IRU):
# 1. Resultados del ACP y Clustering
# 2. Información Técnica del Análisis
# 3. Mapa Interactivo de Clusters
# ==============================================================================

# ------------------------------------------------------------------------------
# INSTALACIÓN Y CARGA DE LIBRERÍAS
# ------------------------------------------------------------------------------

packages <- c(
  "shiny",           # Framework para aplicaciones web interactivas
  "shinydashboard",  # Diseño de dashboard
  "leaflet",         # Mapas interactivos
  "plotly",          # Gráficos interactivos
  "DT",              # Tablas interactivas
  "jsonlite",        # Leer archivos JSON
  "dplyr",           # Manipulación de datos
  "ggplot2",         # Visualización de datos
  "scales",          # Escalas para gráficos
  "readr",           # Lectura de archivos CSV
  "tidyr"            # Limpieza de datos
)

install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

cat("Cargando librerías...\n")
invisible(sapply(packages, install_if_missing))

# ------------------------------------------------------------------------------
# CARGA DE DATOS
# ------------------------------------------------------------------------------

cat("Cargando datos del análisis...\n")

# Cargar resultados del ACP
resultados_acp <- fromJSON("resultados/resultados_acp.json")

# Cargar resultados del clustering
resultados_clustering <- fromJSON("resultados/resultados_clustering.json")

# Cargar datos con clusters asignados
datos_clusters <- read_csv("resultados/datos_con_clusters.csv", show_col_types = FALSE)

# Cargar GeoJSON de sectores
geojson_sectores <- fromJSON("resultados/sectores_geojson.json")

# Cargar resumen de clusters
resumen_clusters <- fromJSON("resultados/resumen_clusters.json")

cat("✓ Datos cargados exitosamente\n")

# ------------------------------------------------------------------------------
# INTERFAZ DE USUARIO (UI)
# ------------------------------------------------------------------------------

ui <- dashboardPage(

  # Encabezado
  dashboardHeader(
    title = "Dashboard IRU - Análisis de Revitalización Urbana",
    titleWidth = 450
  ),

  # Sin barra lateral
  dashboardSidebar(disable = TRUE),

  # Cuerpo del dashboard
  dashboardBody(

    # CSS personalizado
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #f4f6f9; }
        .box { box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .info-box { box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .cluster-legend {
          padding: 10px;
          background: white;
          border-radius: 5px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .cluster-item {
          margin-bottom: 8px;
          padding: 5px;
          border-left: 4px solid;
        }
        .metric-card {
          background: white;
          padding: 15px;
          border-radius: 5px;
          margin-bottom: 15px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .metric-value {
          font-size: 32px;
          font-weight: bold;
          color: #3c8dbc;
        }
        .metric-label {
          font-size: 14px;
          color: #666;
          margin-top: 5px;
        }
      "))
    ),

    # Pestañas principales
    tabBox(
      width = 12,

      # ========================================================================
      # PESTAÑA 1: RESULTADOS DEL ACP Y CLUSTERING
      # ========================================================================
      tabPanel(
        title = tagList(icon("chart-bar"), "Resultados del Análisis"),

        # Fila de métricas resumen
        fluidRow(
          column(3,
            div(class = "metric-card",
              div(class = "metric-value", textOutput("total_sectores")),
              div(class = "metric-label", "Sectores Analizados")
            )
          ),
          column(3,
            div(class = "metric-card",
              div(class = "metric-value", textOutput("n_clusters")),
              div(class = "metric-label", "Clusters Identificados")
            )
          ),
          column(3,
            div(class = "metric-card",
              div(class = "metric-value", textOutput("varianza_clusters")),
              div(class = "metric-label", "Varianza Explicada por Clusters")
            )
          ),
          column(3,
            div(class = "metric-card",
              div(class = "metric-value", textOutput("n_componentes")),
              div(class = "metric-label", "Componentes Principales (>70% var)")
            )
          )
        ),

        # Gráficos principales
        fluidRow(
          box(
            title = "Varianza Explicada por Componentes Principales",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("plot_varianza_explicada", height = "400px")
          ),
          box(
            title = "Distribución de Sectores por Cluster",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("plot_distribucion_clusters", height = "400px")
          )
        ),

        fluidRow(
          box(
            title = "Biplot del ACP - Distribución en Componentes Principales",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("plot_biplot", height = "500px")
          )
        ),

        fluidRow(
          box(
            title = "Caracterización de Clusters",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            uiOutput("caracterizacion_clusters_ui")
          )
        )
      ),

      # ========================================================================
      # PESTAÑA 2: INFORMACIÓN TÉCNICA
      # ========================================================================
      tabPanel(
        title = tagList(icon("info-circle"), "Información Técnica"),

        fluidRow(
          box(
            title = "Metodología del Análisis",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            HTML("
              <h4>Análisis de Componentes Principales (ACP) Robusto</h4>
              <p>El ACP robusto utiliza el método de Hubert para reducir la sensibilidad
              a valores atípicos. Este método es especialmente útil cuando trabajamos con
              datos urbanos que pueden contener observaciones extremas.</p>

              <h5>Pasos del análisis:</h5>
              <ol>
                <li><b>Selección de variables:</b> Se utilizaron únicamente las variables
                    que comienzan con 'Rev_', correspondientes a indicadores de revitalización urbana.</li>
                <li><b>Estandarización:</b> Las variables se estandarizaron (media=0, SD=1)
                    para evitar que las escalas afecten el análisis.</li>
                <li><b>ACP Robusto:</b> Se aplicó el método PcaHubert para obtener componentes
                    principales menos sensibles a valores atípicos.</li>
                <li><b>Selección de componentes:</b> Se seleccionaron los componentes que
                    explican al menos el 70% de la varianza total.</li>
              </ol>

              <h4>Clustering No Supervisado</h4>
              <p>El clustering se realizó utilizando el algoritmo K-means sobre las componentes
              principales seleccionadas. El número óptimo de clusters se determinó automáticamente
              buscando el valor k que maximice la varianza entre grupos (>50%).</p>

              <h5>Criterios de selección del número de clusters:</h5>
              <ul>
                <li><b>Varianza entre grupos:</b> Se busca k donde la varianza entre grupos
                    supere el 50% de la varianza total.</li>
                <li><b>Coeficiente de silueta:</b> Mide qué tan bien está asignado cada
                    sector a su cluster.</li>
                <li><b>Método del codo:</b> Identifica el punto donde añadir más clusters
                    no mejora significativamente la explicación de varianza.</li>
              </ul>
            ")
          )
        ),

        fluidRow(
          box(
            title = "Varianza Explicada por Componente",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            DTOutput("tabla_varianza")
          ),
          box(
            title = "Tamaño de Clusters",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            DTOutput("tabla_tamanos_clusters")
          )
        ),

        fluidRow(
          box(
            title = "Métodos de Determinación del Número Óptimo de Clusters",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("plot_metodos_clustering", height = "400px")
          )
        ),

        fluidRow(
          box(
            title = "Principales Variables por Componente",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("tabla_loadings")
          )
        )
      ),

      # ========================================================================
      # PESTAÑA 3: MAPA INTERACTIVO
      # ========================================================================
      tabPanel(
        title = tagList(icon("map"), "Mapa de Clusters"),

        fluidRow(
          column(9,
            box(
              title = "Mapa Interactivo de Sectores Catastrales por Cluster",
              status = "primary",
              solidHeader = TRUE,
              width = NULL,
              leafletOutput("mapa_clusters", height = "700px")
            )
          ),
          column(3,
            box(
              title = "Leyenda de Clusters",
              status = "info",
              solidHeader = TRUE,
              width = NULL,
              uiOutput("leyenda_clusters")
            ),
            box(
              title = "Información del Sector Seleccionado",
              status = "warning",
              solidHeader = TRUE,
              width = NULL,
              uiOutput("info_sector_seleccionado")
            )
          )
        )
      )
    )
  )
)

# ------------------------------------------------------------------------------
# SERVIDOR
# ------------------------------------------------------------------------------

server <- function(input, output, session) {

  # ============================================================================
  # MÉTRICAS RESUMEN
  # ============================================================================

  output$total_sectores <- renderText({
    format(nrow(datos_clusters), big.mark = ",")
  })

  output$n_clusters <- renderText({
    as.character(resultados_clustering$k_optimo)
  })

  output$varianza_clusters <- renderText({
    paste0(round(resultados_clustering$varianza_entre_grupos, 1), "%")
  })

  output$n_componentes <- renderText({
    as.character(resultados_acp$n_componentes_optimo)
  })

  # ============================================================================
  # GRÁFICOS - PESTAÑA 1
  # ============================================================================

  # Gráfico de varianza explicada
  output$plot_varianza_explicada <- renderPlotly({
    df <- resultados_acp$varianza_explicada
    df <- df[1:min(10, nrow(df)), ]

    p <- plot_ly(df, x = ~Componente, y = ~Varianza_Porcentaje,
                 type = 'bar', name = 'Varianza Individual',
                 marker = list(color = '#3498db')) %>%
      add_trace(y = ~Varianza_Acumulada, type = 'scatter', mode = 'lines+markers',
                name = 'Varianza Acumulada', yaxis = 'y2',
                line = list(color = '#e74c3c', width = 3),
                marker = list(size = 8)) %>%
      layout(
        yaxis = list(title = 'Varianza Individual (%)', side = 'left'),
        yaxis2 = list(title = 'Varianza Acumulada (%)', overlaying = 'y', side = 'right'),
        xaxis = list(title = 'Componente Principal'),
        hovermode = 'x unified',
        legend = list(x = 0.7, y = 1)
      )

    p
  })

  # Gráfico de distribución de clusters
  output$plot_distribucion_clusters <- renderPlotly({
    cluster_counts <- table(datos_clusters$Cluster)
    df <- data.frame(
      Cluster = paste("Cluster", names(cluster_counts)),
      Sectores = as.numeric(cluster_counts),
      Porcentaje = as.numeric(cluster_counts) / sum(cluster_counts) * 100
    )

    # Obtener colores de los clusters
    colores <- sapply(1:length(cluster_counts), function(i) {
      cluster_key <- as.character(i)
      if (cluster_key %in% names(resumen_clusters)) {
        resumen_clusters[[cluster_key]]$color
      } else {
        "#999999"
      }
    })

    p <- plot_ly(df, x = ~Cluster, y = ~Sectores, type = 'bar',
                 marker = list(color = colores),
                 text = ~paste0(round(Porcentaje, 1), "%"),
                 textposition = 'outside',
                 hovertemplate = paste(
                   '<b>%{x}</b><br>',
                   'Sectores: %{y}<br>',
                   'Porcentaje: %{text}<br>',
                   '<extra></extra>'
                 )) %>%
      layout(
        xaxis = list(title = ''),
        yaxis = list(title = 'Número de Sectores'),
        hovermode = 'closest'
      )

    p
  })

  # Biplot del ACP
  output$plot_biplot <- renderPlotly({
    df <- data.frame(
      PC1 = datos_clusters$PC1,
      PC2 = datos_clusters$PC2,
      Cluster = factor(datos_clusters$Cluster),
      Sector = datos_clusters$Sector
    )

    # Obtener colores
    colores <- sapply(unique(df$Cluster), function(c) {
      cluster_key <- as.character(c)
      if (cluster_key %in% names(resumen_clusters)) {
        resumen_clusters[[cluster_key]]$color
      } else {
        "#999999"
      }
    })

    p <- plot_ly(df, x = ~PC1, y = ~PC2, color = ~Cluster,
                 colors = colores,
                 type = 'scatter', mode = 'markers',
                 marker = list(size = 8, opacity = 0.6),
                 text = ~Sector,
                 hovertemplate = paste(
                   '<b>%{text}</b><br>',
                   'PC1: %{x:.3f}<br>',
                   'PC2: %{y:.3f}<br>',
                   '<extra>Cluster %{marker.color}</extra>'
                 )) %>%
      layout(
        xaxis = list(
          title = sprintf('Componente Principal 1 (%.1f%% varianza)',
                         resultados_acp$varianza_explicada$Varianza_Porcentaje[1])
        ),
        yaxis = list(
          title = sprintf('Componente Principal 2 (%.1f%% varianza)',
                         resultados_acp$varianza_explicada$Varianza_Porcentaje[2])
        ),
        hovermode = 'closest',
        showlegend = TRUE
      )

    p
  })

  # Caracterización de clusters (UI dinámico)
  output$caracterizacion_clusters_ui <- renderUI({
    k <- resultados_clustering$k_optimo

    panels <- lapply(1:k, function(i) {
      cluster_key <- as.character(i)

      if (cluster_key %in% names(resumen_clusters)) {
        info <- resumen_clusters[[cluster_key]]

        # Crear tabla de características
        if (length(info$caracteristicas_principales) > 0) {
          caract_df <- do.call(rbind, lapply(info$caracteristicas_principales, function(x) {
            data.frame(
              Indicador = x$nombre,
              Siglas = x$siglas,
              Valor = round(x$valor, 3),
              Eje = x$eje,
              Ambito = x$ambito
            )
          }))

          caract_html <- knitr::kable(caract_df, format = "html", row.names = FALSE) %>%
            as.character()
        } else {
          caract_html <- "<p>Sin información de características</p>"
        }

        box(
          title = sprintf("Cluster %d", i),
          status = "info",
          solidHeader = TRUE,
          width = 12,
          collapsible = TRUE,
          collapsed = (i > 1),  # Solo el primero expandido por defecto
          HTML(sprintf("
            <div style='border-left: 5px solid %s; padding-left: 15px; margin-bottom: 15px;'>
              <h4>%s</h4>
              <p><b>Sectores:</b> %d (%.1f%%)</p>
              <p><b>Descripción:</b> %s</p>
              <h5>Variables Características Principales:</h5>
              %s
            </div>
          ", info$color, info$nombre, info$n_sectores, info$porcentaje,
             info$descripcion, caract_html))
        )
      }
    })

    do.call(tagList, panels)
  })

  # ============================================================================
  # TABLAS - PESTAÑA 2
  # ============================================================================

  # Tabla de varianza explicada
  output$tabla_varianza <- renderDT({
    df <- resultados_acp$varianza_explicada[1:min(10, nrow(resultados_acp$varianza_explicada)), ]
    df$Varianza_Porcentaje <- round(df$Varianza_Porcentaje, 2)
    df$Varianza_Acumulada <- round(df$Varianza_Acumulada, 2)

    datatable(df,
              colnames = c('Componente', 'Varianza (%)', 'Varianza Acum. (%)'),
              options = list(
                pageLength = 10,
                dom = 't',
                ordering = FALSE
              ),
              rownames = FALSE) %>%
      formatStyle('Varianza_Porcentaje',
                  background = styleColorBar(df$Varianza_Porcentaje, '#3498db'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })

  # Tabla de tamaños de clusters
  output$tabla_tamanos_clusters <- renderDT({
    cluster_counts <- table(datos_clusters$Cluster)
    df <- data.frame(
      Cluster = paste("Cluster", names(cluster_counts)),
      Sectores = as.numeric(cluster_counts),
      Porcentaje = round(as.numeric(cluster_counts) / sum(cluster_counts) * 100, 2)
    )

    datatable(df,
              colnames = c('Cluster', 'N° Sectores', 'Porcentaje (%)'),
              options = list(
                pageLength = 15,
                dom = 't',
                ordering = FALSE
              ),
              rownames = FALSE) %>%
      formatStyle('Porcentaje',
                  background = styleColorBar(df$Porcentaje, '#27ae60'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })

  # Tabla de loadings
  output$tabla_loadings <- renderDT({
    df <- resultados_acp$loadings
    df_numeric <- df[, grep("^PC", names(df))]
    df_numeric <- round(df_numeric, 4)
    df_final <- cbind(Variable = df$Variable, df_numeric[, 1:min(5, ncol(df_numeric))])

    datatable(df_final,
              options = list(
                pageLength = 10,
                scrollX = TRUE,
                order = list(list(1, 'desc'))
              ),
              rownames = FALSE) %>%
      formatStyle(columns = 2:ncol(df_final),
                  background = styleColorBar(range(df_numeric), '#9b59b6'),
                  backgroundSize = '100% 90%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })

  # Gráfico de métodos de clustering
  output$plot_metodos_clustering <- renderPlotly({
    # Este gráfico requeriría datos adicionales del análisis
    # Por ahora, mostramos un placeholder
    plot_ly() %>%
      add_annotations(
        text = "Gráficos comparativos de métodos de clustering<br>(Requiere datos adicionales)",
        xref = "paper", yref = "paper",
        x = 0.5, y = 0.5,
        xanchor = "center", yanchor = "middle",
        showarrow = FALSE,
        font = list(size = 16, color = "#999999")
      ) %>%
      layout(
        xaxis = list(showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE),
        yaxis = list(showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE)
      )
  })

  # ============================================================================
  # MAPA - PESTAÑA 3
  # ============================================================================

  # Variable reactiva para el sector seleccionado
  sector_seleccionado <- reactiveVal(NULL)

  # Mapa de clusters
  output$mapa_clusters <- renderLeaflet({
    # Crear mapa base
    mapa <- leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -75.5, lat = 6.25, zoom = 12)  # Centrado en Medellín (ajustar según necesidad)

    # Añadir polígonos de sectores
    for (i in 1:length(geojson_sectores$features)) {
      feature <- geojson_sectores$features[[i]]
      props <- feature$properties

      # Color del cluster
      color_cluster <- props$cluster_color

      # Crear popup con información
      popup_html <- sprintf("
        <div style='font-family: Arial; min-width: 250px;'>
          <h4 style='margin: 0 0 10px 0; color: %s; border-bottom: 2px solid %s; padding-bottom: 5px;'>
            %s
          </h4>
          <p style='margin: 5px 0;'><b>Código:</b> %s</p>
          <p style='margin: 5px 0;'><b>Cluster:</b> %s</p>
          <p style='margin: 5px 0;'><b>Descripción:</b> %s</p>
          <p style='margin: 10px 0 5px 0;'><b>Variables características:</b></p>
          <ul style='margin: 0; padding-left: 20px;'>
            %s
          </ul>
        </div>
      ",
        color_cluster,
        color_cluster,
        props$nombre,
        props$codigo,
        props$cluster_nombre,
        props$cluster_descripcion,
        paste(sapply(props$variables_caracteristicas, function(v) {
          sprintf("<li>%s: %.3f (%s - %s)</li>", v$nombre, v$valor, v$eje, v$ambito)
        }), collapse = "")
      )

      # Añadir polígono al mapa
      mapa <- mapa %>%
        addPolygons(
          data = feature$geometry,
          fillColor = color_cluster,
          fillOpacity = 0.6,
          color = "#333333",
          weight = 1,
          opacity = 0.8,
          highlightOptions = highlightOptions(
            weight = 3,
            color = "#666",
            fillOpacity = 0.8,
            bringToFront = TRUE
          ),
          popup = popup_html,
          layerId = props$codigo,
          label = props$nombre,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "12px",
            direction = "auto"
          )
        )
    }

    mapa
  })

  # Leyenda de clusters
  output$leyenda_clusters <- renderUI({
    k <- resultados_clustering$k_optimo

    items <- lapply(1:k, function(i) {
      cluster_key <- as.character(i)

      if (cluster_key %in% names(resumen_clusters)) {
        info <- resumen_clusters[[cluster_key]]

        div(
          class = "cluster-item",
          style = sprintf("border-color: %s;", info$color),
          HTML(sprintf("
            <div style='display: flex; align-items: center;'>
              <div style='width: 20px; height: 20px; background-color: %s; margin-right: 10px; border-radius: 3px;'></div>
              <div>
                <strong>%s</strong><br>
                <small>%d sectores (%.1f%%)</small>
              </div>
            </div>
          ", info$color, info$nombre, info$n_sectores, info$porcentaje))
        )
      }
    })

    div(class = "cluster-legend", do.call(tagList, items))
  })

  # Observar clics en el mapa
  observeEvent(input$mapa_clusters_shape_click, {
    click <- input$mapa_clusters_shape_click
    if (!is.null(click)) {
      sector_seleccionado(click$id)
    }
  })

  # Información del sector seleccionado
  output$info_sector_seleccionado <- renderUI({
    sector_id <- sector_seleccionado()

    if (is.null(sector_id)) {
      return(HTML("<p style='text-align: center; color: #999; padding: 20px;'>
                   Haga clic en un sector del mapa para ver su información detallada</p>"))
    }

    # Buscar información del sector
    feature <- NULL
    for (i in 1:length(geojson_sectores$features)) {
      if (geojson_sectores$features[[i]]$properties$codigo == sector_id) {
        feature <- geojson_sectores$features[[i]]
        break
      }
    }

    if (is.null(feature)) {
      return(HTML("<p>Sector no encontrado</p>"))
    }

    props <- feature$properties

    # Crear lista de variables características
    vars_html <- if (length(props$variables_caracteristicas) > 0) {
      paste(sapply(props$variables_caracteristicas, function(v) {
        sprintf("<tr><td>%s</td><td>%.3f</td><td>%s</td></tr>",
                v$nombre, v$valor, v$eje)
      }), collapse = "")
    } else {
      "<tr><td colspan='3'>No disponible</td></tr>"
    }

    HTML(sprintf("
      <div style='padding: 10px;'>
        <h4 style='margin-top: 0; color: %s;'>%s</h4>
        <p><strong>Código:</strong> %s</p>
        <p><strong>Cluster:</strong> %s</p>
        <p><strong>Descripción:</strong><br><small>%s</small></p>
        <hr>
        <p><strong>Variables características:</strong></p>
        <table style='width: 100%%; font-size: 11px;'>
          <thead>
            <tr style='background: #f4f4f4;'>
              <th>Variable</th>
              <th>Valor</th>
              <th>Eje</th>
            </tr>
          </thead>
          <tbody>
            %s
          </tbody>
        </table>
      </div>
    ", props$cluster_color, props$nombre, props$codigo,
       props$cluster_nombre, props$cluster_descripcion, vars_html))
  })
}

# ------------------------------------------------------------------------------
# EJECUTAR APLICACIÓN
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 70), "\n", sep = "")
cat("Iniciando Dashboard IRU...\n")
cat(rep("=", 70), "\n", sep = "")
cat("\nEl dashboard se abrirá automáticamente en su navegador.\n")
cat("Para detener el servidor, presione Ctrl+C en la terminal.\n\n")

shinyApp(ui = ui, server = server)
