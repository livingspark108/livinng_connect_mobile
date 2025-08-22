import 'package:flutter/material.dart';

import 'invoicedetail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SendInvoiceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SendInvoiceScreen extends StatelessWidget {
  const SendInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF), // Light beige background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12, bottom: 8),
          decoration: const BoxDecoration(color: Color(0xFFF9F6EF)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
                    SizedBox(width: 4),
                    Text("Back",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              const Spacer(),

            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
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

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Available invoices",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // Invoice List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                invoiceTile(
                  context,
                  "INV-2211",
                  "Unpaid",
                  Colors.orange,
                  "₹1,999",
                  "10/07/2025",
                  "25/07/2025",
                ),
                invoiceTile(
                  context,
                  "INV-2233",
                  "Paid",
                  Colors.green,
                  "₹1,999",
                  "10/07/2025",
                  "25/07/2025",
                ),
                invoiceTile(
                  context,
                  "INV-2233",
                  "Overdue",
                  Colors.red,
                  "₹1,999",
                  "10/07/2025",
                  "25/07/2025",
                ),
              ],
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Send Invoice",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Invoice Tile Widget
  Widget invoiceTile(BuildContext context, String invoiceNo, String status,
      Color statusColor, String amount, String issued, String due) {
    return


      GestureDetector(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InvoicePreviewScreen()),
      );
    },
    child:
      Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row (Invoice Number, Status, Amount)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(invoiceNo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 6),
                  Icon(Icons.circle, size: 6, color: statusColor),
                  const SizedBox(width: 4),
                  Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Professional Services",
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),

          // Dates + View link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Issued: $issued  |  Due: $due",
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Row(
                children: const [
                  Text("view",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              )
            ],
          ),
        ],
      ),
    ));
  }
}
