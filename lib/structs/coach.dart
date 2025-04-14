class Coach {
  final int indexInFormation;
  final String? classSeating; // What class of seating available in this coach
  final int? loading;
  final String? coachNumber;
  final String? toiletType;

  Coach(
      {required this.indexInFormation,
      this.classSeating,
      this.loading,
      this.coachNumber,
      this.toiletType});

  factory Coach.fromJSON(
    Map<String, dynamic> json,
    int indexInFormation,
  ) {
    return Coach(
        indexInFormation: indexInFormation,
        classSeating: json["coachClass"],
        loading:
            json["loading"], // TODO: needs testing (no example found on api)
        coachNumber:
            json["attributes"] != null ? json["attributes"]["number"] : null,
        toiletType: json["toilet"].toString());
  }

  @override
  String toString() {
    return "$indexInFormation: Number: $coachNumber, loading: $loading, class: $classSeating, toilet-type: $toiletType";
  }
}
