import 'package:web_socket_channel/io.dart';

class CustomSocket {
  IOWebSocketChannel channel;

  getSocket() {
    channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
  }

  sentMessage(){
    channel.sink.add('Hello!');
  }

  close(){
    channel.sink.close();
  }
}
