import 'package:flutter/material.dart';

class TaskCarousel extends StatefulWidget {
  const TaskCarousel({super.key});

  @override
  State<TaskCarousel> createState() => _TaskCarouselState();
}

class _TaskCarouselState extends State<TaskCarousel> {
  final int totalTasks = 3;
  int currentTaskIndex = 0;
  final PageController _taskController = PageController();
  
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main PageView
        PageView.builder(
          controller: _taskController,
          onPageChanged: (index) {
            setState(() {
              currentTaskIndex = index;
            });
          },
          itemCount: totalTasks,
          itemBuilder: (context, index) => _buildTaskCard(index),
        ),
        
        // Left and right gradient indicators for scrolling
        if (currentTaskIndex > 0)
          _buildScrollIndicator(true),
          
        if (currentTaskIndex < totalTasks - 1)
          _buildScrollIndicator(false),
      ],
    );
  }
  
  Widget _buildTaskCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            _buildTaskHeader(index),
            const SizedBox(height: 12),
            
            // Middle section with weather and time
            _buildInfoRow(),
            const SizedBox(height: 12),
            
            // Bottom description with ellipsis
            _buildTaskDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(int index) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.task_alt,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                'Check Hive #${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Small text showing current/total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${index + 1}/$totalTasks',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Notification icon moved to the right
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        // Weather info
        _buildInfoBadge(
          icon: Icons.wb_sunny, 
          text: '23°C', 
          color: Colors.blue.withValues(alpha: 0.1),
          iconColor: Colors.amber,
        ),
        const SizedBox(width: 12),
        // Time info
        _buildInfoBadge(
          icon: Icons.access_time, 
          text: 'Due today • 2:30 PM',
          color: Colors.grey.withValues(alpha: 0.1),
          iconColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildInfoBadge({
    required IconData icon, 
    required String text,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDescription() {
    return const Expanded(
      child: Text(
        'Check the health of the hive, ensure proper ventilation and inspect for signs of disease. This is part of the regular maintenance schedule for optimal honey production.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildScrollIndicator(bool isLeft) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isLeft ? Colors.black.withValues(alpha: 0.15) : Colors.transparent,
                isLeft ? Colors.transparent : Colors.black.withValues(alpha: 0.15),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
            color: Colors.white.withValues(alpha: 0.8),
            size: 30,
          ),
        ),
      ),
    );
  }
}
