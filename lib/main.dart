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

*/
import 'package:flutter/material.dart';
import 'variables.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Variables.init(context); // Load class with constant variables for use

    return Scaffold(
      backgroundColor: const Color.fromARGB(121, 150, 132, 132),
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
                Container(
                  color: const Color.fromARGB(255, 240, 238, 233),
                  width: Variables.screenWidth * 0.8,
                  padding: EdgeInsets.all(Variables.screenHeight * 0.02),
                  child: const Center(
                    child: Text(
                      "Geography",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Variables.screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Variables.screenWidth * 0.05,
                  ),
                  child: const Text(
                    "(Jimmy of the Clue Crew presents by a display monitor.) The border between the Greek regions of Macedonia and Thessaly is the location of this legendary home of the gods",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: Variables.screenHeight * 0.1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      hintText: 'Type here...',
                    ),
                  ),
                ),
                SizedBox(height: Variables.screenHeight * 0.1),
                ElevatedButton(
                  onPressed: () {},
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
