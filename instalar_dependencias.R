# ==============================================================================
# INSTALACIÓN DE DEPENDENCIAS - SISTEMA IRU
# ==============================================================================
# Este script instala todas las librerías de R necesarias para el sistema
# ==============================================================================

cat("\n")
cat("======================================================================\n")
cat("   INSTALACIÓN DE DEPENDENCIAS - SISTEMA IRU\n")
cat("======================================================================\n")
cat("\n")

# Lista completa de paquetes necesarios
packages <- c(
  # Lectura de datos
  "foreign",        # Archivos DBF
  "readxl",         # Archivos Excel
  "readr",          # Lectura rápida de CSV

  # Manipulación de datos
  "dplyr",          # Transformación de datos
  "tidyr",          # Limpieza de datos
  "tidyverse",      # Suite completa

  # Análisis multivariado
  "FactoMineR",     # ACP y análisis factorial
  "factoextra",     # Visualización de ACP
  "pcaPP",          # ACP robusto

  # Clustering
  "cluster",        # Algoritmos de clustering
  "NbClust",        # Selección óptima de clusters

  # Visualización
  "ggplot2",        # Gráficos avanzados
  "scales",         # Escalas para gráficos
  "ggrepel",        # Etiquetas sin solapamiento
  "plotly",         # Gráficos interactivos

  # Dashboard
  "shiny",          # Aplicaciones web interactivas
  "shinydashboard", # Diseño de dashboard
  "leaflet",        # Mapas interactivos
  "DT",             # Tablas interactivas

  # Exportación
  "jsonlite"        # Archivos JSON
)

# Función para instalar y verificar paquetes
install_and_check <- function(pkg) {
  cat(sprintf("Verificando %s... ", pkg))

  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("instalando...")

    tryCatch({
      install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
      library(pkg, character.only = TRUE)
      cat(" ✓ instalado correctamente\n")
      return(TRUE)
    }, error = function(e) {
      cat(sprintf(" ✗ ERROR: %s\n", e$message))
      return(FALSE)
    })
  } else {
    cat(" ✓ ya instalado\n")
    return(TRUE)
  }
}

# Instalar todos los paquetes
cat("Iniciando instalación de paquetes...\n\n")

resultados <- sapply(packages, install_and_check)

# Resumen
cat("\n")
cat("======================================================================\n")
cat("   RESUMEN DE INSTALACIÓN\n")
cat("======================================================================\n")

exitosos <- sum(resultados)
fallidos <- sum(!resultados)

cat(sprintf("\nPaquetes instalados correctamente: %d de %d\n", exitosos, length(packages)))

if (fallidos > 0) {
  cat(sprintf("\nPaquetes con errores: %d\n", fallidos))
  cat("\nPaquetes fallidos:\n")
  for (pkg in names(resultados[!resultados])) {
    cat(sprintf("  - %s\n", pkg))
  }
  cat("\nIntente instalar manualmente los paquetes fallidos con:\n")
  cat("  install.packages(c(", paste(sprintf("'%s'", names(resultados[!resultados])), collapse = ", "), "))\n")
} else {
  cat("\n✓ Todas las dependencias se instalaron correctamente!\n")
  cat("\nYa puede ejecutar el sistema con:\n")
  cat("  ./ejecutar_analisis_completo.sh\n")
}

cat("\n======================================================================\n")
