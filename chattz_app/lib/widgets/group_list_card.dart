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
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
                blurRadius: 15,
                offset: const Offset(3, 6),
              ),
            ],
            border: Border.all(
              color: Colors.teal.shade700.withOpacity(0.8),
              width: 0.9,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal.shade700,
                ),
                ImageCircle(
                  letter: group['name'][0].toUpperCase(),
                  circleRadius: 24,
                  fontSize: 24,
                  colors: [Colors.teal.shade800, Colors.teal.shade600],
                ),
              ],
            ),
            title: Text(
              group['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.teal.shade300),
                const SizedBox(width: 5),
                Text(
                  '${group['members'].length} joined',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(10),
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
                Icons.chevron_right,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
