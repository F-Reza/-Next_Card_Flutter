

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/colors_const.dart';
import 'edit_card_screen.dart';

class CardListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final Database database;

  const CardListScreen({
    super.key,
    required this.cards,
    required this.database,
  });

  Future<void> _deleteCard(int id) async {
    await database.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Card deleted successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
        backgroundColor: AppColors.colorB58D67,
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
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
                            database: database,
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
                            cards: List.from(cards)..removeAt(index),
                            database: database,
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
    );
  }
}