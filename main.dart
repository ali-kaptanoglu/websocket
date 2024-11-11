import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketExample extends StatefulWidget {
  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> with WidgetsBindingObserver {
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your-websocket-url'),
    );

    _channel!.stream.listen(
      (message) {
        // Mesaj alındığında yapılacak işlemler
        print('Received: $message');
      },
      onError: (error) {
        // Hata yönetimi
        print('WebSocket Error: $error');
      },
      onDone: () {
        // Bağlantı kapandığında yeniden bağlanmayı deneyebilirsiniz
        print('WebSocket Closed. Reconnecting...');
        Future.delayed(Duration(seconds: 5), () {
          _connectWebSocket();
        });
      },
    );
  }

  void _disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // Uygulama öne alındı
        print('App resumed');
        if (_channel == null) {
          _connectWebSocket();
        }
        break;
      case AppLifecycleState.paused:
        // Uygulama arka plana alındı
        print('App paused');
        _disconnectWebSocket();
        break;
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.detached:
        print('App detached');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
      ),
      body: Center(
        child: Text('WebSocket is connected'),
      ),
    );
  }
}
