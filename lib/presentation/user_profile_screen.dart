import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de perfil
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF6B2A02),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6B2A02),
                      const Color(0xFF6B2A02).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5E2C8),
                        border: Border.all(
                          color: const Color(0xFFFFFCF5),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF6B2A02),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jacobo Urquiso',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFCF5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E2C8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Chofer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B2A02),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // Contenido del perfil
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección Información Personal
                  _buildSectionTitle('Información Personal'),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Nombres',
                    value: 'Jacobo',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Apellidos',
                    value: 'Urquizo',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Celular',
                    value: '099 123 4567',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'Rol',
                    value: 'Chofer de Entregas',
                  ),

                  const SizedBox(height: 32),

                  // Sección Información del Vehículo
                  _buildSectionTitle('Información del Vehículo'),
                  const SizedBox(height: 16),
                  _buildVehicleCard(),

                  const SizedBox(height: 32),

                  // Botones de acción
                  _buildActionButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B2A02),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E2C8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6B2A02), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6B2A02),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B2A02),
            const Color(0xFF6B2A02).withOpacity(0.8),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2C8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF6B2A02),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Placa',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFF5E2C8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PBX-1234',
                      style: TextStyle(
                        fontSize: 24,
                        color: const Color(0xFFFFFCF5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marca',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5E2C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chevrolet',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFFCF5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modelo',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF5E2C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NPR 2020',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFFCF5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: Text(
              'Editar Perfil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2A02),
              foregroundColor: const Color(0xFFFFFCF5),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B2A02),
              side: const BorderSide(color: Color(0xFF6B2A02), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
