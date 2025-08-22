import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled4/ediicontact.dart';
import 'dart:convert';
import 'assignchat.dart';
import 'forgotpass.dart';



class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Section(
                title: 'Contact Info',
                child: ContactInfoCard(),
              ),
              Section(
                title: 'Assign Team Member',
                child: AssignTeamMemberCard(),
              ),
              Section(
                title: 'Labels/Tags',
                trailingIcon: Icons.settings,
                child: LabelsTagsCard(),
              ),
              Section(
                title: 'Notes',
                trailingIcon: Icons.edit,
                child: NotesCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final Widget child;

  const Section({
    super.key,
    required this.title,
    this.trailingIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header “tab”
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 4),
                    Icon(trailingIcon, size: 16, color: Colors.blue),
                  ]
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}



class ContactInfoCard extends StatefulWidget {
  const ContactInfoCard({super.key});
  @override
  State<ContactInfoCard> createState() => _ContactInfoCardState();
}

class _ContactInfoCardState extends State<ContactInfoCard> {
  String _name = '–';
  String _phone = '–';
  String _email = '–';
  String _language = '–';

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('first_name')! + prefs.getString('last_name')!;
      _phone = prefs.getString('mobile_number') ?? '919785184266';
      _email = prefs.getString('email') ?? '-';
      _language = prefs.getString('contact_language') ?? '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Colors.blueGrey.shade900,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      color: Colors.blueGrey.shade700,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Edit button

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (_) => EditContactScreen()));

            },
            child: const Text('Edit Contact', style: TextStyle(color: Colors.white)),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // you could navigate to an edit screen and then reload:
              // Navigator.push(...).then((_) => _loadContactInfo());
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Contact'),
          ),
        ),
        const SizedBox(height: 8),
        _infoRow('Name', _name, labelStyle, valueStyle),
        const SizedBox(height: 12),
        _infoRow('Phone', _phone, labelStyle, valueStyle),
        const SizedBox(height: 12),
        _infoRow('Email', _email, labelStyle, valueStyle),
        const SizedBox(height: 12),
        _infoRow('Language', _language, labelStyle, valueStyle),
      ],
    );
  }

  Widget _infoRow(
      String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}


class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
        color: Colors.blueGrey.shade900,
        fontSize: 16,
        fontWeight: FontWeight.w600);
    final valueStyle = TextStyle(
        color: Colors.blueGrey.shade700,
        fontSize: 16,
        fontWeight: FontWeight.w400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}



// Make sure you have your Agent model somewhere:
// class Agent {
//   final int id;
//   final String name;
//   Agent({required this.id, required this.name});
//   factory Agent.fromJson(Map<String, dynamic> json) =>
//       Agent(id: json['id'], name: json['name']);
// }



// Make sure you have your Agent model somewhere:
// class Agent {
//   final int id;
//   final String name;
//   Agent({required this.id, required this.name});
//   factory Agent.fromJson(Map<String, dynamic> json) =>
//       Agent(id: json['id'], name: json['name']);
// }



class AssignTeamMemberCard extends StatefulWidget {
  const AssignTeamMemberCard({super.key});
  @override
  State<AssignTeamMemberCard> createState() => _AssignTeamMemberCardState();
}

