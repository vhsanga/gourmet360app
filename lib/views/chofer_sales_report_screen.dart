import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/utils/cutom_utils.dart';
import 'package:Gourmet360/models/producto_restante.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/admin_viewmodel.dart';
import 'package:Gourmet360/viewmodels/chofer_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialog_productos_sobrantes_list.dart';
import 'package:Gourmet360/views/templates/dialog_registro_gasto.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';

class ChoferSalesReportScreen extends StatefulWidget {
  final idDespacho;
  ChoferSalesReportScreen({Key? key, required this.idDespacho})
    : super(key: key);

  @override
  State<ChoferSalesReportScreen> createState() =>
      _ChoferSalesReportScreenState();
}

class _ChoferSalesReportScreenState extends State<ChoferSalesReportScreen> {
  Usuario? userSession;

  // Datos de productos (panes)
  int assignedProducts = 1000;

  int soldProducts = 820;

  int returnedProducts = 100;

  int remainingProducts = 80;

  // Datos financieros
  double soldAmount = 98.40;

  double accountsReceivableToday = 8.50;

  double accountsReceivableAccumulated = 35.00;

  double expensesToday = 10.00;

  DateTime fechaUltimoDespachoPendiente = DateTime.now();

  List<ProductoRestante> productosRestantes = [];

  double get totalToDeliver {
    return soldAmount - expensesToday;
  }

