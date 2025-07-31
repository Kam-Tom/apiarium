import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/management/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/management/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/domain/enums/hive_accessory.dart';
import 'package:apiarium/shared/widgets/dropdown/multi_select_dropdown.dart';

class HiveAccessories extends StatelessWidget {
  const HiveAccessories({super.key});

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'edit_hive.accessories'.tr(),
      icon: Icons.extension,
      child: BlocBuilder<EditHiveBloc, EditHiveState>(
        builder: (context, state) {
          final physicalAccessories = HiveAccessory.values.where((a) => a.category == 'accessories.physical'.tr()).toList();
          final iotAccessories = HiveAccessory.values.where((a) => a.category == 'accessories.iot_devices'.tr()).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'accessories.physical'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 8),
              MultiSelectDropdown<HiveAccessory>(
                items: physicalAccessories,
                selectedItems: state.accessories?.where((a) => physicalAccessories.contains(a)).toList() ?? [],
                onChanged: (selectedPhysical) {
                  final selectedIoT = state.accessories?.where((a) => iotAccessories.contains(a)).toList() ?? [];
                  final allSelected = [...selectedPhysical, ...selectedIoT];
                  context.read<EditHiveBloc>().add(EditHiveAccessoriesChanged(allSelected));
                },
                itemLabelBuilder: (accessory) => accessory.displayName,
                hintText: 'edit_hive.select_physical_accessories'.tr(),
                maxHeight: 200,
              ),
              const SizedBox(height: 16),
              Text(
                'accessories.iot_devices'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 8),
              MultiSelectDropdown<HiveAccessory>(
                items: iotAccessories,
                selectedItems: state.accessories?.where((a) => iotAccessories.contains(a)).toList() ?? [],
                onChanged: (selectedIoT) {
                  final selectedPhysical = state.accessories?.where((a) => physicalAccessories.contains(a)).toList() ?? [];
                  final allSelected = [...selectedPhysical, ...selectedIoT];
                  context.read<EditHiveBloc>().add(EditHiveAccessoriesChanged(allSelected));
                },
                itemLabelBuilder: (accessory) => accessory.displayName,
                hintText: 'edit_hive.select_iot_accessories'.tr(),
                maxHeight: 200,
              ),
            ],
          );
        },
      ),
    );
  }
}