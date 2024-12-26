import 'package:chattz_app/main.dart';
import 'package:chattz_app/widgets/group_details_page_body.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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
    return LiquidPullToRefresh(
      animSpeedFactor: 2,
      showChildOpacityTransition: false,
      onRefresh: () async {
        try {
          await Future.delayed(const Duration(milliseconds: 1500));
        } catch (e) {
          // handle error
        }
        if (mounted) {
          setState(() {});
        }
      },
      color: Colors.teal.shade900,
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
        body: Container(
          height: screenHeight,
          width: screenWidth,
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: GroupDetailsPageBody(
                groupDetails: widget.groupDetails,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
