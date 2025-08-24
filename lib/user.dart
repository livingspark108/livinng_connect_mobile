import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:untitled4/chat2.dart';
import 'apiservice.dart';

class User {
  final String name;
  final String lastMessage;
  final String time;
  final String image;
  bool isPinned;
  final String status;
  final int contactsId;
  final String mobileno;

  User({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    this.isPinned = false,
    required this.status,
    required this.contactsId,
    required this.mobileno,
  });
}

class HomeScreen extends StatefulWidget {
  final bool isForwarding;

  const HomeScreen({Key? key, this.isForwarding = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];
  List<dynamic> allUsersRaw = [];
  List<String> allTags = [];
  String? selectedTag; // null means "All Users"
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String uuid = "";
  String pname="";
  String? _deviceToken;
  final ScrollController _scrollController = ScrollController();

  // SEARCH FIELDS
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _setupFirebase();
    _fetchUsers(initial: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _fetchUsers();
      }
    });

    // Listen for search input changes
    _searchController.addListener(() {
      final newQuery = _searchController.text.trim().toLowerCase();
      if (newQuery != _searchQuery) {
        setState(() => _searchQuery = newQuery);
      }
    });
  }
  /// Show contact picker like WhatsApp and return selected contact to previous screen
  Future<String?> showContactPicker(BuildContext context) async {
    final selectedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(isForwarding: true),
      ),
    );

    if (selectedUser != null) {
      final contactJson = jsonEncode({
        'name': selectedUser.name,
        'phone': selectedUser.mobileno,
      });
      return contactJson;
    }

    return null;
  }


  Future<void> _setupFirebase() async {
    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      setState(() => _deviceToken = token);
      await registerFcm();
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      setState(() => _deviceToken = newToken);
      await registerFcm();
    });

    FirebaseMessaging.onMessage.listen((msg) {
      final notif = msg.notification;
      if (notif != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${notif.title}: ${notif.body}')),
        );
      }
    });
  }

  Future<void> registerFcm() async {
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    final prefs = await SharedPreferences.getInstance();
    final apitoken = prefs.getString('token') ?? '';
    int uuidd = prefs.getInt('userid') ?? 0;

    if (token == null) return;

    final success = await ApiService.updateFcmToken(
      uuid: "",
      apiToken: apitoken,
      userId: uuidd,
      fcmToken: token,
    );

    if (success) {
      print('✅ FCM token updated on server');
    } else {
      print('❌ Failed to update FCM token');
    }
  }
  String extractProfileName(Map<String, dynamic> userJson) {
    String profileName = "";

    try {
      // Check in webhook_responses → incoming
      final incoming = userJson['Data']?['webhook_responses']?['incoming'] as List?;
      if (incoming != null && incoming.isNotEmpty) {
        final changes = incoming[0]?['changes'] as List?;
        if (changes != null && changes.isNotEmpty) {
          final contacts = changes[0]?['value']?['contacts'] as List?;
          if (contacts != null && contacts.isNotEmpty) {
            profileName = contacts[0]?['profile']?['name'] ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint("Error extracting profile name: $e");
    }

    // Fallback to MobileNumber if profile name is missing/unknown
    if (profileName.isEmpty || profileName.toLowerCase() == "unknown") {
      profileName = userJson['MobileNumber'] ?? "Unknown";
    }

    return profileName;
  }

    Future<void> _fetchUsers({bool initial = false}) async {
      if (isLoading || (!hasMore && !initial)) return;

      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final role = prefs.getString('role') ?? '';
      final vendorid = prefs.getString('vendorid') ?? '';
      final agentId = prefs.getInt('userid') ?? '';

      var assigned="";
  if(role=="agent"){

    assigned="to-me";
  }
  else{

    assigned="all";
  }
      final uri = Uri.parse(
          "https://livingconnect.in/api/$vendorid/contact/contacts-data?token=$token",
      );

      // Note: no "search" in payload, we filter client-side
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-requested-with': 'XMLHttpRequest',
          'x-external-api-request': 'true',
        },
        body: jsonEncode({
          "page": currentPage,
          "agent_id": agentId,
          "assigned": assigned,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> newUsersRaw = data['data']['users'];

        if (initial) {
          allUsersRaw.clear();
          users.clear();
          currentPage = 1;
          hasMore = true;
        }

        if (newUsersRaw.isEmpty) {
          hasMore = false;
        } else {
          currentPage++;
          allUsersRaw.addAll(newUsersRaw);
        }

        if (initial) {
          Set<String> tagsSet = {};
          for (var user in allUsersRaw) {
            final tagString = user['Tags'] ?? '';
            if (tagString.toString().isNotEmpty) {
              final List<String> tags = tagString
                  .toString()
                  .split(',')
                  .map((e) => e.toString().trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
              tagsSet.addAll(tags);
            }
          }
          allTags = tagsSet.toList();
        }

        // Map newUsersRaw → User and append to users
          for (var userJson in newUsersRaw) {


            // Skip if already in list
            final profileName = userJson['Data']?['initial_response']?['accepted']
            ?['contacts']?[0]?['profile']?['name'] // WhatsApp profile
        // fallback to Notes
                ?? userJson['MobileNumber']; // last fallback

             pname =extractProfileName(userJson);
            final contact = userJson['Data']?['webhook_responses']?['sent']?[0]
            ?['changes']?[0]?['value']?['statuses']?[0]?['recipient_id'] ??
                userJson['MobileNumber'];

            final rawName = contact;
            final name = (rawName == null ||
                rawName.toString().isEmpty ||
                rawName.toString().toLowerCase() == 'unknown')
                ? userJson['MobileNumber']
                : rawName.toString();

            final message = userJson['Message'] ?? '';
            final isoTime = userJson['MessagedAt'] ?? '';
            final time = formatWhatsAppTime(isoTime);
            final status = userJson['Status'] ?? '';
            final contactsId = userJson['ContactsId'] ?? 0;
            final mobileno = userJson['MobileNumber'] ?? '';
            uuid = userJson["ContactsUUId"];

            users.add(User(
              name: pname,
              lastMessage: message,
              time: time,
              image: "assets/images/logo.png",
              status: status,
              contactsId: contactsId,
              mobileno: mobileno,
            ));
          }

        setState(() => isLoading = false);
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch users")),
        );
      }
    }

  String formatWhatsAppTime(String isoTime) {
    if (isoTime.isEmpty) return '';
    try {
      final messageTime = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDay =
      DateTime(messageTime.year, messageTime.month, messageTime.day);
      final difference = today.difference(messageDay).inDays;

      if (difference == 0) {
        return DateFormat.jm().format(messageTime);
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return DateFormat.E().format(messageTime);
      } else {
        return DateFormat('dd/MM/yyyy').format(messageTime);
      }
    } catch (_) {
      return '';
    }
  }

  void _onTagSelected(String? tag) {
    setState(() {
      selectedTag = tag; // null for "All Users", otherwise the tag string
      currentPage = 1;
      users.clear();
      allUsersRaw.clear();
      hasMore = true;
    });
    _fetchUsers(initial: true);
  }

  void _togglePin(int index) {
    final displayList = _buildDisplayList();
    final toToggle = displayList[index];
    setState(() {
      toToggle.isPinned = !toToggle.isPinned;
      displayList.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
      // If no search & no tag filter, update users directly
      if (_searchQuery.isEmpty && (selectedTag == null)) {
        users = displayList;
      }
    });
  }

  String _getAvatarInitial(User user) {
    final name = user.name;
    if (name.toLowerCase() == 'unknown' ||
        RegExp(r'^[0-9]+$').hasMatch(name)) {
      return 'U';
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Build the list we actually show in ListView:
  List<User> _buildDisplayList() {
    List<User> base = List.from(users);

    // 1) Tag filter (selectedTag == null means "All Users")
    if (selectedTag != null && selectedTag!.isNotEmpty) {
      base = base.where((u) {
        final matchJson = allUsersRaw.firstWhere(
              (raw) => raw['MobileNumber'] == u.mobileno,
          orElse: () => null,
        );
        if (matchJson == null) return false;
        final tagString = matchJson['Tags'] ?? '';
        final tags = tagString.toString().split(',').map((e) => e.trim());
        return tags.contains(selectedTag);
      }).toList();
    }

    // 2) Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base.where((u) {
        final nameMatch = u.name.toLowerCase().contains(q);
        final numberMatch = u.mobileno.contains(q);
        return nameMatch || numberMatch;
      }).toList();
    }

    // 3) Sort pinned to top
    base.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return base;
  }

  // WhatsApp-style AppBar with labeled search button
  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _searchQuery = "";
              selectedTag = null; // show all users on back
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search contacts',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Chat", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context); // 👈 Your logout function
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      );
    }
  }
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    final displayList = _buildDisplayList();

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label for tag filters + "All Users" option
            if (allTags.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Filter by Tag:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // "All Users" chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _onTagSelected(null),
                        child: Chip(
                          label: const Text("All Users"),
                          backgroundColor: selectedTag == null ? Colors.blue : Colors.white,
                          labelStyle: TextStyle(
                            color: selectedTag == null ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    // Dynamic tag chips
                    for (final tag in allTags)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _onTagSelected(tag),
                          child: Chip(
                            label: Text(tag),
                            backgroundColor:
                            selectedTag == tag ? Colors.blue : Colors.white,
                            labelStyle: TextStyle(
                              color: selectedTag == tag ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),
            ],
            // Label explaining pin/unpin
            if (!_isSearching && _searchQuery.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Long-press a chat to Pin/Unpin",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: displayList.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= displayList.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = displayList[index];
                  return GestureDetector(
                    onLongPress: () {
                      _togglePin(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(user.isPinned
                              ? 'Pinned ${user.name}'
                              : 'Unpinned ${user.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal[200],
                            radius: 25,
                            child: Text(
                              _getAvatarInitial(user),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                user.time,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            user.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: user.isPinned
                              ? const Icon(Icons.push_pin,
                              color: Colors.orange)
                              : null,
                          onTap: () async {
                            if (widget.isForwarding) {
                              Navigator.pop(context, user);
                            } else {
                              final prefs =
                              await SharedPreferences.getInstance();
                              await prefs.setInt(
                                  'ContactsId', user.contactsId);
                              await prefs.setString('Mobile', user.mobileno);
                              await prefs.setString('UUID', uuid);
                              await prefs.setString('namee', user.name);
                              DateTime lastMessageTime = DateTime.now().subtract(const Duration(hours: 25)); // default 25 hrs ago

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WhatsAppChatScreen(
                                    // Send allowed:
                                    // lastMessageTime: DateTime.now().subtract(Duration(hours: 23)),

                                    // Send disabled (older than 24 hours):
                                    lastMessageTime: DateTime.now().subtract(const Duration(hours: 25)),
                                  ),
                                ),
                              );


                            }
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 72.0),
                          child: Divider(height: 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
