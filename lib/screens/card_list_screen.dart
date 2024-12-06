
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/colors_const.dart';
import 'edit_card_screen.dart';

class CardListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  final Database database;

  const CardListScreen({
    super.key,
    required this.cards,
    required this.database,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {

  Future<void> _deleteCard(int id) async {
    await widget.database.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Card deleted successfully!');
  }

  final items = [
    Image.asset('assets/card_bg.png'),
    Image.asset('assets/card_1.png'),
    Image.asset('assets/card_bg1.png'),
    Image.asset('assets/card_2.png'),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
        backgroundColor: AppColors.colorB58D67,
      ),
      body: Column(
        children: [
          const SizedBox(height: 5,),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: items,
          ),
          DotsIndicator(
            dotsCount: items.length,
            position: currentIndex,
            decorator: const DotsDecorator(
              color: Colors.white,
              activeColor: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cards.length,
              itemBuilder: (context, index) {
                final card = widget.cards[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.credit_card,
                      color: AppColors.colorB58D67,
                    ),
                    title: Text(card['cardHolderName'] ?? 'No Name'),
                    subtitle: Text(
                      '**** **** **** ${card['cardNumber']?.substring(card['cardNumber'].length - 4)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCardScreen(
                                  card: card,
                                  database: widget.database,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteCard(card['id']);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CardListScreen(
                                  cards: List.from(widget.cards)..removeAt(index),
                                  database: widget.database,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}