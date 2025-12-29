import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final pinyinExplanationProvider = AsyncNotifierProvider<PinyinExplanationNotifier, String>(PinyinExplanationNotifier.new);

class PinyinExplanationNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return '';
  }

  Future<void> getExplanation(String pinyin, String tone) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(apiServiceProvider).explainPronunciation(pinyin, tone));
  }
  
  void clear() {
      state = const AsyncValue.data('');
  }
}