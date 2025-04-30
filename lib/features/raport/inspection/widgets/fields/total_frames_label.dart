import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/frame_count_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TotalFramesLabel extends StatelessWidget {
  const TotalFramesLabel({super.key});

  @override
  Widget build(BuildContext context) {
    // Get base values from state
    final maxFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.maxFrames);
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final framesPerBox = context.select<InspectionBloc, int>((bloc) => bloc.state.framesPerSuperBox);
    
    // Get changes in box counts and frame counts
    final boxNetChange = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.honeySuperBoxNet')) ?? 0;
    
    // Get field states to determine colors
    final boxChangeState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.honeySuperBoxNet'));
    
    // Get the states for frame changes
    final emptyNetState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.emptyNet'));
    final honeyNetState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.honeyNet'));
    
    // Calculate frame net changes, prioritizing new values over old ones
    int calculateFramesNetChange() {
      int netChange = 0;
      
      // Only include set/active fields in the calculation, ignore old values if new ones are set
      if (emptyNetState == FieldState.set) {
        netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.emptyNet', defaultValue: 0) ?? 0;
      }
      
      if (honeyNetState == FieldState.set) {
        netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.honeyNet', defaultValue: 0) ?? 0;
      }
      
      // Only fall back to old/saved values if no new values are set
      if (emptyNetState != FieldState.set && honeyNetState != FieldState.set) {
        if (emptyNetState == FieldState.old || emptyNetState == FieldState.saved) {
          netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.emptyNet', defaultValue: 0) ?? 0;
        }
        
        if (honeyNetState == FieldState.old || honeyNetState == FieldState.saved) {
          netChange += context.read<InspectionBloc>().state.getFieldValue<int>('framesMoved.honeyNet', defaultValue: 0) ?? 0;
        }
      }
      
      return netChange;
    }
    
    // Determine composite state for net change display
    FieldState getCompositeState() {
      if (emptyNetState == FieldState.set || honeyNetState == FieldState.set) {
        return FieldState.set;
      } else if (emptyNetState == FieldState.saved || honeyNetState == FieldState.saved) {
        return FieldState.saved;
      } else if (emptyNetState == FieldState.old || honeyNetState == FieldState.old) {
        return FieldState.old;
      }
      return FieldState.unset;
    }
    
    // Calculate the net change
    final framesNetChange = calculateFramesNetChange();
    
    // Calculate dynamic max frames based on box changes
    final dynamicMaxFrames = maxFrames + (boxNetChange * framesPerBox);
    
    // Calculate current total frames with net change
    final currentTotalFrames = totalFrames + framesNetChange;
    
    // Determine box change color
    Color boxChangeColor = Colors.grey.shade600;
    if (boxNetChange > 0) {
      boxChangeColor = Colors.green.shade600;
    } else if (boxNetChange < 0) {
      boxChangeColor = Colors.orange.shade700;
    }
    
    return FrameCountLabel(
      icon: Icons.table_rows,
      label: 'Super Frames',
      currentCount: currentTotalFrames,
      maxCount: dynamicMaxFrames,
      netChange: framesNetChange,
      netChangeState: getCompositeState(),
      boxCount: boxNetChange,
      boxChangeState: boxChangeState,
      boxChangeColor: boxChangeColor,
      framesPerBox: framesPerBox,
    );
  }
}
