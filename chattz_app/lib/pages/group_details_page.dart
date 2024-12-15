import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/user_list_card.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  const GroupDetailsPage({super.key, required this.groupDetails});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  Map<String, dynamic> groupDetails = {};
  Map<String, Map<String, dynamic>> members = {};

  void setGroupDetails() async {
    if (mounted && groupDetails.isEmpty) {
      setState(() {
        groupDetails = widget.groupDetails;
      });
    } else if (mounted) {
      groupDetails = await FirestoreServices()
          .getGroupDetailsByGroupId(groupDetails['groupId']);
      setState(() {});
    }
  }

  void setMemberDetails() async {
    Map<String, Map<String, dynamic>> userDetails =
        await UserService().getUserDetailsByGroupId(groupDetails['groupId']);
    userDetails = Map.fromEntries(userDetails.entries.toList()
      ..sort((a, b) {
        bool aIsAdmin = groupDetails['admins'].contains(a.key);
        bool bIsAdmin = groupDetails['admins'].contains(b.key);
        if (aIsAdmin && !bIsAdmin) return -1;
        if (!aIsAdmin && bIsAdmin) return 1;
        return 0;
      }));
    if (mounted) {
      setState(() {
        members = userDetails;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setGroupDetails();
    setMemberDetails();
  }

  @override
  // Updated build method for enhanced UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: RichText(
          text: TextSpan(
            text: 'Jam',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Node',
                style: TextStyle(
                  color: Colors.teal.shade400,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Image and Name Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      ImageCircle(
                        letter: groupDetails['name'][0].toUpperCase(),
                        circleRadius: 40,
                        fontSize: 30,
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
                      //     radius: 40,
                      //     backgroundColor: Colors.transparent,
                      //     child: Text(
                      //       groupDetails['name'][0].toUpperCase(),
                      //       style: const TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 30,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupDetails['name'] ?? 'Group Name',
                            style: TextStyle(
                              color: Colors.teal.shade400,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${groupDetails['members'].length} members',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Group Info: Created On
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade600.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.teal.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Jam started on ${groupDetails['createdOn']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Members List Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Colors.teal.shade400),
                      const SizedBox(width: 8),
                      Text(
                        'Members',
                        style: TextStyle(
                          color: Colors.teal.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // List of members with dropdown for details
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    bool isAdmin = groupDetails['admins']
                        .contains(members.keys.toList()[index]);
                    return UserListCard(
                      member: members[members.keys.toList()[index]]!,
                      isAdmin: isAdmin,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create a new group or any action
        },
        backgroundColor: Colors.teal.shade600,
        child: const Icon(
          Icons.keyboard_double_arrow_right_rounded,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}
