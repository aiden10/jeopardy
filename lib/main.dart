/*
To do:
- Indicators for correct and incorrect (score/money earned?) x
- Stat tracking x
- Stats menu x
- Polish
- Daily doubles
- Final jeopardy
- Allow full games to be played (might as well be a different app)
- Ads?
- Question history
*/

import 'package:flutter/material.dart';
import 'variables.dart';
import 'dart:math'; // For generating random numbers
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger = Logger();
final Random random = Random();
final data = loadJsonData();
TextEditingController controller = TextEditingController();

void main() {
  runApp(const MyApp());
}

Future<Map<String, dynamic>?> loadJsonData() async { // what question mark does I don't know
  try {
    String jsonData = await rootBundle.loadString('assets/jeopardy.json');
    Map<String, dynamic> data = json.decode(jsonData);
    logger.i('JSON loaded');
    return data;
  }
  
  catch (e) {
    logger.e('Error loading JSON: $e');
    return null;
  }
}

List<String> fetchRandomGame(Map<String, dynamic> data){
  int randomGameNum = random.nextInt(9013) + 1;
  String doubleOrRegular;
  randomGameNum < 4507 ? doubleOrRegular = 'jeopardy' : doubleOrRegular = 'double';

  int randomQuestionNum = random.nextInt(data[randomGameNum.toString()][doubleOrRegular].length);
  String answer = (data[randomGameNum.toString()][doubleOrRegular])[randomQuestionNum]['a'];
  String category = (data[randomGameNum.toString()][doubleOrRegular])[randomQuestionNum]['cat'];
  int value = (data[randomGameNum.toString()][doubleOrRegular])[randomQuestionNum]['val'];
  String question = (data[randomGameNum.toString()][doubleOrRegular])[randomQuestionNum]['q'];
  String date = data[randomGameNum.toString()]['airDate'];
  return [question, category, answer, value.toString(), date, randomGameNum.toString()];
}

class MyApp extends StatelessWidget { // Widget representing the app as a whole
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { // how it gets built
    return const MaterialApp( // returns a MaterialApp widget which contains the MyHomePage widget
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget { // stateful MyHomePage widget 
  const MyHomePage({super.key});

  @override
  GameState createState() => GameState(); // every StatefulWidget must implement the createState method and have a State which then gets updated
}

class GameState extends State<MyHomePage> {
  SharedPreferences? prefs;
  Map<String, dynamic>? _data;
  List<String>? _randomData;
  String _currentQuestion = '';
  String _currentCategory = '';
  String _currentAnswer = '';
  String _currentValue = '';
  String _currentQuestionDate = '';
  String _currentQuestionGameNum = '';
  bool _buzzed = false;
  bool _displayInfo = false;
  int _money = 0;
  int _currentStreak = 0;
  int _correctAnswerCount = 0;
  int _incorrectAnswerCount = 0;
  int _skippedCount = 0;
  int _sessionMoney = 0;
  double _accuracy = 0; // correct / (incorrect + correct)
  int _earnings = 0;  
  double _answerPadding = 0.05;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await loadJsonData();
    prefs = await SharedPreferences.getInstance();
    if (data != null) {
      setState(() {
        _data = data;
        _randomData = fetchRandomGame(_data!);
        _currentQuestion = _randomData![0];
        _currentCategory = _randomData![1];
        _currentAnswer = _randomData![2];
        _currentValue = _randomData![3];
        _currentQuestionDate = _randomData![4];
        _currentQuestionGameNum = _randomData![5];
        _money = prefs?.getInt('money') ?? 0; // default value of 0 if assignment fails
        _currentStreak = prefs?.getInt('streak') ?? 0;
        _correctAnswerCount = prefs?.getInt('correctAnswerCount') ?? 0;
        _incorrectAnswerCount = prefs?.getInt('incorrectAnswerCount') ?? 0;
        _skippedCount = prefs?.getInt('skippedCount') ?? 0;
        _accuracy = prefs?.getDouble('accuracy') ?? 0.0;
        _earnings = prefs?.getInt('earnings') ?? 0;
      });
    }
  }

  void _loadNewQuestion() {
    List<String> randomData = fetchRandomGame(_data!); 
    setState(() {
      _currentCategory = randomData[1];
      _currentQuestion = randomData[0];
      _currentAnswer = randomData[2];
      _currentValue = randomData[3];
      _currentQuestionDate = randomData[4];
      _currentQuestionGameNum = randomData[5];
      _accuracy = _correctAnswerCount / (_correctAnswerCount + _incorrectAnswerCount); 
      storeDoubleValue('accuracy', _accuracy);
    });
  }
  
  void _correctAnswer() async{
    setState(() {
      _money += int.parse(_currentValue);
      _earnings += int.parse(_currentValue);
      _sessionMoney += int.parse(_currentValue);
      _currentStreak++;
      _correctAnswerCount++;
      storeIntValue('money', _money);
      storeIntValue('streak', _currentStreak);
      storeIntValue('correctAnswerCount', _correctAnswerCount);
      storeIntValue('earnings', _earnings);
      _buzzed = false;
      _answerPadding = 0.05;
      _loadNewQuestion();
    });              
  }

  void _incorrectAnswer() async{
    setState(() {
      _currentStreak = 0;
      _incorrectAnswerCount++;
      _earnings -= int.parse(_currentValue);
      _sessionMoney -= int.parse(_currentValue);
      storeIntValue('money', _money);
      storeIntValue('streak', _currentStreak);
      storeIntValue('incorrectAnswerCount', _incorrectAnswerCount);
      storeIntValue('earnings', _earnings);
      _buzzed = false;
      _answerPadding = 0.05;
      _loadNewQuestion();
    });                    
  }

  void skip() async {
    setState(() {
      _buzzed = false;
      _answerPadding = 0.05;
      _skippedCount++;
      storeIntValue('skippedCount', _skippedCount);
      _loadNewQuestion();
    });
  }

  void storeIntValue(String key, int value) async{
    await prefs?.setInt(key, value);
  }
  
  void storeDoubleValue(String key, double value) async{
    await prefs?.setDouble(key, value);
  }

  Color updateSessionMoneyColor(){
    int localMoney = _sessionMoney;
    if (_sessionMoney < 0){
      localMoney *= -1;
      int rValue = 85 + (localMoney ~/ 50);
      return Color.fromARGB(255, rValue, 0, 20);
    }
    else if (_sessionMoney == 0){
      return const Color.fromARGB(255, 255, 255, 255);
    }
    else{ // Color.fromARGB(200, 0, 193, 140)
      int gValue = 85 + (localMoney ~/ 50);
      return Color.fromARGB(255, 0, gValue, 80);
    }
  }

  void resetStats(){
    setState(() {
      _money = 0;
      _currentStreak = 0;
      _correctAnswerCount = 0;
      _incorrectAnswerCount = 0;
      _skippedCount = 0;
      _accuracy = 0; 
      _earnings = 0;  
      _sessionMoney = 0;

      storeIntValue('money', 0);
      storeIntValue('earnings', 0);
      storeIntValue('streak', 0);
      storeIntValue('incorrectAnswerCount', 0);
      storeIntValue('correctAnswerCount', 0);
      storeIntValue('skippedCount', 0);
      storeDoubleValue('accuracy', 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    Variables.init(context); // Load class with constant variables for use

    if (_data == null) { // if JSON is loading, show progress bar
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget buttonsWidget = const SizedBox();
    Widget answerWidget = const SizedBox();
    Widget statsWidget = const SizedBox();

    if (_buzzed) {
      // Show the buttons if submission has occurred
      buttonsWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 30),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 145, 23, 12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _incorrectAnswer();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 30),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(200, 0, 193, 140),
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {
                _correctAnswer();
              },
            ),
          ),
        ],
      );

      answerWidget = Container(
        width: Variables.screenWidth * 0.8,
        color: const Color.fromARGB(240, 246, 243, 243), // White background color
        padding: const EdgeInsets.all(16), // Padding for the white background
        child: Center(
          child: Text(
            'ANSWER: $_currentAnswer'.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black, // Text color against white background
            ),
          ),
        ),
      );
    }

