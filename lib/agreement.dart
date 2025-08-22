import 'package:flutter/material.dart';
import 'package:untitled4/agreementdetail.dart';

void main() {
  runApp(const MaterialApp(home: SendAgreementScreen()));
}

class SendAgreementScreen extends StatelessWidget {
  const SendAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agreements = [
      {
        "title": "Standard Service Agreement",
        "subtitle": "Service Contract",
        "date": "15/07/2025",
        "isHighlighted": true
      },
      {
        "title": "Non-Disclosure Agreement",
        "subtitle": "Legal Documents",
        "date": "10/07/2025",
        "isHighlighted": false
      },
      {
        "title": "Freelance Contract",
        "subtitle": "Employment",
        "date": "10/07/2025",
        "isHighlighted": false
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          padding: const EdgeInsets.only(top: 28, left: 12, bottom: 8),
          color: const Color(0xFFF7F2E7),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      "Back",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send Agreement",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Available templates",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of Agreements
                  ...agreements.map((item) {
                    return


                      GestureDetector(
                        onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AgreementPreviewScreen()),
                      );
                    },
                    child:

                      Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: item['isHighlighted'] == true
                            ? Border.all(color: Colors.black, width: 1)
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'].toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'].toString(),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Updated: ${item['date']}",
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                "view",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ));
                  }).toList(),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2E7),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Send Document",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
