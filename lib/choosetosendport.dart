import 'package:flutter/material.dart';

class PortfolioTab extends StatefulWidget {
  @override
  _PortfolioTabState createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<PortfolioTab> {
  int selectedIndex = -1; // Track which card is selected

  final List<Map<String, dynamic>> portfolioItems = [
    {
      "title": "Complete Product Catalog",
      "subtitle": "Share your entire product portfolio with the customer",
      "items": 6,
      "categories": 3,
      "priceRange": "₹999 - ₹5,999"
    },
    {
      "title": "Starter Pack Portfolio",
      "subtitle": "Curated selection for new customers",
      "items": 3,
      "categories": 2,
      "priceRange": "₹499 - ₹2,999"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: portfolioItems.length,
        itemBuilder: (context, index) {
          final item = portfolioItems[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + View
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            "view",
                            style:
                            TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    item["subtitle"],
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Items & Categories
                  Text(
                    "${item["items"]} items   |   ${item["categories"]} categories",
                    style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  // Price Range
                  Text(
                    "Price range: ${item["priceRange"]}",
                    style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
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
