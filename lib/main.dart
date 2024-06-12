import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF4B1CFE,
          <int, Color>{
            50: Color(0xFF4B1CFE),
            100: Color(0xFF4B1CFE),
            200: Color(0xFF4B1CFE),
            300: Color(0xFF4B1CFE),
            400: Color(0xFF4B1CFE),
            500: Color(0xFF4B1CFE),
            600: Color(0xFF4B1CFE),
            700: Color(0xFF4B1CFE),
            800: Color(0xFF4B1CFE),
            900: Color(0xFF4B1CFE),
          },
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 234, 229, 229),
      ),
      home: SplashScreen(),
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
  List<String> _quickResponses = [];
  bool shouldDisplayButton = false;

  @override
  void initState() {
    super.initState();
    _getSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color.fromRGBO(75, 28, 254, 1),
          title: Row(
            children: [
              Image.asset(
                'assets/6.png',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 2.0),
              Text(
                'ChatBot',
                style: TextStyle(
                    color: Colors.white), // Menentukan warna teks menjadi putih
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
          ),
        ),
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
            AnimatedOpacity(
              opacity: shouldDisplayButton ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickResponses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color.fromRGBO(75, 28, 254, 1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _selectQuickResponse(_quickResponses[index]);
                        },
                        child: Text(
                          _quickResponses[index],
                          style: TextStyle(
                            color: Color.fromRGBO(75, 28, 254, 1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromRGBO(242, 242, 242, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ketikkan Pesan...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _sendMessage();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(15, 172, 145, 1),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
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
      final response = await http.post(
        Uri.parse('http://192.168.251.2:5000/chat'),
        body: {'chatInput': message},
      );

      if (response.statusCode == 200) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: message,
            isUserMessage: true,
          ));

          _chatMessages.add(ChatMessage(
            text: json.decode(response.body)['chatBotReply'],
            isUserMessage: false,
          ));

          shouldDisplayButton = message.isNotEmpty;
        });

        _controller.clear();
        _getSuggestions();
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

  Future<void> _getSuggestions() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.251.2:5000/get_suggestions'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['randomSuggestions'] is List) {
          List<String> allSuggestions =
              List<String>.from(data['randomSuggestions']);

          if (allSuggestions.length >= 6) {
            setState(() {
              _quickResponses = allSuggestions.sublist(0, 6);
            });
          } else {
            setState(() {
              _quickResponses = allSuggestions;
            });
          }
        } else if (data['randomSuggestions'] is String) {
          setState(() {
            _quickResponses = [data['randomSuggestions']];
          });
        }
      } else {
        throw Exception('Failed to contact the server');
      }
    } catch (e) {
      print('Error getting suggestions: $e');
    }
  }

  void _selectQuickResponse(String response) {
    _controller.text = response;
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
        milliseconds: 50 * widget.text.length,
      ),
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
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: widget.isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          widget.isUserMessage
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(right: isWideScreen ? 16 : 8),
                  child: Image.asset(
                    'assets/6.png',
                    width: isWideScreen ? 30 : 45,
                    height: isWideScreen ? 30 : 44,
                  ),
                ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 20 : 15,
                vertical: isWideScreen ? 15 : 10,
              ),
              decoration: BoxDecoration(
                color: widget.isUserMessage
                    ? Color.fromRGBO(71, 32, 225, 1)
                    : Color.fromRGBO(15, 172, 145, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isUserMessage
                  ? Text(
                      widget.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWideScreen ? 18 : 14,
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _textAnimation,
                      builder: (context, child) {
                        final currentText =
                            widget.text.substring(0, _textAnimation.value);
                        return Text(
                          currentText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWideScreen ? 18 : 14,
                          ),
                        );
                      },
                    ),
            ),
          ),
          widget.isUserMessage
              ? Padding(
                  padding: EdgeInsets.only(left: isWideScreen ? 16 : 8),
                  child: Image.asset(
                    'assets/2.png',
                    width: isWideScreen ? 50 : 40,
                    height: isWideScreen ? 50 : 40,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
