import 'package:flutter/material.dart';

class SkillSlider extends StatelessWidget {
  final double screenWidth;
  final String skill;
  final Map<String, int> level;
  final Function onChanged;
  final bool showSlider;

  const SkillSlider({
    super.key,
    required this.screenWidth,
    required this.skill,
    required this.level,
    required this.onChanged,
    required this.showSlider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.grey[900]!,
              Colors.teal.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skill Name and Level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    'Level: ${level[skill]}',
                    // key: ValueKey(
                    //     'Level-${level[skill]}'), // Ensure a unique key
                    style: TextStyle(
                      color: Colors.teal[300],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (showSlider)
              // Slider
              SliderTheme(
                data: SliderThemeData(
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20),
                  thumbColor: Colors.tealAccent,
                  overlayColor: Colors.tealAccent.withOpacity(0.3),
                  activeTrackColor: Colors.teal[300],
                  inactiveTrackColor: Colors.grey[800],
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                  trackHeight: 8,
                ),
                child: Slider(
                  value: level[skill]?.toDouble() ?? 0,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: level[skill]?.toString(),
                  onChanged: (value) {
                    onChanged(skill, value.toInt());
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
