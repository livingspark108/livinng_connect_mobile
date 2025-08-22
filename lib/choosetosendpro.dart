import 'package:flutter/material.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  int selectedIndex = -1;

  final List<Map<String, String>> products = [
    {"title": "Premium Widget Pro", "subtitle": "Electronics", "price": "₹2,999"},
    {"title": "Smart Device Hub", "subtitle": "Electronics", "price": "₹2,999"},
    {"title": "Professional Service Package", "subtitle": "Services", "price": "₹2,999"},
    {"title": "Basic Starter Kit", "subtitle": "Services", "price": "₹2,999"},
    {"title": "Mobile App Solution", "subtitle": "Software", "price": "₹2,999"},
    {"title": "Advanced Analytics Tool", "subtitle": "Software", "price": "₹2,999"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by invoice number",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // List of Products
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final selected = selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['title']!, style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text(product['subtitle']!, style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text(product['price']!, style: TextStyle(color: Colors.green, fontSize: 14)),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage('assets/images/product.png'), // Replace with your product image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
