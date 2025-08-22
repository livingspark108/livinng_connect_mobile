import 'package:flutter/material.dart';
import 'package:untitled4/requestfeedbackcustom.dart';
import 'package:untitled4/requestfeedbacktemplete.dart';


class RequestFeedbackScreen extends StatefulWidget {
  @override
  _RequestFeedbackScreenState createState() => _RequestFeedbackScreenState();
}

class _RequestFeedbackScreenState extends State<RequestFeedbackScreen> {
  String selectedTab = "Templates";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5EF),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "Request Feedback",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabButton("Templates"),
                const SizedBox(width: 12),
                _buildTabButton("Custom"),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: selectedTab == "Templates"
                ? TemplatesTab() // Comes from templates_tab.dart
                :   CustomMessageScreen(),    // Comes from custom_tab.dart
          ),

          // Bottom Buttons
         
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
