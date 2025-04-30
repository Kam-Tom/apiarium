import 'package:flutter/material.dart';

class TreatmentPage extends StatelessWidget {
  const TreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.medication, size: 48.0),
          const SizedBox(height: 12.0),
          const Text(
            'Treatment Records',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Track treatments applied to your hives',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.healing),
                  ),
                  title: Text('Treatment ${index + 1}'),
                  subtitle: Text('Applied on ${DateTime.now().subtract(Duration(days: index * 15)).toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to treatment details
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
