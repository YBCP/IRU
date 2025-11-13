"""
Script para convertir datos DBF a JSON para el dashboard HTML/JS
"""
import json
from dbfread import DBF
from collections import OrderedDict

# Leer archivo DBF
print("Leyendo archivo DBF...")
dbf = DBF('IRUSCV3.dbf', encoding='latin1')

# Convertir a lista de diccionarios
sectores = []
for record in dbf:
    # Convertir OrderedDict a dict regular y manejar valores None
    sector = {}
    for key, value in record.items():
        if value is None:
            sector[key] = 0
        elif isinstance(value, float):
            # Redondear floats a 6 decimales para reducir tamaño
            sector[key] = round(value, 6)
        else:
            sector[key] = value
    sectores.append(sector)

print(f"Total de sectores: {len(sectores)}")

# Guardar como JSON
output_file = 'data/iru_data.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(sectores, f, ensure_ascii=False, indent=2)

print(f"Datos guardados en: {output_file}")

# Crear también un archivo con estadísticas resumidas
stats = {
    'total_sectores': len(sectores),
    'iru_promedio': sum(s['IRU'] for s in sectores) / len(sectores),
    'iru_max': max(s['IRU'] for s in sectores),
    'iru_min': min(s['IRU'] for s in sectores),
    'e1_promedio': sum(s['E1'] for s in sectores) / len(sectores),
    'e2_promedio': sum(s['E2'] for s in sectores) / len(sectores),
    'e3_promedio': sum(s['E3'] for s in sectores) / len(sectores),
}

stats_file = 'data/stats.json'
with open(stats_file, 'w', encoding='utf-8') as f:
    json.dump(stats, f, indent=2)

print(f"Estadísticas guardadas en: {stats_file}")
print("\nEstadísticas:")
for key, value in stats.items():
    print(f"  {key}: {value:.4f}" if isinstance(value, float) else f"  {key}: {value}")
