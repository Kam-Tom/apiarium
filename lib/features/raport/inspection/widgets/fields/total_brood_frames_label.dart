import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/frame_count_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TotalBroodFramesLabel extends StatelessWidget {
  const TotalBroodFramesLabel({super.key});

  @override
  Widget build(BuildContext context) {
    // Get base values from state
    final maxBroodFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.maxBroodFrames);
    final totalBroodFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalBroodFrames);
    final framesPerBroodBox = context.select<InspectionBloc, int>((bloc) => bloc.state.framesPerBroodBox);
    
    // Get changes in box counts and frame counts
    final broodBoxNetChange = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.broodBoxNet')) ?? 0;
    
    // Get field states to determine colors
    final boxChangeState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.broodBoxNet'));
    
    // Get the states for frame changes
    final emptyBroodNetState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.emptyBroodNet'));
    final broodNetState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.broodNet'));
    
    // Calculate frame net changes, prioritizing new values over old ones
    int calculateBroodFramesNetChange() {
      int netChange = 0;
      
      // Only include set/active fields in the calculation, ignore old values if new ones are set
      if (emptyBroodNetState == FieldState.set) {
        netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.emptyBroodNet', defaultValue: 0) ?? 0;
      }
      
      if (broodNetState == FieldState.set) {
        netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.broodNet', defaultValue: 0) ?? 0;
      }
      
      // Only fall back to old/saved values if no new values are set
      if (emptyBroodNetState != FieldState.set && broodNetState != FieldState.set) {
        if (emptyBroodNetState == FieldState.old || emptyBroodNetState == FieldState.saved) {
          netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.emptyBroodNet', defaultValue: 0) ?? 0;
        }
        
        if (broodNetState == FieldState.old || broodNetState == FieldState.saved) {
          netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.broodNet', defaultValue: 0) ?? 0;
        }
      }
      
      return netChange;
    }
    
    // Determine composite state for net change display
    FieldState getCompositeState() {
      if (emptyBroodNetState == FieldState.set || broodNetState == FieldState.set) {
        return FieldState.set;
      } else if (emptyBroodNetState == FieldState.saved || broodNetState == FieldState.saved) {
        return FieldState.saved;
      } else if (emptyBroodNetState == FieldState.old || broodNetState == FieldState.old) {
        return FieldState.old;
      }
      return FieldState.unset;
    }

    // Calculate the net change
    final broodFramesNetChange = calculateBroodFramesNetChange();
    
    // Calculate dynamic max frames based on box changes
    final dynamicMaxBroodFrames = maxBroodFrames + (broodBoxNetChange * framesPerBroodBox);
    
    // Calculate current total brood frames with net change
    final currentTotalBroodFrames = totalBroodFrames + broodFramesNetChange;
    
    // Determine box change color
    Color boxChangeColor = Colors.grey.shade600;
    if (broodBoxNetChange > 0) {
      boxChangeColor = Colors.green.shade600;
    } else if (broodBoxNetChange < 0) {
      boxChangeColor = Colors.orange.shade700;
    }

    return FrameCountLabel(
      icon: Icons.layers,
      label: 'Brood Frames',
      currentCount: currentTotalBroodFrames,
      maxCount: dynamicMaxBroodFrames,
      netChange: broodFramesNetChange,
      netChangeState: getCompositeState(),
      boxCount: broodBoxNetChange,
      boxChangeState: boxChangeState,
      boxChangeColor: boxChangeColor,
      framesPerBox: framesPerBroodBox,
    );
  }
}
