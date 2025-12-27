import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/hover_scale_card.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "Namaste! I am your AI CA Assistant. Ask me anything."
    },
  ];

  // Voice Features
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _available = await _speech.initialize();
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_available) return;
    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) {
        setState(() {
          _controller.text = val.recognizedWords;
        });
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_controller.text.isNotEmpty) {
        _sendMessage(isVoice: true);
      }
    }
  }

  void _speak(String text) async {
    await _flutterTts.setLanguage("hi-IN"); // Try Hindi accent
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _sendMessage({bool isVoice = false}) async {
    if (_controller.text.isEmpty) return;

    final query = _controller.text;
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    setState(() {
      _messages.add({"role": "user", "text": query});
      _controller.clear();
      _isListening = false;
    });

    try {
      // Check if it's an HSN query
      if (query.toLowerCase().contains("tax") ||
          query.toLowerCase().contains("hsn") ||
          query.toLowerCase().contains("gst rate")) {
        final result = await _api.searchHSN(query);
        final answer =
            "HSN ${result['data']['hsn_code']} - GST ${result['data']['gst_rate']}\n${result['data']['reason']}";
        _addBotResponse(answer, shouldSpeak: isVoice);
      } else {
        // General Chat with Language Context
        final result = await _api.chatWithAI(query,
            language: lang.chatLocale.languageCode, userId: lang.userId);
        final reply = result['data']['reply'];
        _addBotResponse(reply, shouldSpeak: isVoice);
      }
    } catch (e) {
      _addBotResponse("Sorry, I faced an error. Please try again.",
          shouldSpeak: isVoice);
    }
  }

  void _addBotResponse(String text, {bool shouldSpeak = false}) {
    setState(() {
      _messages.add({"role": "bot", "text": text});
    });
    if (shouldSpeak) {
      _speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Dynamic Hints based on language (simplified map for hints)
    final hints = {
      'en': [
        'Can I claim ITC on fridge?',
        'Is this notice serious?',
        'What is the late fee?'
      ],
      'hi': [
        'क्या मैं फ्रिज पर ITC ले सकता हूँ?',
        'क्या यह नोटिस गंभीर है?',
        'लेट फीस क्या है?'
      ],
      'mr': [
        'मी फ्रिजवर ITC घेऊ शकतो का?',
        'ही नोटीस गंभीर आहे का?',
        'लेट फी काय आहे?'
      ],
    };
    final currentHints = hints[lang.locale.languageCode] ?? hints['en']!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(lang.t('ask_ai')),
      ),
      body: Column(
        children: [
          /// ASSISTANT HEADER (Presence)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, Color(0xFF003380)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.smart_toy, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('app_title'), // Or some CA title
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isListening ? "Listening..." : lang.t('ready_help'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (_isListening)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
              ],
            ),
          ),

          /// CONTEXT CHIPS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ContextChip("ITC", onTap: () => _controller.text = "ITC"),
                _ContextChip("Notices",
                    onTap: () => _controller.text = "Notice"),
                _ContextChip("Late Fees",
                    onTap: () => _controller.text = "Late Fees"),
                _ContextChip("Filing",
                    onTap: () => _controller.text = "Filing"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// CHAT AREA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF2563EB) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft:
                              isUser ? const Radius.circular(16) : Radius.zero,
                          bottomRight:
                              !isUser ? const Radius.circular(16) : Radius.zero,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          height: 1.4,
                          fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          /// SUGGESTED QUESTIONS
          if (_messages.length < 3)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: currentHints.length,
                itemBuilder: (ctx, i) =>
                    _SuggestionChip(currentHints[i], onTap: _setInput),
              ),
            ),

          const SizedBox(height: 8),

          /// INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask...",
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                            color: Colors.blue.withOpacity(0.3), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _listen,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _isListening ? Colors.redAccent : Colors.blue.shade50,
                    child: Icon(_isListening ? Icons.stop : Icons.mic,
                        color: _isListening ? Colors.white : Colors.blue,
                        size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setInput(String text) {
    _controller.text = text;
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final Function(String) onTap;

  const _SuggestionChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF))),
        onPressed: () => onTap(label),
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ContextChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: HoverScaleCard(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ),
    );
  }
}
