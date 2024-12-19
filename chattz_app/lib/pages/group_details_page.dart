import 'package:chattz_app/components/details_textfield.dart';
import 'package:chattz_app/components/image_circle.dart';
import 'package:chattz_app/main.dart';
import 'package:chattz_app/models/message.dart';
import 'package:chattz_app/pages/chat_page.dart';
import 'package:chattz_app/pages/home_page.dart';
import 'package:chattz_app/services/firestore_services.dart';
import 'package:chattz_app/services/user_services.dart';
import 'package:chattz_app/widgets/group_details_page_body.dart';
import 'package:chattz_app/widgets/user_list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  const GroupDetailsPage({super.key, required this.groupDetails});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  // Updated build method for enhanced UI
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (mounted) {
          setState(() {});
        }
      },
      color: Colors.tealAccent,
      backgroundColor: Colors.black,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                    color: Colors.teal.shade300,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: GroupDetailsPageBody(
          groupDetails: widget.groupDetails,
        ),
      ),
    );
  }
}
