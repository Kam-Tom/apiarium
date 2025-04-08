import 'package:apiarium/features/managment/edit_queen/widgets/edit_queen_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';

class QueenAcquisition extends StatefulWidget {
  const QueenAcquisition({super.key});

  @override
  State<QueenAcquisition> createState() => _QueenAcquisitionState();
}

class _QueenAcquisitionState extends State<QueenAcquisition> {
  final _originController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final origin = context.read<EditQueenBloc>().state.origin;
    if (_originController.text != origin && origin != null) {
      _originController.text = origin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditQueenCard(
      title: 'Acquisition',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildSource(),
          const SizedBox(height: 16),
          _buildOrigin(),
        ],
      ),
    );
  }

  Widget _buildSource() {
    final source = context.select((EditQueenBloc bloc) => bloc.state.source);

    return RoundedDropdown<QueenSource>(
      value: source,
      items: QueenSource.values,
      onChanged: (value) {
        if (value != null) {
          context.read<EditQueenBloc>().add(EditQueenSourceChanged(value));
        }
      },
    );
  }

  Widget _buildOrigin() {
    return TextFormField(
      controller: _originController,
      decoration: const InputDecoration(
        labelText: 'Origin (Optional)',
        hintText: 'Enter where the queen came from',
      ),
      onChanged: (value) {
        final trimmedValue = value.trim();
        if (trimmedValue.isNotEmpty) {
          context.read<EditQueenBloc>().add(EditQueenOriginChanged(trimmedValue));
        }
      },
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    super.dispose();
  }
}
