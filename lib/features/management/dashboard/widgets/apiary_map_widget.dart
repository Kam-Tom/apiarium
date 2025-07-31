import 'package:apiarium/shared/services/dashboard_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apiarium/shared/shared.dart';

class ApiaryMapWidget extends StatefulWidget {
  final List<ApiaryMapData> apiaries;
  final Function(String apiaryId)? onApiaryTap;

  const ApiaryMapWidget({
    super.key,
    required this.apiaries,
    this.onApiaryTap,
  });

  @override
  State<ApiaryMapWidget> createState() => _ApiaryMapWidgetState();
}

class _ApiaryMapWidgetState extends State<ApiaryMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(ApiaryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiaries != widget.apiaries) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    _markers = widget.apiaries.map((apiary) {
      final color = apiary.color ?? Colors.amber;
      final hue = HSLColor.fromColor(color).hue;
      
      return Marker(
        markerId: MarkerId(apiary.id),
        position: LatLng(apiary.latitude, apiary.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: apiary.name,
          snippet: '${apiary.activeHiveCount}/${apiary.hiveCount} ${'apiary_details.active_hives'.tr()}',
          onTap: widget.onApiaryTap != null ? () => widget.onApiaryTap!(apiary.id) : null,
        ),
      );
    }).toSet();
    
    if (mounted) setState(() {});
  }

  LatLng get _center {
    if (widget.apiaries.isEmpty) {
      return const LatLng(52.0693, 19.4803); // Poland center
    }
    
    double lat = 0;
    double lng = 0;
    for (final apiary in widget.apiaries) {
      lat += apiary.latitude;
      lng += apiary.longitude;
    }
    
    return LatLng(lat / widget.apiaries.length, lng / widget.apiaries.length);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.apiaries.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'apiary_details.no_location_data'.tr(),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: widget.apiaries.length == 1 ? 15 : 10,
          ),
          markers: _markers,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
