import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:next_card/utils/colors_const.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'card_list_screen.dart';



class CreditCardInputForm extends StatefulWidget {
  const CreditCardInputForm({super.key});

  @override
  State<CreditCardInputForm> createState() => _CreditCardInputFormState();
}

class _CreditCardInputFormState extends State<CreditCardInputForm> {
  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;

  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'credit_cards.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE cards(id INTEGER PRIMARY KEY, cardNumber TEXT, expiryDate TEXT, cardHolderName TEXT, cvvCode TEXT)'
        );
      },
      version: 1,
    );
  }

  Future<void> _saveCard() async {
    if (_database != null) {
      await _database!.insert(
        'cards',
        {
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cardHolderName': cardHolderName,
          'cvvCode': cvvCode,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Card saved successfully!');
    }
  }

  Future<void> _navigateToCardList(BuildContext context) async {
    if (_database != null) {
      final List<Map<String, dynamic>> cards = await _database!.query('cards');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardListScreen(
            cards: cards,
            database: _database!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Next Credit Card',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: _buildThemeData(Brightness.light),
      darkTheme: _buildThemeData(Brightness.dark),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: isLightTheme ? AppColors.bgLight : AppColors.bgDark,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _navigateToCardList(context),
                            icon: Icon(Icons.sd_card_outlined, color: isLightTheme ? Colors.black : Colors.white),
                          ),
                          const Text(
                            'Next Credit Card',
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              isLightTheme = !isLightTheme;
                            }),
                            icon: Icon(
                              isLightTheme ? Icons.light_mode : Icons.dark_mode,
                              color: isLightTheme ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Axis Bank',
                      frontCardBorder:
                      useGlassMorphism ? null : Border.all(color: Colors.grey),
                      backCardBorder:
                      useGlassMorphism ? null : Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      cardBgColor: isLightTheme
                          ? AppColors.cardBgLightColor
                          : AppColors.cardBgColor,
                      backgroundImage:
                      useBackgroundImage ? 'assets/card_bg.png' : 'assets/card_bg1.png',
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            _buildSwitchRow('Glassmorphism', useGlassMorphism,
                                    (value) => setState(() => useGlassMorphism = value)),
                            _buildSwitchRow('Card Image', useBackgroundImage,
                                    (value) => setState(() => useBackgroundImage = value)),
                            _buildSwitchRow('Floating Card', useFloatingAnimation,
                                    (value) => setState(() => useFloatingAnimation = value)),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _onValidate(context),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      AppColors.colorB58D67,
                                      AppColors.colorF9EED2,
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'halter',
                                    fontSize: 14,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildThemeData(Brightness brightness) {
    return ThemeData(
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
          fontSize: 18,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: brightness == Brightness.light ? Colors.white : Colors.black,
        background: brightness == Brightness.light ? Colors.black : Colors.white,
        primary: brightness == Brightness.light ? Colors.black : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        labelStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }

  void _onValidate(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      //_saveCard();
      _clearCard();
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Card is valid!',
          message:
          'Card saved on the card list.',
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      print('Invalid!');
    }
  }

  void _clearCard() {
    setState(() {
      cardNumber = '';
      expiryDate = '';
      cardHolderName = '';
      cvvCode = '';
    });

  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );
    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title),
          const Spacer(),
          Switch(
            value: value,
            inactiveTrackColor: Colors.white70,
            activeColor: Colors.white,
            activeTrackColor: AppColors.colorE5D1B2,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }


}

