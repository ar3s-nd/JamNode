import 'package:chattz_app/components/details_textfield.dart';
import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/main.dart';
import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/routes/fade_page_route.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/shimmer/shimmer_group_details_page.dart';
import 'package:chattz_app/widgets/user_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GroupDetailsPageBody extends StatefulWidget {
  const GroupDetailsPageBody({
    super.key,
    required this.groupDetails,
  });
  final Map<String, dynamic> groupDetails;

  @override
  State<GroupDetailsPageBody> createState() => _GroupDetailsPageBodyState();
}

class _GroupDetailsPageBodyState extends State<GroupDetailsPageBody> {
  Map<String, dynamic> groupDetails = {};
  Map<String, Map<String, dynamic>> members = {};
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isUpdating = false;
  TextEditingController controller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setDetails();
  }

  void setDetails() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (groupDetails.isEmpty) await setGroupDetails();
      if (members.isEmpty) await setMemberDetails();
    } catch (e) {
      // handle gracefully
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> setGroupDetails() async {
    if (mounted && groupDetails.isEmpty) {
      groupDetails = widget.groupDetails;
      return;
    }

    try {
      groupDetails = await FirestoreServices()
          .getGroupDetailsByGroupId(groupDetails['groupId']);
    } catch (e) {
      // handle gracefully
    }
    if (mounted) {
      setState(() {
        groupDetails = groupDetails;
      });
    }
  }

  Future<void> setMemberDetails() async {
    if (groupDetails['members'].isEmpty) {
      return;
    }
    Map<String, Map<String, dynamic>> userDetails = members;
    try {
      userDetails =
          await UserService().getUserDetailsByGroupId(groupDetails['groupId']);
    } catch (e) {
      // handle gracefully
    }
    members = userDetails;
    if (mounted) {
      setState(() {
        members = userDetails;
      });
    }
  }

  void showErrorMessage(String errorMessage) {
    checkPop();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.teal[900],
          title: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  void joinGroup() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: CircularProgressIndicator(
          color: Colors.teal[900],
        ));
      },
    );

    try {
      Map<String, dynamic> user =
          await UserService().getUserDetailsById(currentUserId);
      if (user['groups'].length >= numberOfGroupsPerPersonGlobal) {
        throw 'You can only be a part of max 3 groups at a time';
      }
      Map<String, dynamic> updatedUser = {
        'groups': [...user['groups'], groupDetails['groupId']]
      };

      Map<String, dynamic> updatedGroup = {
        'members': [...groupDetails['members'], currentUserId],
        'allMembers': groupDetails['allMembers'].contains(currentUserId)
            ? groupDetails['allMembers']
            : [...groupDetails['allMembers'], currentUserId],
      };

      await UserService().updateProfile(currentUserId, updatedUser);
      await FirestoreServices()
          .updateGroupDetails(groupDetails['groupId'], updatedGroup);

      Message message = Message(
        id: DateTime.now().toString(),
        text: '${user['name']} joined',
        senderUserId: currentUserId,
        timestamp: DateTime.now(),
        isLog: true,
      );

      await FirestoreServices().addMessage(groupDetails['groupId'], message);
      // checkPop();
      pushReplacementChatPage();
    } catch (e) {
      // show error message
      showErrorMessage(e.toString());
    }
  }

  void leaveGroup(String userId, bool navigate) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: CircularProgressIndicator(
          color: Colors.teal[900],
        ));
      },
    );

    try {
      Map<String, dynamic> user =
          await UserService().getUserDetailsById(userId);

      user['groups'].remove(groupDetails['groupId']);
      Map<String, dynamic> updatedUser = {'groups': user['groups']};
      await UserService().updateProfile(userId, updatedUser);

      groupDetails['admins'].remove(userId);
      groupDetails['members'].remove(userId);

      if (groupDetails['admins'].isEmpty) {
        if (groupDetails['members'].isEmpty) {
          await FirestoreServices().deleteGroup(groupDetails['groupId']);
        } else {
          groupDetails['admins'].add(groupDetails['members'][0]);
          await FirestoreServices()
              .updateGroupDetails(groupDetails['groupId'], groupDetails);
          Message message = Message(
            id: DateTime.now().toString(),
            text: '${user['name']} left',
            senderUserId: userId,
            timestamp: DateTime.now(),
            isLog: true,
          );
          FirestoreServices().addMessage(groupDetails['groupId'], message);
        }
      } else {
        await FirestoreServices()
            .updateGroupDetails(groupDetails['groupId'], groupDetails);
        Message message = Message(
          id: DateTime.now().toString(),
          text: '${user['name']} was too busy to jam with you',
          senderUserId: userId,
          timestamp: DateTime.now(),
          isLog: true,
        );
        FirestoreServices().addMessage(groupDetails['groupId'], message);
      }
      if (mounted) {
        setState(() {
          members.remove(userId);
        });
      }
      checkPop();
      if (navigate) {
        checkPop();
        checkPop();
        pushReplacementHomePage();
      }
    } catch (e) {
      // show error message
      showErrorMessage(e.toString());
    }
  }

  void pushReplacementChatPage() {
    Navigator.pushReplacement(
      context,
      FadePageRoute(
        page: ChatPage(
          groupDetails: groupDetails,
        ),
      ),
    );
  }

  void pushReplacementHomePage() {
    Navigator.pushReplacement(
      context,
      FadePageRoute(
        page: const HomePage(),
      ),
    );
  }

  void checkPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerGroupDetailsPage();
    }

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            // Group Image, Name
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageCircle(
                    letter: groupDetails['name'][0].toUpperCase(),
                    circleRadius: 40,
                    fontSize: 30,
                    colors: [Colors.tealAccent.shade200, Colors.teal],
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !isUpdating
                            ? Text(
                                groupDetails['name'] ?? 'Group Name',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.teal.shade300,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : DetailsTextField(
                                controller: controller,
                                label: "Group Name",
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
                            Flexible(
                              child: Text(
                                '${groupDetails['members'].length} members',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (members.containsKey(currentUserId) &&
                      groupDetails['admins'].contains(currentUserId))
                    IconButton(
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            isUpdating = !isUpdating;
                            if (isUpdating) {
                              controller.text = groupDetails['name'];
                            } else {
                              groupDetails['name'] = controller.text;
                              FirestoreServices()
                                  .updateGroupDetails(groupDetails['groupId'], {
                                'name': controller.text,
                              });
                            }
                          });
                        }
                      },
                      icon: Icon(
                        isUpdating ? Icons.check_rounded : Icons.edit_rounded,
                        color: Colors.tealAccent,
                      ),
                    ),
                ],
              ),
            ),

            // Group Info: Started On
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade600.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: Colors.teal.shade300),
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

            // Join/Leave Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (groupDetails['members'].contains(currentUserId)) {
                    leaveGroup(currentUserId, true);
                  } else {
                    joinGroup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      !groupDetails['members'].contains(currentUserId)
                          ? Colors.greenAccent.shade700
                          : Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  shadowColor: !groupDetails['members'].contains(currentUserId)
                      ? Colors.teal.shade600
                      : Colors.redAccent.shade700,
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                ),
                child: Text(
                  groupDetails['members'].contains(currentUserId)
                      ? 'Leave Group'
                      : 'Join Group',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Members List Section Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Icon(Icons.group, color: Colors.teal.shade300),
                  const SizedBox(width: 15),
                  Text(
                    '${groupDetails['members'].length} Members',
                    style: TextStyle(
                      color: Colors.teal.shade300,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // List of members with dropdown for details
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool isAdmin = groupDetails['admins']
                    .contains(members.keys.toList()[index]);
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: UserListCard(
                        member: members[members.keys.toList()[index]]!,
                        isAdmin: isAdmin,
                        userId: members.keys.toList()[index],
                        remove: leaveGroup,
                        showRemove: groupDetails['admins']
                            .contains(FirebaseAuth.instance.currentUser!.uid),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
