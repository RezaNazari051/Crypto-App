class Crypto {
  String name;
  String symbol;
  int rank;
  double priceUsd;
  double changePercent24Hr;
  Crypto(
      this.name, this.symbol, this.rank, this.priceUsd, this.changePercent24Hr);

  factory Crypto.fromMapJson(Map<String, dynamic> jsonMapObject) {
    return Crypto(
        jsonMapObject['name'],
        jsonMapObject['symbol'],
        int.parse(jsonMapObject['rank']),
        double.parse(jsonMapObject['priceUsd']),
        double.parse(jsonMapObject['changePercent24Hr']));
  }
}
