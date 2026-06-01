import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/core/themes/app_theme_data.dart';
import 'package:Gourmet360/models/cliente.dart';
import 'package:Gourmet360/models/cliente_admin.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/cliente_viewmodel.dart';
import 'package:Gourmet360/views/templates/dialog_editar_cliente.dart';
import 'package:Gourmet360/views/templates/dialog_registro_cliente.dart';
import 'package:Gourmet360/views/templates/dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientesAdminScreen extends StatefulWidget {
  const ClientesAdminScreen({super.key});

  @override
  State<ClientesAdminScreen> createState() => _ClientesAdminScreenState();
}

class _ClientesAdminScreenState extends State<ClientesAdminScreen> {
  String _searchQuery = '';
  Usuario? _userSession;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    _userSession = context.read<UserProvider>().usuario;
    if (_userSession != null) {
      context.read<ClienteViewModel>().listarClientesForAdmin(
        _userSession!.accessToken,
      );
    }
  }

  List<ClienteAdmin> _filtrar(List<ClienteAdmin> lista) {
    if (_searchQuery.isEmpty) return lista;
    final q = _searchQuery.toLowerCase();
    return lista.where((c) {
      return c.nombre.toLowerCase().contains(q) ||
          c.direccion.toLowerCase().contains(q) ||
          c.telefono.contains(q);
    }).toList();
  }

  void _mostrarDialogoEditarCliente(ClienteAdmin clienteAdmin) {
    final Cliente cliente = clienteAdmin.toCliente();
    final Usuario userSession = context.read<UserProvider>().usuario!;
    showDialog(
      context: context,
      builder: (context) => DialogoEditarCliente(
        cliente: cliente,
        userSession: userSession,
        onSuccess: _loadData,
      ),
    );
  }

  void _eliminarCliente(ClienteAdmin clienteAdmin) {
    DialogsWidget.showConfirmation(
      title: 'Eliminar Cliente',
      message: '¿Estás seguro de que deseas eliminar a ${clienteAdmin.nombre}?',
      onConfirm: () async {
        final userSession = context.read<UserProvider>().usuario!;
        final vm = context.read<ClienteViewModel>();

        DialogsWidget.showLoading(message: 'Eliminando...');
        final success = await vm.eliminarCliente(
          userSession.accessToken,
          clienteAdmin.id,
        );
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        if (success) {
          DialogsWidget.showSuccess(
            title: 'Listo',
            message: vm.msj ?? 'Cliente eliminado correctamente',
            onClose: _loadData,
          );
        } else {
          DialogsWidget.showError(
            title: 'Error',
            message: vm.msj ?? 'No se pudo eliminar el cliente',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClienteViewModel>();
    final filtrados = _filtrar(vm.clientes);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeData.identityColor,
        iconTheme: const IconThemeData(color: AppThemeData.primaryColor),
        title: const Text(
          'Clientes',
          style: TextStyle(
            color: AppThemeData.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar cliente',
            onPressed: _openCrearCliente,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (vm.clientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay clientes registrados',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filtrados.isEmpty
                    ? Center(
                        child: Text(
                          'Sin resultados para "$_searchQuery"',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          itemCount: filtrados.length,
                          itemBuilder: (_, i) => _buildCard(filtrados[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCrearCliente,
        backgroundColor: AppThemeData.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo cliente'),
      ),
    );
  }

  void _openCrearCliente() {
    final userSession = context.read<UserProvider>().usuario!;
    showDialog(
      context: context,
      builder: (_) => DialogoRegistroCliente(
        idChofer: 0,
        userSession: userSession,
        onSuccess: _loadData,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, dirección o teléfono...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppThemeData.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ClienteAdmin cliente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemeData.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppThemeData.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cliente.nombre.trim(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppThemeData.primaryColor,
                              ),
                            ),
                          ),
                          if (cliente.especial) _buildEspecialBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        cliente.direccion,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'editar') {
                      _mostrarDialogoEditarCliente(cliente);
                    }
                    if (value == 'eliminar') {
                      if(_userSession == null || _userSession!.rol != 'admin') {
                        DialogsWidget.showError(
                          title: 'Acceso denegado',
                          message: 'No tienes permisos para eliminar. Solo el administrador puede eliminar clientes.',
                        );
                        return;
                      }
                      _eliminarCliente(cliente);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.person_outline, cliente.contacto),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.phone_outlined, cliente.telefono),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSaldoChip(cliente.saldoActual),
                Text(
                  'Reg. ${_formatFecha(cliente.fechaRegistro)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text.trim(),
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildEspecialBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppThemeData.identityColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Especial',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppThemeData.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSaldoChip(double saldo) {
    final hasDebt = saldo > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasDebt
            ? const Color(0xFFef4444).withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasDebt
                ? Icons.account_balance_wallet_outlined
                : Icons.check_circle_outline,
            size: 13,
            color: hasDebt ? const Color(0xFFef4444) : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            'Saldo: \$${saldo.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasDebt ? const Color(0xFFef4444) : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
