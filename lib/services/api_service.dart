import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qourane/utils/constants.dart';
import '../models/surah.dart';
import 'storage_service.dart';

class ApiService {
  // URLs de l'API Quran.com
  static const String oauthUrl = QuranApiConfig.oauthUrl;
  static const String baseUrl = QuranApiConfig.baseUrl;

  static const String clientId = QuranApiConfig.clientId;
  static const String clientSecret = QuranApiConfig.clientSecret;

  final StorageService _storage = StorageService();

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Obtenir le token d'accès (avec gestion de l'expiration)
  Future<String> _getAccessToken() async {
    // Vérifier si le token existe et n'est pas expiré
    if (_accessToken != null && _tokenExpiry != null) {
      // Vérifier si le token expire dans plus de 5 minutes
      if (_tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
        return _accessToken!;
      }
    }

    // Récupérer le token depuis le stockage local
    final storedToken = await _storage.getSetting<String>('access_token');
    final storedExpiry = await _storage.getSetting<String>('token_expiry');

    if (storedToken != null && storedExpiry != null) {
      final expiryDate = DateTime.parse(storedExpiry);

      // Vérifier si le token stocké est encore valide
      if (expiryDate.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
        _accessToken = storedToken;
        _tokenExpiry = expiryDate;
        return _accessToken!;
      }
    }

    // Si aucun token valide, en obtenir un nouveau
    return await _refreshAccessToken();
  }

  // Rafraîchir le token d'accès
  Future<String> _refreshAccessToken() async {
    try {
      // Créer l'authentification Basic
      final auth = base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse(oauthUrl),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&scope=content',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int; // en secondes

        // Calculer la date d'expiration
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        // Sauvegarder le token et son expiration
        await _storage.saveSetting('access_token', _accessToken!);
        await _storage.saveSetting('token_expiry', _tokenExpiry!.toIso8601String());

        return _accessToken!;
      } else {
        throw Exception('Erreur lors de l\'obtention du token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur d\'authentification: $e');
    }
  }

  // Récupérer toutes les sourates
  Future<List<Surah>> getAllSurahs() async {
    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/chapters'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List chapters = data['chapters'];

        return chapters.map((chapter) {
          return Surah(
            number: chapter['id'],
            name: chapter['name_simple'],
            nameArabic: chapter['name_arabic'],
            versesCount: chapter['verses_count'],
            revelationType: chapter['revelation_place'] == 'makkah'
                ? 'Mecquoise'
                : 'Médinoise',
          );
        }).toList();
      } else if (response.statusCode == 401) {
        // Token expiré, rafraîchir et réessayer
        await _refreshAccessToken();
        return await getAllSurahs();
      } else {
        throw Exception('Erreur lors du chargement des sourates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer une sourate spécifique avec ses versets
  Future<Map<String, dynamic>> getSurahWithVerses(int chapterId) async {
    try {
      final token = await _getAccessToken();

      // Récupérer les informations de la sourate
      final chapterResponse = await http.get(
        Uri.parse('$baseUrl/chapters/$chapterId'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      // Récupérer les versets de la sourate
      final versesResponse = await http.get(
        Uri.parse('$baseUrl/verses/by_chapter/$chapterId?words=false&translations=false&audio=false'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (chapterResponse.statusCode == 200 && versesResponse.statusCode == 200) {
        final chapterData = json.decode(chapterResponse.body)['chapter'];
        final versesData = json.decode(versesResponse.body);

        final surah = Surah(
          number: chapterData['id'],
          name: chapterData['name_simple'],
          nameArabic: chapterData['name_arabic'],
          versesCount: chapterData['verses_count'],
          revelationType: chapterData['revelation_place'] == 'makkah'
              ? 'Mecquoise'
              : 'Médinoise',
        );

        // Extraire les versets
        final List verses = versesData['verses'];
        final List<String> verseTexts = verses
            .map((verse) => verse['text_uthmani'] as String)
            .toList();

        return {
          'surah': surah,
          'verses': verseTexts,
        };
      } else if (chapterResponse.statusCode == 401 || versesResponse.statusCode == 401) {
        // Token expiré, rafraîchir et réessayer
        await _refreshAccessToken();
        return await getSurahWithVerses(chapterId);
      } else {
        throw Exception('Erreur lors du chargement de la sourate');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les récitations audio disponibles
  Future<List<Map<String, dynamic>>> getRecitations() async {
    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/resources/recitations'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recitations = data['recitations'];

        return recitations.map((rec) => {
          'id': rec['id'],
          'reciter_name': rec['reciter_name'],
          'style': rec['style'],
        }).toList();
      } else if (response.statusCode == 401) {
        await _refreshAccessToken();
        return await getRecitations();
      } else {
        throw Exception('Erreur lors du chargement des récitations');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer l'URL audio d'une sourate avec un récitateur spécifique
  Future<String> getAudioUrl(int chapterId, int recitationId) async {
    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/chapter_recitations/$recitationId/$chapterId'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audioFile = data['audio_file'];

        return audioFile['audio_url'];
      } else if (response.statusCode == 401) {
        await _refreshAccessToken();
        return await getAudioUrl(chapterId, recitationId);
      } else {
        throw Exception('Erreur lors du chargement de l\'audio');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les traductions disponibles
  Future<List<Map<String, dynamic>>> getTranslations({String? language}) async {
    try {
      final token = await _getAccessToken();

      String url = '$baseUrl/resources/translations';
      if (language != null) {
        url += '?language=$language';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List translations = data['translations'];

        return translations.map((trans) => {
          'id': trans['id'],
          'name': trans['name'],
          'author_name': trans['author_name'],
          'language_name': trans['language_name'],
        }).toList();
      } else if (response.statusCode == 401) {
        await _refreshAccessToken();
        return await getTranslations(language: language);
      } else {
        throw Exception('Erreur lors du chargement des traductions');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer une sourate avec sa traduction
  Future<Map<String, dynamic>> getSurahWithTranslation(
      int chapterId,
      int translationId
      ) async {
    try {
      final token = await _getAccessToken();

      // Récupérer les informations de la sourate
      final chapterResponse = await http.get(
        Uri.parse('$baseUrl/chapters/$chapterId'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      // Récupérer les versets avec traduction
      final versesResponse = await http.get(
        Uri.parse('$baseUrl/verses/by_chapter/$chapterId?words=false&translations=$translationId&audio=false'),
        headers: {
          'x-auth-token': token,
          'x-client-id': clientId,
        },
      );

      if (chapterResponse.statusCode == 200 && versesResponse.statusCode == 200) {
        final chapterData = json.decode(chapterResponse.body)['chapter'];
        final versesData = json.decode(versesResponse.body);

        final surah = Surah(
          number: chapterData['id'],
          name: chapterData['name_simple'],
          nameArabic: chapterData['name_arabic'],
          versesCount: chapterData['verses_count'],
          revelationType: chapterData['revelation_place'] == 'makkah'
              ? 'Mecquoise'
              : 'Médinoise',
        );

        // Combiner les versets arabes avec leur traduction
        final List verses = versesData['verses'];
        final List<Map<String, String>> combinedVerses = verses.map((verse) {
          final translations = verse['translations'] as List;
          final translationText = translations.isNotEmpty
              ? translations[0]['text']
              : '';

          return {
            'arabic': verse['text_uthmani'] as String,
            'translation': translationText as String,
          };
        }).toList();

        return {
          'surah': surah,
          'verses': combinedVerses,
        };
      } else if (chapterResponse.statusCode == 401 || versesResponse.statusCode == 401) {
        await _refreshAccessToken();
        return await getSurahWithTranslation(chapterId, translationId);
      } else {
        throw Exception('Erreur lors du chargement de la traduction');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Forcer le rafraîchissement du token (utile pour les tests)
  Future<void> forceTokenRefresh() async {
    await _refreshAccessToken();
  }

  // Vérifier si le token est valide
  bool isTokenValid() {
    if (_accessToken == null || _tokenExpiry == null) {
      return false;
    }
    return _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  // Obtenir le temps restant avant expiration du token
  Duration? getTokenTimeRemaining() {
    if (_tokenExpiry == null) return null;
    return _tokenExpiry!.difference(DateTime.now());
  }
}