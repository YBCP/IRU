#!/usr/bin/env python3
# ==============================================================================
# CONVERSIÓN DE SHAPEFILE A GEOJSON
# ==============================================================================
# Este script convierte el shapefile de sectores catastrales a formato GeoJSON
# y lo combina con los resultados del clustering para su visualización en el
# dashboard interactivo.
# ==============================================================================

import geopandas as gpd
import pandas as pd
import json
import os
from pathlib import Path

def convertir_shapefile_a_geojson():
    """
    Convierte el shapefile de sectores catastrales a GeoJSON y lo enriquece
    con información de clusters y características urbanas.
    """

    print("=" * 70)
    print("CONVERSIÓN DE SHAPEFILE A GEOJSON")
    print("=" * 70)

    # Rutas de archivos
    shapefile_path = "Sectores Catastrales/SECTOR_URBANO/SECTOR_URBANO.shp"
    clusters_path = "resultados/sectores_clusters.csv"
    caracterizacion_path = "resultados/resultados_clustering.json"
    output_path = "resultados/sectores_geojson.json"

    # 1. Leer shapefile
    print("\n1. Leyendo shapefile...")
    try:
        gdf = gpd.read_file(shapefile_path, encoding='utf-8')
        print(f"   ✓ Shapefile cargado: {len(gdf)} sectores")
        print(f"   ✓ Sistema de coordenadas: {gdf.crs}")
        print(f"   ✓ Columnas disponibles: {', '.join(gdf.columns.tolist())}")
    except Exception as e:
        print(f"   ✗ Error al leer shapefile: {e}")
        return False

    # 2. Identificar columna de código de sector
    # Buscar columnas que puedan contener el código del sector
    posibles_cols_codigo = ['SECT_CATAS', 'CODIGO', 'COD_SECTOR', 'Cod_SECTOR',
                            'SECTOR', 'ID', 'OBJECTID']
    col_codigo = None
    for col in posibles_cols_codigo:
        if col in gdf.columns:
            col_codigo = col
            break

    if col_codigo is None:
        # Si no se encuentra, usar el índice
        print("   ! No se encontró columna de código, usando índice")
        gdf['SECTOR_ID'] = ['SECTOR_' + str(i) for i in range(len(gdf))]
        col_codigo = 'SECTOR_ID'
    else:
        print(f"   ✓ Columna de código identificada: {col_codigo}")

    # Buscar columna de nombre
    posibles_cols_nombre = ['NOMBRE', 'NOMBRE_SEC', 'NOM_SECTOR', 'Nombre']
    col_nombre = None
    for col in posibles_cols_nombre:
        if col in gdf.columns:
            col_nombre = col
            break

    if col_nombre:
        print(f"   ✓ Columna de nombre identificada: {col_nombre}")

    # 3. Leer resultados de clustering
    print("\n2. Cargando resultados de clustering...")
    try:
        clusters_df = pd.read_csv(clusters_path)
        print(f"   ✓ Clusters cargados: {len(clusters_df)} sectores")

        # Leer caracterización de clusters
        with open(caracterizacion_path, 'r', encoding='utf-8') as f:
            caracterizacion = json.load(f)
        print(f"   ✓ Caracterización cargada: {caracterizacion['k_optimo']} clusters")
    except Exception as e:
        print(f"   ✗ Error al leer resultados de clustering: {e}")
        return False

    # 4. Unir shapefile con clusters
    print("\n3. Combinando datos espaciales con clusters...")

    # Estandarizar el nombre de la columna de código en ambos dataframes
    gdf['sector_codigo'] = gdf[col_codigo].astype(str)
    clusters_df['sector_codigo'] = clusters_df['Sector'].astype(str)

    # Realizar merge
    gdf_con_clusters = gdf.merge(
        clusters_df[['sector_codigo', 'Cluster']],
        on='sector_codigo',
        how='left'
    )

    # Verificar merge
    sectores_sin_cluster = gdf_con_clusters['Cluster'].isna().sum()
    if sectores_sin_cluster > 0:
        print(f"   ! Advertencia: {sectores_sin_cluster} sectores sin cluster asignado")
        # Asignar cluster 0 a sectores sin información
        gdf_con_clusters['Cluster'].fillna(0, inplace=True)

    print(f"   ✓ Datos combinados exitosamente")

    # 5. Agregar información de caracterización a cada sector
    print("\n4. Enriqueciendo datos con caracterización de clusters...")

    # Crear diccionario de colores para clusters
    colores = [
        '#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
        '#ffff33', '#a65628', '#f781bf', '#999999', '#66c2a5'
    ]

    # Función para obtener información del cluster
    def obtener_info_cluster(cluster_id):
        if pd.isna(cluster_id) or cluster_id == 0:
            return {
                'nombre': 'Sin clasificar',
                'descripcion': 'Sector sin información de clustering',
                'color': '#cccccc',
                'n_sectores': 0,
                'variables_caracteristicas': []
            }

        cluster_key = f'Cluster_{int(cluster_id)}'
        if cluster_key in caracterizacion['caracterizacion']:
            info = caracterizacion['caracterizacion'][cluster_key]

            # Extraer nombres de variables características
            vars_caract = []
            if 'variables_caracteristicas' in info:
                for var_key, var_info in info['variables_caracteristicas'].items():
                    vars_caract.append({
                        'nombre': var_info.get('nombre', 'N/A'),
                        'valor': var_info.get('valor_medio', 0),
                        'eje': var_info.get('eje', 'N/A'),
                        'ambito': var_info.get('ambito', 'N/A')
                    })

            return {
                'nombre': f'Cluster {int(cluster_id)}',
                'descripcion': f'Cluster urbano tipo {int(cluster_id)}',
                'color': colores[int(cluster_id) % len(colores)],
                'n_sectores': info.get('n_sectores', 0),
                'porcentaje': info.get('porcentaje', 0),
                'variables_caracteristicas': vars_caract[:3]  # Top 3
            }
        else:
            return {
                'nombre': f'Cluster {int(cluster_id)}',
                'descripcion': f'Cluster urbano tipo {int(cluster_id)}',
                'color': colores[int(cluster_id) % len(colores)],
                'n_sectores': 0,
                'variables_caracteristicas': []
            }

    # Aplicar función a cada sector
    gdf_con_clusters['cluster_info'] = gdf_con_clusters['Cluster'].apply(
        obtener_info_cluster
    )

    print(f"   ✓ Información de caracterización agregada")

    # 6. Reproyectar a WGS84 (EPSG:4326) para compatibilidad web
    print("\n5. Reproyectando a WGS84 (EPSG:4326)...")
    if gdf_con_clusters.crs is None:
        print("   ! Advertencia: Shapefile sin CRS definido, asumiendo EPSG:4326")
        gdf_con_clusters.set_crs(epsg=4326, inplace=True)
    elif gdf_con_clusters.crs.to_epsg() != 4326:
        print(f"   Reproyectando desde {gdf_con_clusters.crs} a EPSG:4326")
        gdf_con_clusters = gdf_con_clusters.to_crs(epsg=4326)
    else:
        print("   ✓ Ya está en EPSG:4326")

    # 7. Preparar propiedades para GeoJSON
    print("\n6. Preparando propiedades para GeoJSON...")

    # Crear propiedades estructuradas
    def crear_propiedades(row):
        props = {
            'codigo': str(row[col_codigo]),
            'cluster': int(row['Cluster']) if not pd.isna(row['Cluster']) else 0,
            'cluster_nombre': row['cluster_info']['nombre'],
            'cluster_descripcion': row['cluster_info']['descripcion'],
            'cluster_color': row['cluster_info']['color'],
            'cluster_n_sectores': row['cluster_info']['n_sectores'],
            'variables_caracteristicas': row['cluster_info']['variables_caracteristicas']
        }

        # Agregar nombre si existe
        if col_nombre and col_nombre in row:
            props['nombre'] = str(row[col_nombre])
        else:
            props['nombre'] = f"Sector {row[col_codigo]}"

        return props

    gdf_con_clusters['properties'] = gdf_con_clusters.apply(
        crear_propiedades, axis=1
    )

    # 8. Convertir a GeoJSON
    print("\n7. Convirtiendo a GeoJSON...")

    # Seleccionar solo geometría y propiedades
    gdf_final = gdf_con_clusters[['geometry', 'properties']].copy()

    # Crear GeoJSON como diccionario
    geojson_dict = {
        'type': 'FeatureCollection',
        'features': []
    }

    for idx, row in gdf_final.iterrows():
        feature = {
            'type': 'Feature',
            'geometry': json.loads(gpd.GeoSeries([row['geometry']]).to_json())['features'][0]['geometry'],
            'properties': row['properties']
        }
        geojson_dict['features'].append(feature)

    # 9. Guardar GeoJSON
    print(f"\n8. Guardando GeoJSON en {output_path}...")
    os.makedirs('resultados', exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(geojson_dict, f, ensure_ascii=False, indent=2)

    print(f"   ✓ GeoJSON guardado exitosamente")
    print(f"   ✓ Total de features: {len(geojson_dict['features'])}")

    # 10. Crear resumen de clusters para el mapa
    print("\n9. Creando resumen de clusters...")

    resumen_clusters = {}
    for cluster_id in range(1, caracterizacion['k_optimo'] + 1):
        cluster_key = f'Cluster_{cluster_id}'
        if cluster_key in caracterizacion['caracterizacion']:
            info = caracterizacion['caracterizacion'][cluster_key]

            # Obtener características principales
            vars_top = []
            if 'variables_caracteristicas' in info:
                for var_key, var_info in info['variables_caracteristicas'].items():
                    vars_top.append({
                        'nombre': var_info.get('nombre', 'N/A'),
                        'siglas': var_info.get('siglas', 'N/A'),
                        'valor': var_info.get('valor_medio', 0),
                        'eje': var_info.get('eje', 'N/A'),
                        'ambito': var_info.get('ambito', 'N/A')
                    })

            resumen_clusters[cluster_id] = {
                'nombre': f'Cluster {cluster_id}',
                'color': colores[(cluster_id - 1) % len(colores)],
                'n_sectores': info.get('n_sectores', 0),
                'porcentaje': info.get('porcentaje', 0),
                'caracteristicas_principales': vars_top[:5],
                'descripcion': generar_descripcion_cluster(cluster_id, vars_top[:3])
            }

    # Guardar resumen
    resumen_path = "resultados/resumen_clusters.json"
    with open(resumen_path, 'w', encoding='utf-8') as f:
        json.dump(resumen_clusters, f, ensure_ascii=False, indent=2)

    print(f"   ✓ Resumen de clusters guardado en {resumen_path}")

    # Resumen final
    print("\n" + "=" * 70)
    print("CONVERSIÓN COMPLETADA EXITOSAMENTE")
    print("=" * 70)
    print(f"Total de sectores: {len(gdf_con_clusters)}")
    print(f"Clusters identificados: {caracterizacion['k_optimo']}")
    print(f"\nDistribución por cluster:")
    for cluster_id in sorted(resumen_clusters.keys()):
        info = resumen_clusters[cluster_id]
        print(f"  {info['nombre']}: {info['n_sectores']} sectores ({info['porcentaje']:.1f}%)")
    print("=" * 70)

    return True

def generar_descripcion_cluster(cluster_id, variables_top):
    """
    Genera una descripción en lenguaje natural del cluster basada en sus
    variables características.
    """
    if not variables_top:
        return f"Cluster {cluster_id} sin caracterización disponible"

    # Agrupar por eje temático
    ejes = {}
    for var in variables_top:
        eje = var.get('eje', 'Otros')
        if eje not in ejes:
            ejes[eje] = []
        ejes[eje].append(var['nombre'])

    # Construir descripción
    descripcion = f"Cluster {cluster_id} - Caracterizado por: "

    partes = []
    for eje, vars_eje in ejes.items():
        if len(vars_eje) == 1:
            partes.append(f"{vars_eje[0]} ({eje})")
        else:
            partes.append(f"{', '.join(vars_eje[:2])} ({eje})")

    descripcion += "; ".join(partes)

    return descripcion

if __name__ == "__main__":
    success = convertir_shapefile_a_geojson()
    if success:
        print("\n✓ Script ejecutado exitosamente")
    else:
        print("\n✗ Hubo errores durante la ejecución")
