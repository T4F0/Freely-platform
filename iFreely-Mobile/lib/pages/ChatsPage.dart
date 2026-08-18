import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/consts/init_user.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/messaging_repo.dart';
import 'package:flut/ui/messaging/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
    
    BlocProvider.of<ConversationBloc>(context).add(
      ConversationGetConversations(
        userId: RepositoryProvider.of<AuthRepo>(context).user_model!.id,
      ),
    );
    RepositoryProvider.of<MessagingRepo>(context).init_user(RepositoryProvider.of<AuthRepo>(context).user_model!.id);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Messages",
            style: TextStyle(fontSize: 13),
          ),
          centerTitle: true,
          leadingWidth: 100,
          leading: Row(
            children: [
              SizedBox(
                width: 15.0,
              ),
              SizedBox(
                width: 15.0,
              ),
              Image(
                image: AssetImage("assets/Avatar.png"),
                width: 40,
              )
            ],
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [
          Expanded(
            child: BlocConsumer<ConversationBloc, ConversationState>(
              listener: (context, state) {
                if (state.error == ConversationError.network) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Network Error")));
                }
              },
              builder: (context, state) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      // spreadRadius: 1,
                                      // blurRadius: 1,
                                      offset: Offset(
                                          0, 1), // changes position of shadow
                                    )
                                  ]),
                              child: TextField(
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        style: BorderStyle.solid,
                                        width: 0,
                                        color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        style: BorderStyle.solid,
                                        width: 0,
                                        color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        style: BorderStyle.solid,
                                        width: 0,
                                        color: Colors.white),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  label: Text(
                                    "Search",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    }
                    index = index - 1;
                    return MessageCard(
                      conversation: state.conversations[index],
                    );
                  },
                  itemCount: state.conversations.length + 1,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
