import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Product {
  final String name;
  final double price;
  final int available;
  final int total;

  Product({
    required this.name,
    required this.price,
    required this.available,
    required this.total,
  });

  double get percentage => (available / total) * 100;
  bool get isLowStock => percentage < 50;
  bool get isCriticalStock => percentage < 30;
}

class ProductCategory {
  final String name;
  final IconData icon;
  final List<Product> products;

  ProductCategory({
    required this.name,
    required this.icon,
    required this.products,
  });
}

class ProductsInventoryScreen extends StatefulWidget {
  const ProductsInventoryScreen({Key? key}) : super(key: key);

  @override
  State<ProductsInventoryScreen> createState() =>
      _ProductsInventoryScreenState();
}

class _ProductsInventoryScreenState extends State<ProductsInventoryScreen> {
  final List<ProductCategory> categories = [
    ProductCategory(
      name: 'Pan',
      icon: Icons.bakery_dining,
      products: [
        Product(name: 'Enrollado', price: 0.13, available: 180, total: 300),
        Product(name: 'Reventado', price: 0.13, available: 215, total: 300),
        Product(name: 'Empanada', price: 0.13, available: 85, total: 500),
      ],
    ),
    ProductCategory(
      name: 'Galletas',
      icon: Icons.cookie,
      products: [
        Product(name: 'Biscocho', price: 0.80, available: 75, total: 150),
        Product(
          name: 'Chavelitas de chocolate',
          price: 0.80,
          available: 120,
          total: 150,
        ),
        Product(
          name: 'Chavelitas de vainilla',
          price: 0.80,
          available: 140,
          total: 150,
        ),
      ],
    ),
    ProductCategory(
      name: 'Keys',
      icon: Icons.cake,
      products: [
        Product(
          name: 'Key de Chocolate',
          price: 0.80,
          available: 35,
          total: 50,
        ),
        Product(name: 'Key de Vainilla', price: 0.80, available: 38, total: 50),
      ],
    ),
  ];

  String selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategorySection(categories[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6B2A02),
        icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
        label: Text(
          'Confirmar Carga',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'Inventario de Productos',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Productos pendientes por entregar',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: const Color(0xFFF5E2C8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalProducts = 0;
    int totalAvailable = 0;
    int totalMax = 0;

    for (var category in categories) {
      totalProducts += category.products.length;
      for (var product in category.products) {
        totalAvailable += product.available;
        totalMax += product.total;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            'Productos',
            '$totalProducts',
            Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniCard(
            'Disponibles',
            '$totalAvailable',
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniCard(
            'Capacidad',
            '$totalMax',
            Icons.all_inbox_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFF5E2C8), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: const Color(0xFFF5E2C8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('Todos', Icons.apps),
          _buildFilterChip('Stock Bajo', Icons.warning_amber_outlined),
          _buildFilterChip('Crítico', Icons.priority_high),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF6B2A02),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onSelected: (value) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: const Color(0xFFF5E2C8),
        selectedColor: const Color(0xFF6B2A02),
        labelStyle: GoogleFonts.montserrat(
          color: isSelected ? Colors.white : const Color(0xFF6B2A02),
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildCategorySection(ProductCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category.icon,
                  color: const Color(0xFF6B2A02),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B2A02),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${category.products.length}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B2A02),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...category.products.map((product) => _buildProductCard(product)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isCriticalStock
              ? Colors.red.shade200
              : product.isLowStock
              ? Colors.orange.shade200
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B2A02),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B2A02),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                product.isCriticalStock
                    ? Icons.error_outline
                    : product.isLowStock
                    ? Icons.warning_amber_outlined
                    : Icons.check_circle_outline,
                size: 18,
                color: product.isCriticalStock
                    ? Colors.red
                    : product.isLowStock
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.available} de ${product.total} unidades',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${product.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: product.isCriticalStock
                      ? Colors.red
                      : product.isLowStock
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: product.available / product.total,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                product.isCriticalStock
                    ? Colors.red
                    : product.isLowStock
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
