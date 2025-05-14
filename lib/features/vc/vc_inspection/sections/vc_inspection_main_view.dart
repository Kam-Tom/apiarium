import 'package:apiarium/features/raport/inspection/inspection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VcInspectionMainView extends StatelessWidget {
  const VcInspectionMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectionBloc, InspectionState>(
      builder: (context, state) {
        final selectedApiary = state.selectedApiary;
        final selectedHive = state.selectedHive;
        
        if (selectedApiary == null) {
          return const Center(
            child: Text(
              'No apiary selected',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        
        return Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.home_work, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              selectedApiary.name,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (selectedApiary.location != null && 
                            selectedApiary.location!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                selectedApiary.location!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                if (selectedHive != null) ...[
                  Card(
                    color: Colors.amber.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.hive, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Hive: ${selectedHive.name}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const Expanded(
                  child: Center(
                    child: Text(
                      'Inspection data will appear here',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
