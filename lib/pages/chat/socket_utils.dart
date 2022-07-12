import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:web_socket_channel/io.dart';

class SocketUtils {
  IOWebSocketChannel channel;
  String userName = '';
  String userID = '';
  String groupID = '';

  SocketUtils() {
    // channel = IOWebSocketChannel.connect('wss://swasthyasethu.in:8090');
    channel =
        IOWebSocketChannel.connect(Uri.parse('ws://swasthyasethu.in:8090 '));
  }

  void addUserForChat(String userName, String userID) {
    this.userName = userName;
    this.userID = userID;
    var msg = {
      'user': userName,
      'command': 'register',
      'userId': userID,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };

    printToConsole("addUserForChat ${msg.toString()}");

    channel.sink.add(jsonEncode(msg));
  }

  void addUserForGroupChat(String userName, String userID, String groupID) {
    this.userName = userName;
    this.userID = userID;
    this.groupID = groupID;
    var msg = {
      'user': userName,
      'userId': userID,
      'command': 'subscribe',
      'channel': groupID,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };
    printToConsole("addUserForGroupChat ${msg.toString()}");

    channel.sink.add(jsonEncode(msg));
  }

  void sendMessageChat(String message, String toUserID) {
    print('sendMessageChat : $message');
    var msg = {
      'command': 'message',
      'user': userName,
      'text': message,
      'from': userID,
      'to': toUserID,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };
    printToConsole("sendMessageChat ${msg.toString()}");
    channel.sink.add(jsonEncode(msg));
  }

  void sendMessageGroupChat(String message) {
    var msg = {
      'command': 'groupchat',
      'channel': groupID,
      'user': userName,
      'text': message,
      'from': userID,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };
    printToConsole("sendMessageGroupChat ${msg.toString()}");

    channel.sink.add(jsonEncode(msg));
  }
}
