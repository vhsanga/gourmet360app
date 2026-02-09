import 'package:Gourmet360/core/providers/user_provider.dart';
import 'package:Gourmet360/models/usuario.dart';
import 'package:Gourmet360/viewmodels/localtion_viewmodel.dart';
import 'package:Gourmet360/viewmodels/location_chofer_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class MapaCamionesScreen extends StatefulWidget {
  @override
  _MapaCamionesScreenState createState() => _MapaCamionesScreenState();
}

class _MapaCamionesScreenState extends State<MapaCamionesScreen> {
  GoogleMapController? _mapController;
  Usuario? userSession;
  BitmapDescriptor? _truckIcon;
  LatLng? _currentLatLng;
  bool _loadingPosition = true;

  Future<void> _loadTruckIcon() async {
    _truckIcon = await getTruckIcon();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTruckIcon();
      final pos = await context.read<LocationViewModel>().getPositionOnce();

      if (pos != null) {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
      }

      final userProvider = context.read<UserProvider>();
      if (userProvider.status == UserStatus.loaded &&
          userProvider.usuario != null) {
        userSession = userProvider.usuario;

        context.read<LocationChoferViewModel>().consultarUbicaciones(
          userSession!.accessToken,
        );
      }

      setState(() {
        _loadingPosition = false;
      });
    });
  }

  Future<BitmapDescriptor> getTruckIcon() async {
    final ByteData data = await rootBundle.load('assets/icons/uil--truck.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 96, // controla tamaño real del marker
    );
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationChoferViewModel>();

    if (_loadingPosition || _currentLatLng == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Rastreo de Camiones")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.isLoadingMap) {
      return Scaffold(
        appBar: AppBar(title: Text("Rastreo de Camiones")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Rastreo de Camiones")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 14,
            ),
            markers: vm.markers.map((m) {
              return m.copyWith(
                iconParam: _truckIcon ?? BitmapDescriptor.defaultMarker,
              );
            }).toSet(),
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;

              controller.animateCamera(
                CameraUpdate.newLatLngZoom(_currentLatLng!, 14),
              );
            },
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
