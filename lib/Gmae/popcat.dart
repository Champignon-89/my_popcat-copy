import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PopCatGame extends StatefulWidget {
  const PopCatGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PopCatGameState createState() => _PopCatGameState();
}

class _PopCatGameState extends State<PopCatGame> {
  int _clickmoney = 0;
  int _clickUpgrades = 1;
  bool _isClicked = false;
  List<dynamic> upgrades = [];

  @override
  void initState() {
    super.initState();
    _loadUpgrades();
  }

  Future<void> _loadUpgrades() async {
    final String response = await rootBundle.loadString('assets/upgrades.json');
    final data = await json.decode(response);
    setState(() {
      upgrades = data['upgrades'];
    });
  }

  void _handleClick() {
    setState(() {
      _clickmoney += _clickUpgrades;
      _isClicked = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isClicked = false;
      });
    });
  }

  void _openShop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Shop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: upgrades.map((upgrade) {
              return ListTile(
                title: Text('${upgrade['name']}'),
                subtitle: Text('Price: ${upgrade['price']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _buyUpgrade(upgrade);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Buy'),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _buyUpgrade(dynamic upgrade) {
    int upgradePrice = upgrade['price'];
    if (_clickmoney >= upgradePrice) {
      // ตรวจสอบว่า clickCount เพียงพอหรือไม่
      setState(() {
        _clickmoney -= upgradePrice;
        upgrade['price'] = ((upgradePrice * (1.5 + _clickUpgrades)).toInt());
        _clickUpgrades += (upgrade['increment'] as num).toInt();
      });
    } else {
      // แสดงข้อความแจ้งเตือนเมื่อ clickCount ไม่เพียงพอ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough cat money!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POPCAT Game',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 1),
                child: Text(
                  'Cat Power: $_clickUpgrades',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _handleClick,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  _isClicked
                      ? 'assets/images/popcat.png'
                      : 'assets/images/cat.png',
                  width: 900,
                  height: 350,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'POP money: $_clickmoney',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight, // กำหนดให้ชิดขวา
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 5),
                child: ElevatedButton.icon(
                  onPressed: _openShop,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('SHOP'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
