# ==============================================================================
# ANÁLISIS DE COMPONENTES PRINCIPALES ROBUSTO Y CLUSTERING NO SUPERVISADO
# ==============================================================================
# Este script realiza un análisis de componentes principales (ACP) robusto
# y una clasificación no supervisada de los datos del IRU (Índice de
# Revitalización Urbana) utilizando únicamente las variables que comienzan
# con "Rev_". El clustering se determina automáticamente seleccionando el
# número de clusters que explique más del 50% de la varianza.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. INSTALACIÓN Y CARGA DE LIBRERÍAS
# ------------------------------------------------------------------------------

# Lista de paquetes necesarios
packages <- c(
  "foreign",        # Para leer archivos DBF
  "readxl",         # Para leer archivos Excel
  "tidyverse",      # Manipulación y visualización de datos
  "FactoMineR",     # ACP y análisis multivariado
  "factoextra",     # Visualización de resultados de ACP
  "pcaPP",          # ACP robusto
  "cluster",        # Algoritmos de clustering
  "NbClust",        # Determinación óptima del número de clusters
  "jsonlite",       # Exportar resultados a JSON
  "scales",         # Escalas para visualización
  "ggrepel"         # Etiquetas sin solapamiento
)

# Instalar paquetes faltantes
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# Aplicar a todos los paquetes
cat("Instalando y cargando librerías necesarias...\n")
invisible(sapply(packages, install_if_missing))

# ------------------------------------------------------------------------------
# 2. CARGA Y PREPARACIÓN DE DATOS
# ------------------------------------------------------------------------------

cat("\n=== CARGANDO DATOS ===\n")

# Leer archivo DBF con los datos del IRU
datos_iru <- read.dbf("IRUSCV3.dbf", as.is = TRUE)
cat(sprintf("✓ Datos cargados: %d observaciones, %d variables\n",
            nrow(datos_iru), ncol(datos_iru)))

# Leer información de los indicadores desde Excel
indicadores_info <- read_excel("Indicadores.xlsx", sheet = "Indicadores")
cat(sprintf("✓ Información de indicadores cargada: %d indicadores\n",
            nrow(indicadores_info)))

# Seleccionar solo las columnas que comienzan con "Rev_"
cols_rev <- grep("^Rev_", names(datos_iru), value = TRUE)
datos_rev <- datos_iru[, cols_rev]
cat(sprintf("✓ Seleccionadas %d variables Rev_\n", length(cols_rev)))

# Guardar identificadores de sectores para uso posterior
if ("SECT_CATAS" %in% names(datos_iru)) {
  sectores_ids <- datos_iru$SECT_CATAS
} else if ("Cod_SECTOR" %in% names(datos_iru)) {
  sectores_ids <- datos_iru$Cod_SECTOR
} else {
  # Usar índice de fila como ID si no existe columna de identificación
  sectores_ids <- paste0("SECTOR_", 1:nrow(datos_iru))
}

# Convertir a numérico y manejar valores faltantes
datos_rev_num <- as.data.frame(lapply(datos_rev, function(x) {
  as.numeric(as.character(x))
}))
rownames(datos_rev_num) <- sectores_ids

# Estadísticas de valores faltantes
na_count <- colSums(is.na(datos_rev_num))
cat(sprintf("✓ Variables con valores faltantes: %d de %d\n",
            sum(na_count > 0), length(na_count)))

# Imputar valores faltantes con la mediana (método robusto)
for (col in names(datos_rev_num)) {
  if (any(is.na(datos_rev_num[[col]]))) {
    mediana <- median(datos_rev_num[[col]], na.rm = TRUE)
    datos_rev_num[[col]][is.na(datos_rev_num[[col]])] <- mediana
  }
}

# Eliminar variables con varianza cero
var_cols <- apply(datos_rev_num, 2, var) > 0
datos_rev_clean <- datos_rev_num[, var_cols]
cat(sprintf("✓ Después de limpiar: %d variables con varianza > 0\n",
            ncol(datos_rev_clean)))

