import 'package:flutter/material.dart';

enum VcInputState {
  previous,  // Above the current input
  current,   // Currently active input
  next,      // Below the current input
}

// Base class for all VC input widgets
abstract class VcInputBase extends StatelessWidget {
  final String label;
  final IconData icon;
  final VcInputState state;
  
  const VcInputBase({
    Key? key,
    required this.label,
    required this.icon,
    required this.state,
  }) : super(key: key);
  
  // Helper method to get appropriate sizes based on state
  double get fontSize {
    switch (state) {
      case VcInputState.current:
        return 16.0;
      case VcInputState.previous:
      case VcInputState.next:
        return 14.0;
    }
  }
  
  double get iconSize {
    switch (state) {
      case VcInputState.current:
        return 18.0;
      case VcInputState.previous:
      case VcInputState.next:
        return 14.0;
    }
  }
  
  double get padding {
    switch (state) {
      case VcInputState.current:
        return 12.0;
      case VcInputState.previous:
      case VcInputState.next:
        return 8.0;
    }
  }
  
  // Every VcInputBase subclass must implement a buildContent method
  Widget buildContent(BuildContext context);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(padding),
      child: buildContent(context),
    );
  }
}