class _AssignTeamMemberCardState extends State<AssignTeamMemberCard> {
  final List<Agent> _agents = [];
  String? _selectedUuid;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse(
        'https://livingconnect.in/api/02e331e5-3746-41a1-a987-50f5eecd778f/agent-lists?token=pbYJx9mgrgQOYiw6YduNGkL5QwxITIvrJJCw2jmnI8VJOfDecIg1pHP3JuSOoDkG',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
      },
      body: json.encode({
        "page": _currentPage,
        "per_page": _perPage,
        "search": ""
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = (data['data']['users'] as List<dynamic>).cast<Map<String, dynamic>>();
      if (users.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          _agents.addAll(users.map((u) => Agent.fromJson(u)));
          _currentPage++;
        });
      }
    } else {
      debugPrint('Error fetching agents: ${response.statusCode}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> assignAgent(String agentUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token       = prefs.getString('token')       ?? '';
    final contactId   = prefs.getInt('ContactsId')     ?? 0;
    final uuidd       = prefs.getString('UUID')        ?? '';

    final resp = await http.post(
      Uri.parse(
        'https://livingconnect.in/api/$contactId/contact/chat/assign-user?token=$token',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
      },
      body: json.encode({
        "contactIdOrUid":     uuidd,
        "assigned_users_uid": agentUuid,
      }),
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (resp.statusCode == 200) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Agent assigned successfully!")),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text("Failed to assign agent.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_agents.isEmpty && _isLoading)
          const Center(child: CircularProgressIndicator())
        else
          NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 50 &&
                  !_isLoading &&
                  _hasMore) {
                fetchAgents();
              }
              return false;
            },
            child: DropdownButtonFormField<String>(
              value: _selectedUuid,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              hint: const Text('Select team member'),
              items: _agents
                  .map(
                    (agent) => DropdownMenuItem(
                  value: agent.uuid,
                  child: Text(agent.firstName +" "+ agent.lastName),
                ),
              )
                  .toList(),
              onChanged: (val) => setState(() => _selectedUuid = val),
            ),
          ),

        const SizedBox(height: 16),

        // **Save** button now calls your assignAgent(...)
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _selectedUuid == null
                ? null
                : () => assignAgent(_selectedUuid!),
            child: const Text('Save'),
          ),
        ),

        // show a small loader when loading more pages
        if (_isLoading && _agents.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}