# ------------------------------------------------------------------------------
# 3. ANÁLISIS DE COMPONENTES PRINCIPALES ROBUSTO
# ------------------------------------------------------------------------------

cat("\n=== ANÁLISIS DE COMPONENTES PRINCIPALES ROBUSTO ===\n")

# Estandarizar datos (media 0, desviación estándar 1)
datos_scaled <- scale(datos_rev_clean)

# ACP Robusto usando método de proyección
# Este método es menos sensible a valores atípicos
cat("Ejecutando ACP robusto...\n")
pca_robusto <- PcaHubert(datos_scaled, k = min(10, ncol(datos_scaled)),
                         kmax = min(10, ncol(datos_scaled)))

# También realizar ACP clásico para comparación
pca_clasico <- PCA(datos_scaled, scale.unit = FALSE, ncp = 10, graph = FALSE)

# Calcular varianza explicada
varianza_explicada <- pca_robusto$eigenvalues / sum(pca_robusto$eigenvalues) * 100
varianza_acumulada <- cumsum(varianza_explicada)

cat("\nVarianza explicada por componente:\n")
for (i in 1:min(10, length(varianza_explicada))) {
  cat(sprintf("  PC%d: %.2f%% (Acumulado: %.2f%%)\n",
              i, varianza_explicada[i], varianza_acumulada[i]))
}

# Determinar número de componentes que explican al menos 70% de varianza
n_componentes_70 <- which(varianza_acumulada >= 70)[1]
cat(sprintf("\n✓ %d componentes explican el 70%% de la varianza\n",
            n_componentes_70))

# Obtener coordenadas de las observaciones en el espacio de componentes principales
scores_pca <- as.data.frame(pca_robusto$scores)
colnames(scores_pca) <- paste0("PC", 1:ncol(scores_pca))
rownames(scores_pca) <- sectores_ids

# Obtener loadings (contribución de variables a componentes)
loadings_pca <- as.data.frame(pca_robusto$loadings)
colnames(loadings_pca) <- paste0("PC", 1:ncol(loadings_pca))
loadings_pca$Variable <- rownames(loadings_pca)

# ------------------------------------------------------------------------------
# 4. CLUSTERING NO SUPERVISADO
# ------------------------------------------------------------------------------

cat("\n=== CLUSTERING NO SUPERVISADO ===\n")

# Usar las primeras componentes que explican >70% de varianza para clustering
datos_clustering <- scores_pca[, 1:n_componentes_70]

# Determinar número óptimo de clusters usando múltiples métodos
cat("Determinando número óptimo de clusters...\n")

# Método del codo (Within Sum of Squares)
wss <- numeric(15)
for (k in 1:15) {
  wss[k] <- sum(kmeans(datos_clustering, centers = k, nstart = 25)$tot.withinss)
}

# Método de Silueta
sil_scores <- numeric(14)
for (k in 2:15) {
  km <- kmeans(datos_clustering, centers = k, nstart = 25)
  sil <- silhouette(km$cluster, dist(datos_clustering))
  sil_scores[k-1] <- mean(sil[, 3])
}
optimal_k_sil <- which.max(sil_scores) + 1

# Criterio de varianza explicada por clusters
# Buscamos el número de clusters donde la varianza entre grupos > 50%
varianza_entre <- numeric(14)
for (k in 2:15) {
  km <- kmeans(datos_clustering, centers = k, nstart = 25)
  varianza_entre[k-1] <- km$betweenss / km$totss * 100
}
optimal_k_var50 <- which(varianza_entre >= 50)[1] + 1

cat(sprintf("  - Óptimo por silueta: %d clusters\n", optimal_k_sil))
cat(sprintf("  - Óptimo por varianza >50%%: %d clusters\n", optimal_k_var50))

# Usar el criterio de varianza >50% como solicitado
k_final <- optimal_k_var50
if (is.na(k_final)) {
  # Si ninguno supera 50%, usar el que maximiza la varianza entre grupos
  k_final <- which.max(varianza_entre) + 1
  cat(sprintf("  - Ninguno supera 50%%, usando k=%d (max varianza: %.2f%%)\n",
              k_final, max(varianza_entre)))
} else {
  cat(sprintf("  - ✓ Usando k=%d clusters (varianza entre grupos: %.2f%%)\n",
              k_final, varianza_entre[k_final-1]))
}

