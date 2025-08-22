  import 'dart:async';
  import 'dart:io';
  import 'package:dio/dio.dart';
  import 'package:flutter/services.dart';
  
  import 'package:permission_handler/permission_handler.dart';
  import 'package:open_file/open_file.dart';
  
  import 'dart:io';
  
  import 'package:dio/dio.dart';
  import 'package:flutter/material.dart';
  import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
  import 'package:http_parser/http_parser.dart';
  import 'package:intl/intl.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:path_provider/path_provider.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:io';
  import 'package:file_picker/file_picker.dart';
  import 'package:http/http.dart' as http;
  import 'package:path/path.dart' as path;
import 'package:untitled4/choosetosend.dart';
import 'package:untitled4/requestfeedback.dart';
import 'package:untitled4/sendpaymentscreen.dart';
  import 'package:untitled4/user.dart';
  import 'package:video_thumbnail/video_thumbnail.dart';
  import 'package:web_socket_channel/web_socket_channel.dart';
  import 'package:mime/mime.dart';
  
  import 'agreement.dart';
import 'apiservice.dart';
  import 'appointment.dart';
import 'assignchat.dart';
  import 'assignchat2.dart';
import 'invoice.dart';
import 'location.dart';
  /*void main() => runApp(MyApp());
  
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WhatsAppChatScreen(lastMessageTime: null,),
      );
    }
  }*/
  List<Message> _messages=[];
  enum MessageStatus {
    uploading,
    sent,
    delivered,
    seen,
  }
  enum MessageDownloadStatus { idle, downloading, downloaded }
  enum MessageType {
    text,
    contact,
    image,
    video,
    document,
  }
  class Message {
    final String text;
    final bool isSender;
    final DateTime timestamp;
    final MessageStatus status;
    final List<MediaFilee>? mediaValues;
    late final String? emojiReaction;
    final double? uploadProgress;

    double? downloadProgress;
    MessageDownloadStatus? downloadStatus;
    final MessageType messageType;
    Message({
      required this.text,
      required this.isSender,
      required this.timestamp,
      required this.status,
      this.mediaValues,
      this.emojiReaction,
      this.uploadProgress,
      this.messageType = MessageType.text,
    });



    factory Message.fromJson(Map<String, dynamic> json) {
      final isIncoming = json['IsIncomingMessage'] == 1;
      final rawTime = json['CreatedAt'];
      DateTime timestamp;

      try {
        timestamp = DateFormat("yyyy-MM-dd hh:mm a").parse(rawTime);
      } catch (_) {
        timestamp = DateTime.now(); // fallback in case of parse error
      }

      List<MediaFilee> media = [];
      final data = json["Data"];
      if (data != null && data['media_values'] != null && data['media_values'] is Map) {
        final m = data['media_values'];
        media.add(MediaFilee(
          url: m['link'] ?? '',
          type: m['type'] ?? '',
          name: m['name'] ?? '',
        ));
      }

      // 🔍 Auto-detect if the message is a contact type
      MessageType type = MessageType.text;
      try {
        final decoded = jsonDecode(json['Message'] ?? '');
        if (decoded is Map &&
            decoded.containsKey('phone') &&
            decoded.containsKey('name')) {
          type = MessageType.contact;
        }
      } catch (_) {
        // not a JSON message, ignore
      }

      return Message(
        text: json['Message'] ?? '',
        isSender: !isIncoming,
        timestamp: timestamp,
        status: parseStatus(json["Status"]),
        mediaValues: media,
        messageType: type, // ✅ now it's correct
      );
    }

  }
  MessageStatus parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'read':
        return MessageStatus.seen;
      case 'delivered':
        return MessageStatus.delivered;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }





  class WhatsAppChatScreen extends StatefulWidget {
    final DateTime lastMessageTime;
  
    const WhatsAppChatScreen({Key? key, required this.lastMessageTime}) : super(key: key);
  
  
    @override
    _WhatsAppChatScreenState createState() => _WhatsAppChatScreenState();
  }
  
  class _WhatsAppChatScreenState extends State<WhatsAppChatScreen> with WidgetsBindingObserver {
    List<Message> messages = [];
    final TextEditingController _controller = TextEditingController();
    final FocusNode _focusNode = FocusNode();
    bool showEmojiPicker = false;
    bool showBottomMenu = false;
    int? selectedMessageIndex;
    final ScrollController _scrollController = ScrollController();
    WebSocketChannel? _channel;
    Timer? _pollingTimer;
    bool _isWebSocketConnected = false;

    String? _uploadResult;
    Map<String, double> _downloadProgress = {};
    Map<String, bool> _downloadCompleted = {};
    String mobile="";
    final TextEditingController _searchController = TextEditingController();
    bool isSearchMode = false;
    List<Message> _allMessages = [];
    List<Message> _displayedMessages = [];
    DateTime? lastMessageTime;
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
      loadMessagesFromApi();
      _initializeWebSocket();
  
    }
    void _initializeWebSocket() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final vendorid = prefs.getString('vendorid') ?? '';
      final contactId = prefs.getInt('ContactsId') ?? '';
       mobile = prefs.getString('Mobile') ?? '';
  
      try {
        _channel = WebSocketChannel.connect(
          Uri.parse('wss://livingconnect.in/ws/$vendorid/contact?token=$token&contact=$contactId'),
        );
  
        _channel!.stream.listen(
              (data) async {
  
            final msg = parseMessage(data); // Parse and create Message object
            setState(() {
              messages.add(msg);
  
              lastMessageTime = DateTime.now();
            });
           // _scrollToBottom();
  
            _isWebSocketConnected = true;
          },
          onError: (error) {
            print("WebSocket error: $error");
            _fallbackToPolling();
          },
          onDone: () {
            print("WebSocket closed.");
            _fallbackToPolling();
          },
        );
      } catch (e) {
        print("WebSocket connection failed: $e");
        _fallbackToPolling();
      }
    }
    void _fallbackToPolling() {
      if (_isWebSocketConnected) return;
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        loadMessagesFromApi();
      });
    }
    Message parseMessage(dynamic data) {
      final decoded = jsonDecode(data);
  
      return Message(
        text: decoded['text'],
        isSender: decoded['isSender'],
        timestamp: DateTime.parse(decoded['timestamp']),
        status: MessageStatus.values.firstWhere(
              (e) => e.toString().split('.').last == decoded['status'],
          orElse: () => MessageStatus.sent,
        ),
      );
    }
  
    void _scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    String? lastNotifiedMessageId;
    int _currentPage = 1; // track current page
    final int _perPage = 50; // your per_page limit
    bool _isLoadingEarlierMessages = false; // prevent multiple triggers

    Future<void> loadMessagesFromApi() async {
      try {
        final apiMessages = await fetchMessages(page: 1);

        if (!mounted) return; // ⛔️ Prevent setState on unmounted widget

        setState(() {
          if (_currentPage == 1) {
            _allMessages = apiMessages;
          } else {
            final existingIds =
            _allMessages.map((m) => m.timestamp.toIso8601String()).toSet();
            final newMessages = apiMessages
                .where((m) => !existingIds.contains(m.timestamp.toIso8601String()))
                .toList();
            _allMessages.addAll(newMessages);
          }
          _applySearchFilter(_searchController.text);
        });
      } catch (e) {
        print('Error fetching messages: $e');
      }
    }

    Future<void> _sendInvoice() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => SendInvoiceScreen()));


    }
    Future<void> _portfolio() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => ChooseToSendScreen()));


    }
    Future<void> _sendrequestfeedback() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => RequestFeedbackScreen()));


    }
    Future<void> _sendpayment() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => SendPaymentLinkScreen()));


    }
    Future<void> _secheduleappointment() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleAppointmentScreen()));


    }
    Future<void> _sendLocation() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => SelectLocationScreen()));


    }
    Future<void> _sendAgreement() async {

      Navigator.push(context, MaterialPageRoute(builder: (_) => SendAgreementScreen()));


    }
    Future<void> _pickAndUploadFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
  
      if (result != null) {
        PlatformFile file = result.files.first;
  
        if (file.bytes == null) {
          setState(() {
            _uploadResult = 'Failed to get file bytes.';
          });
          return;
        }
  
        String mediaType = _getMediaType(file.name); // 'image', 'video', 'document'
  
        // Step 1: Create and insert "uploading" message
        Message uploadingMessage = Message(
          text: '',
          isSender: true,
          timestamp: DateTime.now(),
          status: MessageStatus.uploading,
          mediaValues: [
            MediaFilee(url: '', name: file.name, type: mediaType),
          ],
        );
  
        setState(() {
          _allMessages.insert(0, uploadingMessage);
          _applySearchFilter(_searchController.text); // Show immediately
        });
  
        // Step 2: Upload the file to the server
        String? uploadedUrl = await _uploadFileToServer(file);
  
        if (uploadedUrl != null) {
          // Step 3: Replace the "uploading" message with final message
          Message finalMessage = Message(
            text: '',
            isSender: true,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
            mediaValues: [
              MediaFilee(url: uploadedUrl, name: file.name, type: mediaType),
            ],
          );
  
          setState(() {
            int index = _messages.indexOf(uploadingMessage);
            if (index != -1) {
              _messages[index] = finalMessage;
            }
          });
          _applySearchFilter(_searchController.text);
          // Step 4: Optionally send media message to backend (API)
          await _sendMediaMessage(file, uploadedUrl);
        } else {
          setState(() {
            int index = _messages.indexOf(uploadingMessage);
            if (index != -1) {
              _messages.removeAt(index);
            }
            _uploadResult = 'Upload failed';
            _applySearchFilter(_searchController.text);
          });
        }
      } else {
        setState(() {
          _uploadResult = 'User cancelled file picking.';
        });
      }
    }
  
  
    Future<void> _sendMediaMessage(PlatformFile file, String uploadedUrl) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        final vendorId = prefs.getString('vendorid') ?? '';
        final mobile = int.parse(prefs.getString('Mobile') ?? '0');
  
        if (token.isEmpty || vendorId.isEmpty || uploadedUrl.isEmpty) {
          print("❌ Missing data to send media message.");
          return;
        }
  
        // Determine media type
        String extension = file.extension?.toLowerCase() ?? '';
        String mediaType = (['jpg', 'jpeg', 'png', 'gif'].contains(extension))
            ? 'image'
            : (['mp4', 'mov', 'avi'].contains(extension))
            ? 'video'
            : 'document';
  
        final url = Uri.parse(
          'https://livingconnect.in/api/$vendorId/contact/send-media-message?token=$token',
        );
  
        final body = jsonEncode({
          "phone_number": mobile,
          "media_type": mediaType,
          "media_url": uploadedUrl,
        });
  
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
  
        if (response.statusCode == 200) {
          print("✅ Media message sent successfully.");
        } else {
          print("❌ Failed to send media: ${response.body}");
        }
      } catch (e) {
        print("❌ Error sending media message: $e");
      }
    }
  
    String _getMediaType(String fileName) {
      final ext = fileName.toLowerCase();
  
      if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.gif')) {
        return 'whatsapp_image';
      } else if (ext.endsWith('.mp4') || ext.endsWith('.avi') || ext.endsWith('.mov')) {
        return 'whatsapp_video';
      } else if (ext.endsWith('.mp3') || ext.endsWith('.aac') || ext.endsWith('.wav') || ext.endsWith('.m4a')) {
        return 'whatsapp_audio';
      } else {
        return 'whatsapp_document';
      }
    }
  
    /*Future<String?> _uploadFileToServer(PlatformFile file) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final vendorId = prefs.getString('vendorid') ?? '';
      final mediaType = _getMediaType(file.name);
  
      final uri = Uri.parse(
        'https://livingconnect.in/api/$vendorId/upload-temp-media/$mediaType?token=$token',
      );
  
      try {
        final request = http.MultipartRequest('POST', uri)
          ..fields['media_type'] = mediaType
          ..files.add(
            http.MultipartFile.fromBytes(
              'filepond',
              file.bytes!,
              filename: file.name,
              contentType: _getContentType(file.name),
            ),
          );
  
        final streamedResponse = await request.send();
        final responseText = await streamedResponse.stream.bytesToString();
  
        if (streamedResponse.statusCode == 200) {
  
          final json = jsonDecode(responseText);
          return json['data']['path'];
  
        } else {
          print('❌ Upload failed: ${streamedResponse.statusCode}');
          print('Response: $responseText');
          return null;
        }
      } catch (e) {
        print('❌ Exception during upload: $e');
        return null;
      }
    }*/
    Future<String?> _uploadFileToServer(PlatformFile file) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final vendorId = prefs.getString('vendorid') ?? '';
      final contactUid = prefs.getString('UUID') ?? '1bc55cc9-8aac-4f82-ac02-ee12bab93d18';
      final mediaType = _getMediaType(file.name);

      final uri = Uri.parse(
        'https://livingconnect.in/api/$vendorId/upload-temp-media/$mediaType?token=$token',
      );

      try {
        final request = http.MultipartRequest('POST', uri)
          ..fields['media_type'] = mediaType
          ..fields['contact_uid'] = contactUid
          ..fields['uploaded_media_file_name'] = ''
          ..files.add(
            http.MultipartFile.fromBytes(
              'filepond',
              file.bytes!,
              filename: file.name,
              contentType: _getContentType(file.name), // e.g., MediaType('image', 'jpeg')
            ),
          );

        // Send cookies like in curl
        request.headers['Cookie'] =
        'PHPSESSID=b1tpb3irsbjgc9u1ac3bsfvg35; waba_panel_session=GdGgeBecEJPX0mtuG5kibSOBchj8mq0G0RmLwf2N';

        final streamedResponse = await request.send();
        final responseText = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 200) {
          final json = jsonDecode(responseText);
          final logs = json['client_models']['whatsappMessageLogs'] as Map<String, dynamic>;
          final firstLog = logs.values.first; // If only one log
          final link = firstLog['__data']['media_values']['link'];




          return link;
        } else {
          print('❌ Upload failed: ${streamedResponse.statusCode}');
          print('Response: $responseText');
          return null;
        }
      } catch (e) {
        print('❌ Exception during upload: $e');
        return null;
      }
    }
    MediaType _getContentType(String fileName) {
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
  
  
  
  
  
    Future<bool> requestStoragePermissionWithDialog(BuildContext context) async {
      var status = await Permission.storage.status;
  
      if (status.isGranted) {
        return true;
      }
  
      if (status.isDenied) {
        // Show dialog explaining why permission is needed
        bool userAgreed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Storage Permission Required'),
            content: Text(
                'This app needs access to your storage to select and upload files. Please grant permission.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Allow'),
              ),
            ],
          ),
        ) ?? false;
  
        if (!userAgreed) {
          return false;
        }
  
        status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        }
      }
  
      if (status.isPermanentlyDenied) {
        // Permission permanently denied, open app settings
        bool openSettings = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Permanently Denied'),
            content: Text(
                'Storage permission was permanently denied. Please enable it manually from app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Open Settings'),
              ),
            ],
          ),
        ) ?? false;
  
        if (openSettings) {
          await openAppSettings();
        }
        return false;
      }
  
      return false;
    }
  
  
  
  
  
  
    Future<String?> _uploadMediaFileToLivingConnect(
        PlatformFile file, String vendorId, String token) async {
      final uri = Uri.parse(
        'https://livingconnect.in/api/$vendorId/upload-temp-media/whatsapp_image?token=$token',
      );
  
      final request = http.MultipartRequest('POST', uri)
        ..fields['media_type'] = 'whatsapp_image'
        ..headers['Accept'] = 'application/json';
  
      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg'; // Default fallback
      if (file.extension != null) {
        final ext = file.extension!.toLowerCase();
        if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          mimeType = 'image/jpeg';
        }
      }
  
      try {
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'filepond',
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'filepond',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          print("❌ No file bytes or path found");
          return null;
        }
  
        final streamedResponse = await request.send();
        final responseText = await streamedResponse.stream.bytesToString();
  
        if (streamedResponse.statusCode == 200) {
          final jsonResponse = jsonDecode(responseText);
          return jsonResponse['media_url'] ?? jsonResponse['url'];
        } else {
          print("❌ Upload failed: ${streamedResponse.statusCode}");
          print("Response body: $responseText");
          return null;
        }
      } catch (e) {
        print("❌ Exception: $e");
        return null;
      }
    }
    void _startSearch() {
      setState(() {
        isSearchMode = true;
      });
      // When entering search, focus on the search field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  
  
  
    // Function to pick a file (image/document)
    Future<void> loadEarlierMessages() async {
      if (_isLoadingEarlierMessages) return;
      _isLoadingEarlierMessages = true;
  
      try {
        final newPage = _currentPage + 1; // calculate next page
        final earlierMessages = await fetchMessages(page: newPage); // fetch that page
  
        if (earlierMessages.isNotEmpty) {
          setState(() {
            _currentPage = newPage; // update page number
            _allMessages.insertAll(0, earlierMessages); // insert at top
            _applySearchFilter(_searchController.text);
          });
        }
      } catch (e) {
        print('Error loading earlier messages: $e');
      } finally {
        setState(() {
          _isLoadingEarlierMessages = false;
        });
      }
    }
  
  
  
    Future<List<Message>> fetchMessages({int page = 1}) async {
      final prefs = await SharedPreferences.  getInstance();
      final token = prefs.getString('token') ?? '';
      final vendorid = prefs.getString('vendorid') ?? '';
      final contact = prefs.getInt('ContactsId') ?? '';
  
      final url = Uri.parse(
        'https://livingconnect.in/api/$vendorid/$contact/get-chat?token=$token',
      );
  
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-requested-with': 'XMLHttpRequest',
          'x-external-api-request': 'true',
        },
        body: jsonEncode({"page": page, "per_page": 50, "search": ""}),
      );
  
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['data']['users'] as List).cast<Map<String, dynamic>>();
  
        final rawTags = users.first['Tags'] as String? ?? '';
        final tagsList = rawTags
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        await prefs.setStringList('tags', tagsList);
  
        List<Message> messages = users.map((user) => Message.fromJson(user)).toList();
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  
        return messages;
      } else {
        throw Exception('Failed to fetch messages');
      }
    }


    Future<void> _sendMessage({String? contactJson}) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final vendorid = prefs.getString('vendorid') ?? '';
      final contact = prefs.getInt('ContactsId') ?? '';
      final mobile = int.parse(prefs.getString('Mobile')!);

      final text = contactJson ?? _controller.text.trim();
      if (text.isEmpty) return;

      setState(() {
        _allMessages.add(
          Message(
            text: text,
            isSender: true,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
            messageType: contactJson != null ? MessageType.contact : MessageType.text,

          ),
        );
        _applySearchFilter(_searchController.text);
        _controller.clear();
      });

      try {
        final url = Uri.parse(
          'https://livingconnect.in/api/$vendorid/contact/send-message?token=$token',
        );

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "phone_number": mobile,
            "message_body": text,
          }),
        );

        if (response.statusCode == 200) {
          print("Message sent successfully: ${response.body}");
          await loadMessagesFromApi();
        } else {
          print("Failed to send message: ${response.body}");
        }
      } catch (e) {
        print("Error sending message: $e");
      }
    }

    /* Future<void> _sendMessage() async {
      final text = _controller.text.trim();
      if (text.isEmpty) return;
  
      setState(() {
        _allMessages.add(Message(
          text: text,
          isSender: true,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
  
        ));
        _applySearchFilter(_searchController.text);
        _controller.clear();
      });
      //_scrollToBottom();
  
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        final vendorid = prefs.getString('vendorid') ?? '';
        final contact = prefs.getInt('ContactsId') ?? '';
        final mobile = int.parse(prefs.getString('Mobile')!);
        final url = Uri.parse(
          'https://livingconnect.in/api/$vendorid/contact/send-message?token=$token',
        );
  
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "phone_number": mobile,
            "message_body": text,
          }),
        );
  
        if (response.statusCode == 200) {
         print((response.body));
          await loadMessagesFromApi();
        } else {
          print("Failed to send message: ${response.body}");
        }
      } catch (e) {
        print("Error sending message: $e");
      }
    }*/
    bool sendEnabled = true;
    void _checkIfSendAllowed() {
      final currentTime = DateTime.now();
      final difference = currentTime.difference(widget.lastMessageTime);
      if (difference.inHours >= 24) {
        setState(() {
          sendEnabled = false;
        });
      }
    }
    Map<String, List<Message>> groupMessagesByDate(List<Message> messages) {
      Map<String, List<Message>> grouped = {};
  
      for (var msg in messages) {
        final dateKey = formatDateHeader(msg.timestamp);
        grouped.putIfAbsent(dateKey, () => []).add(msg);
      }
  
      return grouped;
    }
  
    String formatDateHeader(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);
      final difference = today.difference(messageDate).inDays;
  
      if (difference == 0) return "Today";
      if (difference == 1) return "Yesterday";
      return DateFormat('MMM d').format(date);
    }
  
    void _insertEmoji(String emoji) {
      _controller.text += emoji;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
  
    MessageStatus parseStatus(String status) {
      switch (status.toLowerCase()) {
        case 'read':
          return MessageStatus.seen;
        case 'received':
          return MessageStatus.delivered;
        default:
          return MessageStatus.sent;
      }
    }
  
  
    List<int> selectedMessageIndices = [];
    bool isSelectionMode = false;
    void _forwardSelectedMessages() async {
      final bool isForwarding;
      final selectedMessages =
      selectedMessageIndices.map((i) => _displayedMessages[i]).toList();
  
      final forwardedUser = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(isForwarding: true)),
      );
  
  
  
      if (forwardedUser != null && forwardedUser is User) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        final vendorId = prefs.getString('vendorid') ?? '';
        final phoneNumber = forwardedUser.mobileno;
  
        for (final msg in selectedMessages) {
          try {
            if (msg.mediaValues == null || msg.mediaValues!.isEmpty) {
              // Forward text message
              if (msg.text.isNotEmpty) {
                final textUrl = Uri.parse(
                    'https://livingconnect.in/api/$vendorId/contact/send-message?token=$token');
  
                final body = {
                  "phone_number": phoneNumber,
                  "message_body": msg.text,
                };
  
                final response = await http.post(
                  textUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body),
                );
  
                print('✅ Forwarded text: ${response.statusCode}');
                print(response.body);
              }
            } else {
              // Forward media
              final media = msg.mediaValues!.first;
              final tempDir = await getTemporaryDirectory();
              final tempFilePath = '${tempDir.path}/${extractFileName(media.url)}';
              final file = File(tempFilePath);
  
              // Download the media
              final downloadResponse = await Dio().download(media.url, tempFilePath);
              print('Downloaded file: ${downloadResponse.statusCode}');
  
              if (downloadResponse.statusCode == 200) {
                final fileBytes = await file.readAsBytes();
  
                // Determine proper media_type for upload
                String uploadType = 'whatsapp_document';
                if (media.type.contains('image')) {
                  uploadType = 'whatsapp_image';
                } else if (media.type.contains('video')) {
                  uploadType = 'whatsapp_video';
                }
  
                final uploadUri = Uri.parse(
                    'https://livingconnect.in/api/$vendorId/upload-temp-media/$uploadType?token=$token');
  
                final request = http.MultipartRequest('POST', uploadUri)
                  ..fields['media_type'] = uploadType
                  ..files.add(
                    http.MultipartFile.fromBytes(
                      'filepond',
                      fileBytes,
                      filename: extractFileName(media.url),
                      contentType: _getContentType(extractFileName(media.url)),
                    ),
                  );
  
                final streamedResponse = await request.send();
                final responseText = await streamedResponse.stream.bytesToString();
  
                print('Upload response: $responseText');
  
                if (streamedResponse.statusCode == 200) {
                  final json = jsonDecode(responseText);
                  final uploadedUrl = json['data']['path'];
  
                  final mediaUrl = Uri.parse(
                      'https://livingconnect.in/api/$vendorId/contact/send-media-message?token=$token');
                  String extension = (extractFileName(media.url).split('.').last).toLowerCase();
                  String mediaType = (['jpg', 'jpeg', 'png', 'gif'].contains(extension))
                      ? 'image'
                      : (['mp4', 'mov', 'avi'].contains(extension))
                      ? 'video'
                      : 'document';
                  final mediaBody = jsonEncode({
                    "phone_number": int.parse(phoneNumber),
                    "media_type": mediaType,
                    "media_url": uploadedUrl,
                  });
  
                  final forwardResponse = await http.post(
                    mediaUrl,
                    headers: {'Content-Type': 'application/json'},
                    body: mediaBody,
                  );
  
                  print('Forwarded media: ${forwardResponse.statusCode}');
                  print(forwardResponse.body);
                }
              }
            }
          } catch (e) {
            print('❌ Error forwarding message: $e');
          }
        }
  
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Messages forwarded to ${forwardedUser.name}')),
        );
      }
  
      if (!mounted) return;
      setState(() {
        isSelectionMode = false;
        selectedMessageIndices.clear();
      });
    }
  
  
  
  
  
  /*  Widget _buildMessageBubble(Message message, int index) {
      return GestureDetector(
        onLongPress: () {
          // Handle long-press if needed (e.g., emoji reaction)
        },
        child: Align(
          alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: message.isSender ? Color(0xDCd0fecf) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: message.isSender ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: message.isSender ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.emojiReaction != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        message.emojiReaction!,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
  
                  if (message.mediaValues != null && message.mediaValues!.isNotEmpty)
                    ...message.mediaValues!.map((media) {
                      if (media.type == 'video') {
                        return _buildVideoMessage(media, message,index); // Pass full message
                      } else if (media.type == 'image') {
                        return _buildImageMessage(media, message);
                      } else {
                        return _buildDocumentMessage(media, message);
                      }
                      return SizedBox.shrink();
                    }).toList(),
  
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(fontSize: 16),
                    ),
  
                  if (message.status == MessageStatus.uploading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Uploading...',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ),
  
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (message.isSender) ...[
                        SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.sent
                              ? Icons.done
                              : message.status == MessageStatus.delivered
                              ? Icons.done_all
                              : Icons.done_all,
                          size: 18,
                          color: message.status == MessageStatus.seen ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }*/

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

    /// Show contact picker like WhatsApp and return selected contact to previous screen
    void _shareContact() async {
      final contactJson = await showContactPicker(context);

      if (contactJson != null) {
        await _sendMessage(contactJson: contactJson);
      }
    }


    /// Show contact picker like WhatsApp and return selected contact to previous screen


    Widget _buildMessageBubble(Message message, int index) {
      final isSelected = selectedMessageIndices.contains(index);
      if (message.messageType == MessageType.contact) {
        final contact = jsonDecode(message.text);

        return Align(
          alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📇 Shared Contact", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("Name: ${contact['name']}", style: const TextStyle(fontSize: 16)),
                Text("Phone: ${contact['phone']}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text("Call"),
                  onPressed: () async {
                    final number = contact['phone'];
                    if (number != null) {
                      final uri = Uri.parse("tel:$number");

                    }
                  },
                )
              ],
            ),
          ),
        );
      }




      // ✅ Safely update lastMessageTime with latest message timestamp
      if (message.timestamp != null) {
        if (lastMessageTime == null || message.timestamp.isAfter(lastMessageTime!)) {
          lastMessageTime = message.timestamp;
          if (!message.isSender) {
            _updateSendButtonStatus(message.timestamp);
          } // 🔁 Update UI if recent message arrived
        }
      }



      return GestureDetector(
        onLongPress: () {
          setState(() {
            isSelectionMode = true;
            if (!isSelected) {
              selectedMessageIndices.add(index);
            }
          });
        },
        onTap: () {
          if (isSelectionMode) {
            setState(() {
              if (isSelected) {
                selectedMessageIndices.remove(index);
                if (selectedMessageIndices.isEmpty) {
                  isSelectionMode = false;
                }
              } else {
                selectedMessageIndices.add(index);
              }
            });
          }
        },
        child: Align(
          alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.teal.withOpacity(0.3)
                    : message.isSender
                    ? const Color(0xDCd0fecf)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: message.isSender ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: message.isSender ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.emojiReaction != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        message.emojiReaction!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                  if (message.mediaValues != null && message.mediaValues!.isNotEmpty)
                    ...message.mediaValues!.map((media) {
                      if (media.type == 'video') {
                        return _buildVideoMessage(media, message, index);
                      } else if (media.type == 'image') {
                        return _buildImageMessage(media, message);
                      } else {
                        return _buildDocumentMessage(media, message);
                      }
                    }).toList(),

                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: const TextStyle(fontSize: 16),
                    ),

                  if (message.status == MessageStatus.uploading)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Uploading...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (message.isSender) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.sent
                              ? Icons.done
                              : message.status == MessageStatus.delivered
                              ? Icons.done_all
                              : Icons.done_all,
                          size: 18,
                          color: message.status == MessageStatus.seen
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

     showQuickMessagePopup(BuildContext context, List<String> messages) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.white,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text("Quick Messages", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(messages[index]),
                        onTap: () {
                          Navigator.pop(context); // Close popup
                          _controller.text=messages[index]; // Call callback
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _buildImageMessage(MediaFilee media,Message message) {
      return GestureDetector(
        onTap: () => downloadFile(media.url, media.name),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      media.url,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_downloadProgress.containsKey(media.url))
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: _downloadProgress[media.url],
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                extractFileName(media.url),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }
    Future<Uint8List?> _generateThumbnail(String videoUrl) async {
      try {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: videoUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 75,
        );
        return thumbnail;
      } catch (e) {
        print("Error generating thumbnail: $e");
        return null;
      }
    }
  
  
    Widget _buildVideoMessage(MediaFilee media, Message message,int index) {
      return VideoMessageWidget(media: media, message: message, index: index);
  
  
    }
  
  
  
  
  
    Widget _buildDocumentMessage(MediaFilee media,Message message) {
      return GestureDetector(
        onTap: () => downloadFile(media.url, media.name),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extractFileName(media.url),
                      style: TextStyle(fontSize: 14),
                    ),
                    if (_downloadProgress.containsKey(media.url))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: LinearProgressIndicator(
                          value: _downloadProgress[media.url],
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  
  
  
    Future<String> getVideoThumbnail(String url) async {
      final thumb = await VideoThumbnail.thumbnailFile(
        video: url,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      return thumb ?? 'fallback.jpg';
    }
  
  
    String extractFileName(String url) {
      Uri uri = Uri.parse(url);
      // Remove trailing slashes
      String path = uri.path.endsWith('/') ? uri.path.substring(0, uri.path.length - 1) : uri.path;
      // Split and get the last segment
      List<String> segments = path.split('/');
      return segments.isNotEmpty ? segments.last : 'file';
    }
  
  
  
  
    Future<void> downloadFile(String url, String fileName) async {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;
  
      final dirPath = '${directory.path}/living';
      final dir = Directory(dirPath);
      if (!await dir.exists()) await dir.create(recursive: true);
  String fileName=extractFileName(url);
      final filePath = '$dirPath/$fileName';
      final file = File(filePath);
      if (await file.exists()) await file.delete();
  
      setState(() {
        _downloadProgress[url] = 0.0;
        _downloadCompleted[url] = false;
      });
  
      try {
        await Dio().download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _downloadProgress[url] = received / total;
              });
            }
          },
        );
  
        setState(() {
          _downloadCompleted[url] = true;
          _downloadProgress.remove(url);
        });
  
        // 👇 Open the file
        OpenFile.open(filePath);
      } catch (e) {
        print('Download failed: $e');
        setState(() {
          _downloadProgress.remove(url);
          _downloadCompleted[url] = false;
        });
      }
    }
  
  
  
  
  
  
  
  
    void _showEmojiPopup(int index) {
      showModalBottomSheet(
        context: context,
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var emoji in ["👍", "❤️", "😂", "😮", "😢", "👏"])
              IconButton(
                onPressed: () {
                  setState(() {
                    messages[index].emojiReaction = emoji;
                  });
                  Navigator.pop(context);
                },
                icon: Text(emoji, style: TextStyle(fontSize: 24)),
              )
          ],
        ),
      );
    }

    Widget _menuItem(String asset, String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }
  
    bool isSendAllowed() {
      if (lastMessageTime == null) return false;
      return DateTime.now().difference(lastMessageTime!).inHours < 24;
    }
  
  
    Widget _buildInputArea() {
      final sendAllowed = isSendAllowed();
  
      return SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined),
              onPressed: () {
                setState(() {
                  showEmojiPicker = !showEmojiPicker;
                  if (showEmojiPicker) FocusScope.of(context).unfocus();
                });
              },
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sendAllowed ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  enabled: sendAllowed,
                  decoration: InputDecoration(
                    hintText: sendAllowed
                        ? 'Type a message'
                        : 'Chat disabled after 24 hrs',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: sendAllowed
                  ? () => setState(() => showBottomMenu = !showBottomMenu)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.send),
              color: sendAllowed ? Colors.blue : Colors.grey,
              onPressed: sendAllowed ? _sendMessage : null,
            ),
          ],
        ),
      );
    }
  
    bool isSendEnabled = true;
    void _updateSendButtonStatus(DateTime messageTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final now = DateTime.now();
        final difference = now.difference(messageTime);
        final allowed = difference.inHours < 24;
        if (allowed != isSendEnabled) {
          setState(() {
            isSendEnabled = allowed;
          });
        }
      });
    }
  
  
  
    DateTime formatDateForSort(String label) {
      final now = DateTime.now();
      if (label == "Today") return DateTime(now.year, now.month, now.day);
      if (label == "Yesterday") return DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
      try {
        return DateFormat('MMM d').parse(label);
      } catch (_) {
        return DateTime(2000);
      }
    }
    void _stopSearch() {
      setState(() {
        isSearchMode = false;
        _searchController.clear();
        _applySearchFilter("");
        FocusScope.of(context).unfocus();
      });
    }
    List<String> quickMessageList = [];
    void _applySearchFilter(String query) {
      if (query.isEmpty) {
        _displayedMessages = List.from(_allMessages);
      } else {
        final lowerQuery = query.toLowerCase();
        _displayedMessages = _allMessages
            .where((msg) => msg.text.toLowerCase().contains(lowerQuery))
            .toList();
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: isSearchMode
              ? TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search chat...',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                _applySearchFilter(value);
              });
            },
          )
              : Row(
            children: [
              SizedBox(width: 10),
              Text(
                mobile,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContactDetailScreen()),
                  );
                },
                child: Icon(Icons.person, color: Colors.black),
              ),
            ],
          ),
          leading: isSearchMode
              ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _stopSearch,
          )
              : null,
          actions: [
            if (!isSelectionMode)
              IconButton(
                icon: Icon(
                  isSearchMode ? Icons.close : Icons.search,
                  color: Colors.black,
                ),
                onPressed: isSearchMode ? _stopSearch : _startSearch,
              ),
            if (isSelectionMode)
              IconButton(
                icon: Icon(Icons.forward, color: Colors.black),
                onPressed: _forwardSelectedMessages,
              ),
          ],
        ),
  
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/bc.png', // ✅ Your image asset
                fit: BoxFit.cover,
              ),
            ),
  
            // Foreground UI (chat area)
            Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final grouped = groupMessagesByDate(_displayedMessages);
                      final sortedKeys = grouped.keys.toList()
                        ..sort((a, b) => formatDateForSort(a).compareTo(formatDateForSort(b)));
  
                      final items = <Widget>[];
  
                      for (final key in sortedKeys) {
                        items.add(
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(key, style: TextStyle(color: Colors.black54)),
                            ),
                          ),
                        );
  
                        final dateMessages = grouped[key]!;
                        dateMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  
                        for (final msg in dateMessages) {
                          final idx = _displayedMessages.indexOf(msg);
                          items.add(_buildMessageBubble(msg, idx));
                        }
                      }
  
                      return ListView(
                          controller: _scrollController,
                          reverse: false,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          physics: const BouncingScrollPhysics(),
                        children: [
                          _isLoadingEarlierMessages
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : _buildLoadEarlierButton(),
                          ...items,
                        ],
  
                      );
                    },
                  ),
                ),
  
                _buildInputArea(),
  
                if (showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) => _insertEmoji(emoji.emoji),
                      config: Config(),
                    ),
                  ),
  
                if (showBottomMenu)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _menuItem('assets/images/paymentlink.png', "Payment", _sendpayment),
                        _menuItem('assets/images/potfolio.png', "Portfolio", _portfolio),
                        _menuItem('assets/images/agreement.png', "Agreement", _sendAgreement),

                        _menuItem('assets/images/potfolio.png', "Invoice", _sendInvoice),


                        _menuItem(
                          'assets/images/quickmsg.png',
                          "Quick Msgs",
                              () async {
                            final quickMessages = await fetchQuickMessages();
                            if (quickMessages != null && quickMessages.isNotEmpty) {
                              showQuickMessagePopup(
                                context,
                                quickMessages,

                              );
                            }
                          },
                        ),


                        _menuItem(
                          'assets/images/contact.png',
                          "Share Contact",
                              () => _shareContact(),
                        ),

                        _menuItem('assets/images/document.png', "Document", _pickAndUploadFile),
                        _menuItem('assets/images/review.png', "Review", _sendrequestfeedback),
                        _menuItem('assets/images/event.png', "Calendar", _secheduleappointment),
                        _menuItem('assets/images/event.png', "Location", _sendLocation),



                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }


    Future<List<String>> fetchQuickMessages() async {
      final response = await http.post(
        Uri.parse('https://livingconnect.in/api/02e331e5-3746-41a1-a987-50f5eecd778f/get-quick-meesage-list?token=pbYJx9mgrgQOYiw6YduNGkL5QwxITIvrJJCw2jmnI8VJOfDecIg1pHP3JuSOoDkG'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-requested-with': 'XMLHttpRequest',
          'x-external-api-request': 'true',
        },
        body: jsonEncode({
          "page": 1,
          "per_page": 20,
          "search": ""
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'];
        return data.map<String>((e) => e['Message'].toString()).toList();
      } else {
        throw Exception("Failed to load quick messages");
      }
    }

    Widget _buildLoadEarlierButton() {
      return InkWell(
        onTap: () async {
          await loadEarlierMessages();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            'Load Earlier Messages',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  
  /*  Widget _buildMessageBubble(Message message, int index) {
      final isSender = message.isSender;
  
      return Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isSender ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media content (image/documents)
              if (message.mediaValues!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: message.mediaValues!  .map((mediaItem) {
                    if (mediaItem.type == 'image') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => OpenFilex.open(mediaItem.url),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              mediaItem.url,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Document rendering
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => OpenFilex.open(mediaItem.url),
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file, size: 32, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mediaItem.url.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }).toList(),
                ),
  
              // Message text
              if (message.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.text,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
  
              // Timestamp and status (optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  if (isSender) _buildStatusIcon(message.status),
                ],
              ),
            ],
          ),
        ),
      );
    }*/
  
  }
  class MediaFilee {
    final String url;
    final String name;
    final String type; // "image", "video", "document"
  
    MediaFilee({
      required this.url,
      required this.name,
      required this.type,
    });
  }
  class VideoMessageWidget extends StatefulWidget {
    final MediaFilee media;
    final Message message;
    final int index;
  
    const VideoMessageWidget({
      Key? key,
      required this.media,
      required this.message,
      required this.index,
    }) : super(key: key);
  
    @override
    _VideoMessageWidgetState createState() => _VideoMessageWidgetState();
  }
  
  class _VideoMessageWidgetState extends State<VideoMessageWidget> {
    double downloadProgress = 0.0;
    bool isDownloading = false;
    String? thumbnailPath;
  
    @override
    void initState() {
      super.initState();
      _generateThumbnail();
    }
  
    Future<void> _generateThumbnail() async {
      if (widget.media.url.isEmpty) return;
      final thumb = await VideoThumbnail.thumbnailFile(
        video: widget.media.url,
        imageFormat: ImageFormat.PNG,
        maxWidth: 300,
        quality: 75,
      );
      setState(() {
        thumbnailPath = thumb;
      });
    }
  
    Future<void> _downloadAndPlay() async {
      if (widget.media.url.isEmpty || isDownloading) return;
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0;
      });
  
      try {
        final dir = await getApplicationDocumentsDirectory();
        final savePath = '${dir.path}/${extractFileName(widget.media.url)}';
        final file = File(savePath);
        if (await file.exists()) await file.delete();
  
        await Dio().download(widget.media.url, savePath, onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        });
  
        OpenFile.open(savePath);
  
        setState(() {
          isDownloading = false;
          downloadProgress = 0.0;
        });
  
      } catch (e) {
        setState(() {
          isDownloading = false;
          downloadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
    String extractFileName(String url) {
      Uri uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'file';
    }
    @override
    Widget build(BuildContext context) {
      final isUploading = widget.message.status == MessageStatus.uploading;
      final uploadProgress = widget.message.uploadProgress ?? 0.0;
  
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _downloadAndPlay,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.black12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (thumbnailPath != null)
                            Image.file(
                              File(thumbnailPath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          else
                            Image.network(
                              'https://via.placeholder.com/300x200.png?text=Video',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          const Icon(
                            Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
  
                  // Upload progress
                  if (isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: uploadProgress,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Uploading ${(uploadProgress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
  
                  // Download progress
                  if (isDownloading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: downloadProgress,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Downloading ${(downloadProgress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.media.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
  }