class NotesCard extends StatefulWidget {
  const NotesCard({super.key});
  @override
  State<NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<NotesCard> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: 'Vvvvb');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _updateNotes() async {


    final prefs = await SharedPreferences.getInstance();
    final token       = prefs.getString('token')       ?? '';
    final contactId   = prefs.getInt('ContactsId')     ?? 0;
    final uuidd       = prefs.getString('UUID')        ?? '';
    final vendoruid   = prefs.getString('vendorid');
    String url = 'https://livingconnect.in/api/$vendoruid/contact/chat/update-notes?token=$token';

    final body = json.encode({
        "contactIdOrUid": uuidd,
      "contact_notes": _ctrl.text
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-requested-with': 'XMLHttpRequest',
        'x-external-api-request': 'true',
        // You can optionally include the cookie if needed:
        // 'Cookie': 'PHPSESSID=...; waba_panel_session=...',
      },
      body: body,
    );

    final messenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Notes assigned successfully!")),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text("Failed to assign agent.")),
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
    return Column(
      children: [
        TextField(
          controller: _ctrl,
          maxLines: 6,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Enter notes here',
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: _updateNotes,
            child: const Text('Save & Close'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => _logout(context),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

// 1) Simple Tag model with color info
class Tag {
  final String name;
  final Color bgColor;
  final Color textColor;
  Tag({
    required this.name,
    required this.bgColor,
    required this.textColor,
  });
}

// 2) The LabelsTagsCard widget





/// 1) Label model matching your JSON
class Label {
  final int    id;        // <- add this
  final String uuid;
  final String title;
  final Color  bgColor;
  final Color  textColor;

  Label({
    required this.id,
    required this.uuid,
    required this.title,
    required this.bgColor,
    required this.textColor,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id:        json['_id']      as int,      // <- read the integer id
      uuid:      json['_uid']     as String,
      title:     json['title']    as String,
      bgColor:   _hexToColor(json['bg_color']   as String),
      textColor: _hexToColor(json['text_color'] as String),
    );
  }
  static Color _hexToColor(String hex) {
    // Remove “#”, prepend FF for full opacity
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

}


/// 2) The multi-select dropdown widget




class LabelsTagsCard extends StatefulWidget {
  const LabelsTagsCard({super.key});
  @override
  State<LabelsTagsCard> createState() => _LabelsTagsCardState();
}

class _LabelsTagsCardState extends State<LabelsTagsCard> {
  List<Label>   _allLabels     = [];
  List<String>  _selectedUuids = [];
  bool          _loading       = true;

  @override
  void initState() {
    super.initState();
    _fetchLabels();
  }

  Future<void> _fetchLabels() async {
    setState(() => _loading = true);

    final prefs      = await SharedPreferences.getInstance();
    final token      = prefs.getString('token')     ?? '';
    final vendorUuid = prefs.getString('vendorid')  ?? '';
    final storedTags = prefs.getStringList('tags')  ?? [];

    final uri = Uri.parse(
        'https://livingconnect.in/api/$vendorUuid/contact/get-labels?token=$token'
    );
    final resp = await http.post(
      uri,
      headers: {
        'Accept':                'application/json',
        'Content-Type':          'application/json',
        'x-requested-with':      'XMLHttpRequest',
        'x-external-api-request':'true',
      },
      body: '',
    );

    if (resp.statusCode == 200) {
      final body    = json.decode(resp.body) as Map<String, dynamic>;
      final rawList = (body['data']['listOfAllLabels'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final allLabels = rawList.map(Label.fromJson).toList();
      // pre-select tags that match either uuid or id
      final initial   = <String>[];
      for (var label in allLabels) {
        if (storedTags.contains(label.uuid) ||
            storedTags.contains(label.id.toString())) {
          initial.add(label.uuid);
        }
      }

      setState(() {
        _allLabels     = allLabels;
        _selectedUuids = initial;
        _loading       = false;
      });
    } else {
      setState(() => _loading = false);
      // handle error if you want
    }
  }

  Future<void> _updateLabels() async {
    setState(() => _loading = true);

    final prefs      = await SharedPreferences.getInstance();
    final token      = prefs.getString('token')     ?? '';
    final vendorUuid = prefs.getString('vendorid')  ?? '';
    final contactUid = prefs.getString('UUID')      ?? '';

    // convert uuids back to integer IDs
    final selectedIds = _allLabels
        .where((lbl) => _selectedUuids.contains(lbl.uuid))
        .map((lbl) => lbl.id)
        .toList();

    final uri = Uri.parse(
      'https://livingconnect.in/api/'
          '$vendorUuid/contact/chat/assign-labels?token=$token',
    );
    final resp = await http.post(
      uri,
      headers: {
        'Accept':                'application/json',
        'Content-Type':          'application/json',
        'x-requested-with':      'XMLHttpRequest',
        'x-external-api-request':'true',
      },
      body: json.encode({
        'contactUid'    : contactUid,
        'contact_labels': selectedIds,
      }),
    );

    // persist for next time
    if (resp.statusCode == 200) {
      await prefs.setStringList('tags', _selectedUuids);
      final body = json.decode(resp.body);
      final msg  = body['data']?['message'] ?? 'Labels updated';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          SnackBar(content: Text('Failed: ${resp.statusCode}'))
      );
    }

    setState(() => _loading = false);
  }

  Future<void> _pickLabels() async {
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (_) {
        var temp = List<String>.from(_selectedUuids);
        return StatefulBuilder(
          builder: (c, setD) => AlertDialog(
            title: const Text('Select Labels'),
            content: SingleChildScrollView(
              child: Column(
                children: _allLabels.map((label) {
                  final isSel = temp.contains(label.uuid);
                  return CheckboxListTile(
                    value: isSel,
                    secondary: Chip(
                      backgroundColor: label.bgColor,
                      label: Text(label.title,
                          style: TextStyle(color: label.textColor)),
                    ),

                    onChanged: (v) {
                      setD(() {
                        if (v == true) temp.add(label.uuid);
                        else temp.remove(label.uuid);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('CANCEL')),
              TextButton(
                  onPressed: () => Navigator.pop(context, temp),
                  child: const Text('OK')),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedUuids = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // show spinner while loading
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // once loaded, always show the chip row
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickLabels,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _selectedUuids.isEmpty
                      ? const Text('Select tags…')
                      : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedUuids.map((uuid) {
                      final lbl = _allLabels
                          .firstWhere((l) => l.uuid == uuid);
                      return Chip(
                        backgroundColor: lbl.bgColor,
                        label: Text(lbl.title,
                            style: TextStyle(color: lbl.textColor)),
                      );
                    }).toList(),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _selectedUuids.isEmpty ? null : _updateLabels,
            child: const Text('Update'),
          ),
        ),


      ],
    );
  }

}





