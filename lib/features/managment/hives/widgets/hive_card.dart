import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';

class HiveCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final DateTime? lastInspectionDate;
  
  const HiveCard({
    super.key,
    required this.hive,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
    this.lastInspectionDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator at top of card
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            // Hive header section (name, status)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hive image or color
                  _buildHiveImage(),
                  const SizedBox(width: 12),
                  
                  // Hive info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hive.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildHiveStatusChip(),
                          ],
                        ),
                        
                        // Hive type in styled container
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatHiveType(hive.hiveType),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            
            // Location section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: hive.apiary != null ? Colors.teal : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hive.apiary?.name ?? 'No Apiary',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hive.apiary != null ? Colors.teal : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hive.queen != null)
                    _buildQueenStatusChip(),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            
            // Frame counts section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Frames
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFrameCounter(
                            title: 'Frames',
                            current: hive.currentFrameCount,
                            total: _calculateMaxFrames(),
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Brood frames
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade600.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.hexagon,
                            size: 14,
                            color: Colors.brown.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFrameCounter(
                            title: 'Brood Frames',
                            current: hive.currentBroodFrameCount,
                            total: _calculateMaxBroodFrames(),
                            color: Colors.brown.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onEditTap,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      minimumSize: const Size(60, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onDeleteTap,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      minimumSize: const Size(60, 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveImage() {
    // If image exists, use it, otherwise use color
    if (hive.imageUrl != null) {
      return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(hive.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: hive.color ?? Colors.amber.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.home, size: 30, color: Colors.white),
        ),
      );
    }
  }
  
  Widget _buildFrameCounter({
    required String title,
    required int? current,
    required int? total,
    required Color color,
  }) {
    final currentValue = current ?? 0;
    final totalValue = total ?? 0;
    final percentage = totalValue > 0 ? (currentValue / totalValue).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$currentValue${totalValue > 0 ? '/$totalValue' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQueenStatusChip() {
    if (hive.queen == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Text(
          'No Queen',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Queen exists, display simplified information
    final queen = hive.queen!;
    String displayText = '';
    Color color = Colors.grey;
    
    // Determine status color
    color = switch(queen.status) {
      QueenStatus.active => Colors.green,
      QueenStatus.dead => Colors.red,
      QueenStatus.replaced => Colors.blue,
      QueenStatus.lost => Colors.orange,
      _ => Colors.grey
    };
    
    // Display breed if available, otherwise status
    if (queen.breed != null) {
      displayText = queen.breed.name;
      if (displayText.length > 15) {
        displayText = displayText.substring(0, 12) + '...';
      }
    } else {
      // Fallback to status if no breed
      displayText = switch(queen.status) {
        QueenStatus.active => 'Active Queen',
        QueenStatus.dead => 'Dead Queen',
        QueenStatus.replaced => 'Replaced Queen',
        QueenStatus.lost => 'Lost Queen',
        _ => 'Queen'
      };
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show bee icon with marking color if queen is marked
          if (queen.marked)
            Icon(
              Icons.bug_report, // Using bug_report as a bee substitute
              size: 14, 
              color: queen.markColor ?? Colors.amber,
            ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHiveStatusChip() {
    Color color = switch(hive.status) {
      HiveStatus.active => Colors.green,
      HiveStatus.inactive => Colors.grey,
      HiveStatus.archived => Colors.red,
      _ => Colors.purple
    };
    
    String statusText = hive.status.toString().split('.').last;
    // Capitalize first letter only
    statusText = statusText.substring(0, 1).toUpperCase() + 
                 statusText.substring(1).toLowerCase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hive.status == HiveStatus.active ? Icons.check_circle_outline : Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatHiveType(HiveType type) {
    // More descriptive hive type formatting
    String result = type.name;
    if (type.frameStandard != null) {
      result += ' (${type.frameStandard})';
    }
    return result;
  }
  
  int? _calculateMaxFrames() {
    if (hive.hiveType.defaultFrameCount == null) return null;
    
    // Only count honey super boxes for normal frames
    final honeyBoxes = hive.currentHoneySuperBoxCount ?? 0;
    
    if (honeyBoxes == 0) return null;
    
    return hive.hiveType.defaultFrameCount! * honeyBoxes;
  }
  
  int? _calculateMaxBroodFrames() {
    if (hive.hiveType.defaultFrameCount == null) return null;
    
    // Only count brood boxes for brood frames
    final broodBoxes = hive.currentBroodBoxCount ?? 0;
    
    if (broodBoxes == 0) return null;
    
    return hive.hiveType.defaultFrameCount! * broodBoxes;
  }
}
