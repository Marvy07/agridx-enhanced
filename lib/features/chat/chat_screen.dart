import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/services/groq_service.dart';
import '../../core/offline_disease_database.dart';
import '../library/crops_data.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _messages.add(ChatMessage(
      text: "Hello! I am AgriBot, your expert farming assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getOfflineBotResponse(String query) {
    final lowerQuery = query.toLowerCase();

    // 1. Search for diseases
    for (final entry in offlinePathologyDatabase.entries) {
      final key = entry.key.toLowerCase();
      final crop = key.split('___').first.replaceAll('_', ' ');
      final disease = key.split('___').last.replaceAll('_', ' ');

      // Simple match: if query mentions crop AND disease (or part of disease)
      if (lowerQuery.contains(crop) && 
          disease.split(' ').any((word) => word.length > 3 && lowerQuery.contains(word))) {
        
        final data = entry.value;
        String response = 'Here is what I found about **$crop $disease**:\n\n';
        response += '${data['description']}\n\n';
        
        if (data['organic_treatment'] != null) {
          response += '**Organic Treatments:**\n';
          for (var t in data['organic_treatment']) {
            response += '• $t\n';
          }
          response += '\n';
        }
        
        if (data['chemical_treatment'] != null) {
          response += '**Chemical Treatments:**\n';
          for (var t in data['chemical_treatment']) {
            response += '• ${t['product']} (${t['dosage']})\n';
          }
        }
        return response;
      }
    }

    // 2. Search for crops
    for (final crop in availableCrops) {
      if (lowerQuery.contains(crop.name.toLowerCase())) {
        return 'Here is some information about growing **${crop.name}** ${crop.emoji}:\n\n'
               '• **Climate:** Grows best in ${crop.growingTemp} with ${crop.rainfall} of rain.\n'
               '• **Soil:** Requires ${crop.soilType} with a pH of ${crop.pH}.\n'
               '• **Spacing:** Plant them ${crop.plantSpacing} apart in rows ${crop.rowSpacing} apart.\n\n'
               '💡 **Pro Tip:** ${crop.applicationTips}';
      }
    }

    // 3. Fallback
    return "I'm currently operating in offline mode. I can give you detailed treatment plans for diseases (e.g., 'Tomato early blight') or growing guides for crops (e.g., 'How to grow Maize'). What would you like to know?";
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final history = _messages.map((m) => {
        'role': m.isUser ? 'user' : 'model',
        'text': m.text,
      }).toList();

      final response = await ref.read(groqServiceProvider).getChatResponse(history);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        });
        _scrollToBottom();
      }
    } catch (e) {
      final fallbackResponse = _getOfflineBotResponse(text);
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: fallbackResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              radius: 18,
              child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            const Text('AgriBot', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const TypingIndicator();
                }
                final message = _messages[index];
                return ChatBubble(message: message).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask AgriBot anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: const Color(0xFF1B5E20),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(0),
          ),
          boxShadow: message.isUser ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true));
    
    _animations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
       Future.delayed(Duration(milliseconds: i * 200), () {
         if (mounted) _controllers[i].forward();
       });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3 + (_animations[index].value * 0.7)),
                shape: BoxShape.circle,
              ),
            ),
          )),
        ),
      ),
    );
  }
}
