import 'package:flutter/material.dart';

class TemplatesTab extends StatefulWidget {
  @override
  _TemplatesTabState createState() => _TemplatesTabState();
}

class _TemplatesTabState extends State<TemplatesTab> {
  int selectedIndex = -1;

  final List<Map<String, String>> templates = [
    {
      "title": "General Feedback",
      "subtitle": "We'd love to hear your thoughts about our service!",
    },
    {
      "title": "Order Experience",
      "subtitle": "How did we do with your recent order? Your feedback helps us improve!",
    },
    {
      "title": "Service Quality",
      "subtitle": "We hope you had a great experience with our team. Please share your feedback!",
    },
    {
      "title": "Support Experience",
      "subtitle": "How was your support experience? We're always looking to improve!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => setState(() => selectedIndex = index),
          child: _buildTile(
            templates[index]['title']!,
            templates[index]['subtitle']!,
            isSelected: selectedIndex == index,
          ),
        );
      },
    );
  }

  Widget _buildTile(String title, String subtitle, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: isSelected ? 1.5 : 0,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
