import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/pages/profile_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListCard extends StatefulWidget {
  final Map<String, dynamic> member;
  final bool isAdmin;
  final String userId;
  final Function remove;
  final bool showRemove;

  const UserListCard({
    super.key,
    required this.member,
    required this.isAdmin,
    required this.userId,
    required this.remove,
    required this.showRemove,
  });

  @override
  State<UserListCard> createState() => _UserListCardState();
}

class _UserListCardState extends State<UserListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
    bool isMe = FirebaseAuth.instance.currentUser!.uid == widget.userId;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Card(
          elevation: 6,
          shadowColor: Colors.tealAccent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
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
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: Colors.tealAccent.shade400,
                collapsedIconColor: Colors.tealAccent.shade400,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isMe) {
                          Navigator.of(context).push(
                            FadePageRoute(
                              page: ProfilePage(
                                userData: widget.member,
                              ),
                            ),
                          );
                        }
                      },
                      child: Hero(
                        tag: 'avatar_${widget.userId}',
                        child: ImageCircle(
                          letter: widget.member['name'][0].toUpperCase(),
                          circleRadius: 16,
                          fontSize: 20,
                          colors: [Colors.tealAccent.shade200, Colors.teal],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.031),
                    Expanded(
                      child: Text(
                        '${widget.member['name']}${isMe ? ' (You)' : ''}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade600.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.teal.shade700,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Admin',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.tealAccent.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined,
                        color: Colors.tealAccent),
                    title: Text(
                      'Email: ${widget.member['email']}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.music_note, color: Colors.tealAccent),
                    title: Text(
                      widget.member['skills'].isEmpty
                          ? 'Just here for fun'
                          : 'Skills: ${widget.member['skills'].keys.join(', ')}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!widget.isAdmin && !isMe && widget.showRemove)
                        ElevatedButton(
                          onPressed: () {
                            widget.remove(widget.userId, false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 10,
                            shadowColor: Colors.redAccent.shade700,
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
