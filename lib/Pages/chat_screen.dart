import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String name;
  final String? avatar;

  const ChatScreen(
      {super.key, required this.name, this.avatar, required this.chatRoomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  bool _isSendingMessage = false;
  final List<Map<String, dynamic>> messages = [
    {"text": "Hello!", "isMe": false},
    {"text": "Hi, how are you?", "isMe": true},
    {"text": "I’m good, thanks! And you?", "isMe": false},
    {"text": "Doing great!", "isMe": true},
  ];

  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    setState(() {
      _isSendingMessage = true;
    });
    final myId = supabase.auth.currentSession?.user.id;
    final message = _controller.text.trim();
    if (_controller.text.trim().isEmpty) return;
    try {
      final response = await supabase.from("MESSAGES").insert({
        "sender_id": myId,
        "chatroom_id": widget.chatRoomId,
        "message": message,
        "is_read": false,
      }).select();
      if (response.isEmpty) {
        debugPrint("Bhai tera message response is empty");
        return;
      }
      debugPrint("Sab theek ${widget.chatRoomId} $response");
      final chatRoom = await supabase
          .from("CHAT_ROOMS")
          .update({
            "last_message": message,
            "last_message_timestamp": response.first['created_at']
          })
          .eq("id", widget.chatRoomId)
          .select();

      debugPrint("$chatRoom");
      _controller.clear();
      _scrollToBottom();
    } on PostgrestException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint("$e");
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
    // setState(() {
    //   messages.add({"text": _controller.text.trim(), "isMe": true});
    //   _controller.clear();
    // });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    // TODO: implement initState
    _scrollToBottom();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(80)),
              child: widget.avatar == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                    )
                  : Image.network(widget.avatar!),
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
              child: StreamBuilder(
            stream: supabase
                .from("MESSAGES")
                .stream(primaryKey: ['id']).inFilter("chatroom_id",
                    [widget.chatRoomId]).order('created_at', ascending: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No conversations found"),
                );
              }

              final messages = snapshot.data!;

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  bool isMe = message["sender_id"] ==
                      supabase.auth.currentSession?.user.id;
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.indigo.withOpacity(0.9)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Text(
                            message["message"],
                            style: TextStyle(
                              fontSize: 15,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            timeago.format(
                                DateTime.tryParse(message['created_at']) ??
                                    DateTime.now()),
                            style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white : Colors.black),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _isSendingMessage ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
