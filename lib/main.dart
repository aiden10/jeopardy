/*
To do:
- Indicators for correct and incorrect (score/money earned?)
- Stat tracking
- Stats menu
- Polish
- Ads
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
  int randomQuestionNum = random.nextInt(data[randomGameNum.toString()]['jeopardy'].length);
  String answer = (data[randomGameNum.toString()]['jeopardy'])[randomQuestionNum]['a'];
  String category = (data[randomGameNum.toString()]['jeopardy'])[randomQuestionNum]['cat'];
  int value = (data[randomGameNum.toString()]['jeopardy'])[randomQuestionNum]['val'];
  String question = (data[randomGameNum.toString()]['jeopardy'])[randomQuestionNum]['q'];
  return [question, category, answer, value.toString()];
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
  _MyHomePageState createState() => _MyHomePageState(); // every StatefulWidget must implement the createState method and have a State which then gets updated
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences? prefs;
  Map<String, dynamic>? _data;
  List<String>? _randomData;
  String _currentQuestion = '';
  String _currentCategory = '';
  String _currentAnswer = '';
  String _currentValue = '';
  bool _buzzed = false;
  bool _displayInfo = false;
  int _money = 0;
  int _currentStreak = 0;

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
        _money = prefs?.getInt('money') ?? 0; // default value of 0 if assignment fails
        _currentStreak = prefs?.getInt('streak') ?? 0;
      });
    }
  }

  void _loadNewQuestion() {
    if (!_buzzed){
      List<String> randomData = fetchRandomGame(_data!); 
      setState(() {
        _currentCategory = randomData[1];
        _currentQuestion = randomData[0];
        _currentAnswer = randomData[2];
        _currentValue = randomData[3];
      });
    } 
  }
  
  void _correctAnswer() async{
    setState(() {
      _money += int.parse(_currentValue);
      _currentStreak++;
      storeIntValue('money', _money);
      storeIntValue('streak', _currentStreak);

      _buzzed = false;
      _loadNewQuestion();
    });              
  }
  void _incorrectAnswer() async{
    setState(() {
      _money -= int.parse(_currentValue);
      _currentStreak = 0;
      storeIntValue('money', _money);
      storeIntValue('streak', _currentStreak);

      _buzzed = false;
      _loadNewQuestion();
    });                    
  }

  void storeIntValue(String key, int value) async{
    await prefs?.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    Variables.init(context); // Load class with constant variables for use

    if (_data == null){ // if JSON is loading, show progress bar
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
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red, 
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _incorrectAnswer();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green, 
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
          color: Colors.white, // White background color
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

      if (_displayInfo){
        statsWidget = Stack(
          children: [Center(
          child: Container(
            width: Variables.screenWidth * 0.8, // Width of the square
            height: Variables.screenHeight * 0.35, // Height of the square
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75), // Half-transparent black color
            ),
            child: Text(
              """Total Money Earned: $_money \nCurrent Streak: $_currentStreak
              """,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(121, 184, 171, 171),
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
                    SizedBox(height: Variables.screenHeight * 0.05), // Adjust height as needed
                    Text(
                      '\$$_currentValue',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 211, 191, 9),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.05),
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
                    SizedBox(height: Variables.screenHeight * 0.12),
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
                    answerWidget,
                    SizedBox(height: Variables.screenHeight * 0.1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Visibility(
                        visible: !_buzzed,
                        child: TextField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Type here...',
                          ),
                          controller: controller,
                          enabled: !_buzzed,
                          onSubmitted: (value) {
                            setState(() {
                              _buzzed = true;
                              controller.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: Variables.screenHeight * 0.1),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton(
                        onPressed: _loadNewQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(177, 204, 23, 23),
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
                    ),
                    SizedBox(height: Variables.screenHeight * 0.02),
                    buttonsWidget,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40, // Adjust this value to position it properly
            right: 20, // Adjust this value to position it properly
            child: IconButton(
              icon: const Icon(Icons.info, color: Colors.white),
              onPressed: () {
                setState(() {
                  _displayInfo = !_displayInfo;
                });
              },
            ),
          ),
          statsWidget,
        ],
      ),
    );
  }
}
