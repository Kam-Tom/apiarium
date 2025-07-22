import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

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
  
  // For continuous increment/decrement
  bool _isIncrementing = false;
  bool _isDecrementing = false;
  String _currentField = '';

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

  // Method to handle continuous increment/decrement
  void _startContinuousUpdate({
    required String field,
    required bool increment,
    required int currentValue,
    required int min,
    required int max,
    required Function(int) onUpdate,
  }) async {
    setState(() {
      _currentField = field;
      if (increment) {
        _isIncrementing = true;
      } else {
        _isDecrementing = true;
      }
    });
    
    // Initial value
    int updatedValue = currentValue;
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    while ((_isIncrementing || _isDecrementing) && mounted && _currentField == field) {
      if (increment) {
        if (updatedValue < max) {
          updatedValue += 1;
          onUpdate(updatedValue);
        } else {
          break;
        }
      } else {
        if (updatedValue > min) {
          updatedValue -= 1;
          onUpdate(updatedValue);
        } else {
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _stopContinuousUpdate() {
    if (mounted) {
      setState(() {
        _isIncrementing = false;
        _isDecrementing = false;
        _currentField = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditHiveBloc, EditHiveState>(
      buildWhen: (previous, current) => 
        previous.honeyFrameCount != current.honeyFrameCount ||
        previous.broodFrameCount != current.broodFrameCount ||
        previous.boxCount != current.boxCount ||
        previous.superBoxCount != current.superBoxCount ||
        previous.framesPerBox != current.framesPerBox ||
        previous.hasFrames != current.hasFrames ||
        previous.frameStandard != current.frameStandard,
      builder: (context, state) {
        if (!(state.hasFrames ?? false)) {
          return const SizedBox.shrink();
        }

        _frameCountController.text = state.honeyFrameCount?.toString() ?? '0';
        _broodFrameCountController.text = state.broodFrameCount?.toString() ?? '0';
        _broodBoxCountController.text = state.boxCount?.toString() ?? '0';
        _honeySuperBoxCountController.text = state.superBoxCount?.toString() ?? '0';

        return EditHiveCard(
          title: 'frames_and_boxes'.tr(),
          icon: Icons.grid_view,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFramesAndBoxesGrid(context, state, isSmall),
                  if (state.frameStandard != null) ...[
                    const SizedBox(height: 16),
                    _buildFrameInfo(context, state),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFramesAndBoxesGrid(BuildContext context, EditHiveState state, bool isSmall) {
    final broodBoxCount = state.boxCount ?? 0;
    final honeySuperCount = state.superBoxCount ?? 0;
    final framesPerBox = state.framesPerBox ?? 0;

    final maxNormalFrames = honeySuperCount > 0 && framesPerBox > 0 ? framesPerBox * honeySuperCount : 100;
    final maxBroodFrames = broodBoxCount > 0 && framesPerBox > 0 ? framesPerBox * broodBoxCount : 100;

    final rowChildren = [
      // Normal Frames
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'normal_frames'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _frameCountController,
              decoration: InputDecoration(
                labelText: 'frame_count'.tr(),
                border: const OutlineInputBorder(),
                helperText: framesPerBox > 0 && honeySuperCount > 0
                    ? '${state.honeyFrameCount ?? 0}/${framesPerBox * honeySuperCount}'
                    : 'total_frames'.tr(),
                suffixIcon: _buildCounterButtons(
                  onDecrease: () {
                    final currentValue = state.honeyFrameCount ?? 0;
                    if (currentValue > 0) {
                      context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(currentValue - 1));
                    }
                  },
                  onIncrease: () {
                    final currentValue = state.honeyFrameCount ?? 0;
                    if (currentValue < maxNormalFrames) {
                      context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(currentValue + 1));
                    }
                  },
                  onLongPressIncrease: () {
                    final currentValue = state.honeyFrameCount ?? 0;
                    _startContinuousUpdate(
                      field: 'frameCount',
                      increment: true,
                      currentValue: currentValue,
                      min: 0,
                      max: maxNormalFrames,
                      onUpdate: (value) {
                        context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(value));
                      },
                    );
                  },
                  onLongPressDecrease: () {
                    final currentValue = state.honeyFrameCount ?? 0;
                    _startContinuousUpdate(
                      field: 'frameCount',
                      increment: false,
                      currentValue: currentValue,
                      min: 0,
                      max: maxNormalFrames,
                      onUpdate: (value) {
                        context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(value));
                      },
                    );
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                if (intValue <= maxNormalFrames) {
                  context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(intValue));
                }
              },
            ),
          ],
        ),
      ),
      const SizedBox(width: 16),
      // Brood Frames
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'brood_frames'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _broodFrameCountController,
              decoration: InputDecoration(
                labelText: 'brood_count'.tr(),
                border: const OutlineInputBorder(),
                helperText: framesPerBox > 0 && broodBoxCount > 0
                    ? '${state.broodFrameCount ?? 0}/${framesPerBox * broodBoxCount}'
                    : 'frames_with_brood'.tr(),
                suffixIcon: _buildCounterButtons(
                  onDecrease: () {
                    final currentValue = state.broodFrameCount ?? 0;
                    if (currentValue > 0) {
                      context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(currentValue - 1));
                    }
                  },
                  onIncrease: () {
                    final currentValue = state.broodFrameCount ?? 0;
                    if (currentValue < maxBroodFrames) {
                      context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(currentValue + 1));
                    }
                  },
                  onLongPressIncrease: () {
                    final currentValue = state.broodFrameCount ?? 0;
                    _startContinuousUpdate(
                      field: 'broodFrameCount',
                      increment: true,
                      currentValue: currentValue,
                      min: 0,
                      max: maxBroodFrames,
                      onUpdate: (value) {
                        context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(value));
                      },
                    );
                  },
                  onLongPressDecrease: () {
                    final currentValue = state.broodFrameCount ?? 0;
                    _startContinuousUpdate(
                      field: 'broodFrameCount',
                      increment: false,
                      currentValue: currentValue,
                      min: 0,
                      max: maxBroodFrames,
                      onUpdate: (value) {
                        context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(value));
                      },
                    );
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                if (intValue <= maxBroodFrames) {
                  context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(intValue));
                }
              },
            ),
          ],
        ),
      ),
    ];

    final row2Children = [
      // Honey Supers
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'honey_supers'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _honeySuperBoxCountController,
              decoration: InputDecoration(
                labelText: 'super_count'.tr(),
                border: const OutlineInputBorder(),
                helperText: honeySuperCount > 0 && framesPerBox > 0
                    ? '${honeySuperCount * framesPerBox} frames capacity'
                    : 'frames_with_honey'.tr(),
                suffixIcon: _buildCounterButtons(
                  onDecrease: () {
                    final currentBoxValue = state.superBoxCount ?? 0;
                    if (currentBoxValue > 0) {
                      _adjustFrameCountForHoneyBoxChange(
                        context: context,
                        state: state,
                        newBoxCount: currentBoxValue - 1,
                      );
                      context.read<EditHiveBloc>().add(
                        EditHiveHoneySuperBoxCountChanged(currentBoxValue - 1)
                      );
                    }
                  },
                  onIncrease: () {
                    final currentBoxValue = state.superBoxCount ?? 0;
                    _adjustFrameCountForHoneyBoxChange(
                      context: context,
                      state: state,
                      newBoxCount: currentBoxValue + 1,
                    );
                    context.read<EditHiveBloc>().add(
                      EditHiveHoneySuperBoxCountChanged(currentBoxValue + 1)
                    );
                  },
                  onLongPressIncrease: () {
                    final currentValue = state.superBoxCount ?? 0;
                    _startContinuousUpdate(
                      field: 'honeySuperBoxCount',
                      increment: true,
                      currentValue: currentValue,
                      min: 0,
                      max: 10,
                      onUpdate: (value) {
                        _adjustFrameCountForHoneyBoxChange(
                          context: context,
                          state: state,
                          newBoxCount: value,
                        );
                        context.read<EditHiveBloc>().add(
                          EditHiveHoneySuperBoxCountChanged(value)
                        );
                      },
                    );
                  },
                  onLongPressDecrease: () {
                    final currentValue = state.superBoxCount ?? 0;
                    _startContinuousUpdate(
                      field: 'honeySuperBoxCount',
                      increment: false,
                      currentValue: currentValue,
                      min: 0,
                      max: 10,
                      onUpdate: (value) {
                        _adjustFrameCountForHoneyBoxChange(
                          context: context,
                          state: state,
                          newBoxCount: value,
                        );
                        context.read<EditHiveBloc>().add(
                          EditHiveHoneySuperBoxCountChanged(value)
                        );
                      },
                    );
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
      // Brood Boxes
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'brood_boxes'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _broodBoxCountController,
              decoration: InputDecoration(
                labelText: 'box_count'.tr(),
                border: const OutlineInputBorder(),
                suffixIcon: _buildCounterButtons(
                  onDecrease: () {
                    final currentValue = state.boxCount ?? 0;
                    if (currentValue > 0) {
                      _adjustBroodFrameCountForBroodBoxChange(
                        context: context,
                        state: state,
                        newBoxCount: currentValue - 1,
                      );
                      context.read<EditHiveBloc>().add(
                        EditHiveBroodBoxCountChanged(currentValue - 1)
                      );
                    }
                  },
                  onIncrease: () {
                    final currentValue = state.boxCount ?? 0;
                    _adjustBroodFrameCountForBroodBoxChange(
                      context: context,
                      state: state,
                      newBoxCount: currentValue + 1,
                    );
                    context.read<EditHiveBloc>().add(
                      EditHiveBroodBoxCountChanged(currentValue + 1)
                    );
                  },
                  onLongPressIncrease: () {
                    final currentValue = state.boxCount ?? 0;
                    _startContinuousUpdate(
                      field: 'broodBoxCount',
                      increment: true,
                      currentValue: currentValue,
                      min: 0,
                      max: 10,
                      onUpdate: (value) {
                        _adjustBroodFrameCountForBroodBoxChange(
                          context: context,
                          state: state,
                          newBoxCount: value,
                        );
                        context.read<EditHiveBloc>().add(
                          EditHiveBroodBoxCountChanged(value)
                        );
                      },
                    );
                  },
                  onLongPressDecrease: () {
                    final currentValue = state.boxCount ?? 0;
                    _startContinuousUpdate(
                      field: 'broodBoxCount',
                      increment: false,
                      currentValue: currentValue,
                      min: 0,
                      max: 10,
                      onUpdate: (value) {
                        _adjustBroodFrameCountForBroodBoxChange(
                          context: context,
                          state: state,
                          newBoxCount: value,
                        );
                        context.read<EditHiveBloc>().add(
                          EditHiveBroodBoxCountChanged(value)
                        );
                      },
                    );
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isSmall
            ? Column(
                children: [
                  ...rowChildren,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rowChildren,
              ),
        const SizedBox(height: 16),
        isSmall
            ? Column(
                children: [
                  ...row2Children,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: row2Children,
              ),
      ],
    );
  }

  void _adjustFrameCountForHoneyBoxChange({
    required BuildContext context,
    required EditHiveState state,
    required int newBoxCount,
  }) {
    final framesPerBox = state.framesPerBox ?? 0;
    if (framesPerBox == 0) return;
    final oldBoxCount = state.superBoxCount ?? 0;
    final oldFrameCount = state.honeyFrameCount ?? 0;
    final newMaxFrames = newBoxCount * framesPerBox;
    int newFrameCount;
    if (newBoxCount > oldBoxCount) {
      newFrameCount = math.min(oldFrameCount + framesPerBox, newMaxFrames);
    } else if (newBoxCount < oldBoxCount) {
      newFrameCount = math.min(oldFrameCount, newMaxFrames);
      if (oldFrameCount > newMaxFrames) {
        newFrameCount = newMaxFrames;
      } else if (newBoxCount == 0) {
        newFrameCount = 0;
      }
    } else {
      return;
    }
    context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(newFrameCount));
  }
  
  void _adjustBroodFrameCountForBroodBoxChange({
    required BuildContext context,
    required EditHiveState state,
    required int newBoxCount,
  }) {
    final framesPerBox = state.framesPerBox ?? 0;
    if (framesPerBox == 0) return;
    final oldBoxCount = state.boxCount ?? 0;
    final oldBroodFrameCount = state.broodFrameCount ?? 0;
    final newMaxFrames = newBoxCount * framesPerBox;
    int newBroodFrameCount;
    if (newBoxCount > oldBoxCount) {
      newBroodFrameCount = math.min(oldBroodFrameCount + framesPerBox, newMaxFrames);
    } else if (newBoxCount < oldBoxCount) {
      newBroodFrameCount = math.min(oldBroodFrameCount, newMaxFrames);
      if (oldBroodFrameCount > newMaxFrames) {
        newBroodFrameCount = newMaxFrames;
      } else if (newBoxCount == 0) {
        newBroodFrameCount = 0;
      }
    } else {
      return;
    }
    context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(newBroodFrameCount));
  }

  Widget _buildCounterButtons({
    required VoidCallback onDecrease, 
    required VoidCallback onIncrease,
    required VoidCallback onLongPressIncrease,
    required VoidCallback onLongPressDecrease,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrease,
          onLongPress: onLongPressDecrease,
          onLongPressEnd: (_) => _stopContinuousUpdate(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.remove, color: Colors.grey, size: 20),
          ),
        ),
        Container(
          height: 20,
          width: 1,
          color: Colors.grey.shade300,
        ),
        GestureDetector(
          onTap: onIncrease,
          onLongPress: onLongPressIncrease,
          onLongPressEnd: (_) => _stopContinuousUpdate(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.add, color: Colors.grey, size: 20),
          ),
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
            'frame_information'.tr(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (state.frameStandard != null)
            _infoRow('standard'.tr(), state.frameStandard!),
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
// No changes needed here if you use state.hasFrames, state.framesPerBox, state.frameStandard