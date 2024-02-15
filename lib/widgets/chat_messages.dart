import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages yet"),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 20, right: 10),
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final nextChatDoc =
                index + 1 < chatDocs.length ? chatDocs[index + 1] : null;
            final currentMessageUserId = chatDoc['userId'];
            final nextMessageUserId =
                nextChatDoc != null ? nextChatDoc['userId'] : null;
            final isLastMessageByCurrentUser =
                currentMessageUserId == nextMessageUserId;
            if (isLastMessageByCurrentUser) {
              return MessageBubble.next(
                message: chatDoc['text'],
                isMe:
                    FirebaseAuth.instance.currentUser!.uid == chatDoc['userId'],
              );
            } else {
              return MessageBubble.first(
                message: chatDoc['text'],
                isMe:
                    FirebaseAuth.instance.currentUser!.uid == chatDoc['userId'],
                username: chatDoc['userName'],
                userImage: chatDoc['userImage'],
              );
            }
          },
        );
      },
    );
  }
}
