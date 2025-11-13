/**
 * Dashboard IRU - Main JavaScript Application
 */

// Global variables
let iruData = [];
let charts = {};
let currentPage = 1;
const itemsPerPage = 20;

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    loadData();
});

/**
 * Load data from JSON file
 */
async function loadData() {
    try {
        const response = await fetch('data/iru_data.json');
        iruData = await response.json();

        console.log(`Loaded ${iruData.length} sectores`);

        // Hide loading, show content
        document.getElementById('loading').style.display = 'none';
        document.getElementById('main-content').style.display = 'block';

        // Initialize dashboard
        initializeDashboard();
    } catch (error) {
        console.error('Error loading data:', error);
        document.getElementById('loading').innerHTML = `
            <div class="alert alert-danger">
                <h4>Error al cargar datos</h4>
                <p>${error.message}</p>
            </div>
        `;
    }
}

/**
 * Initialize all dashboard components
 */
function initializeDashboard() {
    // Update summary statistics
    updateStatCards();

    // Initialize all charts
    initializeOverviewCharts();
    initializeEjesCharts();
    initializeAmbitosCharts();
    initializeRankings();
    initializeDataTable();

    // Setup event listeners
    setupEventListeners();
}

/**
 * Update summary stat cards
 */
function updateStatCards() {
    const iruValues = iruData.map(d => d.IRU);
    const total = iruData.length;
    const avg = iruValues.reduce((a, b) => a + b, 0) / total;
    const max = Math.max(...iruValues);
    const min = Math.min(...iruValues);

    document.getElementById('sector-count').textContent = total;
    document.getElementById('stat-total').textContent = total;
    document.getElementById('stat-avg').textContent = avg.toFixed(3);
    document.getElementById('stat-max').textContent = max.toFixed(3);
    document.getElementById('stat-min').textContent = min.toFixed(3);
}

/**
 * Initialize Overview tab charts
 */
function initializeOverviewCharts() {
    // Histogram
    createIRUHistogram();

    // Top 10 sectors
    createTopSectoresChart();

    // Box plot (approximation with bar chart)
    createEjesBoxplot();
}

/**
 * Create IRU histogram
 */
function createIRUHistogram() {
    const ctx = document.getElementById('iruHistogram').getContext('2d');

    // Create bins
    const bins = 30;
    const iruValues = iruData.map(d => d.IRU);
    const min = Math.min(...iruValues);
    const max = Math.max(...iruValues);
    const binSize = (max - min) / bins;

    const histogram = Array(bins).fill(0);
    iruValues.forEach(value => {
        const binIndex = Math.min(Math.floor((value - min) / binSize), bins - 1);
        histogram[binIndex]++;
    });

    const labels = Array(bins).fill(0).map((_, i) =>
        (min + i * binSize).toFixed(3)
    );

    charts.iruHistogram = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Frecuencia',
                data: histogram,
                backgroundColor: 'rgba(13, 110, 253, 0.7)',
                borderColor: 'rgba(13, 110, 253, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                title: {
                    display: false
                },
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Frecuencia'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Valor IRU'
                    },
                    ticks: {
                        maxRotation: 45,
                        minRotation: 45
                    }
                }
            }
        }
    });
}

/**
 * Create top 10 sectores chart
 */
function createTopSectoresChart() {
    const ctx = document.getElementById('topSectoresChart').getContext('2d');

    const top10 = [...iruData]
        .sort((a, b) => b.IRU - a.IRU)
        .slice(0, 10);

    charts.topSectores = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: top10.map(d => d.SCaNombre),
            datasets: [{
                label: 'IRU',
                data: top10.map(d => d.IRU),
                backgroundColor: 'rgba(25, 135, 84, 0.7)',
                borderColor: 'rgba(25, 135, 84, 1)',
                borderWidth: 1
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Valor IRU'
                    }
                }
            }
        }
    });
}

/**
 * Create Ejes boxplot (approximation)
 */
