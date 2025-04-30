import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
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
    
    // Calculate max frame limits
    final maxNormalFrames = honeySuperCount > 0 ? defaultFramesPerBox * honeySuperCount : 100;
    final maxBroodFrames = broodBoxCount > 0 ? defaultFramesPerBox * broodBoxCount : 100;
    
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
                      helperText: defaultFramesPerBox > 0 && honeySuperCount > 0
                          ? '${state.currentFrameCount ?? 0}/${defaultFramesPerBox * honeySuperCount}'
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
                          if (currentValue < maxNormalFrames) {
                            context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(currentValue + 1));
                          }
                        },
                        onLongPressIncrease: () {
                          final currentValue = state.currentFrameCount ?? 0;
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
                          final currentValue = state.currentFrameCount ?? 0;
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
                          if (currentValue < maxBroodFrames) {
                            context.read<EditHiveBloc>().add(EditHiveBroodFrameCountChanged(currentValue + 1));
                          }
                        },
                        onLongPressIncrease: () {
                          final currentValue = state.currentBroodFrameCount ?? 0;
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
                          final currentValue = state.currentBroodFrameCount ?? 0;
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
                          final currentBoxValue = state.currentHoneySuperBoxCount ?? 0;
                          if (currentBoxValue > 0) {
                            // Adjust frame count when decreasing honey supers
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
                          final currentBoxValue = state.currentHoneySuperBoxCount ?? 0;
                          // Adjust frame count when increasing honey supers
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
                          final currentValue = state.currentHoneySuperBoxCount ?? 0;
                          _startContinuousUpdate(
                            field: 'honeySuperBoxCount',
                            increment: true,
                            currentValue: currentValue,
                            min: 0,
                            max: 10, // Reasonable max for honey supers
                            onUpdate: (value) {
                              // Adjust frame count when changing honey supers with long press
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
                          final currentValue = state.currentHoneySuperBoxCount ?? 0;
                          _startContinuousUpdate(
                            field: 'honeySuperBoxCount',
                            increment: false,
                            currentValue: currentValue,
                            min: 0,
                            max: 10,
                            onUpdate: (value) {
                              // Adjust frame count when changing honey supers with long press
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
                          : state.hiveType?.broodBoxCount != null 
                             ? 'Typical: ${state.hiveType!.broodBoxCount}' 
                             : 'Number of boxes',
                      suffixIcon: _buildCounterButtons(
                        onDecrease: () {
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          if (currentValue > 0) {
                            // Adjust brood frame count when decreasing brood boxes
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
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          // Adjust brood frame count when increasing brood boxes
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
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          _startContinuousUpdate(
                            field: 'broodBoxCount',
                            increment: true,
                            currentValue: currentValue,
                            min: 0,
                            max: 10, // Reasonable max for brood boxes
                            onUpdate: (value) {
                              // Adjust brood frame count when changing brood boxes with long press
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
                          final currentValue = state.currentBroodBoxCount ?? 0;
                          _startContinuousUpdate(
                            field: 'broodBoxCount',
                            increment: false,
                            currentValue: currentValue,
                            min: 0,
                            max: 10,
                            onUpdate: (value) {
                              // Adjust brood frame count when changing brood boxes with long press
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
          ],
        ),
      ],
    );
  }

  // Helper method to adjust normal frame count when honey box count changes
  void _adjustFrameCountForHoneyBoxChange({
    required BuildContext context,
    required EditHiveState state,
    required int newBoxCount,
  }) {
    final defaultFramesPerBox = state.hiveType?.defaultFrameCount ?? 0;
    if (defaultFramesPerBox == 0) return;
    
    final oldBoxCount = state.currentHoneySuperBoxCount ?? 0;
    final oldFrameCount = state.currentFrameCount ?? 0;
    
    // Calculate the new maximum capacity
    final newMaxFrames = newBoxCount * defaultFramesPerBox;
    
    // Calculate the new frame count based on box count change
    int newFrameCount;
    
    if (newBoxCount > oldBoxCount) {
      // Increasing box count: Add frames for the new box, but don't exceed the new maximum
      newFrameCount = math.min(oldFrameCount + defaultFramesPerBox, newMaxFrames);
    } else if (newBoxCount < oldBoxCount) {
      // Decreasing box count: Clamp to the new maximum
      newFrameCount = math.min(oldFrameCount, newMaxFrames);
      
      // If there are more frames than the new maximum, reduce to the new maximum
      if (oldFrameCount > newMaxFrames) {
        newFrameCount = newMaxFrames;
      } else if (newBoxCount == 0) {
        // If we're removing all boxes, set frames to 0
        newFrameCount = 0;
      }
    } else {
      // No change in box count
      return;
    }
    
    // Update the frame count in the bloc
    context.read<EditHiveBloc>().add(EditHiveFrameCountChanged(newFrameCount));
  }
  
  // Helper method to adjust brood frame count when brood box count changes
  void _adjustBroodFrameCountForBroodBoxChange({
    required BuildContext context,
    required EditHiveState state,
    required int newBoxCount,
  }) {
    final defaultFramesPerBox = state.hiveType?.defaultFrameCount ?? 0;
    if (defaultFramesPerBox == 0) return;
    
    final oldBoxCount = state.currentBroodBoxCount ?? 0;
    final oldBroodFrameCount = state.currentBroodFrameCount ?? 0;
    
    // Calculate the new maximum capacity
    final newMaxFrames = newBoxCount * defaultFramesPerBox;
    
    // Calculate the new brood frame count based on box count change
    int newBroodFrameCount;
    
    if (newBoxCount > oldBoxCount) {
      // Increasing box count: Add frames for the new box, but don't exceed the new maximum
      newBroodFrameCount = math.min(oldBroodFrameCount + defaultFramesPerBox, newMaxFrames);
    } else if (newBoxCount < oldBoxCount) {
      // Decreasing box count: Clamp to the new maximum
      newBroodFrameCount = math.min(oldBroodFrameCount, newMaxFrames);
      
      // If there are more frames than the new maximum, reduce to the new maximum
      if (oldBroodFrameCount > newMaxFrames) {
        newBroodFrameCount = newMaxFrames;
      } else if (newBoxCount == 0) {
        // If we're removing all boxes, set frames to 0
        newBroodFrameCount = 0;
      }
    } else {
      // No change in box count
      return;
    }
    
    // Update the brood frame count in the bloc
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.remove, color: Colors.grey),
          ),
        ),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.shade300,
        ),
        GestureDetector(
          onTap: onIncrease,
          onLongPress: onLongPressIncrease,
          onLongPressEnd: (_) => _stopContinuousUpdate(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.add, color: Colors.grey),
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
            _infoRow('Typical brood boxes:', state.hiveType!.broodBoxCount.toString()),
          if (state.hiveType?.honeySuperBoxCount != null)
            _infoRow('Typical honey supers:', state.hiveType!.honeySuperBoxCount.toString()),
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