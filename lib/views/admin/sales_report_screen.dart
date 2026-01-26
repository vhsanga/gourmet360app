import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({Key? key}) : super(key: key);

  // Datos del conductor
  final String driverName = 'Jacobo Urquizo';
  final String driverPlate = 'PBX-1234';

  // Datos de productos (panes)
  final int assignedProducts = 1000;
  final int soldProducts = 820;
  final int returnedProducts = 100;
  final int remainingProducts = 80;

  // Datos financieros
  final double soldAmount = 98.40;
  final double accountsReceivableToday = 8.50;
  final double accountsReceivableAccumulated = 35.00;
  final double expensesToday = 10.00;

  double get totalToDeliver {
    return soldAmount - expensesToday;
  }

  double get productPercentageSold {
    return (soldProducts / assignedProducts) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDriverInfoCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Reporte de Productos'),
                    const SizedBox(height: 12),
                    _buildProductsReportCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Reporte Financiero'),
                    const SizedBox(height: 12),
                    _buildFinancialReportCard(),
                    const SizedBox(height: 24),
                    _buildTotalToDeliverCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B2A02),
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
            onPressed: () {},
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Miércoles, 20 de Noviembre 2024',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: const Color(0xFFF5E2C8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B2A02),
            const Color(0xFF6B2A02).withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2A02).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E2C8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                driverName[0].toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B2A02),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_rounded,
                      size: 16,
                      color: Color(0xFFF5E2C8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driverPlate,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: const Color(0xFFF5E2C8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified, color: Colors.white, size: 28),
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
        color: const Color(0xFF6B2A02),
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
                        color: const Color(0xFF6B2A02),
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
          _buildProductStatRow(
            'Sobrantes',
            remainingProducts,
            Icons.inventory,
            Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: soldProducts / assignedProducts,
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
              color: const Color(0xFF6B2A02),
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Financiero',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B2A02),
                      ),
                    ),
                    Text(
                      'Movimientos del día',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          _buildFinancialStatRow(
            'Gastos del Día',
            expensesToday,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Monto a entregar al finalizar el día',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
