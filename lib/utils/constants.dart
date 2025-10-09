import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00897B);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color accent = Color(0xFF4DB6AC);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF757575);
}

// Configuration OAuth Quran.com
// ⚠️ IMPORTANT: Remplacez ces valeurs par vos vrais identifiants
class QuranApiConfig {
  static const String clientId = '739a7ddf-3da5-4c96-999d-273d37c28be4';
  static const String clientSecret = 'wfZx408XJ3YLa.83k42g1-Dyp0';
  static const String oauthUrl = 'https://prelive-oauth2.quran.foundation/oauth2/token';
  static const String baseUrl = 'https://apis-prelive.quran.foundation/content/api/v4';
}

// IDs des traductions populaires (Quran.com API)
class TranslationIds {
  static const int french = 31; // French - Muhammad Hamidullah
  static const int english = 131; // English - Dr. Mustafa Khattab
  static const int spanish = 83; // Spanish - Abdel Ghani Navio
  static const int german = 27; // German - Amir Zaidan
  static const int turkish = 77; // Turkish - Diyanet İşleri
  static const int urdu = 97; // Urdu - Abul A'ala Maududi
}

// IDs des récitateurs populaires (Quran.com API)
class ReciterIds {
  static const int abdulBasit = 1; // AbdulBaset AbdulSamad
  static const int misharyRashid = 7; // Mishary Rashid Alafasy
  static const int sudais = 3; // Abdur-Rahman as-Sudais
  static const int hussary = 2; // Mahmoud Khalil Al-Hussary
  static const int saadAlGhamdi = 5; // Saad Al-Ghamdi
  static const int maherAlMuaiqly = 9; // Maher Al Muaiqly
  static const int ahmedAlAjmi = 11; // Ahmed ibn Ali al-Ajamy
}

// Clés pour SharedPreferences
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String tokenExpiry = 'token_expiry';
  static const String darkMode = 'dark_mode';
  static const String fontSize = 'font_size';
  static const String selectedReciter = 'selected_reciter';
  static const String selectedTranslation = 'selected_translation';
  static const String autoPlay = 'auto_play';
  static const String lastReadSurah = 'last_read_surah';
  static const String lastReadVerse = 'last_read_verse';
  static const String bookmarks = 'bookmarks';
  static const String history = 'history';
}

// Tailles de police
class FontSizes {
  static const double small = 20.0;
  static const double medium = 24.0;
  static const double large = 28.0;
  static const double extraLarge = 32.0;
}

// Messages d'erreur
class ErrorMessages {
  static const String noInternet = 'Pas de connexion Internet';
  static const String serverError = 'Erreur du serveur';
  static const String unknownError = 'Une erreur est survenue';
  static const String loadingFailed = 'Échec du chargement';
  static const String authError = 'Erreur d\'authentification';
  static const String tokenExpired = 'Session expirée';
}
