import pandas as pd
import sys

# Leer archivo Excel
print("=== Analizando Indicadores.xlsx ===")
try:
    xls = pd.ExcelFile('Indicadores.xlsx')
    print(f"\nHojas disponibles: {xls.sheet_names}")

    for sheet in xls.sheet_names:
        df = pd.read_excel(xls, sheet_name=sheet)
        print(f"\n--- Hoja: {sheet} ---")
        print(f"Dimensiones: {df.shape}")
        print(f"Columnas: {list(df.columns)}")
        print(f"\nPrimeras filas:")
        print(df.head())
        print("\n" + "="*50)
except Exception as e:
    print(f"Error leyendo Excel: {e}")

# Leer archivo DBF
print("\n=== Analizando IRUSCV3.dbf ===")
try:
    from dbfread import DBF
    dbf = DBF('IRUSCV3.dbf', encoding='latin1')
    print(f"Campos: {dbf.field_names}")
    print(f"\nPrimeros 5 registros:")
    for i, record in enumerate(dbf):
        if i >= 5:
            break
        print(record)
except ImportError:
    print("dbfread no está instalado. Intentando con simpledbf...")
    try:
        # Alternativa con pandas
        import pydbf
        df_dbf = pd.read_dbf('IRUSCV3.dbf')
        print(f"Dimensiones: {df_dbf.shape}")
        print(f"Columnas: {list(df_dbf.columns)}")
        print(f"\nPrimeras filas:")
        print(df_dbf.head())
    except Exception as e:
        print(f"Error leyendo DBF: {e}")
        print("Intentando método alternativo...")
except Exception as e:
    print(f"Error: {e}")
