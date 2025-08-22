import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AssignAgentScreen extends StatefulWidget {
  @override
  _AssignAgentScreenState createState() => _AssignAgentScreenState();
}

class _AssignAgentScreenState extends State<AssignAgentScreen> {
  List<Agent> agents = [];
  int currentPage = 1;
  final int perPage = 20;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Replace with dynamic value if needed


  @override
  void initState() {
    super.initState();
    fetchAgents();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchAgents();
      }
    });
  }

  Future<void> fetchAgents() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://livingconnect.in/api/02e331e5-3746-41a1-a987-50f5eecd778f/agent-lists?token=pbYJx9mgrgQOYiw6YduNGkL5QwxITIvrJJCw2jmnI8VJOfDecIg1pHP3JuSOoDkG'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
      },
      body: json.encode({
        "page": currentPage,
        "per_page": perPage,
        "search": ""
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> users = jsonData['data']['users'] ?? [];

      if (users.isEmpty) {
        hasMore = false;
      } else {
        setState(() {
          agents.addAll(users.map((item) => Agent.fromJson(item)).toList());
          currentPage++;
        });
      }
    } else {
      print('Failed to load agents');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> assignAgent(String agentUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final vendorid = prefs.getString('vendorid') ?? '';
    final contactId = prefs.getInt('ContactsId') ?? '';

    var uuidd=   await prefs.getString('UUID');
    final response = await http.post(
      Uri.parse(
          'https://livingconnect.in/api/$contactId/contact/chat/assign-user?token=$token'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
      },
      body: json.encode({
        "contactIdOrUid": uuidd,
        "assigned_users_uid": agentUuid,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agent assigned successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to assign agent.")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Assign Agent",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: agents.length + (isLoading ? 1 : 0),
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= agents.length) {
                return Center(child: CircularProgressIndicator());
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    agents[index].firstName.isNotEmpty
                        ? agents[index].firstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text("${agents[index].firstName} ${agents[index].lastName}"),
                trailing: Icon(Icons.chevron_right),
                onTap: () async {
                  await assignAgent(agents[index].uuid);
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.chat_bubble_outline),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.green,
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                )
              ],
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle tab switch here
        },
      ),
    );
  }
}

class Agent {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String uuid;

  Agent({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.uuid,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['ID'],
      username: json['Username'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      uuid: json['UUID'] ?? '',
    );
  }
}
