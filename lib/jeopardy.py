# import json
# import os 
# import subprocess

# fh = open("jeopardy.json", encoding="utf8")
# data = json.load(fh)
# first = data["1"]["jeopardy"]
# for question in first:
#     spaces = " " * int(question["x"])
#     print(question["cat"])
#     print((question["q"], question["val"]), spaces, end="")



















from selenium import webdriver
from bs4 import BeautifulSoup
import time

driver = webdriver.Firefox()  # or webdriver.Firefox()

# URL of the first page
url = "https://www.patreon.com/posts/i-became-tyrant-85247078"
f = open("Tyrant of a Defense Game.txt", "a", encoding='utf-8')
chapter_num = 1
while True:
    text = "\n\n\n Chapter " + str(chapter_num) + '\n'
    # Navigate to the current page
    driver.get(url)
    time.sleep(2)  # Optional: Wait for the page to load, adjust as needed

    # Get the HTML content of the page
    page_source = driver.page_source

    # Parse the HTML content with BeautifulSoup
    soup = BeautifulSoup(page_source, 'html.parser')

    # Extract text from <p> tags
    paragraphs = soup.find('div', {'class': 'sc-1ye87qi-0 bCBphS'}).find_all('p')

    for paragraph in paragraphs:
        text += paragraph.get_text() + "\n"

    f.write(text)
    chapter_num += 1
    # Find the link to the next page
    next_page_link = soup.find('a', string='Next')

    if next_page_link:
        # Get the URL of the next page
        url = next_page_link['href']
    else:
        # If there is no next page link, break the loop
        break

# Close the browser
driver.quit()
f.close()