# Ejecutar clustering final con k óptimo
set.seed(123)  # Para reproducibilidad
clustering_final <- kmeans(datos_clustering, centers = k_final, nstart = 50)

# Añadir clusters a los datos
datos_con_cluster <- cbind(
  Sector = sectores_ids,
  datos_rev_clean,
  scores_pca,
  Cluster = clustering_final$cluster
)

# ------------------------------------------------------------------------------
# 5. CARACTERIZACIÓN DE CLUSTERS
# ------------------------------------------------------------------------------

cat("\n=== CARACTERIZACIÓN DE CLUSTERS ===\n")

# Calcular estadísticas por cluster para cada variable Rev_
caracterizacion_clusters <- list()

for (k in 1:k_final) {
  datos_cluster <- datos_rev_clean[clustering_final$cluster == k, ]

  # Calcular medias por variable
  medias <- colMeans(datos_cluster)

  # Identificar las 5 variables más altas (características distintivas)
  top5_vars <- names(sort(medias, decreasing = TRUE)[1:5])

  # Buscar nombres descriptivos de estas variables
  top5_info <- list()
  for (var in top5_vars) {
    codigo <- gsub("Rev_", "", var)
    info_var <- indicadores_info[indicadores_info$Código == as.numeric(codigo), ]

    if (nrow(info_var) > 0) {
      top5_info[[var]] <- list(
        codigo = codigo,
        nombre = as.character(info_var$Nombre[1]),
        siglas = as.character(info_var$SIGLAS[1]),
        valor_medio = round(medias[var], 3),
        eje = as.character(info_var$Eje[1]),
        ambito = as.character(info_var$Ámbito[1])
      )
    } else {
      top5_info[[var]] <- list(
        codigo = codigo,
        nombre = "No disponible",
        valor_medio = round(medias[var], 3)
      )
    }
  }

  caracterizacion_clusters[[paste0("Cluster_", k)]] <- list(
    n_sectores = sum(clustering_final$cluster == k),
    porcentaje = round(sum(clustering_final$cluster == k) / nrow(datos_rev_clean) * 100, 2),
    variables_caracteristicas = top5_info,
    centroide_PC1 = clustering_final$centers[k, 1],
    centroide_PC2 = clustering_final$centers[k, 2]
  )

  cat(sprintf("\nCluster %d:\n", k))
  cat(sprintf("  - Sectores: %d (%.1f%%)\n",
              sum(clustering_final$cluster == k),
              sum(clustering_final$cluster == k) / nrow(datos_rev_clean) * 100))
  cat("  - Variables características:\n")
  for (var_name in names(top5_info)) {
    var_info <- top5_info[[var_name]]
    cat(sprintf("    • %s: %.3f\n", var_info$nombre, var_info$valor_medio))
  }
}

# ------------------------------------------------------------------------------
# 6. EXPORTAR RESULTADOS
# ------------------------------------------------------------------------------

cat("\n=== EXPORTANDO RESULTADOS ===\n")

# Crear directorio de resultados
dir.create("resultados", showWarnings = FALSE)

# 1. Datos con clusters asignados
write.csv(datos_con_cluster, "resultados/datos_con_clusters.csv", row.names = FALSE)
cat("✓ Datos con clusters guardados en resultados/datos_con_clusters.csv\n")

# 2. Resultados del ACP
resultados_acp <- list(
  varianza_explicada = data.frame(
    Componente = paste0("PC", 1:length(varianza_explicada)),
    Varianza_Porcentaje = varianza_explicada,
    Varianza_Acumulada = varianza_acumulada
  ),
  loadings = loadings_pca,
  n_componentes_optimo = n_componentes_70
)
write_json(resultados_acp, "resultados/resultados_acp.json", pretty = TRUE)
cat("✓ Resultados ACP guardados en resultados/resultados_acp.json\n")

