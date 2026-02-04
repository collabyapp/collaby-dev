import 'package:collaby_app/models/chat_model/chat_model.dart';
import 'package:collaby_app/res/assets/image_assets.dart';
import 'package:collaby_app/res/fonts/app_fonts.dart';
import 'package:collaby_app/res/routes/routes_name.dart';
import 'package:collaby_app/view/chats_view/chat_detail_view/chat_view.dart';
import 'package:collaby_app/view_models/controller/chat_controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ChatFilter { all, read, unread }

class ChatsListView extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());
  final Rx<ChatFilter> selectedFilter = ChatFilter.all.obs;

  ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteName.bottomNavigationView);
        return true; // prevent default behavior (app close)
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          automaticallyImplyLeading: false,
          centerTitle: false,
          // actions: [
          //   // Connection status indicator
          //   Obx(
          //     () => Container(
          //       margin: EdgeInsets.only(right: 16),
          //       child: Row(
          //         children: [
          //           Container(
          //             width: 8,
          //             height: 8,
          //             decoration: BoxDecoration(
          //               color: chatController.socketService.isConnected.value
          //                   ? Colors.green
          //                   : Colors.red,
          //               shape: BoxShape.circle,
          //             ),
          //           ),
          //           SizedBox(width: 8),
          //           Text(
          //             chatController.socketService.isConnected.value
          //                 ? 'Connected'
          //                 : 'Disconnected',
          //             style: AppTextStyles.extraSmallText,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: Obx(() {
          if (chatController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterChip('All', ChatFilter.all),
                        _buildFilterChip('Read', ChatFilter.read),
                        _buildFilterChip('Unread', ChatFilter.unread),
                      ],
                    ),
                  ),
                ),
              ),

              // Chat List
              Expanded(
                child: Obx(() {
                  final List<ChatUser> allUsers = chatController.users;
                  final List<ChatUser> filteredUsers = allUsers.where((user) {
                    switch (selectedFilter.value) {
                      case ChatFilter.all:
                        return true;
                      case ChatFilter.read:
                        return user.unreadCount == 0;
                      case ChatFilter.unread:
                        return user.unreadCount > 0;
                    }
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    final String emptyMsg = () {
                      switch (selectedFilter.value) {
                        case ChatFilter.unread:
                          return "No unread messages.";
                        case ChatFilter.read:
                        case ChatFilter.all:
                          return "You haven't received any messages from\nclients yet.";
                      }
                    }();

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ImageAssets.noMessageImage, width: 58),
                          const SizedBox(height: 16),
                          Text(
                            emptyMsg,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.extraSmallText,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => chatController.loadChats(),
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: _buildChatTile(user),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => _showUserSearch(),
        //   child: Icon(Icons.add),
        //   backgroundColor: Color(0xff917DE5),
        // ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ChatFilter value) {
    final bool isSelected = selectedFilter.value == value;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => selectedFilter.value = value,
      child: Container(
        width: 102,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.extraSmallMediumText.copyWith(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatUser user) {
    return Obx(() {
      final isOnline = chatController.isUserOnline(user.id);

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user.avatar),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(user.name, style: AppTextStyles.smallMediumText),
          subtitle: Text(
            user.lastMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.extraSmallText,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chatController.formatTime(user.lastSeen),
                style: AppTextStyles.extraSmallText.copyWith(
                  color: Color(0xff676767),
                ),
              ),
              if (user.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xffEB5757),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    user.unreadCount > 99 ? '99+' : user.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
          onTap: () async {
            await chatController.selectUser(user);
            Get.to(() => ChatScreen());
          },
        ),
      );
    });
  }

  // void _showUserSearch() {
  //   Get.dialog(UserSearchDialog(), barrierDismissible: true);
  // }
}

// User Search Dialog
class UserSearchDialog extends StatelessWidget {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController searchController = TextEditingController();
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isSearching = false.obs;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start New Chat', style: AppTextStyles.h6),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search brands...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _searchUsers(value),
            ),
            SizedBox(height: 16),

            // Results
            Expanded(
              child: Obx(() {
                if (isSearching.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'Type at least 2 characters to search',
                      style: AppTextStyles.smallText,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final user = searchResults[index];
                    return _buildUserTile(user);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(dynamic user) {
    final String name =
        user['profile']?['brandCompanyName'] ??
        user['profile']?['username'] ??
        user['email'];
    final String imageUrl =
        user['profile']?['imageUrl'] ?? 'https://via.placeholder.com/150';
    final String role = user['role'] ?? '';

    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      title: Text(name, style: AppTextStyles.smallMediumText),
      subtitle: Text(user['email'], style: AppTextStyles.extraSmallText),
      trailing: Chip(
        label: Text(
          role == 'brand' ? 'Brand' : 'Creator',
          style: AppTextStyles.extraSmallText,
        ),
        backgroundColor: role == 'brand'
            ? Colors.blue.shade100
            : Colors.green.shade100,
      ),
      onTap: () async {
        Get.back();
        await chatController.createChat(user['_id']);
        Get.to(() => ChatScreen());
      },
    );
  }

  void _searchUsers(String query) async {
    if (query.trim().length < 2) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final results = await chatController.searchUsers(query.trim());
      searchResults.value = results;
    } catch (e) {
      print('Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }
}
