import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/location_chofer_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapaCamionesScreen extends StatefulWidget {
  @override
  _MapaCamionesScreenState createState() => _MapaCamionesScreenState();
}

class _MapaCamionesScreenState extends State<MapaCamionesScreen> {
  GoogleMapController? _mapController;
  Usuario? userSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        print("Cargando lista de conductores para admin...");

        userSession = userProvider.usuario;
        context.read<LocationChoferViewModel>().consultarUbicaciones(
          userSession!.accessToken,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel
    final vm = context.watch<LocationChoferViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text("Rastreo de Camiones")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                -12.046374,
                -77.042793,
              ), // Coordenada inicial (ej: Lima)
              zoom: 12,
            ),
            markers: vm.markers, // Los marcadores vienen del VM
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
          ),

          if (vm.isLoadingMap)
            Center(
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => vm.consultarUbicaciones(userSession!.accessToken),
      ),
    );
  }
}