# 3. Resultados del clustering
resultados_clustering <- list(
  k_optimo = k_final,
  varianza_entre_grupos = clustering_final$betweenss / clustering_final$totss * 100,
  varianza_intra_grupos = clustering_final$tot.withinss / clustering_final$totss * 100,
  centroides = as.data.frame(clustering_final$centers),
  tamaños_clusters = table(clustering_final$cluster),
  caracterizacion = caracterizacion_clusters
)
write_json(resultados_clustering, "resultados/resultados_clustering.json", pretty = TRUE)
cat("✓ Resultados clustering guardados en resultados/resultados_clustering.json\n")

# 4. Tabla resumen de clusters por sector
tabla_clusters <- data.frame(
  Sector = sectores_ids,
  Cluster = clustering_final$cluster
)
write.csv(tabla_clusters, "resultados/sectores_clusters.csv", row.names = FALSE)
cat("✓ Asignación de clusters por sector guardada en resultados/sectores_clusters.csv\n")

# ------------------------------------------------------------------------------
# 7. VISUALIZACIONES
# ------------------------------------------------------------------------------

cat("\n=== GENERANDO VISUALIZACIONES ===\n")

# Paleta de colores para clusters
colores_clusters <- hue_pal()(k_final)

# 1. Gráfico de varianza explicada (Scree plot)
png("resultados/grafico_varianza_explicada.png", width = 1200, height = 800, res = 120)
par(mar = c(5, 5, 4, 2))
barplot(varianza_explicada[1:10],
        names.arg = paste0("PC", 1:10),
        col = "#3498db",
        main = "Varianza Explicada por Componente Principal",
        xlab = "Componente Principal",
        ylab = "Varianza Explicada (%)",
        ylim = c(0, max(varianza_explicada[1:10]) * 1.2))
lines(seq(0.7, by = 1.2, length.out = 10), varianza_acumulada[1:10],
      col = "#e74c3c", lwd = 2, type = "b", pch = 19)
legend("topright", legend = c("Varianza Individual", "Varianza Acumulada"),
       col = c("#3498db", "#e74c3c"), lwd = 2, pch = c(15, 19))
abline(h = 50, col = "darkgreen", lty = 2, lwd = 2)
text(5, 52, "50% de varianza", pos = 3, col = "darkgreen")
dev.off()
cat("✓ Gráfico de varianza explicada guardado\n")

# 2. Biplot del ACP (PC1 vs PC2)
png("resultados/biplot_acp.png", width = 1400, height = 1000, res = 120)
df_plot <- data.frame(
  PC1 = scores_pca$PC1,
  PC2 = scores_pca$PC2,
  Cluster = factor(clustering_final$cluster)
)

