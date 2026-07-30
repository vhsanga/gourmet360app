import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_venta_dia.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/models/venta_producto.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/viewmodels/ventas_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialogo_cobro_deuda.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ClientHistorySalesScreen extends StatefulWidget {
  ClienteVentas cliente;
  ClientHistorySalesScreen({super.key, required this.cliente});

  @override
  State<ClientHistorySalesScreen> createState() =>
      _ClientHistorySalesScreenState();
}

class _ClientHistorySalesScreenState extends State<ClientHistorySalesScreen> {
  Usuario? userSession;
  List<ClienteVentaDia> clientesVentaDias = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, ClienteVentaDia> ventasPorDia = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(DateTime.now());
    });
  }

  void _loadData(DateTime fechaSeleccionada) {
    final userProvider = context.read<UserProvider>();

    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      userSession = userProvider.usuario;

      context.read<AdminViewModel>().getResumenVentaClienteDiaRango(
        int.parse(widget.cliente.id),
        CustomUils.getFirstDateOfMonth(fechaSeleccionada),
        CustomUils.getLastDateOfMonth(fechaSeleccionada),
        userSession!.accessToken,
      );
    }
  }

  void _mapearDatos() {
    ventasPorDia.clear();
    for (var item in clientesVentaDias) {
      final date = DateTime.parse(item.dia);
      final normalized = DateTime(date.year, date.month, date.day);
      ventasPorDia[normalized] = item;
    }
  }

  Future<void> loadVentaProductoFecha(DateTime fecha) async {
    if (userSession == null) return;
    await context.read<VentasViewModel>().listarVentaProductosFecha(
      widget.cliente.id,
      CustomUils.formatDateToString(fecha),
      userSession!.accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final ventasVM = context.watch<VentasViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.cliente.nombre)),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                children: [
                  Text(vm.error!),
                  ElevatedButton(
                    onPressed: () => _loadData(DateTime.now()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (vm.clientesVentaDias.isNotEmpty) {
            clientesVentaDias = vm.clientesVentaDias;
            _mapearDatos();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    loadVentaProductoFecha(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadData(focusedDay);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      return _buildDayCell(day, ventasPorDia[normalized]);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      return _buildDayCell(
                        day,
                        ventasPorDia[normalized],
                        isToday: true,
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      return _buildDayCell(
                        day,
                        ventasPorDia[normalized],
                        isSelected: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedDay != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetalleDia(),
                        const SizedBox(height: 20),
                        const Divider(thickness: 2, height: 30),
                        _buildProductosList(
                          ventasVM.productosVendidos,
                          ventasVM.isLoading,
                          "Productos vendidos",
                        ),
                        if (ventasVM.productosCortesia.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(thickness: 2, height: 30),
                          _buildProductosList(
                            ventasVM.productosCortesia,
                            ventasVM.isLoading,
                            "Productos de cortesía (Yapas)",
                          ),
                        ],
                        if (ventasVM.productosDevueltos.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(thickness: 2, height: 30),
                          _buildProductosList(
                            ventasVM.productosDevueltos,
                            ventasVM.isLoading,
                            "Productos devueltos",
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    ClienteVentaDia? data, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    bool hayDeuda = (data != null && (data.totalDeuda - data.totalPagado) > 0);
    return Container(
      width: 65,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: hayDeuda
            ? Colors.red.shade200
            : isSelected
            ? Colors.blue.shade200
            : isToday
            ? Colors.blue.shade50
            : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (data != null)
            Text(
              '${data.totalContado.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildDetalleDia() {
    final normalized = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final data = ventasPorDia[normalized];
    final fechaLegible = CustomUils.formatearFecha(_selectedDay!);
    bool hayDeuda = (data != null && (data.totalDeuda - data.totalPagado) > 0);

    if (data == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Fecha: $fechaLegible',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Sin ventas en este día', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Fecha: $fechaLegible',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Valor venta: \$${data.totalDeuda.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Cobrado: \$${data.totalPagado.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Deuda: \$${(data.totalDeuda - data.totalPagado).toStringAsFixed(2)}',
                textAlign: TextAlign.center,
              ),
              if (hayDeuda) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _cobrarDeuda(
                    data.idVenta,
                    data.totalDeuda - data.totalPagado,
                  ),
                  child: const Text('Cobrar Deuda'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductosList(
    List<VentaProducto> productos,
    bool isLoading,
    titulo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.indigo.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Contenido
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (productos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin productos para este día',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          )
        else ...[
          ...productos.map((p) => _buildProductoItem(p)),
          const SizedBox(height: 4),
          _buildTotalRow(productos),
        ],
      ],
    );
  }

  Widget _buildProductoItem(VentaProducto p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                p.cantidad.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.cantidad.toStringAsFixed(0)} × \$${p.precioUnitario.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '\$${p.subtotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(List<VentaProducto> productos) {
    final total = productos.fold(0.0, (s, p) => s + p.subtotal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cobrarDeuda(int idVenta, double valorDeuda) async {
    if (idVenta == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay venta registrada para el cobro')),
      );
      return;
    }
    final admVM = context.read<AdminViewModel>();
    final navigator = Navigator.of(context, rootNavigator: true);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DialogoCobroDeuda(
        ventaId: idVenta,
        deudaTotal: valorDeuda,
        choferId: int.parse(userSession!.id),
      ),
    );

    if (result != null) {
      DialogsWidget.showLoading(message: 'Procesando...');

      final success = await admVM.cobrarDeuda(
        result,
        userSession?.accessToken ?? '',
      );
      if (!mounted) return;
      navigator.pop();
      if (success) {
        DialogsWidget.showSuccess(
          title: 'Muy bien',
          message: admVM.msj ?? 'Guardado correctamente',
          onClose: () {
            if (!mounted) return;
            _loadData(DateTime.now());
          },
        );
      } else {
        DialogsWidget.showError(
          title: 'Atención',
          message: admVM.msj ?? 'Error desconocido',
        );
      }
    }
  }
}
