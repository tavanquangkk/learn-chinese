import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final chatMessagesProvider = NotifierProvider<ChatMessagesNotifier, List<Map<String, String>>>(ChatMessagesNotifier.new);
final chatLoadingProvider = NotifierProvider<ChatLoadingNotifier, bool>(ChatLoadingNotifier.new);

class ChatMessagesNotifier extends Notifier<List<Map<String, String>>> {
  @override
  List<Map<String, String>> build() => [];

  void addMessage(Map<String, String> message) {
    state = [...state, message];
  }
}

class ChatLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool loading) {
    state = loading;
  }
}

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    ref.read(chatMessagesProvider.notifier).addMessage({'role': 'user', 'content': text});
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
    });

    ref.read(chatLoadingProvider.notifier).setLoading(true);

    final api = ApiService();
    final response = await api.chat(text);

    ref.read(chatLoadingProvider.notifier).setLoading(false);
    ref.read(chatMessagesProvider.notifier).addMessage({'role': 'bot', 'content': response});
    
     Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trợ lý AI Tiếng Trung')),
      body: SelectionArea(
        child: Column(
          children: [
            Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Hỏi gì đó về tiếng Trung...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }