import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/frame_count_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TotalFramesField extends StatelessWidget {
  const TotalFramesField({super.key});

  @override
  Widget build(BuildContext context) {
    final maxFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.maxFrames);
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);

    return FrameCountLabel(
      icon: Icons.table_rows,
      label: 'Total Frames',
      currentCount: totalFrames,
      maxCount: maxFrames,
      netChange: 0,
      showNetChange: false,
    );
  }
}
