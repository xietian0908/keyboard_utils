import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_utils_fork/keyboard_utils.dart';
import 'package:keyboard_utils_fork/keyboard_listener.dart' as keyboard_listener;
import 'package:keyboard_utils_fork/widgets.dart';

void main() => runApp(MyApp());

// Sample Bloc
class KeyboardBloc {
  KeyboardUtils _keyboardUtils = KeyboardUtils();
  StreamController<double> _streamController = StreamController<double>();

  Stream<double> get stream => _streamController.stream;

  KeyboardUtils get keyboardUtils => _keyboardUtils;

  late int _idKeyboardListener;

  void start() {
    _idKeyboardListener = _keyboardUtils.add(
        listener: keyboard_listener.KeyboardListener(willHideKeyboard: () {
      _streamController.sink.add(_keyboardUtils.keyboardHeight);
    }, willShowKeyboard: (double keyboardHeight) {
      _streamController.sink.add(keyboardHeight);
    }));
  }

  void dispose() {
    _keyboardUtils.unsubscribeListener(subscribingId: _idKeyboardListener);
    if (_keyboardUtils.canCallDispose()) {
      _keyboardUtils.dispose();
    }
    _streamController.close();
  }
}

// App
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  KeyboardBloc _bloc = KeyboardBloc();

  KeyboardUtils _keyboardUtils = KeyboardUtils();

  double tempHeight = 0;

  late int tempId;

  @override
  void initState() {
    super.initState();
    tempId = _keyboardUtils.add(
      listener: keyboard_listener.KeyboardListener(
        willHideKeyboard: () {
          tempHeight = 0;
          setState(() {});
        },
        willShowKeyboard: (result) {
          tempHeight = result;
          setState(() {});
        },
      ),
    );
    _keyboardUtils.init();
    // _bloc.start();
  }

  Widget buildSampleUsingKeyboardAwareWidget() {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: KeyboardAware(
              builder: (context, keyboardConfig) {
                return GestureDetector(
                  onTap: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Center(
                    child: Text(
                      'is keyboard open: ${keyboardConfig.isKeyboardOpen}\n'
                      'Height: ${keyboardConfig.keyboardHeight}',
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              // keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '请输入',
              ),
            ),
          ),
          Container(
            height: tempHeight,
          ),
        ],
      ),
    );
  }

  Widget buildSampleUsingRawListener() {
    return Center(
      child: Column(
        children: <Widget>[
          TextField(),
          TextField(
            keyboardType: TextInputType.number,
          ),
          TextField(),
          SizedBox(
            height: 30,
          ),
          StreamBuilder<double>(
              stream: _bloc.stream,
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                return Text('is keyboard open: ${_bloc.keyboardUtils.isKeyboardOpen}\n'
                    'Height: ${_bloc.keyboardUtils.keyboardHeight}');
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Keyboard Utils Sample'),
        ),
        resizeToAvoidBottomInset: false,
        body: buildSampleUsingKeyboardAwareWidget(),
      ),
    );
  }

  @override
  void dispose() {
    // _bloc.dispose();
    _keyboardUtils.unsubscribeListener(subscribingId: tempId);
    _keyboardUtils.dispose();
    super.dispose();
  }
}
