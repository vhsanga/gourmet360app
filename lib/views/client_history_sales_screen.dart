import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/cliente_venta_dia.dart';
import 'package:Gourmet360/models/cliente_ventas.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
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
              TableCalendar(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
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
    return Container(
      width: 65,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected
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

    if (data == null) {
      return const Text("Sin ventas en este día");
    }

    return Column(
      children: [
        Text(
          "Detalle del día ${_selectedDay!.day}/${_selectedDay!.month}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("Contado: ${data.totalContado}"),
        Text("Crédito: ${data.totalCredito}"),
      ],
    );
  }
}
