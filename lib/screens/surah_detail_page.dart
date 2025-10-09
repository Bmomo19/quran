import 'package:flutter/material.dart';
import 'package:qourane/services/api_service.dart';
import 'package:qourane/services/audio_service.dart';
import 'package:qourane/utils/constants.dart';
import '../models/surah.dart';
import '../models/reciter.dart';
import '../widgets/verse_card.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  Reciter? selectedReciter;

  bool isListenMode = true;
  bool isPlaying = false;
  int selectedReciterId = ReciterIds.misharyRashid;
  List<String> verses = [];
  List reciters = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentAudioUrl;
  final AudioService _audioService = AudioService();
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _loadVerses();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadVerses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await apiService.getSurahWithVerses(widget.surah.number);

      setState(() {
        verses = result['verses'] as List<String>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });

      // // Fallback: garder les versets par défaut
      // setState(() {
      //   verses = [
      //     'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      //     'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      //     'الرَّحْمَٰنِ الرَّحِيمِ',
      //     'مَالِكِ يَوْمِ الدِّينِ',
      //     'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      //     'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      //     'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      //   ];
      // });
    }
  }

  Future<void> _toggleAudio() async {
    if (isPlaying) {
      await _audioService.pause();
      setState(() => isPlaying = false);
    } else {
      try {
        if (_currentAudioUrl == null) {
          // Charger l'URL audio
          final apiService = ApiService();
          _currentAudioUrl = await apiService.getAudioUrl(
            widget.surah.number,
            selectedReciterId,
          );
        }

        await _audioService.play(_currentAudioUrl!);
        setState(() => isPlaying = true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur audio: $e')));
      }
    }
  }

  Future<void> _allRecitateur() async {
    try {
      final result = await apiService.getRecitations();
      setState(() {
        reciters = result as List<Reciter>;
      });
      print('${reciters.length} récitateurs disponibles');
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildModeSelector(),
          if (isListenMode) _buildAudioPlayer(),
          _buildVersesList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.surah.name,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  widget.surah.nameArabic,
                  style: const TextStyle(
                    fontSize: 32,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.surah.versesCount} versets',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => isListenMode = true),
                icon: const Icon(Icons.headset),
                label: const Text('Écoute'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isListenMode
                      ? AppColors.primary
                      : Colors.grey[300],
                  foregroundColor: isListenMode ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => isListenMode = false),
                icon: const Icon(Icons.menu_book),
                label: const Text('Lecture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isListenMode
                      ? AppColors.primary
                      : Colors.grey[300],
                  foregroundColor: !isListenMode ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Récitateur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: selectedReciterId,
                isExpanded: true,
                underline: const SizedBox(),
                items: reciters.map((recit) {
                  return DropdownMenuItem<int>(
                    value: recit.id,
                    child: Text(recit.reciter_name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedReciterId = newValue!;
                    _currentAudioUrl = null; // Réinitialiser l'URL
                    if (isPlaying) {
                      _audioService.stop();
                      isPlaying = false;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _toggleAudio,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next),
                  iconSize: 40,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Slider(
              value: 0.3,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1:23', style: TextStyle(fontSize: 12)),
                  Text('4:56', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return VerseCard(
            verseNumber: index + 1,
            verseText: verses[index],
            onBookmark: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté aux favoris')),
              );
            },
            onShare: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partager le verset')),
              );
            },
          );
        }, childCount: verses.length),
      ),
    );
  }
}
