import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    bool isMe = FirebaseAuth.instance.currentUser!.uid == userId;
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
              splashColor: Colors.transparent, // Removes splash
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
                  // Enhanced Avatar
                  GestureDetector(
                    onTap: () {
                      if (!isMe) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              userData: member,
                            ),
                          ),
                        );
                      }
                    },
                    child: ImageCircle(
                      letter: member['name'][0].toUpperCase(),
                      circleRadius: 16,
                      fontSize: 20,
                      colors: [Colors.tealAccent.shade200, Colors.teal],
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.031),
                  Expanded(
                    child: Text(
                      '${member['name']}${isMe ? ' (You)' : ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                    'Email: ${member['email']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.music_note, color: Colors.tealAccent),
                  title: Text(
                    member['skills'].isEmpty
                        ? 'Just here for fun'
                        : 'Skills: ${member['skills'].keys.join(', ')}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isAdmin && !isMe && showRemove)
                      ElevatedButton(
                        onPressed: () {
                          remove(userId, false);
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
    );
  }
}
