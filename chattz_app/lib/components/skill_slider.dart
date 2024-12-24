import 'package:flutter/material.dart';

class SkillSlider extends StatefulWidget {
  final double screenWidth;
  final String skill;
  final Map<String, int> level;
  final Function onChanged;
  final bool showSlider;

  const SkillSlider({
    Key? key,
    required this.screenWidth,
    required this.skill,
    required this.level,
    required this.onChanged,
    required this.showSlider,
  }) : super(key: key);

  @override
  _SkillSliderState createState() => _SkillSliderState();
}

class _SkillSliderState extends State<SkillSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.screenWidth * 0.03),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.skill,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(
                        begin: 0, end: widget.level[widget.skill] ?? 0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Text(
                        'Level: $value',
                        style: TextStyle(
                          color: Colors.teal[300],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (widget.showSlider) const SizedBox(height: 12),
              if (widget.showSlider)
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
                    value: widget.level[widget.skill]?.toDouble() ?? 0,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: widget.level[widget.skill]?.toString(),
                    onChanged: (value) {
                      widget.onChanged(widget.skill, value.toInt());
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
