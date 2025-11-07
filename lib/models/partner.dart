class Partner {
  final String name;
  final DateTime? birthday;
  final DateTime? togetherSince;
  final String? gender;
  final String? loveLanguagePrimary;
  final String? loveLanguageSecondary;
  final String? favorites;
  final String? dislikes;
  final String? budget;
  final String? photoPath;
  // Love language ratings: 0–5
  final int? qualityTime;
  final int? wordsOfAffirmation;
  final int? actsOfService;
  final int? physicalTouch;
  final int? receivingGifts;

  Partner({
    required this.name,
    this.birthday,
    this.togetherSince,
    this.gender,
    this.loveLanguagePrimary,
    this.loveLanguageSecondary,
    this.favorites,
    this.dislikes,
    this.budget,
    this.photoPath,
    this.qualityTime,
    this.wordsOfAffirmation,
    this.actsOfService,
    this.physicalTouch,
    this.receivingGifts,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthday': birthday?.toIso8601String(),
        'togetherSince': togetherSince?.toIso8601String(),
        'gender': gender,
        'loveLanguagePrimary': loveLanguagePrimary,
        'loveLanguageSecondary': loveLanguageSecondary,
        'favorites': favorites,
        'dislikes': dislikes,
        'budget': budget,
        'photoPath': photoPath,
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
        togetherSince: json['togetherSince'] != null
            ? DateTime.parse(json['togetherSince'])
            : null,
        gender: json['gender'],
        loveLanguagePrimary: json['loveLanguagePrimary'],
        loveLanguageSecondary: json['loveLanguageSecondary'],
        favorites: json['favorites'],
        dislikes: json['dislikes'],
        budget: json['budget'],
        photoPath: json['photoPath'],
        qualityTime: json['qualityTime'],
        wordsOfAffirmation: json['wordsOfAffirmation'],
        actsOfService: json['actsOfService'],
        physicalTouch: json['physicalTouch'],
        receivingGifts: json['receivingGifts'],
      );
}

extension PartnerCopyExt on Partner {
  Partner copyWith({
    String? name,
    DateTime? birthday,
    DateTime? togetherSince,
    String? gender,
    String? loveLanguagePrimary,
    String? loveLanguageSecondary,
    String? favorites,
    String? dislikes,
    String? budget,
    String? photoPath,
    int? qualityTime,
    int? wordsOfAffirmation,
    int? actsOfService,
    int? physicalTouch,
    int? receivingGifts,
  }) {
    return Partner(
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      togetherSince: togetherSince ?? this.togetherSince,
      gender: gender ?? this.gender,
      loveLanguagePrimary: loveLanguagePrimary ?? this.loveLanguagePrimary,
      loveLanguageSecondary: loveLanguageSecondary ?? this.loveLanguageSecondary,
      favorites: favorites ?? this.favorites,
      dislikes: dislikes ?? this.dislikes,
      budget: budget ?? this.budget,
      photoPath: photoPath ?? this.photoPath,
      qualityTime: qualityTime ?? this.qualityTime,
      wordsOfAffirmation: wordsOfAffirmation ?? this.wordsOfAffirmation,
      actsOfService: actsOfService ?? this.actsOfService,
      physicalTouch: physicalTouch ?? this.physicalTouch,
      receivingGifts: receivingGifts ?? this.receivingGifts,
    );
  }
}
