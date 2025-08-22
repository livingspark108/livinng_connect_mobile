import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: InvoicePreviewScreen()));
}

class InvoicePreviewScreen extends StatelessWidget {
  const InvoicePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E7), // Light beige background
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
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
                    "INV-2211",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Invoice Preview",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 14),

                  // Invoice Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "INVOICE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Center(
                          child: Text(
                            "Living Connect Services",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bill To + Invoice Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Bill To:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  SizedBox(height: 4),
                                  Text("Rahul Sharma", style: TextStyle(fontSize: 13)),
                                  Text("+91 98765 43210", style: TextStyle(fontSize: 12)),
                                  Text("rahul@example.com", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Invoice #: INV-2211",
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 2),
                                const Text("Issue Date: 10 July 2024",
                                    style: TextStyle(fontSize: 12)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Due Date: 25 July 2024",
                                        style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Unpaid",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Divider(),

                        // Invoice Table Header
                        Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text("Description",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Expanded(
                              child: Text("Qty",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Expanded(
                              child: Text("Rate",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Expanded(
                              child: Text("Amount",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        _buildInvoiceRow(
                            "Consultation Services", "1", "₹1,500", "₹1,500"),
                        _buildInvoiceRow(
                            "Documentation Fee", "1", "₹499", "₹499"),

                        const SizedBox(height: 12),
                        const Divider(),

                        // Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text("Subtotal:", style: TextStyle(fontSize: 13)),
                            SizedBox(width: 4),
                            Text("₹1,999", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text("Tax:", style: TextStyle(fontSize: 13)),
                            SizedBox(width: 4),
                            Text("₹0", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text("Total:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              "₹1,999",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text("Thank you for your business!",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Download PDF Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFFEFE8D8),
                    ),
                    child: const Center(
                      child: Text("Download PDF",
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
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
                      "Send Invoice",
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

  Widget _buildInvoiceRow(
      String desc, String qty, String rate, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(desc, style: const TextStyle(fontSize: 13))),
          Expanded(child: Text(qty, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
          Expanded(child: Text(rate, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
          Expanded(child: Text(amount, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
