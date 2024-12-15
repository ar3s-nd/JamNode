import 'package:chattz_app/components/image_circle.dart';
import 'package:flutter/material.dart';

class UserListCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isAdmin;

  const UserListCard({super.key, required this.member, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              colors: [Colors.grey.shade900, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: Colors.tealAccent.shade400,
              collapsedIconColor: Colors.tealAccent.shade400,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                children: [
                  // Enhanced Avatar
                  ImageCircle(
                    letter: member['name'][0].toUpperCase(),
                    circleRadius: 16,
                    fontSize: 20,
                    colors: [Colors.tealAccent.shade200, Colors.teal],
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [Colors.tealAccent.shade200, Colors.teal],
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //     ),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: CircleAvatar(
                  //     radius: 16,
                  //     backgroundColor: Colors.transparent,
                  //     child: Text(
                  //       member['name'][0].toUpperCase(),
                  //       style: const TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      member['name'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isAdmin)
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
                    'Email: ${member['email']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.music_note, color: Colors.tealAccent),
                  title: Text(
                    'Roles: ${member['roles'].join(", ")}',
                    style: const TextStyle(color: Colors.white70),
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
