import 'package:chattz_app/pages/onboarding.dart';
import 'package:chattz_app/pages/profile_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  final bool isActiveGroupShown;
  final Function(bool) onActiveGroupChanged;
  final Map<String, dynamic> userData;

  const MainDrawer({
    super.key,
    required this.isActiveGroupShown,
    required this.onActiveGroupChanged,
    required this.userData,
  });

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _drawerContentsOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerContentsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border(
          left: BorderSide(
            color: isSelected ? Colors.teal[200]! : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isSelected ? Colors.teal[200] : Colors.white,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: isSelected ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.teal[200] : Colors.white,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        horizontalTitleGap: 16,
        tileColor: isSelected ? Colors.teal.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Colors.black87,
      child: FadeTransition(
        opacity: _drawerContentsOpacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    _buildDrawerTile(
                      icon: Icons.person_2_rounded,
                      text: 'Profile',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          FadePageRoute(
                            page: ProfilePage(userData: widget.userData),
                          ),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.queue_music_rounded,
                      text: 'Active Jams',
                      isSelected: widget.isActiveGroupShown,
                      onTap: () {
                        widget.onActiveGroupChanged(true);
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.library_music_rounded,
                      text: 'My Jams',
                      isSelected: !widget.isActiveGroupShown,
                      onTap: () {
                        widget.onActiveGroupChanged(false);
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.logout_rounded,
                      text: 'Logout',
                      isSelected: false,
                      onTap: () async {
                        ErrorDialog.show(
                          context: context,
                          title: 'Logout',
                          description: 'Are you sure you want to logout?',
                          text1: 'Yes',
                          text2: 'No',
                          onRetry: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                            } catch (e) {
                              // handle error
                            }
                            Navigator.pushReplacement(
                              context,
                              FadePageRoute(
                                page: const OnboardingPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "© 2024 JamNode",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
