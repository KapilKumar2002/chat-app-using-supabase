import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/Pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListing extends StatefulWidget {
  const ChatListing({super.key});
  @override
  State<ChatListing> createState() => _ChatListingState();
}

class _ChatListingState extends State<ChatListing> {
  bool _isLoading = false;
  bool _isSearching = false;

  // Mock chat data
  final List<Map<String, dynamic>> chats = [
    {
      "name": "John Doe",
      "message": "Hey! How are you?",
      "time": "09:30",
      "unread": 2,
      "avatar": "https://i.pravatar.cc/150?img=1"
    },
    {
      "name": "Jane Smith",
      "message": "Let’s catch up tomorrow.",
      "time": "Yesterday",
      "unread": 0,
      "avatar": "https://i.pravatar.cc/150?img=2"
    },
    {
      "name": "Alex Johnson",
      "message": "The file is ready.",
      "time": "Mon",
      "unread": 1,
      "avatar": "https://i.pravatar.cc/150?img=3"
    },
  ];

  List<Map<String, dynamic>> users = [];

  Future<void> fetchUsers() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentSession?.user;

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from("USERS")
          .select()
          .neq("id", currentUser?.id ?? "")
          .order("username", ascending: true);

      if (!mounted) return;
      // Store data
      users = response;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> searchUsers(String searchQuery) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentSession?.user;

    try {
      final response = await supabase
          .from("USERS")
          .select()
          .neq("id", currentUser?.id ?? "")
          .or("username.ilike.%${searchQuery.trim()}%")
          .order("username", ascending: true);

      if (!mounted) return;
      users = response;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    }
  }

  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        fetchUsers();
      } else {
        searchUsers(value.trim());
      }
    });
  }

  Future<void> createChatRoom(String userId) async {
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentSession?.user.id;
    setState(() {
      _isLoading = true;
    });
    try {
      final chatRoomId1 = "${myId}_$userId";
      final chatRoomId2 = "${userId}_$myId";
      final chatRoomsNotExists = (await supabase
              .from("CHAT_ROOMS")
              .select()
              .or('id.eq.$chatRoomId1,id.eq.$chatRoomId2'))
          .isEmpty;

      if (chatRoomsNotExists) {
        await supabase.from("CHAT_ROOMS").insert({
          "id": chatRoomId1,
          "user_id_1": myId,
          "user_id_2": userId,
        });
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chatroom already exists!")),
        );
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong!")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.indigo,
          ),
        ),
      );
    }
    if (users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          title: const Text("Users"),
          actions: const [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: null,
            ),
          ],
        ),
        body: const Center(
          child: Text("No data found!"),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                cursorColor: Colors.white,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w200),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search chats...",
                  hintStyle: TextStyle(
                      color: Colors.white54, fontWeight: FontWeight.w200),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text("Users"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });

              if (!_isSearching) {
                fetchUsers();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(80)),
                child: user['profile_image'] == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : Image.network(user["profile_image"]),
              ),
            ),
            title: Text(
              user["username"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              user["email"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            // trailing: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       chat["time"],
            //       style: const TextStyle(
            //         fontSize: 12,
            //         color: Colors.grey,
            //       ),
            //     ),
            //     const SizedBox(height: 5),
            //     if (chat["unread"] > 0)
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 6, vertical: 2),
            //         decoration: BoxDecoration(
            //           color: Colors.indigo,
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: Text(
            //           chat["unread"].toString(),
            //           style: const TextStyle(
            //             fontSize: 12,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //   ],
            // ),
            onTap: () async {
              await createChatRoom(user['id']);
            },
          );
        },
      ),
    );
  }
}