function createEjesBoxplot() {
    const ctx = document.getElementById('ejesBoxplot').getContext('2d');

    const e1Values = iruData.map(d => d.E1).sort((a, b) => a - b);
    const e2Values = iruData.map(d => d.E2).sort((a, b) => a - b);
    const e3Values = iruData.map(d => d.E3).sort((a, b) => a - b);

    const getStats = (arr) => {
        const q1 = arr[Math.floor(arr.length * 0.25)];
        const median = arr[Math.floor(arr.length * 0.5)];
        const q3 = arr[Math.floor(arr.length * 0.75)];
        const min = arr[0];
        const max = arr[arr.length - 1];
        return { min, q1, median, q3, max };
    };

    const e1Stats = getStats(e1Values);
    const e2Stats = getStats(e2Values);
    const e3Stats = getStats(e3Values);

    charts.ejesBoxplot = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['E1 (Hábitat)', 'E2 (Funcionalidad)', 'E3 (Sostenibilidad)'],
            datasets: [
                {
                    label: 'Mínimo',
                    data: [e1Stats.min, e2Stats.min, e3Stats.min],
                    backgroundColor: 'rgba(255, 99, 132, 0.7)'
                },
                {
                    label: 'Q1',
                    data: [e1Stats.q1, e2Stats.q1, e3Stats.q1],
                    backgroundColor: 'rgba(54, 162, 235, 0.7)'
                },
                {
                    label: 'Mediana',
                    data: [e1Stats.median, e2Stats.median, e3Stats.median],
                    backgroundColor: 'rgba(255, 206, 86, 0.7)'
                },
                {
                    label: 'Q3',
                    data: [e1Stats.q3, e2Stats.q3, e3Stats.q3],
                    backgroundColor: 'rgba(75, 192, 192, 0.7)'
                },
                {
                    label: 'Máximo',
                    data: [e1Stats.max, e2Stats.max, e3Stats.max],
                    backgroundColor: 'rgba(153, 102, 255, 0.7)'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                title: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Valor'
                    }
                }
            }
        }
    });
}

/**
 * Initialize Ejes tab charts
 */
function initializeEjesCharts() {
    createEjesScatter();
    createEjesPie();
    createEjesComparison();
}

/**
 * Create scatter plot E1 vs E2
 */
function createEjesScatter() {
    const ctx = document.getElementById('ejesScatter').getContext('2d');

    charts.ejesScatter = new Chart(ctx, {
        type: 'scatter',
        data: {
            datasets: [{
                label: 'Sectores',
                data: iruData.map(d => ({
                    x: d.E1,
                    y: d.E2
                })),
                backgroundColor: 'rgba(13, 110, 253, 0.5)',
                borderColor: 'rgba(13, 110, 253, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const sector = iruData[context.dataIndex];
                            return `${sector.SCaNombre}: E1=${sector.E1.toFixed(3)}, E2=${sector.E2.toFixed(3)}`;
                        }
                    }
                }
            },
            scales: {
                x: {
                    title: {
                        display: true,
                        text: 'E1 (Hábitat)'
                    }
                },
                y: {
                    title: {
                        display: true,
                        text: 'E2 (Funcionalidad)'
                    }
                }
            }
        }
    });
}

/**
 * Create pie chart for average Ejes
 */
function createEjesPie() {
    const ctx = document.getElementById('ejesPie').getContext('2d');

    const e1Avg = iruData.reduce((sum, d) => sum + d.E1, 0) / iruData.length;
    const e2Avg = iruData.reduce((sum, d) => sum + d.E2, 0) / iruData.length;
    const e3Avg = iruData.reduce((sum, d) => sum + d.E3, 0) / iruData.length;

    charts.ejesPie = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['E1 (Hábitat)', 'E2 (Funcionalidad)', 'E3 (Sostenibilidad)'],
            datasets: [{
                data: [e1Avg, e2Avg, e3Avg],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.7)',
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 206, 86, 0.7)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `${context.label}: ${context.parsed.toFixed(3)}`;
                        }
                    }
                }
            }
        }
    });
}

/**
 * Create comparison chart for top 20 sectors
 */
function createEjesComparison() {
    const ctx = document.getElementById('ejesComparison').getContext('2d');

    const top20 = [...iruData]
        .sort((a, b) => b.IRU - a.IRU)
        .slice(0, 20);

    charts.ejesComparison = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: top20.map(d => d.SCaNombre),
            datasets: [
                {
                    label: 'E1 (Hábitat)',
                    data: top20.map(d => d.E1),
                    backgroundColor: 'rgba(255, 99, 132, 0.7)',
                    borderColor: 'rgba(255, 99, 132, 1)',
                    borderWidth: 1
                },
                {
                    label: 'E2 (Funcionalidad)',
                    data: top20.map(d => d.E2),
                    backgroundColor: 'rgba(54, 162, 235, 0.7)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 1
                },
                {
                    label: 'E3 (Sostenibilidad)',
                    data: top20.map(d => d.E3),
                    backgroundColor: 'rgba(255, 206, 86, 0.7)',
                    borderColor: 'rgba(255, 206, 86, 1)',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                x: {
                    ticks: {
                        maxRotation: 45,
                        minRotation: 45
                    }
                },
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Valor'
                    }
                }
            }
        }
    });
}

