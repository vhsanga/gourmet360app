import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_venta_dia.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
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

  /// 🔥 Mapa para acceso rápido por fecha
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
    } else {
      print("No hay sesión de usuario activa.");
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
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
                    onPressed: () {
                      _loadData(DateTime.now());
                    },
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
          return Column(
            children: [
              SizedBox(height: 20),
              TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,

                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;

                  /// 🔥 aquí luego llamas tu backend real
                  _loadData(focusedDay);
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final normalized = DateTime(day.year, day.month, day.day);

                    final data = ventasPorDia[normalized];

                    return _buildDayCell(day, data);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final normalized = DateTime(day.year, day.month, day.day);

                    final data = ventasPorDia[normalized];

                    return _buildDayCell(day, data, isToday: true);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final normalized = DateTime(day.year, day.month, day.day);

                    final data = ventasPorDia[normalized];

                    return _buildDayCell(day, data, isSelected: true);
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 👇 DETALLE DEL DÍA SELECCIONADO
              if (_selectedDay != null) _buildDetalleDia(),
            ],
          );
        },
      ),
    );
  }

  /// 🔥 CELDA PERSONALIZADA
  Widget _buildDayCell(
    DateTime day,
    ClienteVentaDia? data, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    bool hayDeuda = (data != null && data.totalPagado < data.totalCredito);
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

          if (data != null) ...[
            Text('${data.totalContado}', style: const TextStyle(fontSize: 10)),
          ],
        ],
      ),
    );
  }

  /// 🔥 DETALLE ABAJO
  Widget _buildDetalleDia() {
    final normalized = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final data = ventasPorDia[normalized];
    bool hayDeuda = (data != null && data.totalPagado < data.totalCredito);

    final fechaLegible = CustomUils.formatearFecha(_selectedDay!);

    if (data == null) {
      return Column(
        children: [
          Text(
            "Fecha:  $fechaLegible",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Sin ventas en este día"),
        ],
      );
    }

    return Column(
      children: [
        Text(
          "Fecha: $fechaLegible",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        if (!hayDeuda && data.totalContado > 0)
          Text("Cobrado: ${data.totalContado}"),
        if (!hayDeuda && data.totalPagado > 0)
          Text("Cobrado: ${data.totalPagado}"),

        if (hayDeuda) Text("Deuda: ${data.totalCredito}"),

        if (hayDeuda)
          ElevatedButton(
            onPressed: () {
              _cobrarDeuda(data.idVenta, data.totalCredito);
            },
            child: Text("Cobrar Deuda"),
          ),
      ],
    );
  }

  _cobrarDeuda(int idVenta, double valorDeuda) async {
    if (idVenta == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay venta registrada para el cobro")),
      );
      return;
    }
    final result = await showDialog<Map<String, num>>(
      context: context,
      builder: (_) =>
          DialogoCobroDeuda(ventaId: idVenta, deudaTotal: valorDeuda),
    );

    if (result != null) {
      final admVM = context.read<AdminViewModel>();
      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);

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
        return;
      } else {
        DialogsWidget.showError(
          title: 'Atención',
          message: admVM.msj ?? 'Error desconocido',
        );
        return;
      }
    }
  }
}
