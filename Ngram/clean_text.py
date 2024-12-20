import re
import string
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer

lemmatizer = WordNetLemmatizer()

def clean_text(text):
    text = text.strip().lower()
    text = re.sub('(\\b[A-Za-z] \\b|\\b [A-Za-z]\\b)', '', text)
    words_to_remove = ['eg','etc','also', 'yet', 'chapter', 'page', 'yes', 'et', 'al', 'figure', 'ti', 'step', 'cid', 'last', 'access', 'fig', 'table', 'vol', 'tion', 'oct']
    words_to_remove_regex = r'\b(?:{})\b'.format('|'.join(map(re.escape, words_to_remove)))
    text = re.sub(words_to_remove_regex, '', text, flags=re.IGNORECASE)
    text = re.sub(r'(?:^|\s)-+(?=\S)|(?<=\S)-+(?:\s|$)', '', text)
    text = re.sub(r'\s+', ' ', text)
    text = re.sub(r'http\S+', '', text)
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub("[%s]" % re.escape(string.punctuation), " ", text)
    text = re.sub(r"\s*•\s*", " ", text)
    text = re.sub(r"\b([ivxlcdm]+|\d+)\b", "", text, flags=re.IGNORECASE)
    text = re.sub(r"\b\w{1}\b", "", text)
    text = re.sub(r"\d+", "", text)
    text = re.sub(r"[^A-Za-z0-9(),!?\'\`]", " ", text)
    text = re.sub(r"\'s", " ", text)
    text = re.sub(r"\'ve", " ", text)
    text = re.sub(r"n\'t", " not ", text)
    text = re.sub(r"\'re", " ", text)
    text = re.sub(r"\'d", " ", text)
    text = re.sub(r"\'ll", " ", text)
    text = re.sub(r"\s{2,}", " ", text)
    stop_words = set(stopwords.words('english'))
    tokens = word_tokenize(text)
    filtered_text = [lemmatizer.lemmatize(word) for word in tokens if word.lower() not in stop_words]
    return " ".join(filtered_text)
