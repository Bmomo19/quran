class Reciter {
  final String name;
  final String arabicName;
  final String identifier; // Pour l'API plus tard

  Reciter({
    required this.name,
    required this.arabicName,
    required this.identifier,
  });
}

class ReciterData {
  static List<Reciter> getAllReciters() {
    return [
      Reciter(name: 'Abdul Basit', arabicName: 'عبد الباسط عبد الصمد', identifier: 'ar.abdulbasitmurattal'),
      Reciter(name: 'Mishary Rashid', arabicName: 'مشاري بن راشد العفاسي', identifier: 'ar.alafasy'),
      Reciter(name: 'Saad Al-Ghamdi', arabicName: 'سعد الغامدي', identifier: 'ar.saadalghamadi'),
      Reciter(name: 'Maher Al-Muaiqly', arabicName: 'ماهر المعيقلي', identifier: 'ar.mahermuaiqly'),
      Reciter(name: 'Ahmed Al-Ajmi', arabicName: 'أحمد العجمي', identifier: 'ar.ahmedajamy'),
    ];
  }
}