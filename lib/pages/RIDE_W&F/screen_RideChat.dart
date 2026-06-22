import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/TextField.dart';
import 'package:zion3/UI/tile_place.dart';
import 'package:zion3/models/chat_model.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Chat.dart';
import 'package:zion3/theme.dart';

// ---------------------------------------------------------------------------
// LOCAL providers — scoped to this widget via ProviderScope override so two
// simultaneous ChatPage instances never share state.
// ---------------------------------------------------------------------------
final _isSendingProvider = StateProvider<bool>((ref) => false);
final _messagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

class ChatPage extends ConsumerStatefulWidget {
  final String rideId;
  final String currentUserId;
  final String receiverId;

  const ChatPage({
    required this.rideId,
    required this.currentUserId,
    required this.receiverId,
    super.key,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late StreamSubscription<List<ChatMessage>> _subscription;

  // Prevent firing markMessagesAsRead on every single stream event
  bool _markReadPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _markRead();
    });
    _startListening();
  }

  // ---------------------------------------------------------------------------
  // Stream listener — only calls markRead when there are actually unread msgs
  // ---------------------------------------------------------------------------
  void _startListening() {
    _subscription = getMessages(widget.rideId).listen((msgs) {
      // Update message list
      ref.read(_messagesProvider.notifier).state = msgs;

      // Check for unread messages from the other person
      final hasUnread = msgs.any((msg) =>
          msg.senderId != widget.currentUserId &&
          msg.readBy[widget.currentUserId] == false);

      if (hasUnread && !_markReadPending) {
        _markReadPending = true;
        _markRead().then((_) => _markReadPending = false);
      }
    });
  }

  Future<void> _markRead() =>
      markMessagesAsRead(widget.rideId, widget.currentUserId);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _subscription.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------
  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _controller.clear();
    ref.read(_isSendingProvider.notifier).state = true;

    try {
      await sendMessage(
        ref: ref,
        text: trimmed,
        senderId: widget.currentUserId,
        receiverId: widget.receiverId,
        rideId: widget.rideId,
      );
    } finally {
      // Guard against calling setState on a disposed widget
      if (mounted) ref.read(_isSendingProvider.notifier).state = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final isSending = ref.watch(_isSendingProvider);

    // Index of the sender's most recent message — O(n) once per build,
    // used below in O(1) per item instead of calling indexOf() inside itemBuilder.
    final lastMyMsgIndex =
        messages.lastIndexWhere((m) => m.senderId == widget.currentUserId);

    return ProviderScope(
      // Isolate local providers so two chat screens don't share state
      overrides: [
        _isSendingProvider,
        _messagesProvider,
      ],
      child: Scaffold(
        backgroundColor: Themes.white0(context),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Chat", style: Themes.headline2(context)),
          backgroundColor: Themes.white1(context),
          foregroundColor: Themes.black0(context),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const _EmptyChat()
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (_, reversedIndex) {
                        // reverse:true means index 0 = last message in list
                        final actualIndex = messages.length - 1 - reversedIndex;
                        final msg = messages[actualIndex];
                        final isMe = msg.senderId == widget.currentUserId;
                        final isLastMine = actualIndex == lastMyMsgIndex;
                        final isSeen = msg.readBy[widget.receiverId] == true;

                        return _MessageBubble(
                          msg: msg,
                          isMe: isMe,
                          showSending: isSending && isMe && isLastMine,
                          showSeen: !isSending && isMe && isLastMine && isSeen,
                        );
                      },
                    ),
            ),
            _SuggestionBar(onSend: _sendMessage),
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              isSending: isSending,
              onSend: () => _sendMessage(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets — extracted to avoid rebuilding the whole tree
// ---------------------------------------------------------------------------

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No messages yet.\nSay hi! 👋",
        textAlign: TextAlign.center,
        style: TextStyle(color: Themes.gray3(context), fontSize: 14.sp),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  final bool showSending;
  final bool showSeen;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.showSending,
    required this.showSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bubble
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe ? Themes.tree_green : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                ),
              ),
              child: Text(
                msg.text,
                style: Themes.TextFieldMainText(context).copyWith(
                  color: isMe ? Colors.white : Themes.black0(context),
                ),
              ),
            ),
          ),

          // Status line — only one of these shows at a time
          if (showSending || showSeen)
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 4),
              child: Text(
                showSending ? "Sending…" : "Seen",
                style: Themes.SuperSmallContainerText(context),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final void Function(String) onSend;

  static const _suggestions = [
    "Waiting for you!",
    "Be there soon",
    "Where are you",
    "Looking for you",
  ];

  const _SuggestionBar({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) => PlaceTile(
          label: _suggestions[index],
          onTap: () => onSend(_suggestions[index]),
          context: context,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Expanded(
            child: textField(
              focusNode: focusNode,
              controller,
              context,
              "Type a message",
              icon: Icons.message,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: isSending ? null : onSend, // disable while sending
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isSending
                  ? Themes.tree_green.withOpacity(0.5)
                  : Themes.tree_green,
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.send_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
