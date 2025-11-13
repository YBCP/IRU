"""
Módulo para procesar datos del Índice de Revitalización Urbana (IRU)
"""
import pandas as pd
from dbfread import DBF
from collections import OrderedDict

class IRUDataProcessor:
    """Clase para procesar y gestionar datos del IRU"""

    def __init__(self, dbf_path='IRUSCV3.dbf', excel_path='Indicadores.xlsx'):
        self.dbf_path = dbf_path
        self.excel_path = excel_path
        self.df_sectores = None
        self.df_indicadores = None

    def load_data(self):
        """Carga todos los datos necesarios"""
        self.df_sectores = self._load_dbf()
        self.df_indicadores = self._load_excel()
        return self.df_sectores, self.df_indicadores

    def _load_dbf(self):
        """Carga el archivo DBF con datos de sectores catastrales"""
        dbf = DBF(self.dbf_path, encoding='latin1')
        records = []
        for record in dbf:
            records.append(OrderedDict(record))

        df = pd.DataFrame(records)
        return df

    def _load_excel(self):
        """Carga el archivo Excel con información de indicadores"""
        df = pd.read_excel(self.excel_path, sheet_name='Indicadores')
        return df

    def get_sector_summary(self):
        """Obtiene resumen estadístico de los sectores"""
        if self.df_sectores is None:
            self.load_data()

        summary = {
            'total_sectores': len(self.df_sectores),
            'iru_promedio': self.df_sectores['IRU'].mean(),
            'iru_max': self.df_sectores['IRU'].max(),
            'iru_min': self.df_sectores['IRU'].min(),
            'area_total': self.df_sectores['AreaActual'].sum()
        }
        return summary

    def get_top_sectores(self, n=10, metric='IRU'):
        """Obtiene los top N sectores según métrica"""
        if self.df_sectores is None:
            self.load_data()

        return self.df_sectores.nlargest(n, metric)[['CodSec', 'SCaNombre', metric]]

    def get_bottom_sectores(self, n=10, metric='IRU'):
        """Obtiene los bottom N sectores según métrica"""
        if self.df_sectores is None:
            self.load_data()

        return self.df_sectores.nsmallest(n, metric)[['CodSec', 'SCaNombre', metric]]

    def get_ejes_data(self):
        """Obtiene datos de los tres ejes principales"""
        if self.df_sectores is None:
            self.load_data()

        ejes_cols = ['CodSec', 'SCaNombre', 'E1', 'E2', 'E3', 'IRU']
        return self.df_sectores[ejes_cols]

    def get_ambitos_data(self):
        """Obtiene datos de los ámbitos A1-A10"""
        if self.df_sectores is None:
            self.load_data()

        ambitos_cols = ['CodSec', 'SCaNombre'] + [f'A{i}' for i in range(1, 11)]
        return self.df_sectores[ambitos_cols]

    def filter_by_iru_range(self, min_iru=0, max_iru=1):
        """Filtra sectores por rango de IRU"""
        if self.df_sectores is None:
            self.load_data()

        mask = (self.df_sectores['IRU'] >= min_iru) & (self.df_sectores['IRU'] <= max_iru)
        return self.df_sectores[mask]

    def get_correlation_matrix(self):
        """Obtiene matriz de correlación entre ejes y IRU"""
        if self.df_sectores is None:
            self.load_data()

        cols = ['E1', 'E2', 'E3', 'IRU']
        return self.df_sectores[cols].corr()
