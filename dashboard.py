"""
Dashboard Interactivo del Índice de Revitalización Urbana (IRU)
"""
import dash
from dash import dcc, html, Input, Output, dash_table
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
from data_processor import IRUDataProcessor

# Inicializar la aplicación Dash con tema Bootstrap
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

# Cargar datos
processor = IRUDataProcessor()
df_sectores, df_indicadores = processor.load_data()

# Layout del dashboard
app.layout = dbc.Container([
    dbc.Row([
        dbc.Col([
            html.H1("Dashboard IRU - Índice de Revitalización Urbana",
                   className="text-center text-primary mb-4")
        ])
    ]),

    # Tarjetas de resumen
    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Total Sectores", className="card-title"),
                    html.H2(f"{len(df_sectores)}", className="text-primary")
                ])
            ])
        ], width=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("IRU Promedio", className="card-title"),
                    html.H2(f"{df_sectores['IRU'].mean():.3f}", className="text-success")
                ])
            ])
        ], width=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("IRU Máximo", className="card-title"),
                    html.H2(f"{df_sectores['IRU'].max():.3f}", className="text-info")
                ])
            ])
        ], width=3),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("IRU Mínimo", className="card-title"),
                    html.H2(f"{df_sectores['IRU'].min():.3f}", className="text-warning")
                ])
            ])
        ], width=3),
    ], className="mb-4"),

    # Pestañas
    dbc.Tabs([
        # Pestaña 1: Resumen General
        dbc.Tab(label="Resumen General", children=[
            dbc.Row([
                dbc.Col([
                    html.H4("Distribución del IRU", className="mt-3"),
                    dcc.Graph(id='histograma-iru')
                ], width=6),
                dbc.Col([
                    html.H4("Top 10 Sectores - Mayor IRU", className="mt-3"),
                    dcc.Graph(id='top-sectores')
                ], width=6),
            ]),
            dbc.Row([
                dbc.Col([
                    html.H4("Distribución por Ejes (E1, E2, E3)", className="mt-3"),
                    dcc.Graph(id='ejes-boxplot')
                ], width=12),
            ])
        ]),

        # Pestaña 2: Análisis por Ejes
        dbc.Tab(label="Análisis por Ejes", children=[
            dbc.Row([
                dbc.Col([
                    html.H4("Comparación de Ejes", className="mt-3"),
                    dcc.Graph(id='ejes-scatter')
                ], width=6),
                dbc.Col([
                    html.H4("Correlación entre Ejes e IRU", className="mt-3"),
                    dcc.Graph(id='correlation-heatmap')
                ], width=6),
            ]),
            dbc.Row([
                dbc.Col([
                    html.H4("Promedio de Ejes por Sector", className="mt-3"),
                    dcc.Graph(id='ejes-bars')
                ], width=12),
            ])
        ]),

        # Pestaña 3: Ámbitos (A1-A10)
        dbc.Tab(label="Ámbitos", children=[
            dbc.Row([
                dbc.Col([
                    html.H4("Selector de Sector", className="mt-3"),
                    dcc.Dropdown(
                        id='sector-dropdown',
                        options=[{'label': f"{row['CodSec']} - {row['SCaNombre']}",
                                 'value': row['CodSec']}
                                for _, row in df_sectores.iterrows()],
                        value=df_sectores['CodSec'].iloc[0],
                        className="mb-3"
                    ),
                ], width=12),
            ]),
            dbc.Row([
                dbc.Col([
                    html.H4("Ámbitos del Sector Seleccionado", className="mt-3"),
                    dcc.Graph(id='ambitos-radar')
                ], width=6),
                dbc.Col([
                    html.H4("Comparación de Ámbitos", className="mt-3"),
                    dcc.Graph(id='ambitos-bars')
                ], width=6),
            ])
        ]),

        # Pestaña 4: Rankings
        dbc.Tab(label="Rankings", children=[
            dbc.Row([
                dbc.Col([
                    html.H4("Top 10 Sectores con Mayor IRU", className="mt-3"),
                    html.Div(id='top-table')
                ], width=6),
                dbc.Col([
                    html.H4("Top 10 Sectores con Menor IRU", className="mt-3"),
                    html.Div(id='bottom-table')
                ], width=6),
            ]),
            dbc.Row([
                dbc.Col([
                    html.H4("Filtro por Rango de IRU", className="mt-4"),
                    dcc.RangeSlider(
                        id='iru-range-slider',
                        min=df_sectores['IRU'].min(),
                        max=df_sectores['IRU'].max(),
                        value=[df_sectores['IRU'].min(), df_sectores['IRU'].max()],
                        marks={i/10: f'{i/10:.1f}' for i in range(0, 11)},
                        tooltip={"placement": "bottom", "always_visible": True}
                    ),
                    html.Div(id='filtered-count', className="mt-3")
                ], width=12),
            ])
        ]),

        # Pestaña 5: Datos
        dbc.Tab(label="Explorar Datos", children=[
            dbc.Row([
                dbc.Col([
                    html.H4("Datos de Sectores Catastrales", className="mt-3"),
                    html.Div(id='data-table')
                ], width=12),
            ])
        ])
    ])

], fluid=True)

