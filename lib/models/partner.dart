class Partner {
  final String name;
  final DateTime? birthday;
  final String? loveLanguagePrimary;
  final String? loveLanguageSecondary;
  final String? favorites;
  final String? dislikes;
  final String? budget;
  // Love language ratings: 0–5
  final int? qualityTime;
  final int? wordsOfAffirmation;
  final int? actsOfService;
  final int? physicalTouch;
  final int? receivingGifts;

  Partner({
    required this.name,
    this.birthday,
    this.loveLanguagePrimary,
    this.loveLanguageSecondary,
    this.favorites,
    this.dislikes,
    this.budget,
    this.qualityTime,
    this.wordsOfAffirmation,
    this.actsOfService,
    this.physicalTouch,
    this.receivingGifts,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthday': birthday?.toIso8601String(),
        'loveLanguagePrimary': loveLanguagePrimary,
        'loveLanguageSecondary': loveLanguageSecondary,
        'favorites': favorites,
        'dislikes': dislikes,
        'budget': budget,
        'qualityTime': qualityTime,
        'wordsOfAffirmation': wordsOfAffirmation,
        'actsOfService': actsOfService,
        'physicalTouch': physicalTouch,
        'receivingGifts': receivingGifts,
      };

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        name: json['name'] ?? '',
        birthday: json['birthday'] != null
            ? DateTime.parse(json['birthday'])
            : null,
        loveLanguagePrimary: json['loveLanguagePrimary'],
        loveLanguageSecondary: json['loveLanguageSecondary'],
        favorites: json['favorites'],
        dislikes: json['dislikes'],
        budget: json['budget'],
        qualityTime: json['qualityTime'],
        wordsOfAffirmation: json['wordsOfAffirmation'],
        actsOfService: json['actsOfService'],
        physicalTouch: json['physicalTouch'],
        receivingGifts: json['receivingGifts'],
      );
}
