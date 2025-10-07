class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final int versesCount;
  final String revelationType; // 'Mecquoise' ou 'Médinoise'

  Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.versesCount,
    required this.revelationType,
  });

  // Méthode pour créer un objet Surah depuis JSON (utile pour l'API plus tard)
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      nameArabic: json['nameArabic'],
      versesCount: json['versesCount'],
      revelationType: json['revelationType'],
    );
  }

  // Méthode pour convertir en JSON (utile pour sauvegarder localement)
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'nameArabic': nameArabic,
      'versesCount': versesCount,
      'revelationType': revelationType,
    };
  }
}

// Liste de toutes les sourates (données statiques pour l'instant)
class SurahData {
  static List<Surah> getAllSurahs() {
    return [
      Surah(number: 1, name: 'Al-Fatiha', nameArabic: 'الفاتحة', versesCount: 7, revelationType: 'Mecquoise'),
      Surah(number: 2, name: 'Al-Baqara', nameArabic: 'البقرة', versesCount: 286, revelationType: 'Médinoise'),
      Surah(number: 3, name: 'Al-Imran', nameArabic: 'آل عمران', versesCount: 200, revelationType: 'Médinoise'),
      Surah(number: 4, name: 'An-Nisa', nameArabic: 'النساء', versesCount: 176, revelationType: 'Médinoise'),
      Surah(number: 5, name: 'Al-Maida', nameArabic: 'المائدة', versesCount: 120, revelationType: 'Médinoise'),
      Surah(number: 6, name: 'Al-Anam', nameArabic: 'الأنعام', versesCount: 165, revelationType: 'Mecquoise'),
      Surah(number: 7, name: 'Al-Araf', nameArabic: 'الأعراف', versesCount: 206, revelationType: 'Mecquoise'),
      Surah(number: 18, name: 'Al-Kahf', nameArabic: 'الكهف', versesCount: 110, revelationType: 'Mecquoise'),
      Surah(number: 36, name: 'Ya-Sin', nameArabic: 'يس', versesCount: 83, revelationType: 'Mecquoise'),
      Surah(number: 112, name: 'Al-Ikhlas', nameArabic: 'الإخلاص', versesCount: 4, revelationType: 'Mecquoise'),
      Surah(number: 113, name: 'Al-Falaq', nameArabic: 'الفلق', versesCount: 5, revelationType: 'Mecquoise'),
      Surah(number: 114, name: 'An-Nas', nameArabic: 'الناس', versesCount: 6, revelationType: 'Mecquoise'),
    ];
  }

  // Méthode pour obtenir une sourate spécifique
  static Surah? getSurahByNumber(int number) {
    try {
      return getAllSurahs().firstWhere((surah) => surah.number == number);
    } catch (e) {
      return null;
    }
  }
}