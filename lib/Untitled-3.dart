import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<ChatMessage> _chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return _chatMessages[index];
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final String message = _controller.text;

    if (message.isNotEmpty) {
      // Send the message to Flask server
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.9:5000/chat'), // Ganti dengan alamat IP Flask server Anda
        body: {'chatInput': message},
      );

      if (response.statusCode == 200) {
        // Update UI with chatbot reply
        setState(() {
          _chatMessages.add(ChatMessage(
            text: message,
            isUserMessage: true,
          ));

          _chatMessages.add(ChatMessage(
            text: json.decode(response.body)['chatBotReply'],
            isUserMessage: false,
          ));
        });

        _controller.clear(); // Bersihkan input setelah mengirim
      } else {
        // Handle error, if any
        print('Error: ${response.statusCode}');
      }
    }
  }
}

class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds:
              100 * widget.text.length), // Sesuaikan kecepatan animasi
    );

    if (!widget.isUserMessage) {
      _textAnimation =
          IntTween(begin: 0, end: widget.text.length).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
          widget.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isUserMessage ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.isUserMessage
            ? Text(
                widget.text,
                style: TextStyle(color: Colors.white),
              )
            : AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  final currentText =
                      widget.text.substring(0, _textAnimation.value);
                  return Text(
                    currentText,
                    style: TextStyle(color: Colors.white),
                  );
                },
              ),
      ),
    );
  }
}
