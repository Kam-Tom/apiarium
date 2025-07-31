import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiaryStatusInfo extends StatelessWidget {
  const ApiaryStatusInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return EditApiaryCard(
      title: 'common.status'.tr(),
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('edit_apiary.apiary_status'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildStatus(context),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final status = context.select((EditApiaryBloc bloc) => bloc.state.status);

    return DropdownButtonFormField<ApiaryStatus>(
      value: status,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: ApiaryStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_formatStatus(status)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<EditApiaryBloc>().add(EditApiaryStatusChanged(value));
        }
      },
    );
  }

  String _formatStatus(ApiaryStatus status) {
    switch (status) {
      case ApiaryStatus.active:
        return 'edit_apiary.status_active'.tr();
      case ApiaryStatus.inactive:
        return 'edit_apiary.status_inactive'.tr();
      case ApiaryStatus.archived:
        return 'edit_apiary.status_archived'.tr();
    }
  }
}
