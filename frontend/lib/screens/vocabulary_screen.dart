import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  
  // データ状態
  List<dynamic> fullVocabularyList = []; // 現在のレベルの全単語リスト
  List<dynamic> displayedVocabulary = []; // 表示中のリスト (パートごとに分割)
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  // ページネーション設定
  final int _itemsPerPart = 50; // 1パートあたりの単語数
  int _currentPartIndex = 0; // 現在のパート (0 = Part 1)

  // TTS (音声合成) 状態
  List<Map<String, String>> _availableChineseVoices = [];
  Map<String, String>? _currentVoice;

  @override
  void initState() {
    super.initState();
    _initTts(); // TTSの初期化
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
             _currentPartIndex = 0; // HSKレベル変更時にパートをリセット
             _fetchVocabulary();
        }
    });
    _fetchVocabulary();
    _searchController.addListener(_onSearchChanged);
  }
  
  // TTSの初期化と音声リストの取得
  Future<void> _initTts() async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    try {
        await Future.delayed(const Duration(milliseconds: 500));
        dynamic voices = await flutterTts.getVoices;
        
        List<Map<String, String>> tempVoices = [];
        if (voices is List) {
            for (var voice in voices) {
                String voiceStr = voice.toString(); 
                if (voiceStr.contains('zh-CN') || voiceStr.contains('zh_CN')) {
                     tempVoices.add({
                        "name": voice["name"].toString(), 
                        "locale": voice["locale"].toString()
                    });
                }
            }
        }

        setState(() {
            _availableChineseVoices = tempVoices;
        });

        if (_availableChineseVoices.isNotEmpty) {
            // Googleの音声を優先的に選択
            var googleVoice = _availableChineseVoices.firstWhere(
                (v) => v['name']!.contains('Google'), 
                orElse: () => _availableChineseVoices.first
            );
            _setVoice(googleVoice);
        }
    } catch (e) {
        print("❌ 音声リストの取得失敗: $e");
    }
  }

  Future<void> _setVoice(Map<String, String> voice) async {
      setState(() {
          _currentVoice = voice;
      });
      await flutterTts.setVoice(voice);
  }

  Future<void> _speak(String text) async {
    if (_currentVoice != null) {
        await flutterTts.setVoice(_currentVoice!);
    }
    await flutterTts.speak(text);
  }

  // 音声設定ポップアップの表示
  void _showVoiceSettings() {
      showModalBottomSheet(
          context: context, 
          builder: (context) {
              return Container(
                  padding: const EdgeInsets.all(16),
                  height: 400,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text("音声の選択", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text("注意: 表示されるリストはブラウザに依存します。", style: TextStyle(color: Colors.grey)),
                          const Divider(),
                          Expanded(
                              child: _availableChineseVoices.isEmpty 
                                ? const Center(child: Text("中国語の音声が見つかりません。"))
                                : ListView.builder(
                                    itemCount: _availableChineseVoices.length,
                                    itemBuilder: (context, index) {
                                        final voice = _availableChineseVoices[index];
                                        final isSelected = _currentVoice?['name'] == voice['name'];
                                        return ListTile(
                                            leading: Icon(
                                                Icons.record_voice_over, 
                                                color: isSelected ? Colors.deepOrange : Colors.grey
                                            ),
                                            title: Text(voice['name']!),
                                            trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                                            onTap: () {
                                                _setVoice(voice);
                                                _speak("你好"); // テスト発音
                                                Navigator.pop(context);
                                            },
                                        );
                                    },
                                ),
                          )
                      ],
                  ),
              );
          }
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    flutterTts.stop();
    super.dispose();
  }
  
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  // 検索クエリ変更時の処理: 全リストから検索しページネーションを一時無効化
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _updateDisplayedListByPart();
      } else {
        displayedVocabulary = fullVocabularyList.where((item) {
          final simplified = item['simplified'].toString().toLowerCase();
          final pinyin = item['pinyin'].toString().toLowerCase();
          final meaning = item['meaning'].toString().toLowerCase();
          return simplified.contains(query) || pinyin.contains(query) || meaning.contains(query);
        }).toList();
        _sortList(displayedVocabulary);
      }
    });
  }

  // 現在のパートに基づいて表示リストを更新
  void _updateDisplayedListByPart() {
    int start = _currentPartIndex * _itemsPerPart;
    int end = start + _itemsPerPart;
    if (start >= fullVocabularyList.length) {
      start = 0;
      end = _itemsPerPart;
      _currentPartIndex = 0;
    }
    if (end > fullVocabularyList.length) {
      end = fullVocabularyList.length;
    }
    var partList = fullVocabularyList.sublist(start, end).toList();
    _sortList(partList);
    setState(() {
      displayedVocabulary = partList;
    });
    _scrollToTop();
  }
  
  // ソート処理: 未習得を上へ, 習得済みを下へ
  void _sortList(List<dynamic> list) {
      list.sort((a, b) {
          bool rememberA = a['remembered'] ?? false;
          bool rememberB = b['remembered'] ?? false;
          if (rememberA == rememberB) return 0;
          return rememberA ? 1 : -1;
      });
  }

  // APIから単語データを取得
  Future<void> _fetchVocabulary() async {
    setState(() => isLoading = true);
    try {
      String level = 'HSK${_tabController.index + 1}';
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/vocabulary?level=$level'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          fullVocabularyList = data;
          _updateDisplayedListByPart();
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  // 習得状態の切り替え
  Future<void> _toggleRemember(String id) async {
      final index = displayedVocabulary.indexWhere((item) => item['id'] == id);
      if (index != -1) {
          final item = displayedVocabulary[index];
          setState(() {
              item['remembered'] = !(item['remembered'] ?? false);
              final originalItem = fullVocabularyList.firstWhere((e) => e['id'] == id);
              originalItem['remembered'] = item['remembered'];
              _sortList(displayedVocabulary);
          });
          await _apiService.toggleRemember(id);
      }
  }

  @override
  Widget build(BuildContext context) {
    int totalParts = (fullVocabularyList.length / _itemsPerPart).ceil();
    bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('中国語単語学習'),
        backgroundColor: Colors.deepOrange.shade50,
        actions: [
            IconButton(
                icon: const Icon(Icons.settings_voice),
                tooltip: "音声設定",
                onPressed: _showVoiceSettings,
            )
        ],
        bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.deepOrange,
            indicatorColor: Colors.deepOrange,
            tabs: const [
                Tab(text: 'HSK 1'),
                Tab(text: 'HSK 2'),
                Tab(text: 'HSK 3'),
            ],
        ),
      ),
      body: SelectionArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '検索 (単語, ピンイン, 意味)...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            
            // パート選択 (検索中でない場合のみ表示)
            if (!isSearching && totalParts > 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: totalParts,
                  itemBuilder: (context, index) {
                    bool isSelected = _currentPartIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('Part ${index + 1}'),
                        selected: isSelected,
                        selectedColor: Colors.deepOrange.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _currentPartIndex = index;
                              _updateDisplayedListByPart();
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

            if (!isSearching)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '表示中: ${_currentPartIndex * _itemsPerPart + 1} - ${(_currentPartIndex + 1) * _itemsPerPart > fullVocabularyList.length ? fullVocabularyList.length : (_currentPartIndex + 1) * _itemsPerPart} / ${fullVocabularyList.length} 語',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      key: ValueKey('Part_$_currentPartIndex'), 
                      itemCount: displayedVocabulary.length,
                      itemBuilder: (context, index) {
                        final item = displayedVocabulary[index];
                        final isRemembered = item['remembered'] ?? false;
                        
                        final textColor = isRemembered ? Colors.grey : Colors.black;
                        final highlightColor = isRemembered ? Colors.grey : Colors.deepOrange;
                        final subTextColor = isRemembered ? Colors.grey.shade400 : Colors.blueGrey;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: isRemembered ? 0 : 3,
                          color: isRemembered ? Colors.grey.shade100 : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.volume_up, color: isRemembered ? Colors.grey : Colors.blue),
                                  onPressed: () => _speak(item['simplified']),
                                  tooltip: '発音を聞く',
                                ),
                                Switch(
                                    value: isRemembered,
                                    activeColor: Colors.green,
                                    onChanged: (val) => _toggleRemember(item['id']),
                                ),
                              ],
                            ),
                            
                            title: Row(
                              children: [
                                Text(
                                  item['simplified'],
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: highlightColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '[${item['traditional']}]',
                                  style: TextStyle(fontSize: 16, color: subTextColor),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${item['pinyin']} (${item['pinyinWithNumbers']})',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: subTextColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['meaning'],
                                  style: TextStyle(fontSize: 18, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "btnUp",
            onPressed: _scrollToTop,
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: "btnDown",
            onPressed: _scrollToBottom,
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}