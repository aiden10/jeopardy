/*
Every Flutter app has a root widget and is essentially a tree.
You create more widgets and nest them. Widgets are quite varied, some serve as containers that will organize the inner components and others
serve as the elements themselves.
You can create your own widgets and reuse them within your app. 
Stateful vs Stateless widgets. If something doesn't change it is stateless, if it does then it is stateful. I don't quite know what constitutes
a change in state though. If text is to change within a widget must it be stateful? 
Some widgets are quite important. MaterialApp is one that seems to often serve as the root widget and follows the "Material Design" language.
It allows you to set up themes, localization support, navigation, title, and icon easily. 

Widget Types: So there's various kinds of widgets, but some fall into particular categories. 
- Structural Widgets
- Text Widgets
- Button Widgets
- Image Widgets
- Layout Widgets
- Input Widgets
- Dialog and Overlay Widgets
- Scrolling and Navigation Widgets
- Animation Widgets 
So basically everything that you need to do already exists in the form of widgets and you just need to put them together.
Sample app:
class SampleApp extends StatelessWidget {
  const SampleApp({super.key}); // I get that a key is useful to identify unique widgets but I don't fully get the inheritance aspect

  @override // also not sure what this is doing here
  return Scaffold{ // Scaffold is a structural widget
    appBar: AppBar( // I guess the Scaffold Widget requires an AppBar argument
      title: const Text('Sample'), // title for the app bar
    ),
    body: Center( // Scaffold also needs a 'body', which in this case is a "Center" widget which centers the child widget
      child: ElevatedButton( // a button widget, has text and runs code when pressed
        child: const Text('This is a button'), // text for the button
        onPressed: (){ // kinda weird syntax with the closed parentheses followed by the actual code 
          // do something
        },
      ),
    );
  }
}

Page Navigation:
This relies on routes to go from page to page. 
Navigator seems to be a constant that you can use to go from page to page. It's also a stack.
To go to a new page, you push it onto the stack (Navigator) and to go back you pop from the stack. 
Example:
  onPressed () {
    Navigator.push( // push function to go to new page
      context, // not really sure what the context is defined as or if it's automatic
      MaterialPageRoute(builder: (context) => const NewPage())
    );
  }

Text Widgets:
All text widgets must specify which direction they go in (left to right or right to left). 
You can do this by wrapping the components in a directionality widget. Then all the widgets inside it will be rendered in the specified direction,
like CSS it cascades down and applies to all the inner widgets.  

Const keyword? Used when the value of the variable is known at compile time. i.e use for constants. I guess without knowing a lot more about
Flutter specifics it's hard to know exactly what is and isn't known at compile time.

Widget sizes/units: can use different widgets to achieve desired effect (FractionallySizedBox or Expanded), use 'hardcoded' numbers instead of percentages.
Can use MediaQuery.of(context).size.height or width to get height or width of device and scale appropiately 

Stateful Widgets: 
Stateful widgets extend the StatefulWidget class and must also be paired with a generic 'State' class. This state class also extends another 
class, which will be the type of the widget <T>. Types are specified like in Java with the greater than less than signs. Then your stateful widget
will have a createState method to create an instance of the State class. Then you can call setState to update its state. 
I think the general idea is pretty straightforward at least. You have a state widget class and it might have some parameters,
you initialize with some default value for the parameters and then can call setState with new arguments to update the state. The hard part would be
understanding how Flutter handles the process exactly and the syntax for it. 
Example:
void main(){
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){ // build method here is automatically called by Flutter I think
    return MaterialApp(home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState(); // I don't quite get this line
}

class _MyHomePageState extends State<MyHomePage> { // class which represents a State of an instance of MyHomePage
  int _counter = 0; // private variable(?) not sure what underscores indicate

  void _incrementCounter() { // method which increments the counter
    setState(() {
      _counter++;
    });
  }

Your root widget that extends the Stateful widget class is comprised of two sections. Everything before the build method and everything
within it. The stuff inside the build method is the relevant widgets that make up how it looks, and the stuff before it are basically the constructor
and any additional functions.

Exclamation points: if something might be null and you use it in such a way that if it is null it causes your program to encounter an error,
it won't compile in the first place. So if you are sure that it won't ever be null then you can add the exclamation mark to let it compile. 

Updating interface conditionally: basically update the condition, then call setState to force a rebuild (now I see why constant widgets are important).
At the top of your build initialize a new widget object/variable. Only add the contents that you want to display inside the condition.
This way you can add it to your root returned widget and it won't do anything until the condition is met. 

To do:
- Load JSON x
- Properly display random questions and their category x
- Make skip button load a random question x
- Add buttons to designate incorrect and correct guesses when text is submitted x
- Indicators for correct and incorrect (score?)
- Stats
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

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> saveStreak(int streak) async {
    // Sample Usage
    // int newHighScore = 1000;
    // await SharedPreferencesService.saveHighScore(newHighScore);
    await _preferences?.setInt('streak', streak);
  }

  int? getStreak() {
    // Sample Usage
    // int? retrievedScore = SharedPreferencesService.getHighScore();
    return _preferences?.getInt('streak');
  }
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
  Map<String, dynamic>? _data;
  List<String>? _randomData;
  String _currentQuestion = '';
  String _currentCategory = '';
  String _currentAnswer = '';
  String _currentValue = '';
  bool _buzzed = false;
  bool _displayInfo = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

    Future<void> _loadData() async {
    final data = await loadJsonData();
    if (data != null) {
      setState(() {
        _data = data;
        _randomData = fetchRandomGame(_data!);
        _currentQuestion = _randomData![0];
        _currentCategory = _randomData![1];
        _currentAnswer = _randomData![2];
        _currentValue = _randomData![3];
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
                setState(() {
                  _buzzed = false;
                  _loadNewQuestion();
                });                    
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
                setState(() {
                  _buzzed = false;
                  _loadNewQuestion();
                });                    
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

    return Scaffold(
      backgroundColor: const Color.fromARGB(121, 184, 171, 171),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Variables.screenWidth * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Variables.screenHeight * 0.1), 
                Text(
                  '\$$_currentValue', 
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 211, 191, 9), 
                    ),
                  ),
                SizedBox(height: Variables.screenHeight * 0.03), // category container and below
                Container(
                  color: const Color.fromARGB(255, 240, 238, 233),
                  width: Variables.screenWidth * 0.8,
                  padding: EdgeInsets.all(Variables.screenHeight * 0.04), // CATEGORY CONTAINER
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
                SizedBox(height: Variables.screenHeight * 0.1), // everything below the question
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Variables.screenWidth * 0.03, // question width
                  ),
                  child: SizedBox(
                    height: Variables.screenHeight * 0.1, // answer and below
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
                ),
                answerWidget,
                SizedBox(height: Variables.screenHeight * 0.065), // textfield and below
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
                      onSubmitted: (value){
                        setState(() {
                          _buzzed = true;
                          controller.clear();
                        });                    
                      },
                    ),
                  ),
                ),
                SizedBox(height: Variables.screenHeight * 0.04), // skip button
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
                SizedBox(height: Variables.screenHeight * 0.05), // below skip button
                buttonsWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
