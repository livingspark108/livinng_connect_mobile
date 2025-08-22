import 'package:flutter/material.dart';
import 'choosetosendcate.dart';
import 'choosetosendport.dart';
import 'choosetosendpro.dart';


class ChooseToSendScreen extends StatefulWidget {
  @override
  State<ChooseToSendScreen> createState() => _ChooseToSendScreenState();
}

class _ChooseToSendScreenState extends State<ChooseToSendScreen> {
  int selectedTab = 0;

  final List<String> tabs = ['Products', 'Category', 'Portfolio'];

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabScreens = [
      ProductsTab(),
      CategoryTab(),
      PortfolioTab(),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF8F5EF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFF8F5EF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Choose to send",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final selected = selectedTab == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Active Tab Screen
          Expanded(child: tabScreens[selectedTab]),

          // Bottom Buttons
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Cancel", style: TextStyle(color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Send", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