/**
 * Initialize Ámbitos tab charts
 */
function initializeAmbitosCharts() {
    // Populate sector select
    const select = document.getElementById('sectorSelect');
    select.innerHTML = iruData.map(d =>
        `<option value="${d.CodSec}">${d.CodSec} - ${d.SCaNombre}</option>`
    ).join('');

    // Create initial charts with first sector
    updateAmbitosCharts(iruData[0].CodSec);
}

/**
 * Update ámbitos charts for selected sector
 */
function updateAmbitosCharts(codSec) {
    const sector = iruData.find(d => d.CodSec === codSec);
    if (!sector) return;

    const ambitos = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10'];
    const valores = ambitos.map(a => sector[a]);

    // Radar chart
    const radarCtx = document.getElementById('ambitosRadar').getContext('2d');
    if (charts.ambitosRadar) charts.ambitosRadar.destroy();

    charts.ambitosRadar = new Chart(radarCtx, {
        type: 'radar',
        data: {
            labels: ambitos,
            datasets: [{
                label: sector.SCaNombre,
                data: valores,
                backgroundColor: 'rgba(13, 110, 253, 0.2)',
                borderColor: 'rgba(13, 110, 253, 1)',
                borderWidth: 2,
                pointBackgroundColor: 'rgba(13, 110, 253, 1)',
                pointBorderColor: '#fff',
                pointHoverBackgroundColor: '#fff',
                pointHoverBorderColor: 'rgba(13, 110, 253, 1)'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                r: {
                    beginAtZero: true,
                    max: 1
                }
            }
        }
    });

    // Bar chart
    const barCtx = document.getElementById('ambitosBar').getContext('2d');
    if (charts.ambitosBar) charts.ambitosBar.destroy();

    charts.ambitosBar = new Chart(barCtx, {
        type: 'bar',
        data: {
            labels: ambitos,
            datasets: [{
                label: 'Valor',
                data: valores,
                backgroundColor: 'rgba(13, 110, 253, 0.7)',
                borderColor: 'rgba(13, 110, 253, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 1,
                    title: {
                        display: true,
                        text: 'Valor'
                    }
                }
            }
        }
    });
}

/**
 * Initialize rankings tables
 */
function initializeRankings() {
    // Top 10
    const top10 = [...iruData]
        .sort((a, b) => b.IRU - a.IRU)
        .slice(0, 10);

    const topTableBody = document.querySelector('#topTable tbody');
    topTableBody.innerHTML = top10.map((d, i) => `
        <tr>
            <td><strong>${i + 1}</strong></td>
            <td>${d.CodSec}</td>
            <td>${d.SCaNombre}</td>
            <td><span class="badge bg-success">${d.IRU.toFixed(3)}</span></td>
        </tr>
    `).join('');

    // Bottom 10
    const bottom10 = [...iruData]
        .sort((a, b) => a.IRU - b.IRU)
        .slice(0, 10);

    const bottomTableBody = document.querySelector('#bottomTable tbody');
    bottomTableBody.innerHTML = bottom10.map((d, i) => `
        <tr>
            <td><strong>${i + 1}</strong></td>
            <td>${d.CodSec}</td>
            <td>${d.SCaNombre}</td>
            <td><span class="badge bg-warning">${d.IRU.toFixed(3)}</span></td>
        </tr>
    `).join('');

    // Initialize range sliders
    const iruValues = iruData.map(d => d.IRU);
    const minIRU = Math.min(...iruValues);
    const maxIRU = Math.max(...iruValues);

    document.getElementById('rangeMin').textContent = minIRU.toFixed(3);
    document.getElementById('rangeMax').textContent = maxIRU.toFixed(3);

    updateFilteredCount();
}

/**
 * Update filtered count based on range
 */
function updateFilteredCount() {
    const minSlider = document.getElementById('iruMinSlider');
    const maxSlider = document.getElementById('iruMaxSlider');

    const iruValues = iruData.map(d => d.IRU);
    const minIRU = Math.min(...iruValues);
    const maxIRU = Math.max(...iruValues);

    const minValue = minIRU + (maxIRU - minIRU) * (minSlider.value / 100);
    const maxValue = minIRU + (maxIRU - minIRU) * (maxSlider.value / 100);

    document.getElementById('rangeMin').textContent = minValue.toFixed(3);
    document.getElementById('rangeMax').textContent = maxValue.toFixed(3);

    const filtered = iruData.filter(d => d.IRU >= minValue && d.IRU <= maxValue);
    document.getElementById('filteredCount').textContent = filtered.length;
}

/**
 * Initialize data table
 */
function initializeDataTable() {
    renderDataTable();
}

/**
 * Render data table with pagination
 */
function renderDataTable(searchTerm = '', sortBy = 'IRU-desc') {
    let filtered = [...iruData];

    // Filter by search term
    if (searchTerm) {
        filtered = filtered.filter(d =>
            d.CodSec.toLowerCase().includes(searchTerm.toLowerCase()) ||
            d.SCaNombre.toLowerCase().includes(searchTerm.toLowerCase())
        );
    }

    // Sort
    const [field, order] = sortBy.split('-');
    filtered.sort((a, b) => {
        if (order === 'asc') {
            return a[field] > b[field] ? 1 : -1;
        } else {
            return a[field] < b[field] ? 1 : -1;
        }
    });

    // Paginate
    const totalPages = Math.ceil(filtered.length / itemsPerPage);
    const start = (currentPage - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    const page = filtered.slice(start, end);

    // Render table
    const tbody = document.querySelector('#dataTable tbody');
    tbody.innerHTML = page.map(d => `
        <tr>
            <td>${d.CodSec}</td>
            <td>${d.SCaNombre}</td>
            <td>${d.E1.toFixed(3)}</td>
            <td>${d.E2.toFixed(3)}</td>
            <td>${d.E3.toFixed(3)}</td>
            <td><span class="badge bg-primary">${d.IRU.toFixed(3)}</span></td>
            <td>${d.AreaActual.toFixed(2)}</td>
        </tr>
    `).join('');

    // Render pagination
    renderPagination(totalPages);
}

/**
 * Render pagination controls
 */
function renderPagination(totalPages) {
    const pagination = document.getElementById('pagination');

    let html = '';

    // Previous button
    html += `
        <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">
                <i class="fas fa-chevron-left"></i>
            </a>
        </li>
    `;

    // Page numbers (show max 5)
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, currentPage + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += `
            <li class="page-item ${i === currentPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="changePage(${i}); return false;">${i}</a>
            </li>
        `;
    }

    // Next button
    html += `
        <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">
                <i class="fas fa-chevron-right"></i>
            </a>
        </li>
    `;

    pagination.innerHTML = html;
}

/**
 * Change page
 */
function changePage(page) {
    currentPage = page;
    const searchTerm = document.getElementById('searchInput').value;
    const sortBy = document.getElementById('sortSelect').value;
    renderDataTable(searchTerm, sortBy);
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Sector select for ámbitos
    document.getElementById('sectorSelect').addEventListener('change', function(e) {
        updateAmbitosCharts(e.target.value);
    });

    // Range sliders
    document.getElementById('iruMinSlider').addEventListener('input', updateFilteredCount);
    document.getElementById('iruMaxSlider').addEventListener('input', updateFilteredCount);

    // Search input
    document.getElementById('searchInput').addEventListener('input', function(e) {
        currentPage = 1;
        const sortBy = document.getElementById('sortSelect').value;
        renderDataTable(e.target.value, sortBy);
    });

    // Sort select
    document.getElementById('sortSelect').addEventListener('change', function(e) {
        currentPage = 1;
        const searchTerm = document.getElementById('searchInput').value;
        renderDataTable(searchTerm, e.target.value);
    });
}

/**
 * Export data to CSV
 */
function exportToCSV() {
    const headers = ['CodSec', 'SCaNombre', 'E1', 'E2', 'E3', 'IRU', 'AreaActual'];
    const csv = [
        headers.join(','),
        ...iruData.map(d => [
            d.CodSec,
            `"${d.SCaNombre}"`,
            d.E1,
            d.E2,
            d.E3,
            d.IRU,
            d.AreaActual
        ].join(','))
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'iru_data.csv';
    a.click();
    window.URL.revokeObjectURL(url);
}
