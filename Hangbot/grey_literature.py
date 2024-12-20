from selenium import webdriver
from bs4 import BeautifulSoup
import time
import pandas as pd
import urllib.request
import random
import ssl

driver = webdriver.Chrome()

# Initialize columns for DataFrame
df = pd.DataFrame()
links = []
titles = []

# Define Google search URL
google_url = "https://www.google.com.au/search?q=+finance+OR+OR+mitigation+OR+OR+OR+adaptation&lr=&safe=active&as_qdr=all&sxsrf=AOaemvI7GzXzq-hKmzPCca8dFsJ1ppkeyA%3A1635811442215&source=lnt&tbs=cdr%3A1%2Ccd_min%3A1%2F1%2F1970%2Ccd_max%3A31%2F12%2F1979&tbm="
driver.get(google_url)

# Parse the page source
soup = BeautifulSoup(driver.page_source, 'html.parser')
result_div = soup.find_all('div', attrs={'class': 'g'})

# Extract data from the search results
for r in result_div:
    try:
        link = r.find('a', href=True)
        title = r.find('h3')
        if title:
            title = title.get_text()
        if link and title:
            links.append(link['href'])
            titles.append(title)
    except Exception as e:
        print(e)
        continue

# Save data to DataFrame
df['title'] = titles
df['url'] = links
print(df)

# Save DataFrame to CSV
df.to_csv('private_climate_finance.csv')

# Filter for PDF links and clean titles
f2 = df[df['url'].str.contains("pdf")].reset_index().drop(['index'], axis=1)
f2['title'] = f2['title'].str.replace('[!@#$%&*{}?|\\/:]', '')

# Define user agents for requests
user_agent_list = [
    {"User-Agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15'},
    {"User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0'},
    {"User-Agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36'},
    {"User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36'},
]

# Function to download files
def download_file(download_url, filename):
    req = urllib.request.Request(download_url, headers=random.choice(user_agent_list))
    response = urllib.request.urlopen(req)
    with open(filename + ".pdf", 'wb') as file:
        file.write(response.read())

# Download PDF files
ssl._create_default_https_context = ssl._create_unverified_context
for i in range(len(f2)):
    try:
        time.sleep(30)
        name1 = f2['title'][i]
        download_file(f2['url'][i], f'{name1}')
    except Exception as e:
        print(i)
        print(e)
        continue

# Save filtered DataFrame to CSV
f2.to_csv('list_of_pdf_privateclimatefinance.csv')
