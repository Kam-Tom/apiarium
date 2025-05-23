import 'package:flutter/material.dart';

class VcScaleInput extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final int maxValue;
  final List<String> valueLabels;
  final String commandPrefix;

  const VcScaleInput({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.maxValue = 5,
    required this.valueLabels,
    required this.commandPrefix,
  }) : assert(valueLabels.length == maxValue, 'Must provide labels for all values'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a color gradient for the scale
    final List<Color> scaleColors = [
      Colors.red.shade400,
      Colors.orange.shade300,
      Colors.amber,
      Colors.lightGreen.shade400,
      Colors.green.shade500,
    ];
    
    // Select the current value color
    final Color valueColor = value <= scaleColors.length 
        ? scaleColors[value - 1] 
        : scaleColors.last;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      valueLabels[value - 1],
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Scale visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: List.generate(maxValue, (index) {
                final isSelected = index + 1 == value;
                final normalizedIndex = index < scaleColors.length ? index : scaleColors.length - 1;
                final dotColor = scaleColors[normalizedIndex];
                
                return Expanded(
                  child: Column(
                    children: [
                      // Scale dot
                      Container(
                        width: isSelected ? 20 : 16,
                        height: isSelected ? 20 : 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? dotColor.withOpacity(0.3) 
                              : Colors.grey.shade800.withOpacity(0.5),
                          border: Border.all(
                            color: isSelected ? dotColor : Colors.grey.shade700,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                        ) : null,
                      ),
                      
                      // Scale line
                      if (index < maxValue - 1)
                        Container(
                          height: 2,
                          color: index < value - 1 
                              ? dotColor.withOpacity(0.5)
                              : Colors.grey.shade800,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Command hints
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13),
                  children: [
                    TextSpan(
                      text: commandPrefix,
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: " 1-$maxValue",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(maxValue, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: index + 1 == value 
                        ? scaleColors[index < scaleColors.length ? index : scaleColors.length - 1].withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: index + 1 == value
                          ? scaleColors[index < scaleColors.length ? index : scaleColors.length - 1]
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    valueLabels[index],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: index + 1 == value ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
