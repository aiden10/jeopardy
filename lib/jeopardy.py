"""
Want:
Random question from random game, its category, and its answer
2 random numbers needed. First, the question number and two, the game number 

Random game number: (1, 9013)
Random question number: ( 0, len(data[game_number]['jeopardy']) )

Extracting entire game:
    data[game_number]['jeopardy']

Extracting additional data:
    data[question_number]['a'] # Answer
    data[question_number]['cat'] # Category
    data[question_number]['val'] # Value

"""

import json
import random 

fh = open(r"C:\Users\aiden\Documents\Jeopardy\jeopardy\lib\jeopardy.json", encoding="utf8")
data = json.load(fh)
first = data["1"]["jeopardy"]
print(first)
print(data['1']['jeopardy'][0]['q'])
# for question in first:
#     print(question)
    # print(question['a'])
    # print(question["cat"])
    # print((question["q"], question["val"]), spaces, end="")

