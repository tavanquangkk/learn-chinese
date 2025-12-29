import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pinyin_provider.dart';

class PinyinScreen extends ConsumerWidget {
  final List<String> pinyinList = [
    'ba', 'pa', 'ma', 'fa',
    'da', 'ta', 'na', 'la',
    'ga', 'ka', 'ha',
    'ji', 'qi', 'xi',
    'zhi', 'chi', 'shi', 'ri',
    'zi', 'ci', 'si',
  ];

  PinyinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập Pinyin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: pinyinList.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () => _showToneDialog(context, ref, pinyinList[index]),
              child: Text(
                pinyinList[index],
                style: const TextStyle(fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showToneDialog(BuildContext context, WidgetRef ref, String pinyin) {
    showDialog(
      context: context,
      builder: (context) => ToneDialog(pinyin: pinyin),
    );
  }
}

class ToneDialog extends ConsumerWidget {
  final String pinyin;
  
  const ToneDialog({super.key, required this.pinyin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explanationState = ref.watch(pinyinExplanationProvider);

    return AlertDialog(
      title: Text('Chọn thanh điệu cho "$pinyin"'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToneButton(ref, '1', '¯'),
                _buildToneButton(ref, '2', '´'),
                _buildToneButton(ref, '3', 'ˇ'),
                _buildToneButton(ref, '4', '`'),
              ],
            ),
            const SizedBox(height: 20),
            explanationState.when(
              data: (data) => data.isNotEmpty 
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue.shade50,
                      child: Text(data, style: const TextStyle(fontSize: 16)),
                    ) 
                  : const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Lỗi: $err', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(pinyinExplanationProvider.notifier).clear();
            Navigator.of(context).pop();
          },
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  Widget _buildToneButton(WidgetRef ref, String tone, String symbol) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      onPressed: () {
        // Play sound (TODO)
        ref.read(pinyinExplanationProvider.notifier).getExplanation(pinyin, tone);
      },
      child: Text(
        symbol,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
