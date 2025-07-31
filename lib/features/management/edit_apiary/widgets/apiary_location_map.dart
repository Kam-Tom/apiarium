import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiaryLocationMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Color? apiaryColor;
  final String apiaryName;
  final Function(double latitude, double longitude, String address) onLocationSelected;

  const ApiaryLocationMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.apiaryColor,
    required this.apiaryName,
    required this.onLocationSelected,
  });

  @override
  State<ApiaryLocationMap> createState() => _ApiaryLocationMapState();
}

class _ApiaryLocationMapState extends State<ApiaryLocationMap> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _isLoading = false;

  // Default location (Poland center)
  static const LatLng _defaultLocation = LatLng(52.0693, 19.4803);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _updateMarker(_selectedLocation!);
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: const MarkerId('apiary_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.apiaryColor != null ? HSLColor.fromColor(widget.apiaryColor!).hue : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: widget.apiaryName.isNotEmpty ? widget.apiaryName : 'edit_apiary.new_apiary'.tr(),
            snippet: 'edit_apiary.lat'.tr() + ': ${location.latitude.toStringAsFixed(6)}, ' +
                     'edit_apiary.lng'.tr() + ': ${location.longitude.toStringAsFixed(6)}',
          ),
        ),
      };
    });
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      setState(() => _isLoading = true);
      final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      final address = placemarks.isNotEmpty ? _formatAddress(placemarks.first) : 'edit_apiary.unknown_location'.tr();
      widget.onLocationSelected(location.latitude, location.longitude, address);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatAddress(Placemark placemark) {
    if (placemark.locality?.isNotEmpty == true) return placemark.locality!;
    if (placemark.subLocality?.isNotEmpty == true) return placemark.subLocality!;
    if (placemark.administrativeArea?.isNotEmpty == true) return placemark.administrativeArea!;
    return placemark.country ?? 'edit_apiary.unknown_location'.tr();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    try {
      setState(() => _isLoading = true);
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = LatLng(locations.first.latitude, locations.first.longitude);
        _updateMarker(location);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
        await _reverseGeocode(location);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'edit_apiary.search_location'.tr(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _searchLocation(_searchController.text),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        
        // Map
        SizedBox(
          height: 300,
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: _selectedLocation != null ? 15 : 6,
            ),
            markers: _markers,
            onTap: (LatLng location) {
              _updateMarker(location);
              _reverseGeocode(location);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),
        
        // Location info
        if (_selectedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: widget.apiaryColor ?? Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'edit_apiary.selected_location'.tr(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        'edit_apiary.lat'.tr() + ': ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'edit_apiary.lng'.tr() + ': ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}