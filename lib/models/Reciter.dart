class Reciter {
  final int id;
  final String name;
  final String arabicName;
  final String identifier; // Pour l'API plus tard

  Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.identifier,
  });
}

class ReciterData {
  static List<Reciter> getAllReciters() {
    return [
      Reciter(id: 1, name: 'Abdul Basit', arabicName: 'عبد الباسط عبد الصمد', identifier: 'ar.abdulbasitmurattal'),
      Reciter(id: 2, name: 'Mishary Rashid', arabicName: 'مشاري بن راشد العفاسي', identifier: 'ar.alafasy'),
      Reciter(id: 3, name: 'Saad Al-Ghamdi', arabicName: 'سعد الغامدي', identifier: 'ar.saadalghamadi'),
      Reciter(id: 4, name: 'Maher Al-Muaiqly', arabicName: 'ماهر المعيقلي', identifier: 'ar.mahermuaiqly'),
      Reciter(id: 5, name: 'Ahmed Al-Ajmi', arabicName: 'أحمد العجمي', identifier: 'ar.ahmedajamy'),
    ];
  }
}