import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditContactScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditContactScreen extends StatefulWidget {
  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedCountry;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  String mobile = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  /// Load saved contact info from SharedPreferences and set into fields
  Future<void> _loadContactInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      firstNameController.text = prefs.getString('first_name') ?? '';
      lastNameController.text = prefs.getString('last_name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      mobile = prefs.getString('mobile_number') ?? '919785184266';
      selectedCountry = prefs.getString('country') ?? 'India'; // default
    });
  }

  /// Submit form data to API
  Future<void> submitData() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? '';
    final contactUid = prefs.getString('UUID') ?? '';

    final url =
        "https://livingconnect.in/api/02e331e5-3746-41a1-a987-50f5eecd778f/update-customer-data?token=$token";

    final body = {
      "IsApi": "yes",
      "contactIdOrUid": contactUid,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "language_code": "HI",
      "email": emailController.text,
      "contact_groups": [11, 12, 14]
    };

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-requested-with": "XMLHttpRequest",
          "x-external-api-request": "true",
        },
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Success: ${responseData['message'] ?? 'Contact updated'}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Contact")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeaderSection(),
              const SizedBox(height: 32),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              const Text("Other Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          submitData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: isLoading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text("Submit"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("First Name"),
        buildTextField(controller: firstNameController),
        buildLabel("Last Name"),
        buildTextField(controller: lastNameController),
        buildLabel("Country"),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          value: selectedCountry,
          hint: const Text("Country"),
          items: ["India", "USA", "UK"].map((country) {
            return DropdownMenuItem(value: country, child: Text(country));
          }).toList(),
          onChanged: (value) => setState(() => selectedCountry = value),
        ),
        const SizedBox(height: 16),
        buildLabel("Mobile Number"),
        TextFormField(
          initialValue: mobile,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFFEFEFEF),
          ),
        ),
        const SizedBox(height: 16),
        buildLabel("Email"),
        buildTextField(controller: emailController),
      ],
    );
  }

  Widget buildTextField({TextEditingController? controller}) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
      ],
    );
  }
}