p <- ggplot(df_plot, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  stat_ellipse(level = 0.68, size = 1) +
  scale_color_manual(values = colores_clusters) +
  labs(
    title = "Análisis de Componentes Principales - Distribución de Clusters",
    subtitle = sprintf("PC1: %.1f%% varianza | PC2: %.1f%% varianza",
                       varianza_explicada[1], varianza_explicada[2]),
    x = sprintf("Componente Principal 1 (%.1f%% varianza)", varianza_explicada[1]),
    y = sprintf("Componente Principal 2 (%.1f%% varianza)", varianza_explicada[2])
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )
print(p)
dev.off()
cat("✓ Biplot del ACP guardado\n")

# 3. Gráfico del codo para clustering
png("resultados/metodo_codo.png", width = 1200, height = 800, res = 120)
par(mar = c(5, 5, 4, 2))
plot(1:15, wss, type = "b", pch = 19, col = "#3498db", lwd = 2,
     main = "Método del Codo - Determinación de K Óptimo",
     xlab = "Número de Clusters (k)",
     ylab = "Suma de Cuadrados Intra-Cluster (WSS)")
abline(v = k_final, col = "#e74c3c", lty = 2, lwd = 2)
text(k_final, max(wss) * 0.9, paste("k óptimo =", k_final),
     pos = 4, col = "#e74c3c", font = 2)
grid()
dev.off()
cat("✓ Gráfico del método del codo guardado\n")

# 4. Gráfico de silueta
png("resultados/silueta.png", width = 1200, height = 800, res = 120)
par(mar = c(5, 5, 4, 2))
plot(2:15, sil_scores, type = "b", pch = 19, col = "#9b59b6", lwd = 2,
     main = "Coeficiente de Silueta por Número de Clusters",
     xlab = "Número de Clusters (k)",
     ylab = "Coeficiente de Silueta Promedio")
abline(v = optimal_k_sil, col = "#e74c3c", lty = 2, lwd = 2)
text(optimal_k_sil, max(sil_scores) * 0.9,
     paste("k óptimo silueta =", optimal_k_sil),
     pos = 4, col = "#e74c3c", font = 2)
grid()
dev.off()
cat("✓ Gráfico de silueta guardado\n")

# 5. Gráfico de varianza entre grupos
png("resultados/varianza_entre_grupos.png", width = 1200, height = 800, res = 120)
par(mar = c(5, 5, 4, 2))
plot(2:15, varianza_entre, type = "b", pch = 19, col = "#27ae60", lwd = 2,
     main = "Varianza Entre Grupos por Número de Clusters",
     xlab = "Número de Clusters (k)",
     ylab = "Varianza Entre Grupos (%)")
abline(h = 50, col = "#e74c3c", lty = 2, lwd = 2)
text(8, 52, "50% de varianza", pos = 3, col = "#e74c3c", font = 2)
if (!is.na(optimal_k_var50)) {
  abline(v = optimal_k_var50, col = "#e74c3c", lty = 2, lwd = 2)
  text(optimal_k_var50, max(varianza_entre) * 0.9,
       paste("k =", optimal_k_var50),
       pos = 4, col = "#e74c3c", font = 2)
}
grid()
dev.off()
cat("✓ Gráfico de varianza entre grupos guardado\n")

# 6. Mapa de calor de las variables por cluster
datos_heatmap <- aggregate(. ~ Cluster,
                           data = cbind(Cluster = clustering_final$cluster,
                                       datos_scaled),
                           FUN = mean)
rownames(datos_heatmap) <- paste("Cluster", datos_heatmap$Cluster)
datos_heatmap <- datos_heatmap[, -1]

# Seleccionar top 20 variables con mayor variabilidad entre clusters
var_entre_clusters <- apply(datos_heatmap, 2, var)
top20_vars <- names(sort(var_entre_clusters, decreasing = TRUE)[1:20])

png("resultados/heatmap_clusters.png", width = 1400, height = 1000, res = 120)
heatmap(as.matrix(datos_heatmap[, top20_vars]),
        scale = "none",
        col = colorRampPalette(c("#3498db", "white", "#e74c3c"))(100),
        main = "Perfil de Clusters - Top 20 Variables Distintivas",
        margins = c(10, 10))
dev.off()
cat("✓ Mapa de calor de clusters guardado\n")

# ------------------------------------------------------------------------------
# 8. RESUMEN FINAL
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 70), "\n", sep = "")
cat("                    RESUMEN DEL ANÁLISIS\n")
cat(rep("=", 70), "\n", sep = "")
cat(sprintf("Total de sectores analizados: %d\n", nrow(datos_rev_clean)))
cat(sprintf("Variables Rev_ utilizadas: %d\n", ncol(datos_rev_clean)))
cat(sprintf("Componentes principales (>70%% var): %d\n", n_componentes_70))
cat(sprintf("Número óptimo de clusters: %d\n", k_final))
cat(sprintf("Varianza explicada por clusters: %.2f%%\n",
            clustering_final$betweenss / clustering_final$totss * 100))
cat("\nDistribución de sectores por cluster:\n")
for (k in 1:k_final) {
  n_sect <- sum(clustering_final$cluster == k)
  pct <- n_sect / nrow(datos_rev_clean) * 100
  cat(sprintf("  Cluster %d: %d sectores (%.1f%%)\n", k, n_sect, pct))
}
cat(rep("=", 70), "\n", sep = "")

cat("\n✓ ANÁLISIS COMPLETADO EXITOSAMENTE\n")
cat("  Todos los resultados se encuentran en el directorio 'resultados/'\n\n")
