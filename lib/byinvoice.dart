import 'package:flutter/material.dart';

class ByInvoiceTab extends StatelessWidget {
  final List<Map<String, String>> invoices = [
    {
      "id": "INV-2211",
      "status": "Unpaid",
      "statusColor": "orange",
      "service": "Professional Services",
      "issued": "10/07/2025",
      "due": "25/07/2025",
      "price": "₹1,999"
    },
    {
      "id": "INV-2745",
      "status": "Unpaid",
      "statusColor": "orange",
      "service": "Professional Services",
      "issued": "10/07/2025",
      "due": "25/07/2025",
      "price": "₹2,999"
    },
    {
      "id": "INV-2965",
      "status": "Overdue",
      "statusColor": "red",
      "service": "Professional Services",
      "issued": "10/07/2025",
      "due": "25/07/2025",
      "price": "₹5,999"
    },
  ];

  Color getStatusColor(String colorName) {
    switch (colorName) {
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      invoice['id']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    const Text("•"),
                    const SizedBox(width: 4),
                    Text(
                      invoice['status']!,
                      style: TextStyle(
                        color: getStatusColor(invoice['statusColor']!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  invoice['price']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice['service']!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Issued: ${invoice['issued']}"),
                      const SizedBox(width: 12),
                      Text("Due: ${invoice['due']}"),
                      const Spacer(),
                      const Text("view", style: TextStyle(color: Colors.grey)),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