    if (_displayInfo) {
      statsWidget = Stack(
        children: [
          Center(
            child: Container(
              width: Variables.screenWidth * 0.9, // Width of the square
              height: Variables.screenHeight * 0.45, // Height of the square
              decoration: BoxDecoration(
                border: Border.all(width: 10, color: const Color.fromARGB(255, 144, 120, 47)),
                color: const Color.fromARGB(255, 108, 96, 60).withOpacity(0.85), // Half-transparent black color
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 0, 0),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        """
Total Money Earned: \$$_money
Earnings: \$$_earnings
Current Streak: $_currentStreak
Number of Incorrect Answers: $_incorrectAnswerCount
Number of Correct Answers: $_correctAnswerCount
Number of Questions Skipped: $_skippedCount
Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%
Game Number: $_currentQuestionGameNum
Question Date: $_currentQuestionDate
                          """,
                        style: const TextStyle(
                          fontSize: 17.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(225, 216, 168, 21),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        minimumSize: Size(Variables.screenWidth * 0.9, Variables.screenHeight * 0.055),
                      ),
                      onPressed: () {
                        resetStats();
                      },
                      child: const Text(
                        'Reset Stats',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Variables.screenWidth * 0.1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Variables.screenHeight * 0.07), // Adjust height as needed
                    Text(
                      '\$$_currentValue',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 211, 191, 9),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.03),
                    Container(
                      color: const Color.fromARGB(255, 240, 238, 233),
                      width: Variables.screenWidth * 0.8,
                      padding: EdgeInsets.all(Variables.screenHeight * 0.04),
                      child: Center(
                        child: Text(
                          _currentCategory,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Variables.screenWidth * 0.025,
                      ),
                      child: Text(
                        _currentQuestion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * _answerPadding), // conditional padding
                    answerWidget,
                    SizedBox(height: Variables.screenHeight * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Visibility(
                        visible: !_buzzed,
                        child: TapRegion(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: TextField(
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(240, 246, 243, 243),
                              border: OutlineInputBorder(),
                              hintText: 'What/Who is...',
                            ),
                            controller: controller,
                            enabled: !_buzzed,
                            onSubmitted: (value) {
                              setState(() {
                                _buzzed = true;
                                _answerPadding = 0.08;
                                controller.clear();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.1),
                    ElevatedButton(
                      onPressed: () {
                        skip();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 145, 23, 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(175, 65),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.1),
                    buttonsWidget,
                    Text(
                      "\$$_sessionMoney",
                      style: TextStyle(
                        color: updateSessionMoneyColor(),
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 20, 0),
              child: IconButton(
                iconSize: Variables.screenHeight * 0.04,
                icon: const Icon(Icons.info, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _displayInfo = !_displayInfo;
                  });
                },
              ),
            ),
          ),
          TapRegion(
            onTapOutside: (tap) {
              if (_displayInfo) {
                setState(() {
                  _displayInfo = !_displayInfo;
                });
              }
            },
            child: statsWidget,
          ),
        ],
      ),
    );
  }
}
