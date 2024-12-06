

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/colors_const.dart';

class EditCardScreen extends StatefulWidget {
  final Map<String, dynamic> card;
  final Database database;

  const EditCardScreen({
    super.key,
    required this.card,
    required this.database,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;

  @override
  void initState() {
    super.initState();
    cardNumber = widget.card['cardNumber'] ?? '';
    expiryDate = widget.card['expiryDate'] ?? '';
    cardHolderName = widget.card['cardHolderName'] ?? '';
    cvvCode = widget.card['cvvCode'] ?? '';
  }

  Future<void> _updateCard(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final id = widget.card['id'];
      if (id != null) {
        await widget.database.update(
          'cards',
          {
            'cardNumber': cardNumber,
            'expiryDate': expiryDate,
            'cardHolderName': cardHolderName,
            'cvvCode': cvvCode,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        print('Card updated successfully!');
        Navigator.of(context).pop(true);
      } else {
        print('Card ID is null. Cannot update.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        backgroundColor: AppColors.colorB58D67,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: cardNumber,
                decoration: const InputDecoration(labelText: 'Card Number'),
                onChanged: (value) => cardNumber = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Card Number is required' : null,
              ),
              TextFormField(
                initialValue: expiryDate,
                decoration: const InputDecoration(labelText: 'Expiry Date'),
                onChanged: (value) => expiryDate = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Expiry Date is required' : null,
              ),
              TextFormField(
                initialValue: cardHolderName,
                decoration: const InputDecoration(labelText: 'Card Holder Name'),
                onChanged: (value) => cardHolderName = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Card Holder Name is required' : null,
              ),
              TextFormField(
                initialValue: cvvCode,
                decoration: const InputDecoration(labelText: 'CVV Code'),
                onChanged: (value) => cvvCode = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'CVV Code is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateCard(context),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
