import 'package:avatar_glow/avatar_glow.dart';
import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/group_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GroupListCard extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupListCard({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupListCard> createState() => _GroupListCardState();
}

class _GroupListCardState extends State<GroupListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _shadowAnimation = Tween<double>(begin: 15.0, end: 30.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (mounted) {
      setState(() => _isHovered = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (mounted) {
      setState(() => _isHovered = false);
    }
    bool isMember = widget.group['members']
        .contains(FirebaseAuth.instance.currentUser!.uid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => isMember
            ? ChatPage(groupDetails: widget.group)
            : GroupDetailsPage(groupDetails: widget.group),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onTapCancel() {
    _controller.reverse();
    if (mounted) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 12.0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade900,
                  Colors.grey.shade900,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: _shadowAnimation.value,
                  offset: Offset(3, _isHovered ? 8 : 6),
                ),
              ],
              border: Border.all(
                color: Colors.teal.shade700.withOpacity(0.8),
                width: _isHovered ? 1.2 : 0.9,
              ),
            ),
            child: Stack(
              children: [
                if (_isHovered)
                  const Positioned.fill(
                    child: ShimmerOverlay(),
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  leading: AvatarGlow(
                    glowCount: 2,
                    glowRadiusFactor: 0.2,
                    child: ImageCircle(
                      letter: widget.group['name'][0].toUpperCase(),
                      circleRadius: 24,
                      fontSize: 24,
                      colors: [
                        Colors.tealAccent.shade200,
                        Colors.teal,
                      ],
                    ),
                  ),
                  title: Text(
                    overflow: TextOverflow.ellipsis,
                    widget.group['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0.0,
                          end: _isHovered ? 1.2 : 1.0,
                        ),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Icon(
                              Icons.group,
                              size: 16,
                              color: Colors.teal.shade300,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.group['members'].length} joined',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: _isHovered ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(8 * value, 0),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade800,
                                  Colors.teal.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerOverlay extends StatelessWidget {
  const ShimmerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.transparent,
      highlightColor: Colors.white.withOpacity(0.1),
      period: const Duration(milliseconds: 1500),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}
