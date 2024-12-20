import os
import glob
import pandas as pd
from tqdm import tqdm
from extract_text import extract_text_from_pdf
from clean_text import clean_text
from ngram_utils import count_ngrams, calculate_total_ngram_words, create_dataframe

data = []

def process_data(input_folder, ngram_list):
    ngram_dfs = []
    for subfolder in glob.glob(os.path.join(input_folder, '*')):
        if os.path.isdir(subfolder):
            texts = []
            pdf_count = 0
            total_words_before_cleaning = 0
            total_words_after_cleaning = 0
            for file in glob.glob(os.path.join(subfolder, '*.pdf')):
                pdf_count += 1
                text = extract_text_from_pdf(file)
                texts.append(text)
            cleaned_text = clean_text(' '.join(texts))
            texts_combined = ' '.join(texts)
            total_words_before_cleaning += len(texts_combined.split())
            total_words_after_cleaning += len(cleaned_text.split())

            total_1gram_words = calculate_total_ngram_words(count_ngrams(cleaned_text, 1))
            total_2gram_words = calculate_total_ngram_words(count_ngrams(cleaned_text, 2))
            total_3gram_words = calculate_total_ngram_words(count_ngrams(cleaned_text, 3))
            print(total_1gram_words)
            print(total_2gram_words)
            print(total_3gram_words)

            data.append({
                'Folder': os.path.basename(subfolder),
                'Total_PDFs': pdf_count,
                'Total_Words_Before_Cleaning': total_words_before_cleaning,
                'Total_Words_After_Cleaning': total_words_after_cleaning,
                'Total_1gram_Words': total_1gram_words,
                'Total_2gram_Words': total_2gram_words,
                'Total_3gram_Words': total_3gram_words
            })
            for n in tqdm(ngram_list, desc='n-grams', leave=False):               
                ngram_counts = count_ngrams(cleaned_text, n)
                file_df = create_dataframe(ngram_counts, n, m)
                file_df['Subfolder'] = os.path.basename(subfolder)
                ngram_dfs.append(file_df)
            
            result_df = pd.concat(ngram_dfs)
            result_df.to_excel(os.path.join(subfolder, f'result_{m}.xlsx'), index=False)
            print(f'Reading {subfolder}-{n} completed')
        print(f'Reading {subfolder} finish')
    return pd.concat(ngram_dfs)

ngram_list = [1, 2, 3]

input_folder = input('Enter folder path containing PDF files: ')
m = input('Enter how many n-gram words: ')
if input_folder:
    all_results_df = process_data(input_folder, ngram_list)
    all_results_df.to_excel(os.path.join(input_folder, f'all_results_{m}.xlsx'), index=False)
    df = pd.DataFrame(data)
    df = df.sort_values(by='Folder', ascending=True)
    df.to_excel(os.path.join(input_folder, 'total_words_count.xlsx'), index=False)
    print(df)
    print('All results completed')
