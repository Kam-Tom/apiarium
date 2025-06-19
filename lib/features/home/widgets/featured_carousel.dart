import 'package:flutter/material.dart';
import 'package:apiarium/shared/widgets/custom_card.dart';

const List<Map<String, dynamic>> featuredItems = [
  {
    'title': 'Spring Honey Sale',
    'description': '15% off all honey products',
    'icon': Icons.local_offer,
    'color': Colors.amber,
    'badge': 'Limited Time',
  },
  {
    'title': 'New Discussion',
    'description': 'Join the beekeepers forum',
    'icon': Icons.forum,
    'color': Colors.blue,
    'badge': '3 new posts',
  },
  {
    'title': 'New Equipment',
    'description': 'Check out latest beekeeping tools',
    'icon': Icons.shopping_bag,
    'color': Colors.green,
    'badge': 'New arrival',
  },
];

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  int currentIndex = 0;
  final PageController _controller = PageController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;
    
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          onPageChanged: (index) => setState(() => currentIndex = index),
          itemCount: featuredItems.length,
          itemBuilder: (context, index) => _buildFeaturedCard(featuredItems[index], index, isSmall),
        ),
        if (currentIndex > 0 && !isSmall) _buildSideIndicator(true),
        if (currentIndex < featuredItems.length - 1 && !isSmall) _buildSideIndicator(false),
      ],
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> item, int index, bool isSmall) {
    final theme = Theme.of(context);
    final color = item['color'] as Color;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomCard(
        onTap: () {},
        padding: EdgeInsets.all(isSmall ? 8 : 12),
        child: Row(
          children: [
            _buildIcon(item['icon'], color, isSmall),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['title'],
                    style: (isSmall ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['description'],
                    style: (isSmall ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['badge'],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isSmall) ...[
              Text(
                '${index + 1}/${featuredItems.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color, bool isSmall) {
    final size = isSmall ? 40.0 : 50.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  Widget _buildSideIndicator(bool isLeft) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 16,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
              topRight: isLeft ? const Radius.circular(20) : Radius.zero,
              bottomRight: isLeft ? const Radius.circular(20) : Radius.zero,
              topLeft: isLeft ? Radius.zero : const Radius.circular(20),
              bottomLeft: isLeft ? Radius.zero : const Radius.circular(20),
            ),
          ),
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            color: Colors.grey,
            size: 16,
          ),
        ),
      ),
    );
  }
}