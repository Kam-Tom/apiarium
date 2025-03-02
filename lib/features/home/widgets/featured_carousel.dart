import 'package:flutter/material.dart';

class FeaturedItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String badgeText;

  const FeaturedItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.badgeText,
  });
}

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  int currentFeaturedIndex = 0;
  final PageController _featuredController = PageController();
  
  final List<FeaturedItem> _featuredItems = const [
    FeaturedItem(
      title: 'Spring Honey Sale',
      description: '15% off all honey products',
      icon: Icons.local_offer,
      iconColor: Colors.amber,
      badgeText: 'Limited Time',
    ),
    FeaturedItem(
      title: 'New Discussion',
      description: 'Join the beekeepers forum',
      icon: Icons.forum,
      iconColor: Colors.blue,
      badgeText: '3 new posts',
    ),
    FeaturedItem(
      title: 'New Equipment',
      description: 'Check out latest beekeeping tools',
      icon: Icons.shopping_bag,
      iconColor: Colors.green,
      badgeText: 'New arrival',
    ),
  ];

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main PageView for featured cards
        PageView.builder(
          controller: _featuredController,
          onPageChanged: (index) {
            setState(() {
              currentFeaturedIndex = index;
            });
          },
          itemCount: _featuredItems.length,
          itemBuilder: (context, index) => _buildFeaturedCard(_featuredItems[index], index),
        ),
        
        // Side indicators (only show when there are more items to scroll)
        if (currentFeaturedIndex > 0)
          _buildSideIndicator(true),
        
        if (currentFeaturedIndex < _featuredItems.length - 1)
          _buildSideIndicator(false),
      ],
    );
  }

  Widget _buildFeaturedCard(FeaturedItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Handle featured item tap
          },
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Icon
                    _buildIconContainer(item),
                    const SizedBox(width: 14),
                    
                    // Content
                    _buildContentSection(item),
                    
                    // Navigation indicator
                    _buildNavIndicator(index),
                  ],
                ),
              ),
              
              // Small drag handle indicator at the bottom
              _buildDragHandle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(FeaturedItem item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: item.iconColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.icon,
        color: item.iconColor,
        size: 26,
      ),
    );
  }

  Widget _buildContentSection(FeaturedItem item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.badgeText,
              style: TextStyle(
                color: item.iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIndicator(int index) {
    return Row(
      children: [
        Text(
          '${index + 1}/${_featuredItems.length}',
          style: TextStyle(
            fontSize: 12,
            color: _featuredItems[index].iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.chevron_right,
          color: _featuredItems[index].iconColor,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
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
