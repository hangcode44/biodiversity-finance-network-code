from collections import Counter
from nltk import word_tokenize
from word_forms.lemmatizer import lemmatize

def count_ngrams(text, n):
    words = text.split()
    ngrams = []
    words = [word for word in words if len(word) > 1]
    
    if n == 1:
        for word in words:
            try:
                ngrams.append(tuple([lemmatize(word)]))
            except ValueError:
                ngrams.append(tuple([word]))
    else:
        for i in range(len(words) - n + 1):
            ngram = []
            for j in range(i, i + n):
                ngram.append(words[j])
            ngrams.append(tuple(ngram))
    
    words_to_remove = ['eg','also', 'yet', 'chapter', 'page', 'yes', 'et', 'al', 'figure', 'ti', 'step', 'cid', 'last', 'access', 'fig', 'table', 'vol', 'tion', 'oct']
    ngrams = [ngram for ngram in ngrams if not any(word in words_to_remove for word in ngram)]
    
    ngram_counts = Counter(ngrams)
    total_ngram_words = sum(ngram_counts.values())
    for ngram, count in ngram_counts.items():
        ngram_counts[ngram] = int(count / total_ngram_words * 100000)
    
    return ngram_counts

def calculate_total_ngram_words(ngram_counts):
    return sum(ngram_counts.values())

def create_dataframe(ngram_counts, n, m):
    sorted_ngrams = sorted(ngram_counts.items(), key=lambda x: x[1], reverse=True)[:int(m)]
    return pd.DataFrame({'N-gram type': f'{n}-gram', 
                         'N-Gram': [ng[0] if isinstance(ng[0], str) else ' '.join(ng[0]) for ng in sorted_ngrams], 
                         'Frequency': [ng[1] for ng in sorted_ngrams]})[['N-gram type', 'N-Gram', 'Frequency']]
