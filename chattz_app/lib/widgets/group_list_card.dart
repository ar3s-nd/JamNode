import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/group_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupListCard extends StatelessWidget {
  final Map<String, dynamic> group;
  const GroupListCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bool isMember =
            group['members'].contains(FirebaseAuth.instance.currentUser!.uid);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isMember
                ? ChatPage(
                    groupDetails: group,
                  )
                : GroupDetailsPage(
                    groupDetails: group,
                  ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade800,
                Colors.grey.shade900,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: ImageCircle(
              letter: group['name'][0].toUpperCase(),
              circleRadius: 25,
              fontSize: 30,
              colors: [Colors.teal.shade400, Colors.teal],
            ),
            // CircleAvatar(
            //   radius: 25,
            //   backgroundColor: Colors.tealAccent.shade700,
            //   child: Icon(
            //     Icons.music_note,
            //     size: 30,
            //     color: Colors.grey.shade900,
            //   ),
            // ),
            title: Text(
              group['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${group['members'].length} joined',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: 28,
              color: Colors.teal.shade300,
            ),
          ),
        ),
      ),
    );
  }
}
