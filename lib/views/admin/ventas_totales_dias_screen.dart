import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/models/ventas_totales_dia.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

class VentasTotalesDiasScreen extends StatefulWidget {
  const VentasTotalesDiasScreen({Key? key}) : super(key: key);

  @override
  State<VentasTotalesDiasScreen> createState() =>
      _VentasTotalesDiasScreenState();
}

class _VentasTotalesDiasScreenState extends State<VentasTotalesDiasScreen> {
  List<VentasTotalesDia> ventasTotalesDias = [];
  Usuario? userSession;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      userSession = userProvider.usuario;
      context.read<AdminViewModel>().fetchVentasTotalesDia(
        userSession!.accessToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: AppThemeData.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Por día',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (vm.ventasTotalesDias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay ventas registradas.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Recargar')),
          ],
        ),
      );
    }

    ventasTotalesDias = vm.ventasTotalesDias;

    return _tabIndex == 0 ? _buildListaTab() : _buildEstadisticasTab();
  }

  Widget _buildListaTab() {
    return Column(
      children: [
        _buildResumenGeneral(ventasTotalesDias),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ventasTotalesDias.length,
            itemBuilder: (context, index) =>
                _buildDiaCard(ventasTotalesDias[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasTab() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final Map<int, double> ventasPorDia = {};
    for (final v in ventasTotalesDias) {
      final d = v.dia.toLocal();
      final day = DateTime(d.year, d.month, d.day);
      if (!day.isBefore(weekStart) && day.isBefore(weekEnd)) {
        ventasPorDia[d.weekday] = v.totalVentas;
      }
    }

    const etiquetas = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final maxVal = ventasPorDia.values.fold(0.0, (m, v) => v > m ? v : m);
    final todayWeekday = now.weekday;

    final barGroups = List.generate(7, (i) {
      final weekday = i + 1;
      final valor = ventasPorDia[weekday] ?? 0.0;
      final isToday = weekday == todayWeekday;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: valor,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            color: isToday
                ? AppThemeData.primaryColor
                : AppThemeData.identityColor,
          ),
        ],
      );
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ventas de la semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppThemeData.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_labelFecha(weekStart)} – ${_labelFecha(weekEnd.subtract(const Duration(days: 1)))}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxVal == 0 ? 100 : maxVal * 1.25,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (v, _) => Text(
                        '\$${v.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        final isToday = (idx + 1) == todayWeekday;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            etiquetas[idx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isToday
                                  ? AppThemeData.primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(2)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppThemeData.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Hoy',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppThemeData.identityColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Otros días',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildVentasPorMes(ventasTotalesDias),
        ],
      ),
    );
  }

  Widget _buildVentasPorMes(List<VentasTotalesDia> lista) {
    // Agrupar por año-mes
    final Map<String, double> totales = {};
    final Map<String, DateTime> fechaRef = {};

    for (final v in lista) {
      final d = v.dia.toLocal();
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      totales[key] = (totales[key] ?? 0) + v.totalVentas;
      fechaRef.putIfAbsent(key, () => d);
    }

    if (totales.isEmpty) return const SizedBox.shrink();

    final sorted = totales.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxVal = sorted.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    const nombresMes = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ventas por mes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppThemeData.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...sorted.map((entry) {
          final fecha = fechaRef[entry.key]!;
          final label = '${nombresMes[fecha.month]} ${fecha.year}';
          final ratio = maxVal > 0 ? entry.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppThemeData.primaryColor,
                      ),
                    ),
                    Text(
                      _fmt(entry.value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppThemeData.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppThemeData.identityColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _labelFecha(DateTime d) {
    final mes = _meses[d.month];
    return '${d.day} $mes';
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeData.identityColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppThemeData.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ventas Totales por Día',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _meses = [
    '',
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  String _formatFecha(DateTime d) {
    final local = d.toLocal();
    final dow = _dias[local.weekday - 1];
    final mes = _meses[local.month];
    return '$dow ${local.day} $mes ${local.year}';
  }

  String _fmt(double v) => '\$${v.toStringAsFixed(2)}';

  Widget _buildResumenGeneral(List<VentasTotalesDia> lista) {
    final totalVentas = lista.fold(0.0, (s, e) => s + e.totalVentas);
    final totalRecaudado = lista.fold(0.0, (s, e) => s + e.recaudado);
    final totalDeuda = lista.fold(0.0, (s, e) => s + e.totalDeuda);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeData.identityColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _resumenCol('Ventas', _fmt(totalVentas), AppThemeData.primaryColor),
          _resumenCol('Recaudado', _fmt(totalRecaudado), Colors.green.shade800),
          _resumenCol('Deuda', _fmt(totalDeuda), Colors.red.shade800),
        ],
      ),
    );
  }

  Widget _resumenCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppThemeData.primaryColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDiaCard(VentasTotalesDia item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatFecha(item.dia),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppThemeData.primaryColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _metricaTile(
                  'Total ventas',
                  item.totalVentas,
                  Colors.grey.shade800,
                  flex: 2,
                ),
                _metricaTile(
                  'Recaudado',
                  item.recaudado,
                  Colors.green.shade700,
                ),
                _metricaTile('Deuda', item.totalDeuda, Colors.red.shade600),
              ],
            ),
            if (item.totalEfectivo > 0 || item.totalTransferencias > 0) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  _metricaSecundaria('Efectivo', item.totalEfectivo),
                  const SizedBox(width: 20),
                  _metricaSecundaria(
                    'Transferencias',
                    item.totalTransferencias,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricaTile(String label, double value, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            _fmt(value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricaSecundaria(String label, double value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          _fmt(value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No se encontraron ventas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
