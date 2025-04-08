import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/edit_apiary_card.dart';
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
          _buildLocation(),
          const SizedBox(height: 16),
          _buildMigratoryOption(),
        ],
      ),
    );
  }

  Widget _buildLocation() {
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
      ),
      onChanged: (value) {
        context.read<EditApiaryBloc>().add(EditApiaryLocationChanged(value.trim()));
      },
    );
  }

  Widget _buildMigratoryOption() {
    final isMigratory = context.select((EditApiaryBloc bloc) => bloc.state.isMigratory);
    
    return Row(
      children: [
        Switch(
          value: isMigratory,
          onChanged: (value) {
            context.read<EditApiaryBloc>().add(EditApiaryIsMigratoryChanged(value));
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This is a migratory apiary'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
