import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class ChatScreen extends StatefulWidget {
  final String username;
  final String profile;

  const ChatScreen({super.key, required this.username, required this.profile});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  bool showEmojiPicker = false;

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        'text': text,
        'isMe': true,
        'type': 'text',
        'time': DateTime.now(),
        'status': 'sent'
      });
    });
    _controller.clear();
    _scrollToBottom();

    _simulateReply(); // Simulate incoming message
    _simulateSeen();  // Simulate 'seen' status
  }

  void _sendImage(File file) {
    setState(() {
      messages.add({
        'image': file,
        'isMe': true,
        'type': 'image',
        'time': DateTime.now(),
        'status': 'sent'
      });
    });
    _scrollToBottom();

    _simulateReply();
    _simulateSeen();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _sendImage(File(image.path));
    }
  }

  void _simulateReply() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        messages.add({
          'text': 'Auto-reply from John',
          'isMe': false,
          'type': 'text',
          'time': DateTime.now(),
          'status': 'seen'
        });
      });
      _scrollToBottom();
    });
  }

  void _simulateSeen() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        for (var msg in messages) {
          if (msg['isMe'] == true) {
            msg['status'] = 'seen';
          }
        }
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'];
    final type = msg['type'];
    final time = msg['time'] as DateTime;
    final status = msg['status'];

    final tickIcon = status == 'seen'
        ? const Icon(Icons.done_all, size: 16, color: Colors.blue)
        : const Icon(Icons.check, size: 16, color: Colors.grey);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal[300] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (type == 'text')
              Text(msg['text'], style: const TextStyle(fontSize: 16)),
            if (type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(msg['image'], fit: BoxFit.cover),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 11),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe) tickIcon,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _controller.text += emoji.emoji;
      },
      config: const Config(

      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage('assets/profile.jpg')),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("John Doe", style: TextStyle(fontSize: 18)),
                Text("online", style: TextStyle(fontSize: 14)),
              ],
            )
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => showEmojiPicker = !showEmojiPicker);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onTap: () => setState(() => showEmojiPicker = false),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendTextMessage(_controller.text),
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Voice message not implemented."),
                    ));
                  },
                ),
              ],
            ),
          ),
          if (showEmojiPicker) _buildEmojiPicker(),
        ],
      ),
    );
  }
}