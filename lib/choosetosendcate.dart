import 'package:flutter/material.dart';

class CategoryTab extends StatefulWidget {
  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  int selectedIndex = 0;

  final List<Map<String, String>> categories = [
    {
      "title": "Electronics",
      "subtitle": "Smart devices and electronic components",
      "items": "2 items",
      "priceRange": "₹999 - ₹5,999",
    },
    {
      "title": "Services",
      "subtitle": "Professional and consulting services",
      "items": "12 items",
      "priceRange": "₹999 - ₹5,999",
    },
    {
      "title": "Software",
      "subtitle": "Digital tools and applications",
      "items": "4 items",
      "priceRange": "₹999 - ₹5,999",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF8F5EF),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.black : Colors.transparent,
                  width: selected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and "view" link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category['title']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "view",
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Subtitle
                  Text(
                    category['subtitle']!,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  // Items and Price Range
                  Text(
                    "${category['items']}",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Price range: ${category['priceRange']}",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
