import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';

class HiveFrames extends StatefulWidget {
  const HiveFrames({super.key});

  @override
  State<HiveFrames> createState() => _HiveFramesState();
}

class _HiveFramesState extends State<HiveFrames> {
  late TextEditingController _frameCountController;
  late TextEditingController _broodFrameCountController;
  late TextEditingController _broodBoxCountController;
  late TextEditingController _honeySuperBoxCountController;

  @override
  void initState() {
    super.initState();
    _frameCountController = TextEditingController();
    _broodFrameCountController = TextEditingController();
    _broodBoxCountController = TextEditingController();
    _honeySuperBoxCountController = TextEditingController();
  }

  @override
  void dispose() {
    _frameCountController.dispose();
    _broodFrameCountController.dispose();
    _broodBoxCountController.dispose();
    _honeySuperBoxCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditHiveBloc, EditHiveState>(
      buildWhen: (previous, current) => 
        previous.hiveType != current.hiveType ||
        previous.currentFrameCount != current.currentFrameCount ||
        previous.currentBroodFrameCount != current.currentBroodFrameCount ||
        previous.currentBroodBoxCount != current.currentBroodBoxCount ||
        previous.currentHoneySuperBoxCount != current.currentHoneySuperBoxCount,
      builder: (context, state) {
        // Only show this section if the selected hive type has frames
        if (state.hiveType == null || !state.hiveType!.hasFrames) {
          return const SizedBox.shrink();
        }
        
        // Update controllers when state changes
        _frameCountController.text = state.currentFrameCount?.toString() ?? '0';
        _broodFrameCountController.text = state.currentBroodFrameCount?.toString() ?? '0';
        _broodBoxCountController.text = state.currentBroodBoxCount?.toString() ?? '0';
        _honeySuperBoxCountController.text = state.currentHoneySuperBoxCount?.toString() ?? '0';
        
        return EditHiveCard(
          title: 'Frames and Boxes',
          icon: Icons.grid_view,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFramesAndBoxesGrid(context, state),
              if (state.hiveType?.frameStandard != null) ...[
                const SizedBox(height: 16),
                _buildFrameInfo(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFramesAndBoxesGrid(BuildContext context, EditHiveState state) {
    // Calculate expected total frames based on defaults and box counts
    final broodBoxCount = state.currentBroodBoxCount ?? 0;
    final honeySuperCount = state.currentHoneySuperBoxCount ?? 0;
    final defaultFramesPerBox = state.hiveType?.defaultFrameCount ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: Normal Frames and Brood Frames
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frame Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Normal Frames',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _frameCountController,
                    decoration: InputDecoration(
                      labelText: 'Frame Count',
                      border: const OutlineInputBorder(),
                      helperText: defaultFramesPerBox > 0 && (broodBoxCount + honeySuperCount) > 0
                          ? '${state.currentFrameCount ?? 0}/${defaultFramesPerBox * (broodBoxCount + honeySuperCount)}'
                          : 'Total frames',
                      suffixIcon: _buildCounterButtons(
                        onDecrease: () {
                          final currentValue = state.currentFrameCount ?? 0;
                          if (currentValue > 0) {
                            context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(currentValue - 1));
                          }
                        },
                        onIncrease: () {
                          final currentValue = state.currentFrameCount ?? 0;
                          context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(currentValue + 1));
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final intValue = int.tryParse(value) ?? 0;
                      context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(intValue));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Brood Frame Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brood Frames',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _broodFrameCountController,
                    decoration: InputDecoration(
                      labelText: 'Brood Count',
                      border: const OutlineInputBorder(),
                      helperText: defaultFramesPerBox > 0 && broodBoxCount > 0
                          ? '${state.currentBroodFrameCount ?? 0}/${defaultFramesPerBox * broodBoxCount}'
                          : 'Frames with brood',
                      suffixIcon: _buildCounterButtons(
                        onDecrease: () {
                          final currentValue = state.currentBroodFrameCount ?? 0;
                          if (currentValue > 0) {
                            context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(currentValue - 1));
                          }
                        },
                        onIncrease: () {
                          final currentValue = state.currentBroodFrameCount ?? 0;
                          context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(currentValue + 1));
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final intValue = int.tryParse(value) ?? 0;
                      context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(intValue));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Honey Supers and Brood Boxes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Honey Super Box Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Honey Supers',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _honeySuperBoxCountController,
                    decoration: InputDecoration(
                      labelText: 'Super Count',
                      border: const OutlineInputBorder(),
                      helperText: honeySuperCount > 0 && defaultFramesPerBox > 0
                          ? '${honeySuperCount * defaultFramesPerBox} frames capacity'
                          : 'Frames with honey',
                      suffixIcon: _buildCounterButtons(
                        onDecrease: () {
                          final currentValue = state.currentHoneySuperBoxCount ?? 0;
                          if (currentValue > 0) {
                            context.read<EditHiveBloc>().add(EditHiveHoneySuperBoxCountChanged(currentValue - 1));
                          }
                        },
                        onIncrease: () {
                          final currentValue = state.currentHoneySuperBoxCount ?? 0;
                          context.read<EditHiveBloc>().add(EditHiveHoneySuperBoxCountChanged(currentValue + 1));
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final intValue = int.tryParse(value) ?? 0;
                      context.read<EditHiveBloc>().add(EditHiveHoneySuperBoxCountChanged(intValue));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Brood Box Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brood Boxes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _broodBoxCountController,
                    decoration: InputDecoration(
                      labelText: 'Box Count',
                      border: const OutlineInputBorder(),
                      helperText: defaultFramesPerBox > 0
                          ? '${broodBoxCount * defaultFramesPerBox} frames capacity'
                          : 'Typical: ${state.hiveType?.broodBoxCount ?? 0}',
                      suffixIcon: _buildCounterButtons(
                        onDecrease: () {
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          if (currentValue > 0) {
                            context.read<EditHiveBloc>().add(EditHiveBroodBoxCountChanged(currentValue - 1));
                          }
                        },
                        onIncrease: () {
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          context.read<EditHiveBloc>().add(EditHiveBroodBoxCountChanged(currentValue + 1));
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final intValue = int.tryParse(value) ?? 0;
                      context.read<EditHiveBloc>().add(EditHiveBroodBoxCountChanged(intValue));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButtons({required VoidCallback onDecrease, required VoidCallback onIncrease}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.grey),
          onPressed: onDecrease,
          tooltip: 'Decrease',
        ),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.shade300,
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.grey),
          onPressed: onIncrease,
          tooltip: 'Increase',
        ),
      ],
    );
  }

  Widget _buildFrameInfo(BuildContext context, EditHiveState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frame Information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (state.hiveType?.frameStandard != null)
            _infoRow('Standard:', state.hiveType!.frameStandard!),
          if (state.hiveType?.frameWidth != null && state.hiveType?.frameHeight != null)
            _infoRow(
              'Dimensions:',
              '${state.hiveType!.frameWidth} × ${state.hiveType!.frameHeight} cm',
            ),
          if (state.hiveType?.broodFrameWidth != null && state.hiveType?.broodFrameHeight != null)
            _infoRow(
              'Brood frame:',
              '${state.hiveType!.broodFrameWidth} × ${state.hiveType!.broodFrameHeight} cm',
            ),
          if (state.hiveType?.broodBoxCount != null)
            _infoRow('Typical brood boxes:', state.hiveType!.broodBoxCount!),
          if (state.hiveType?.honeySuperBoxCount != null)
            _infoRow('Typical honey supers:', state.hiveType!.honeySuperBoxCount!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}