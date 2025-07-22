import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/apiary_location_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiaryLocationInfo extends StatefulWidget {
  const ApiaryLocationInfo({super.key});

  @override
  State<ApiaryLocationInfo> createState() => _ApiaryLocationInfoState();
}

class _ApiaryLocationInfoState extends State<ApiaryLocationInfo> {
  final _locationController = TextEditingController();
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = context.read<EditApiaryBloc>().state.location;
  }

  @override
  Widget build(BuildContext context) {
    return EditApiaryCard(
      title: 'Location'.tr(),
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationField(),
          const SizedBox(height: 16),
          _buildMapToggle(),
          if (_showMap) ...[
            const SizedBox(height: 16),
            _buildLocationMap(),
          ],
          const SizedBox(height: 16),
          _buildUseLocationAsNameButton(),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    final locationError = context.select(
      (EditApiaryBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.location.trim().isEmpty
              ? 'Location is required'.tr()
              : null,
    );

    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location/Address'.tr(),
        border: const OutlineInputBorder(),
        hintText: 'e.g. 123 Bee Street, Honey Valley'.tr(),
        errorText: locationError,
        errorBorder: locationError != null
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _showMap = !_showMap;
            });
          },
          icon: Icon(_showMap ? Icons.map_outlined : Icons.map),
          tooltip: _showMap ? 'Hide Map'.tr() : 'Show Map'.tr(),
        ),
      ),
      onChanged: (value) {
        context.read<EditApiaryBloc>().add(EditApiaryLocationChanged(value.trim()));
      },
    );
  }

  Widget _buildMapToggle() {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Tap on the map to select location or use search to find a place'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap() {
    return BlocBuilder<EditApiaryBloc, EditApiaryState>(
      builder: (context, state) {
        return ApiaryLocationMap(
          initialLatitude: state.latitude,
          initialLongitude: state.longitude,
          apiaryColor: state.color,
          apiaryName: state.name,
          onLocationSelected: (latitude, longitude, address) {
            context.read<EditApiaryBloc>().add(
              EditApiaryLocationCoordinatesChanged(
                latitude: latitude,
                longitude: longitude,
              ),
            );
            
            if (_locationController.text.trim().isEmpty || address.isNotEmpty) {
              _locationController.text = address;
              context.read<EditApiaryBloc>().add(
                EditApiaryLocationChanged(address),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUseLocationAsNameButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          final location = _locationController.text.trim();
          if (location.isNotEmpty) {
            context.read<EditApiaryBloc>().add(EditApiaryNameChanged(location));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('edit_apiary.name_updated'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Text(
          'edit_apiary.use_location_as_name'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
