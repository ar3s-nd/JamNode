import 'package:flutter/material.dart';
import 'package:chattz_app/components/auto_complete_text_field.dart';
import 'package:chattz_app/components/details_textfield.dart';
import 'package:chattz_app/main.dart';

class DetailsCard extends StatefulWidget {
  const DetailsCard({
    Key? key,
    required this.update,
    required this.icon,
    required this.label,
    required this.value,
    this.isUpdatable = false,
    required this.isMe,
  }) : super(key: key);

  final Function update;
  final IconData icon;
  final String label;
  final String value;
  final bool isUpdatable;
  final bool isMe;

  @override
  State<DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DetailsCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController controller;
  bool isUpdating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.tealAccent.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade900,
                Colors.black,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.tealAccent),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      ),
                    );
                  },
                  child: isUpdating
                      ? widget.label == 'College Name'
                          ? AutoCompleteTextField(
                              key: ValueKey<bool>(isUpdating),
                              controller: controller,
                              label: widget.label,
                              suggestions: collegeNamesGlobal,
                            )
                          : DetailsTextField(
                              key: ValueKey<bool>(isUpdating),
                              controller: controller,
                              label: widget.label,
                            )
                      : Column(
                          key: ValueKey<bool>(isUpdating),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.value,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                ),
              ),
              if (widget.isUpdatable && widget.isMe)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: IconButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          if (isUpdating) {
                            if (widget.label == 'College Name' &&
                                !collegeNamesGlobal.contains(controller.text)) {
                              controller.text = widget.value;
                            } else {
                              widget.update(controller.text);
                            }
                          }
                          isUpdating = !isUpdating;
                        });
                      }
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return RotationTransition(
                          turns: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isUpdating ? Icons.check_rounded : Icons.edit_rounded,
                        key: ValueKey<bool>(isUpdating),
                        color: Colors.tealAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
