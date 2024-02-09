import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:gdsc360/pages/MainPage.dart';

class SpeechButton extends StatefulWidget {
  @override
  _SpeechButtonState createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: _isListening,
      glowColor: Theme.of(context).primaryColor,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      child: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _navigateBasedOnSpeech(_text);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _navigateBasedOnSpeech(String text) {
    if (text.contains("health")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(pageIndex: 1)));
    } else if (text.contains("message")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(pageIndex: 2)));
    } else if (text.contains("home")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(pageIndex: 0)));
    } else if (text.contains("location")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(pageIndex: 3)));
    } else if (text.contains("profile")) {
      Navigator.pushNamed(context, "/profilepage");
    } else if (text.contains("settings")) {
      Navigator.pushNamed(context, "/settingspage");
    } else if (text.contains("location")) {
      Navigator.pushNamed(context, "/mappage");
    }
  }
}
