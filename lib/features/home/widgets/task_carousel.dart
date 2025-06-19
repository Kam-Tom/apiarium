import 'package:flutter/material.dart';
import 'package:apiarium/shared/widgets/custom_card.dart';

class TaskCarousel extends StatefulWidget {
  const TaskCarousel({super.key});

  @override
  State<TaskCarousel> createState() => _TaskCarouselState();
}

class _TaskCarouselState extends State<TaskCarousel> {
  static const int totalTasks = 3;
  int currentTaskIndex = 0;
  final PageController _taskController = PageController();
  
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;
    
    return Stack(
      children: [
        PageView.builder(
          controller: _taskController,
          onPageChanged: (index) => setState(() => currentTaskIndex = index),
          itemCount: totalTasks,
          itemBuilder: (context, index) => _buildTaskCard(index, isSmall),
        ),
        if (currentTaskIndex > 0) _buildScrollIndicator(true, isSmall),
        if (currentTaskIndex < totalTasks - 1) _buildScrollIndicator(false, isSmall),
      ],
    );
  }
  
  Widget _buildTaskCard(int index, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomCard(
        color: Colors.white.withOpacity(0.95),
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(index, isSmall),
            SizedBox(height: isSmall ? 8 : 12),
            _buildInfoRow(isSmall),
            SizedBox(height: isSmall ? 8 : 12),
            Expanded(child: _buildTaskDescription(isSmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(int index, bool isSmall) {
    return Row(
      children: [
        _buildTaskIcon(isSmall),
        SizedBox(width: isSmall ? 8 : 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Check Hive #${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 18 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildBadge('${index + 1}/$totalTasks', Colors.amber),
            ],
          ),
        ),
        _buildNotificationBadge(isSmall),
      ],
    );
  }

  Widget _buildTaskIcon(bool isSmall) {
    final size = isSmall ? 28.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.task_alt, color: Colors.amber, size: size * 0.6),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(bool isSmall) {
    final size = isSmall ? 32.0 : 40.0;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
      child: Icon(Icons.notifications_active, color: Colors.white, size: size * 0.55),
    );
  }

  Widget _buildInfoRow(bool isSmall) {
    return Row(
      children: [
        _buildInfoBadge(Icons.wb_sunny, '23°C', Colors.blue, isSmall),
        const SizedBox(width: 12),
        _buildInfoBadge(Icons.access_time, isSmall ? '2:30 PM' : 'Due today • 2:30 PM', Colors.grey, isSmall),
      ],
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmall ? 14 : 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDescription(bool isSmall) {
    return Text(
      'Check the health of the hive, ensure proper ventilation and inspect for signs of disease.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: isSmall ? 14 : 14,
        height: isSmall ? 1.1 : 1.1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildScrollIndicator(bool isLeft, bool isSmall) {
    final indicatorSize = isSmall ? 25.0 : 30.0;
    final indicatorHeight = isSmall ? 40.0 : 50.0;
    
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: indicatorSize,
          height: indicatorHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isLeft ? Colors.black.withOpacity(0.15) : Colors.transparent,
                isLeft ? Colors.transparent : Colors.black.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? const Radius.circular(16) : Radius.zero,
              bottomLeft: isLeft ? const Radius.circular(16) : Radius.zero,
              topRight: isLeft ? Radius.zero : const Radius.circular(16),
              bottomRight: isLeft ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            color: Colors.white.withOpacity(0.8),
            size: indicatorSize,
          ),
        ),
      ),
    );
  }
}