import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_view.dart';
import 'package:apiarium/features/managment/apiaries/bloc/apiaries_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApiariesPage extends StatelessWidget {
  const ApiariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiariesBloc(
        apiaryRepository: context.read<ApiaryRepository>(),
      )..add(const LoadApiaries()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Apiaries'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade800, Colors.amber.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter options
                  _showFilterDialog(context);
                },
                tooltip: 'Filter',
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortDialog(context),
                tooltip: 'Sort',
              ),
            ],
          ),
          body: const ApiariesView(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.push(AppRouter.editApiary);
              if(context.mounted) {
                context.read<ApiariesBloc>().add(const LoadApiaries());
              }
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final apiariesBloc = context.read<ApiariesBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: apiariesBloc,
        child: AlertDialog(
          title: const Text('Filter Apiaries'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location filter
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Filter by location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (value) {
                  apiariesBloc.add(FilterByLocation(
                    value.isNotEmpty ? value : null,
                  ));
                },
              ),
              const SizedBox(height: 16),
              // Migratory filter
              Row(
                children: [
                  const Text('Migratory:'),
                  const SizedBox(width: 16),
                  DropdownButton<bool?>(
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Yes'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('No'),
                      ),
                    ],
                    onChanged: (value) {
                      apiariesBloc.add(FilterByMigratory(value));
                    },
                    value: null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status filter
              Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 16),
                  DropdownButton<ApiaryStatus?>(
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All'),
                      ),
                      ...ApiaryStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      apiariesBloc.add(FilterByApiaryStatus(value));
                    },
                    value: null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                apiariesBloc.add(const ResetFilters());
                Navigator.of(dialogContext).pop();
              },
              child: const Text('RESET'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final apiariesBloc = context.read<ApiariesBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: apiariesBloc,
        child: AlertDialog(
          title: const Text('Sort Apiaries'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in ApiarySortOption.values)
                RadioListTile<ApiarySortOption>(
                  title: Text(_getSortOptionTitle(option)),
                  value: option,
                  groupValue: apiariesBloc.state.sortOption,
                  onChanged: (value) {
                    if (value != null) {
                      apiariesBloc.add(SortApiaries(
                        sortOption: value,
                        ascending: apiariesBloc.state.ascending,
                      ));
                    }
                  },
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Ascending'),
                    onPressed: () {
                      apiariesBloc.add(SortApiaries(
                        sortOption: apiariesBloc.state.sortOption,
                        ascending: true,
                      ));
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Descending'),
                    onPressed: () {
                      apiariesBloc.add(SortApiaries(
                        sortOption: apiariesBloc.state.sortOption,
                        ascending: false,
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortOptionTitle(ApiarySortOption option) {
    switch (option) {
      case ApiarySortOption.name:
        return 'Name';
      case ApiarySortOption.location:
        return 'Location';
      case ApiarySortOption.hiveCount:
        return 'Hive Count';
      case ApiarySortOption.createdAt:
        return 'Creation Date';
      case ApiarySortOption.status:
        return 'Status';
    }
  }
  
  void _showAddApiaryDialog(BuildContext context) {
    final apiariesBloc = context.read<ApiariesBloc>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Apiary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Apiary Name',
                hintText: 'Enter apiary name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter location',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Migratory Apiary'),
              value: false,
              onChanged: (value) {
                // Update value in a real implementation
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add new apiary logic here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New apiary added')),
              );
              // Refresh the list
              apiariesBloc.add(const LoadApiaries());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
