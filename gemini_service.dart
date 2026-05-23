import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️  Replace with your actual key from https://aistudio.google.com/app/apikey
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        '''You are StudyBot, a friendly and smart AI study assistant inside the StudyPulse app. 
Your job is to:
- Help students understand difficult concepts in simple language
- Answer questions about any subject (Math, Science, English, History, etc.)
- Give study tips and memory techniques
- Motivate students when they feel stressed
- Suggest effective study schedules
- Explain topics step by step

Keep your answers clear, concise, and encouraging. Use emojis sometimes to make it friendly. 
If a student asks something off-topic, gently redirect them to study-related topics.''',
      ),
    );
    _chat = _model.startChat();
    _initialized = true;
  }

  /// Send a message and get a response
  Future<String> sendMessage(String userMessage) async {
    _init();
    try {
      final response = await _chat.sendMessage(
        Content.text(userMessage),
      );
      return response.text ?? 'Sorry, I could not understand that. Try again!';
    } on GenerativeAIException catch (e) {
      return 'AI Error: ${e.message}. Check your API key.';
    } catch (e) {
      return 'Something went wrong. Please check your internet connection.';
    }
  }

  /// Quick one-shot question (no chat history)
  Future<String> ask(String prompt) async {
    _init();
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Reset chat history
  void resetChat() {
    _initialized = false;
    _init();
  }
}
