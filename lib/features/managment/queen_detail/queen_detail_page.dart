import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';

class QueenDetailPage extends StatelessWidget {
  final Queen queen;
  
  const QueenDetailPage({
    super.key,
    required this.queen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(queen.name),
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
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/edit-queen',
                arguments: queen.id,
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildBreedingCard(),
              const SizedBox(height: 16),
              _buildStatusCard(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildQueenMarking(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    queen.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (queen.breedName.isNotEmpty)
                    Text(
                      queen.breedName,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }  Widget _buildQueenMarking() {
    final isMarked = queen.marked;
    final hasMarkColor = queen.markColor != null;

    Color circleColor;
    Widget icon;

    if (isMarked && hasMarkColor) {
      circleColor = queen.markColor!;
      icon = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (!isMarked && hasMarkColor) {
      circleColor = queen.markColor!.withOpacity(0.5);
      icon = const Icon(Icons.help_outline, color: Colors.white, size: 18);
    } else if (isMarked && !hasMarkColor) {
      circleColor = Colors.amber;
      icon = const Icon(Icons.check, color: Colors.white, size: 18);
    } else {
      circleColor = Colors.grey.shade300;
      icon = Icon(Icons.help_outline, color: Colors.grey.shade600, size: 18);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData iconData;

    switch (queen.status) {
      case QueenStatus.active:
        badgeColor = Colors.green;
        statusText = 'enums.QueenStatus.active'.tr();
        iconData = Icons.check_circle;
        break;
      case QueenStatus.dead:
        badgeColor = Colors.red;
        statusText = 'enums.QueenStatus.dead'.tr();
        iconData = Icons.cancel;
        break;
      case QueenStatus.replaced:
        badgeColor = Colors.orange;
        statusText = 'enums.QueenStatus.replaced'.tr();
        iconData = Icons.swap_horiz;
        break;
      case QueenStatus.lost:
        badgeColor = Colors.grey;
        statusText = 'enums.QueenStatus.lost'.tr();
        iconData = Icons.help;
        break;
      default:
        badgeColor = Colors.blue;
        statusText = queen.status.name;
        iconData = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final currentYear = DateTime.now().year;
    final queenAge = currentYear - queen.birthDate.year;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'details.queen.basicInfo'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('details.queen.birthDate'.tr(), dateFormat.format(queen.birthDate)),
            _buildInfoRow(
              'details.queen.age'.tr(),
              tr('details.queen.yearsOld', args: [queenAge.toString()], namedArgs: {})
            ),
            _buildInfoRow('details.queen.marked'.tr(), queen.marked ? 'common.yes'.tr() : 'common.no'.tr()),
            if (queen.marked && queen.markColor != null)
              _buildInfoRowWithColor('details.queen.markColor'.tr(), _getColorName(queen.markColor!), queen.markColor!),
            _buildInfoRow('details.queen.source'.tr(), _getSourceText()),
            if (queen.origin != null && queen.origin!.isNotEmpty)
              _buildInfoRow('details.queen.origin'.tr(), queen.origin!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Location Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Apiary', queen.apiaryName ?? 'Unassigned'),
            _buildInfoRow('Hive', queen.hiveName ?? 'No Hive'),
            if (queen.apiaryLocation != null && queen.apiaryLocation!.isNotEmpty)
              _buildInfoRow('Location', queen.apiaryLocation!),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Breeding Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],            ),
            const SizedBox(height: 16),
            _buildInfoRow('Breed', queen.breedName),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Status & Dates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Current Status', _formatEnumName(queen.status.name)),
            _buildInfoRow('Created', DateFormat('MMMM d, yyyy').format(queen.createdAt)),
            _buildInfoRow('Last Updated', DateFormat('MMMM d, yyyy').format(queen.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithColor(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  String _getSourceText() {
    if (queen.origin != null && queen.origin!.isNotEmpty) {
      return queen.origin!;
    }
    return _formatEnumName(queen.source.name);
  }

  String _formatEnumName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  String _getColorName(Color color) {
    if (color.toARGB32() == Colors.red.toARGB32()) return 'details.queen.red'.tr();
    if (color.toARGB32() == Colors.blue.toARGB32()) return 'details.queen.blue'.tr();
    if (color.toARGB32() == Colors.green.toARGB32()) return 'details.queen.green'.tr();
    if (color.toARGB32() == Colors.yellow.toARGB32()) return 'details.queen.yellow'.tr();
    if (color.toARGB32() == Colors.white.toARGB32()) return 'details.queen.white'.tr();
    if (color.toARGB32() == Colors.orange.toARGB32()) return 'details.queen.orange'.tr();
    if (color.toARGB32() == Colors.purple.toARGB32()) return 'details.queen.purple'.tr();
    if (color.toARGB32() == Colors.pink.toARGB32()) return 'details.queen.pink'.tr();
    return '';
  }
}