  double get productPercentageSold {
    return (assignedProducts > 0 ? soldProducts / assignedProducts : 0) * 100;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      userSession = userProvider.usuario;
      context.read<AdminViewModel>().getResumenDespachosChoferForAdminEndpoint(
        int.parse(userSession!.id),
        userSession!.accessToken,
      );

      final adminVM = context.read<AdminViewModel>();
      await adminVM.getDetalleProductosSobrantes(
        int.parse(userSession!.id),
        userSession!.accessToken,
      );

      productosRestantes = adminVM.productosRestantes;
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadSobrantesList() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.status == UserStatus.loaded &&
        userProvider.usuario != null) {
      print("Cargando lista de sobrantes para admin...");

      userSession = userProvider.usuario;
      await context.read<AdminViewModel>().getDetalleProductosSobrantes(
        int.parse(userSession!.id),
        userSession!.accessToken,
      );
      productosRestantes = context.read<AdminViewModel>().productosRestantes;
      if (mounted) setState(() {});
    }
  }

  Future<void> _showSobrantesDialog() async {
    if (productosRestantes.isEmpty) {
      await _loadSobrantesList();
    }
    if (!mounted) return;
    DialogProductosSobrantes.showDialogSobrantesList(productosRestantes);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    return Scaffold(
      body: Builder(
        builder: (_) {
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
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (vm.despachosChofer == null) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Text('No hay datos disponibles.'),
                  SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (vm.despachosChofer != null) {
            assignedProducts = vm.despachosChofer!.cantidad_asignada.toInt();
            soldProducts = vm.despachosChofer!.cantidad_entregada.toInt();
            returnedProducts = vm.despachosChofer!.cantidad_devuelta.toInt();
            remainingProducts = vm.despachosChofer!.cantidad_restante.toInt();
            soldAmount = vm.despachosChofer!.ventas_contado;
            accountsReceivableToday = vm.despachosChofer!.ventas_credito;
            accountsReceivableAccumulated =
                vm.despachosChofer!.cuentas_por_cobrar;
            expensesToday = vm.despachosChofer!.gastos;
            fechaUltimoDespachoPendiente = vm.despachosChofer!.fecha;
          }
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Reporte de Productos'),
                        const SizedBox(height: 12),
                        _buildProductsReportCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Reporte Financiero'),
                        const SizedBox(height: 12),
                        _buildFinancialReportCard(),
                        const SizedBox(height: 24),
                        _buildTotalToDeliverCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  'Reporte de Ventas',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CustomUils.formatearFecha(fechaUltimoDespachoPendiente),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppThemeData.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppThemeData.primaryColor,
      ),
    );
  }

  Widget _buildProductsReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bakery_dining,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventario de Panes',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemeData.primaryColor,
                      ),
                    ),
                    Text(
                      'Control diario',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${productPercentageSold.toStringAsFixed(0)}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProductStatRow(
            'Cantidad Asignada',
            assignedProducts,
            Icons.inventory_2,
            Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          _buildProductStatRow(
            'Vendidos Hoy',
            soldProducts,
            Icons.check_circle,
            Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _buildProductStatRow(
            'Devueltos/Cambiados',
            returnedProducts,
            Icons.keyboard_return,
            Colors.orange.shade700,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showSobrantesDialog,
            child: _buildProductStatRow(
              'Sobrantes',
              remainingProducts,
              Icons.inventory,
              Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: assignedProducts > 0 ? soldProducts / assignedProducts : 0,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStatRow(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E2C8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$value panes',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppThemeData.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialStatRow(
            'Dinero Vendido Hoy',
            soldAmount,
            Icons.point_of_sale,
            Colors.green,
            isPositive: true,
          ),
          const SizedBox(height: 12),
          _buildFinancialStatRow(
            'Cuentas por Cobrar (Hoy)',
            accountsReceivableToday,
            Icons.schedule,
            Colors.orange,
            isWarning: true,
          ),
          const SizedBox(height: 12),
          _buildFinancialStatRow(
            'Cuentas por Cobrar (Acumulado)',
            accountsReceivableAccumulated,
            Icons.account_balance_wallet,
            Colors.orange,
            isWarning: true,
          ),
          const SizedBox(height: 12),
          _buildFinancialStatRowButton(
            'Gastos del Día',
            Icons.local_gas_station,
            Colors.red,
            isNegative: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatRow(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isPositive = false,
    bool isNegative = false,
    bool isWarning = false,
  }) {
    Color backgroundColor;
    if (isPositive) {
      backgroundColor = Colors.green.shade50;
    } else if (isNegative) {
      backgroundColor = Colors.red.shade50;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade50;
    } else {
      backgroundColor = const Color(0xFFF5E2C8).withOpacity(0.3);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}\$${value.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? Colors.green.shade700
                  : isNegative
                  ? Colors.red.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatRowButton(
    String label,
    IconData icon,
    Color color, {
    bool isPositive = false,
    bool isNegative = false,
    bool isWarning = false,
  }) {
    Color backgroundColor;
    if (isPositive) {
      backgroundColor = Colors.green.shade50;
    } else if (isNegative) {
      backgroundColor = Colors.red.shade50;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade50;
    } else {
      backgroundColor = const Color(0xFFF5E2C8).withOpacity(0.3);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icono
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),

          // Texto/Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Input Text
          Expanded(
            flex: 2,
            child: Text(
              expensesToday.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPositive
                    ? Colors.green.shade700
                    : isNegative
                    ? Colors.red.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón Guardar
          if (expensesToday == 0)
            ElevatedButton.icon(
              onPressed: () {
                _registrarGasto();
              },
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Registrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _registrarGasto() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DialogoRegistroGasto(
        idDespacho: widget.idDespacho,
        idChofer: int.parse(userSession!.id),
      ),
    );

    if (result != null) {
      // JSON listo para enviar a la API

      final choferVM = context.read<ChoferViewModel>();
      DialogsWidget.showLoading(message: 'Procesando...');
      final navigator = Navigator.of(context, rootNavigator: true);

      final success = await choferVM.registrarGastoDespacho(
        result,
        userSession?.accessToken ?? '',
      );
      if (!mounted) return;
      navigator.pop();
      if (success) {
        DialogsWidget.showSuccess(
          title: 'Muy bien',
          message: choferVM.msj ?? 'Guardado correctamente',
          onClose: () {
            if (!mounted) return;
            Navigator.pop(context);
          },
        );
        return;
      } else {
        DialogsWidget.showError(
          title: 'Atención',
          message: choferVM.msj ?? 'Error desconocido',
        );
        return;
      }
    }
  }

  Widget _buildTotalToDeliverCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Saldo Total a Entregar',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ventas - Gastos',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '\$${soldAmount.toStringAsFixed(2)} - \$${expensesToday.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${totalToDeliver.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
