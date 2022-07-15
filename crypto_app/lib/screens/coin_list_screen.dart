import 'package:crypto_app/data/constants/colors.dart';
import 'package:crypto_app/data/model/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ShowCoinListScreen extends StatefulWidget {
  ShowCoinListScreen({Key? key, required this.cryptoList}) : super(key: key);
  List<Crypto>? cryptoList;

  @override
  State<ShowCoinListScreen> createState() => _ShowCoinListScreenState();
}

class _ShowCoinListScreenState extends State<ShowCoinListScreen> {
  List<Crypto>? cryptoList;
  bool searchTextTextField = false;
  bool isSearchLoadingVisible = false;
  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppbar(),
      backgroundColor: blackColor,
      body: SafeArea(
          child: RefreshIndicator(
        color: blackColor,
        backgroundColor: greenColor,
        onRefresh: () async {
          List<Crypto> freshData = await _getData();
          setState(
            () {
              cryptoList = freshData;
            },
          );
        },
        child: Column(
          children: [
            searchCoinsByName(),
            Expanded(
              child: ListView.builder(
                itemCount: cryptoList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _getListTileItem(cryptoList![index]),
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _getListTileItem(Crypto crypto) {
    return ListTile(
      title: Container(
        child: Text(
          crypto.name,
          style: TextStyle(
            color: greenColor,
          ),
        ),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor),
      ),
      leading: _getLeadingItem(crypto),
      trailing: _getTrailingItems(crypto),
    );
  }

  Widget _getIconChangePercent(double changePercent) {
    return changePercent <= 0
        ? Icon(
            Icons.trending_down,
            color: _getColorChangePercentItems(changePercent),
          )
        : Icon(
            Icons.trending_up,
            color: _getColorChangePercentItems(changePercent),
          );
  }

  Widget _getTrailingItems(Crypto crypto) {
    return SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints(
                        minHeight: 20,
                        maxHeight: 20,
                        minWidth: 70,
                        maxWidth: 70),
                    child: Center(
                      child: Text(
                        crypto.priceUsd.toStringAsFixed(2),
                        style: TextStyle(
                            color: greyColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        minHeight: 25,
                        maxHeight: 25,
                        minWidth: 70,
                        maxWidth: 70),
                    child: Center(
                      child: Text(
                        crypto.changePercent24Hr.toStringAsFixed(2),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getColorChangePercentItems(crypto.changePercent24Hr),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
            _getIconChangePercent(crypto.changePercent24Hr),
          ],
        ));
  }

  Color _getColorChangePercentItems(double changePercent) {
    return changePercent <= 0 ? redColor : greenColor;
  }

  Widget _getLeadingItem(Crypto crypto) {
    return SizedBox(
      width: 30,
      child: Center(
        child: Text(
          crypto.rank.toString(),
          style: TextStyle(color: greyColor),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppbar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'قیمت رمزارزها',
        style: TextStyle(fontFamily: 'mh'),
      ),
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
              onPressed: () {
                setState(() {
                  searchTextTextField = !searchTextTextField;
                });
              },
              icon: Icon(Icons.search)),
        )
      ],
    );
  }

  //get data methode
  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    //print(response);
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();

    return cryptoList;
  }

  Widget searchCoinsByName() {
    return Visibility(
      visible: searchTextTextField,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          onChanged: (value) {
            _fiterList(value);
          },
          decoration: InputDecoration(
              hintText: 'اسم رمزارز مورد نظر  را سرچ کنید',
              hintStyle: TextStyle(fontFamily: 'mh', color: blackColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 0, style: BorderStyle.none),
              ),
              filled: true,
              fillColor: greenColor),
        ),
      ),
    );
  }

  Future<void> _fiterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchLoadingVisible = true;
      });
      var result = await _getData();
      setState(() {
        cryptoList = result;
        isSearchLoadingVisible = false;
      });
      return;
    }
    cryptoResultList = cryptoList!.where((element) {
      return element.name.toLowerCase().contains(enteredKeyword.toLowerCase());
    }).toList();

    setState(() {
      cryptoList = cryptoResultList;
    });
  }
}