# Callbacks para actualizar gráficos

@app.callback(
    Output('histograma-iru', 'figure'),
    Input('histograma-iru', 'id')
)
def update_histogram(_):
    fig = px.histogram(df_sectores, x='IRU', nbins=30,
                      title='Distribución del Índice de Revitalización Urbana',
                      labels={'IRU': 'Valor IRU', 'count': 'Frecuencia'},
                      color_discrete_sequence=['#636EFA'])
    fig.update_layout(showlegend=False)
    return fig

@app.callback(
    Output('top-sectores', 'figure'),
    Input('top-sectores', 'id')
)
def update_top_sectores(_):
    top_10 = df_sectores.nlargest(10, 'IRU')
    fig = px.bar(top_10, x='IRU', y='SCaNombre',
                orientation='h',
                title='Top 10 Sectores con Mayor IRU',
                labels={'IRU': 'Valor IRU', 'SCaNombre': 'Sector'},
                color='IRU',
                color_continuous_scale='Greens')
    fig.update_layout(yaxis={'categoryorder':'total ascending'})
    return fig

@app.callback(
    Output('ejes-boxplot', 'figure'),
    Input('ejes-boxplot', 'id')
)
def update_ejes_boxplot(_):
    ejes_data = df_sectores[['E1', 'E2', 'E3']].melt(var_name='Eje', value_name='Valor')
    fig = px.box(ejes_data, x='Eje', y='Valor',
                title='Distribución de Valores por Eje',
                color='Eje',
                color_discrete_map={'E1': '#FF6692', 'E2': '#B6E880', 'E3': '#FF97FF'})
    return fig

@app.callback(
    Output('ejes-scatter', 'figure'),
    Input('ejes-scatter', 'id')
)
def update_ejes_scatter(_):
    fig = px.scatter_3d(df_sectores, x='E1', y='E2', z='E3',
                       color='IRU',
                       hover_data=['SCaNombre', 'CodSec'],
                       title='Relación entre los Tres Ejes (E1, E2, E3)',
                       labels={'E1': 'Eje 1', 'E2': 'Eje 2', 'E3': 'Eje 3'},
                       color_continuous_scale='Viridis')
    return fig

@app.callback(
    Output('correlation-heatmap', 'figure'),
    Input('correlation-heatmap', 'id')
)
def update_correlation(_):
    corr_matrix = processor.get_correlation_matrix()
    fig = px.imshow(corr_matrix,
                   text_auto='.2f',
                   title='Matriz de Correlación entre Ejes e IRU',
                   color_continuous_scale='RdBu_r',
                   aspect='auto')
    return fig

@app.callback(
    Output('ejes-bars', 'figure'),
    Input('ejes-bars', 'id')
)
def update_ejes_bars(_):
    top_20 = df_sectores.nlargest(20, 'IRU')
    fig = go.Figure()
    fig.add_trace(go.Bar(name='E1', x=top_20['SCaNombre'], y=top_20['E1']))
    fig.add_trace(go.Bar(name='E2', x=top_20['SCaNombre'], y=top_20['E2']))
    fig.add_trace(go.Bar(name='E3', x=top_20['SCaNombre'], y=top_20['E3']))
    fig.update_layout(
        title='Valores de Ejes para Top 20 Sectores',
        xaxis_title='Sector',
        yaxis_title='Valor',
        barmode='group',
        xaxis={'tickangle': 45}
    )
    return fig

