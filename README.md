# Code for paper: "Trends in biodiversity finance terminology, actors and networks over two decades"

This repository contains the code and HTML outputs for the paper:
**"Trends in biodiversity finance terminology, actors and networks over two decades"**.

The interactive visualizations (HTML files) can be explored locally or embedded in your own applications. These files provide dynamic network views of biodiversity finance actors across different time periods (epochs).

Web application: [https://biodiversity-finance-network.vercel.app/](https://biodiversity-finance-network.vercel.app/)

---

## 📦 Contents

- `Hangbot/`: Web scraper using Selenium and BeautifulSoup to download relevant PDFs.
- `Ngram/`: Code to clean text, extract n-grams, compute n-gram frequencies, and visualize them over time.
- `Social_network/`: Scripts to display social network analysis.
- `install/requirements.txt`: Python dependencies list.
- `install/install_packages.R`: R package installer script.

---

## 🚀 Getting Started

To use or embed the interactive HTML files locally or in your own app:

### Clone the repository
```bash
git clone https://github.com/hangcode44/biodiversity-finance-network-code.git
cd biodiversity-finance-network-code
```



## 🧰 Dependencies (for running the code)

### Python dependencies
Install all required Python libraries:
```bash
pip install -r install/requirements.txt
```

Alternatively, manually install key packages:
```bash
pip install pandas numpy scikit-learn bertopic networkx matplotlib pyvis beautifulsoup4 selenium tqdm nltk word_forms PyPDF2
```

### R dependencies
Install the required R libraries by running:
```r
source("install/install_packages.R")
```

This script installs:
- readxl
- dplyr
- stringr
- colorspace
- colorBlindness
- rcartocolor
- ggrepel
- ggplot2
- tools
- patchwork

---

## 🗂 Folder Details

### 🔎 `Hangbot/`
- Uses Selenium and BeautifulSoup to automatically search and download PDF files.
- Replace the default `google_url` with your own search query.
- Outputs a list of PDF links based on your query.

### 📊 `Ngram/`
- `clean_text.py`, `extract_text.py`: For preprocessing and extracting text from PDFs.
- `ngram.py`: Counts total n-grams.
- `ngram_utils.py`: Calculates n-gram frequencies and includes utilities for aggregation.
- `visual_r.R`: R script to visualize n-gram frequencies over time using ggplot2 and related packages.

### 🌐 `Social_network/`
- Interactive HTML files showing connections and clusters.
### 2. Run the HTML locally
You can open the HTML files directly in your browser:
```bash
open contributor_all_epoch.html   # On macOS
start contributor_all_epoch.html  # On Windows
xdg-open contributor_all_epoch.html  # On Linux
```

Alternatively, serve via a local web server:
```bash
# Using Python 3
python -m http.server
```
Then visit `http://localhost:8000/` in your browser.

### 3. Embed in another application
You can embed the HTML file using an `<iframe>`:
```html
<iframe src="path/to/contributor_all_epoch.html" width="100%" height="600px"></iframe>
```

---

## 💡 How to Use the Visualizations

Once you load an HTML file in your browser:

- **Click on one of the Epoch tabs** to load the corresponding network.
- **Wait for the data to load**: It may take 2–15 minutes depending on your internet connection.
  - A blue loading bar will indicate progress.
- **Interact with the network**:
  - Use your **mouse scroll** or **trackpad** to zoom.
  - **Drag nodes** to explore connections.
  - Use the **search bar** to highlight specific organisations or terms.

---

## 📜 License
MIT License.

