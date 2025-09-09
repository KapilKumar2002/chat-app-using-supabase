import 'dart:async';

import 'package:first_app/Pages/LoginPage.dart';
import 'package:first_app/Pages/chat_listing.dart';
import 'package:first_app/Pages/chat_screen.dart';
import 'package:first_app/Pages/select_profile_image.dart';
import 'package:first_app/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;
  String _searchQuery = "";
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> chatRooms = [];
  // Mock chat data

  Future<void> fetchChatRooms() async {
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentSession?.user.id;
    setState(() {
      _isLoading = false;
    });
    try {
      chatRooms = await supabase
          .from('chatrooms')
          .select()
          .or('user_id_1.eq.$myId,user_id_2.eq.$myId')
          .order("last_message_timestamp", ascending: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create user!")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signout() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } on AuthApiException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> searchChatRooms(String query) async {
    final myId = supabase.auth.currentSession?.user.id;
    try {
      chatRooms = await supabase
          .from("chatrooms")
          .select()
          .ilike("chatroom_name", '%$query%')
          .or('user_id_1.eq.$myId,user_id_2.eq.$myId')
          .order("last_message_timestamp", ascending: false);
      setState(() {});
      print(chatRooms);
    } catch (e) {
      debugPrint("$e");
    }
  }

  _onSearchChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(
      Duration(milliseconds: 500),
      () {
        if (value.trim().isEmpty) {
          fetchChatRooms();
          return;
        }
        searchChatRooms(value.trim());
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchChatRooms();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        signout: signout,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListing(),
            ),
          );
        },
        child: const Center(child: Icon(Icons.chat)),
      ),
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
            : Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = "";
                }
                _isSearching = !_isSearching;
              });

              if (!_isSearching) {
                fetchChatRooms();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchChatRooms();
        },
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final myId =
                      Supabase.instance.client.auth.currentSession?.user.id;
                  final chatroom = chatRooms[index];

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(80),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(80)),
                        child: chatroom['chatroom_image'] == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                            : Image.network(chatroom['chatroom_image']),
                      ),
                    ),
                    title: Text(
                      chatroom["chatroom_name"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      chatroom["last_message"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (chatroom['last_message_timestamp'] != null)
                          Text(
                            timeago.format((DateTime.tryParse(
                                        chatroom['last_message_timestamp']) ??
                                    DateTime.now())
                                .toLocal()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 5),
                        // if (chat["unread"] > 0)
                        //   Container(
                        //     height: 20,
                        //     width: 20,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 6, vertical: 2),
                        //     decoration: BoxDecoration(
                        //       color: Colors.indigo,
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: Center(
                        //       child: Text(
                        //         chat["unread"].toString(),
                        //         style: const TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatroom['id'],
                            name: chatroom["chatroom_name"],
                            avatar: chatroom["chatroom_image"],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  final VoidCallback signout;

  const AppDrawer({
    Key? key,
    required this.signout,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _avatarUrl;
  Map<String, dynamic> userInfo = {};
  final supabase = Supabase.instance.client;
  Future<void> fetchUserInfo() async {
    final userId = supabase.auth.currentSession?.user.id;

    try {
      userInfo = await supabase
          .from("USERS")
          .select()
          .filter("id", "eq", userId)
          .single();
      setState(() {});
    } on PostgrestException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('USERS').upsert({
        'id': userId,
        'profile_image': imageUrl,
      });
      if (mounted) {
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      print(error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create user!")),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create user!")),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchUserInfo();
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.indigo,
            ),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Avatar(
                height: 120,
                width: 120,
                imageUrl: _avatarUrl ?? userInfo['profile_image'],
                onUpload: _onUpload,
              ),
            ),
            accountName: Text(
              userInfo['username'] ?? "Unknown",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            accountEmail: Text(userInfo['email'] ?? ""),
          ),

          // Example Menu Items
          ListTile(
            leading: const Icon(Icons.home, color: Colors.indigo),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // Just close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.indigo),
            title: const Text("Settings"),
            onTap: () {},
          ),
          const Spacer(),
          const Divider(),

          // Sign Out Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              widget.signout();
            },
          ),
        ],
      ),
    );
  }
}