@app.callback(
    Output('ambitos-radar', 'figure'),
    Input('sector-dropdown', 'value')
)
def update_ambitos_radar(selected_sector):
    sector_data = df_sectores[df_sectores['CodSec'] == selected_sector].iloc[0]
    ambitos = [f'A{i}' for i in range(1, 11)]
    valores = [sector_data[a] for a in ambitos]

    fig = go.Figure()
    fig.add_trace(go.Scatterpolar(
        r=valores,
        theta=ambitos,
        fill='toself',
        name=sector_data['SCaNombre']
    ))
    fig.update_layout(
        polar=dict(radialaxis=dict(visible=True, range=[0, 1])),
        title=f"Ámbitos para {sector_data['SCaNombre']} (Código: {selected_sector})"
    )
    return fig

@app.callback(
    Output('ambitos-bars', 'figure'),
    Input('sector-dropdown', 'value')
)
def update_ambitos_bars(selected_sector):
    sector_data = df_sectores[df_sectores['CodSec'] == selected_sector].iloc[0]
    ambitos = [f'A{i}' for i in range(1, 11)]
    valores = [sector_data[a] for a in ambitos]

    fig = px.bar(x=ambitos, y=valores,
                labels={'x': 'Ámbito', 'y': 'Valor'},
                title=f'Valores de Ámbitos - {sector_data["SCaNombre"]}',
                color=valores,
                color_continuous_scale='Blues')
    fig.update_layout(showlegend=False)
    return fig

@app.callback(
    [Output('top-table', 'children'),
     Output('bottom-table', 'children')],
    Input('top-table', 'id')
)
def update_tables(_):
    top_10 = processor.get_top_sectores(10, 'IRU')
    bottom_10 = processor.get_bottom_sectores(10, 'IRU')

    top_table = dash_table.DataTable(
        data=top_10.to_dict('records'),
        columns=[{'name': col, 'id': col} for col in top_10.columns],
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold'},
        style_data_conditional=[
            {'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'}
        ]
    )

    bottom_table = dash_table.DataTable(
        data=bottom_10.to_dict('records'),
        columns=[{'name': col, 'id': col} for col in bottom_10.columns],
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold'},
        style_data_conditional=[
            {'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'}
        ]
    )

    return top_table, bottom_table

@app.callback(
    Output('filtered-count', 'children'),
    Input('iru-range-slider', 'value')
)
def update_filtered_count(iru_range):
    filtered = processor.filter_by_iru_range(iru_range[0], iru_range[1])
    return html.H5(f"Sectores en rango [{iru_range[0]:.3f}, {iru_range[1]:.3f}]: {len(filtered)}")

@app.callback(
    Output('data-table', 'children'),
    Input('data-table', 'id')
)
def update_data_table(_):
    # Mostrar columnas principales
    cols = ['CodSec', 'SCaNombre', 'E1', 'E2', 'E3', 'IRU', 'AreaActual']
    display_data = df_sectores[cols].round(3)

    return dash_table.DataTable(
        data=display_data.to_dict('records'),
        columns=[{'name': col, 'id': col} for col in display_data.columns],
        page_size=20,
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': 'rgb(230, 230, 230)', 'fontWeight': 'bold'},
        style_data_conditional=[
            {'if': {'row_index': 'odd'}, 'backgroundColor': 'rgb(248, 248, 248)'}
        ],
        filter_action="native",
        sort_action="native",
        sort_mode="multi"
    )

if __name__ == '__main__':
    print("\n" + "="*60)
    print("Dashboard IRU iniciado correctamente")
    print("="*60)
    print("\nResumen de datos cargados:")
    print(f"  - Total de sectores: {len(df_sectores)}")
    print(f"  - IRU promedio: {df_sectores['IRU'].mean():.3f}")
    print(f"  - IRU máximo: {df_sectores['IRU'].max():.3f}")
    print(f"  - IRU mínimo: {df_sectores['IRU'].min():.3f}")
    print("\nAccede al dashboard en: http://127.0.0.1:8050")
    print("="*60 + "\n")

    app.run_server(debug=True, host='0.0.0.0', port=8050)
