import 'package:flutter/material.dart';

class FeedingPage extends StatelessWidget {
  const FeedingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.local_dining, size: 48.0),
          const SizedBox(height: 12.0),
          const Text(
            'Feeding Records',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Track feeding supplements for your hives',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.fastfood),
                  ),
                  title: Text('Feeding ${index + 1}'),
                  subtitle: Text('Added on ${DateTime.now().subtract(Duration(days: index * 10)).toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to feeding details
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
