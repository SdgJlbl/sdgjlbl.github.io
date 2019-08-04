---
title: Various options to (latin-script-based) language detection
---

In order to optimise a NLP preprocessing pipeline, or to be able to tag a batch of documents and to present a user only 
with results in their preferred language, it might be useful to automatically determine the language of a text sample. 

This article presents various options to do so in Python, from custom solutions to external libraries. 
Each solution is evaluated according to three dimensions, accuracy in language detection, execution time and ease of use.

If you are not interested in the implementation details, you can go directly to [the conclusion](#ccl). 

If you want to play around with the code, the notebook is available 
[here](//gist.github.com/SdgJlbl/3f2ef47d926a1d44e4f361c77c3b77e7).

<h4> Experimental setup </h4>

We use the genesis corpus from nltk, which has the advantage of being easily available. You can download it as follow after installing nltk :



```python
import nltk
nltk.download('genesis')
```

    [nltk_data] Downloading package genesis to /home/sdg/nltk_data...
    [nltk_data]   Package genesis is already up-to-date!


The genesis corpus contains the text from the Genesis in 6 languages: Finnish, French, German, Portuguese, Swedish, and three different English versions.

The writing style might not be representative of the typical context in which language detection could be used (very formal and rather outdated), but it had the advantage of being already labeled. 

In all of the following, the genesis corpus will be used solely for testing. When we train our classifier for custom solutions, we will use other data sources.

We will compute accuracy when predicting each sentence of the corpus, and the execution time for predicting the complete dataset. 

External depencies in addition to nltk are numpy and pandas.

<h5>Dataset creation</h5>

We create a Pandas dataframe containing all sentences with their associated labels. 


```python
import pandas as pd
import numpy as np
from nltk.corpus import genesis as dataset

dfs  = []
for ids in dataset.fileids():
    df = pd.DataFrame(data=np.array(dataset.sents(ids)), columns=['sentences'])
    df['label'] = ids.strip('.txt') if ids not in {'english-kjv.txt', 'english-web.txt', 'lolcat.txt'} else 'english'
    dfs.append(df)
sentences = pd.concat(dfs)
```
---

<h4> Naive solution (baseline)</h4>

We present here a naive solution relying on stop words (most common words in a language). We will use the stopwords corpus from nltk.

We first create a dictionary of stop words per language. It must be noted that this dictionnary includes languages which are not present in the genesis corpus, such as Norwegian or Danish. This ensures a fair comparison between custom solutions and external libraries (which have no restriction on which languages might be present).


```python
from nltk.corpus import stopwords
from collections import defaultdict

languages = stopwords.fileids()
stopwords_dict = defaultdict(list)
for l in languages:
    for sw in stopwords.words(l):
        stopwords_dict[sw].append(l)
```

For each sentence (represented as a list of tokens), we compute the number of stop words of each language present in the sentence, using a dictionary to accumulate the counts. Then, we simply predict the sentence to be of the language with the largest count (if the dictionary is not empty; else we predict 'unknown').

In case of equality, we toss a coin and choose at random.


```python
from collections import defaultdict, Counter
import random

def predict_language_naive(sentence):
    random.seed(0)
    cnt = Counter()
    cnt.update(language
              for word in sentence
              for language in stopwords_dict.get(word, ()))
    if not cnt:
        return 'unknown'
        
    m = max(cnt.values())
    return random.choice([k for k, v in cnt.items() if v == m])
```

We can compute the accuracy as follow : 


```python
def compute_accuracy(predictor):
    return (sentences['sentences'].apply(predictor) == sentences['label']).sum() / len(sentences)
```
---

```python
compute_accuracy(predict_language_naive)
```
    0.92565982404692082


>As a side note, accuracy might not be the ideal metrics here, since we have a slightly unbalanced class distribution,
> with English being 3 times as frequent as any other language.

Execution time is computed using the timeit magic.


```python
%timeit compute_accuracy(predict_language_naive)
```

    299 ms ± 24.4 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)


This solution is quite fast, but not very accurate. It does not use any external library which might be an advantage in some contexts.

<h4> External libraries </h4>

Now that we have a baseline, we can benchmark a few external libraries to see how good they perform. They will probably be more accurate, but at what cost in term of execution time? 

Two libraries have been tested, langdetect and pycld2.

<h5>langdetect</h5>

The official documentation can be found [here](https://pypi.python.org/pypi/langdetect?). It's a port of a Google library in Python. Unfortunately, the code is not very Pythonic...

It's easily installed with pip.


```python
from langdetect import detect, lang_detect_exception
```

The langdetect API takes whole sentences (not tokenised) as input, so we first concatenate tokenised sentences.

Another thing is that the detect function may raise an exception when it is unsure about the language, in which case we want to have an unknown label. Our wrapper should catch the exception.

Another thing we want to consider is that the output is the ISO 639-1 code for the language, which is not very user-friendly. We use a mapping dictionary to convert the output.


```python
iso_to_human = {'da': 'danish', 'de': 'german', 'en': 'english', 'es': 'spanish', 'et': 'estonian', 'fr': 'french', 
                'hu': 'hungarian', 'it': 'italian', 'lt': 'lithuanian', 'lv': 'latvian', 'nl': 'dutch', 'no': 'norwegian',
                'pt': 'portuguese', 'ro': 'romanian', 'sk': 'slovak', 'sl': 'slovenian', 'sv': 'swedish'}

def detect_without_exception(s):
    try:
        return iso_to_human[detect(' '.join(s))]
    except lang_detect_exception.LangDetectException:
        return 'unknown'
```

Here we go for the prediction accuracy, and the execution time.


```python
compute_accuracy(detect_without_exception)
```
    0.96539589442815255

---
```python
%timeit compute_accuracy(detect_without_exception)
```

    51.3 s ± 966 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)


We have improved the classification accuracy, at the expense of being more than 150 times slower. It will not be acceptable in most use cases.

<h5>pycld2</h5>

[pycld2](https://pypi.python.org/pypi/pycld2/) provides Python bindings around Google compact language detection library (CLD2). 

The API exposes more details than langdetect, providing a confidence percentage for each language detected, and since it's a wrapper on a C++ compiled binary, we can hope that it'll be faster. 

It's easily installed with pip.

It is the underlying library used by [Polyglot](https://pypi.python.org/pypi/polyglot), a NLP library offering a wide variety of tools for handling multilingual usages. Check it out !

As langdetect, pycld2 takes whole sentences as input, so we will reuse our previously defined `sentences_agg`.


```python
import pycld2 as cld2

compute_accuracy(lambda s: cld2.detect(' '.join(s), bestEffort=True)[2][0][0].lower())
```
    0.97375366568914956

---
```python
%timeit compute_accuracy(lambda s: cld2.detect(' '.join(s), bestEffort=True)[2][0][0].lower())
```

    134 ms ± 776 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)


The accuracy is actually sligtly better than what we have with langdetect, and it's even faster than our naive solution. 

The downside is that the GitHub repository has not been updated since 2015, and the documentation seems out of sync. Furthermore, the computation is not made in Python, which makes it harder to alter the code to suit custom needs.

One last thing we can try is to biais the algorithm towards choosing English more often, given that it is the more frequent language.


```python
compute_accuracy(lambda s: cld2.detect(' '.join(s), bestEffort=True, hintLanguage='ENGLISH')[2][0][0].lower())
```
    0.96796187683284463

Here, it does not improve accuracy, maybe because we have such short pieces of text to label, but it might be of use in other contexts.

<h4> Improvements on the naive solution</h4>

Can we beat the 97% accuracy of a off-the-shelf solution? Let's try to improve our naive solution.

<h5> Training dataset</h5>

In order to improve our naive solution, we will need another source of multilingual text - using the genesis corpus would be cheating since it's our test set. 

We use the [European Parliament Proceedings Parallel Corpus](http://www.statmt.org/europarl/) which we can download with nltk.


```python
from nltk.corpus import europarl_raw
```

We can obtain the list of words for each language as follow : 

```python
europarl_raw.english.words()
```
    ['Resumption', 'of', 'the', 'session', 'I', 'declare', ...]

We define the list of languages for which we have data: 


```python
languages = ['danish', 'dutch', 'english', 'finnish', 'french', 'german', 'italian', 'portuguese', 'spanish', 'swedish']
```

We also define a small function to help us clean our lists of tokens.


```python
def clean_tokens(tokens):
    return [token.lower() for token in tokens if token.isalpha()]
```

<h5> Weighting stop words </h5>

We can observe that some stop words are present in more than one language. We can consider that these words are less discriminant with respect to the languages they belong to, so we want to assign them a weight proportionnal to how frequent a stop word is in the set of all languages.

```python
weighted_stopwords_dict = defaultdict(dict)
for sword, langs in stopwords_dict.items():
    coeff = 1/ len(langs)
    for lang in langs:
        weighted_stopwords_dict[sword][lang] = coeff
```
---

```python
def predict_language_weighted_stopwords(sentence):
    random.seed(0)
    cnt = Counter()
    for word in sentence:
        if word in weighted_stopwords_dict:
            cnt.update(weighted_stopwords_dict[word])

    if not cnt:
        return 'unknown'
    m = max(cnt.values())
    return random.choice([k for k, v in cnt.items() if v == m])
```
---

```python
compute_accuracy(predict_language_weighted_stopwords)
```
    0.92184750733137832

---
```python
%timeit compute_accuracy(predict_language_weighted_stopwords)
```
    413 ms ± 47.8 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)


Unfortunately, this weighting scheme does not improve our naive solution.

<h5> Use diacritics</h5>

Diacritics are, as defined by Wikipedia, glyphs added to a letter. They can be quite distinctive of a given language (if present), and so we want to use them in addition to stopwords to improve our classification accuracy for western languages. 

First, we need to determine a list of diacritics used per language. We will use the European Parliament Proceedings to do so.

In the first line of the function, we get a list of all characters presents in the proceedings for a given language, after cleaning the tokens (we keep only alphabetic words and we cast everything to lower case). 

Then we count the number of occurences for each character. We remove characters occuring less than 500 times, since they can come from foreign words such as surnames or location names, and we only want to keep typical diacritics for a language. 

In a last step, we remove non-accentuated characters (= ascii characters) from the set.


```python
import string

def get_diacritics(language):
    char_list = list(''.join(clean_tokens(europarl_raw.__getattribute__(language).words())))
    cnt = Counter(char_list)
    frequent_chars = {k for k, v in cnt.items() if v > 500}
    return frequent_chars - set(string.ascii_lowercase)
```

Let's print the list of diacritics per language.


```python
diacritics = {language: list(get_diacritics(language)) for language in languages}
diacritics
```
    {'danish': ['æ', 'å', 'ø', 'é'],
     'dutch': ['ë', 'é'],
     'english': [],
     'finnish': ['ö', 'ä'],
     'french': ['à', 'û', 'ô', 'ê', 'è', 'ç', 'é', 'î'],
     'german': ['ö', 'ü', 'ä', 'ß'],
     'italian': ['à', 'ò', 'ù', 'è', 'ì', 'é'],
     'portuguese': ['à', 'ú', 'ê', 'ã', 'ç', 'á', 'é', 'í', 'ó', 'õ', 'â'],
     'spanish': ['ú', 'ñ', 'á', 'é', 'í', 'ó'],
     'swedish': ['ö', 'å', 'ä']}



The lists seem about right (at least for the languages I know), and it's running reasonably fast for a naive solution.

Now what we have a list of diacritics, we can use the same method as we used for stop words to detect language. 

At first, let's try to only use diacritics.


```python
diacritics_transposed = defaultdict(list)
for language, chars in diacritics.items():
    for char in chars:
        diacritics_transposed[char].append(language)

        
def predict_language_diacritics(sentence):
    cnt = Counter()
    cnt.update(language
             for ch in ''.join(sentence).lower()
             for language in diacritics_transposed[ch]
             if ch not in string.ascii_lowercase)
    if not cnt:
        return 'english'
    m = max(cnt.values())
    return random.choice([k for k, v in cnt.items() if v == m])
```
---

```python
compute_accuracy(predict_language_diacritics)
```
    0.65058651026392966

---

```python
%timeit compute_accuracy(predict_language_diacritics)
```

    169 ms ± 5.79 ms per loop (mean ± std. dev. of 7 runs, 10 loops each)


On such small chunks of text, we are far from guaranteed to have diacritics, which could explain the low accuracy. 

Let's check the confusion matrix to see if our hypothesis is right.

We use the pandas-ml library, which combines the power of scikit-learn with the readability of pandas.


```python
from pandas_ml import ConfusionMatrix
ConfusionMatrix(sentences['label'], sentences['sentences'].apply(predict_language_diacritics))
```


    Predicted   danish  dutch  english  finnish  french  german  italian   portuguese  spanish  swedish  __all__  
    Actual                                                                     
    danish           0      0        0        0       0       0        0            0        0        0        0   
    dutch            0      0        0        0       0       0        0            0        0        0        0   
    english          0      0     4521        0       0       0        0            0        0        0     4521   
    finnish          0      0      227      648       0     671        0            0        0      614     2160   
    french          66    115      295        0     646       0      462          339       81        0     2004   
    german           0     10      876      152       0     687        0            0        0      175     1900   
    italian          0      0        0        0       0       0        0            0        0        0        0   
    portuguese      12     10      198        0      77       1       18         1213      140        0     1669   
    spanish          0      0        0        0       0       0        0            0        0        0        0   
    swedish         43      1       35       95       1      89        1            0        2     1119     1386   
    __all__        121    136     6152      895     724    1448      481         1552      223     1908    13640   



The confusion matrix gives us two very interesting pieces of information. 

First, a lot of sentences are predicted as English; actuallly, any sentence with no diacritics will be predicted as English, as there are no diacritics in the English language. On short sentences, it is possible that whatever the language, there are no diacritics.

Secundly, we can observe that for example, a large number of Swedish sentences are predicted as Finnish. That can be explained by the fact that two out of three Swedish diacritics are also Finnish ones, and the fact that our naive implementation returns a language at random amongst the most probable in case of equality. 

Let's try now to use the diacritics in addition to the stop words.


```python
def predict_language_stopwords_diacritics(sentence):
    random.seed(0)
    cnt = Counter()
    cnt.update(language
              for word in sentence
              for language in stopwords_dict.get(word, ()))
    cnt.update(language
               for ch in ''.join(sentence).lower()
               for language in diacritics_transposed[ch]
               if ch not in string.ascii_lowercase)
    if not cnt:
        return 'unknown'
        
    m = max(cnt.values())
    return random.choice([k for k, v in cnt.items() if v == m])
```
---
```python
compute_accuracy(predict_language_stopwords_diacritics)
```
    0.93995601173020527
---
```python
%timeit compute_accuracy(predict_language_stopwords_diacritics)
```
    463 ms ± 63.4 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)


We do have a gain in accuracy, at the expense of a slightly increased run time.

<h4> Learn a classifier based on n-grams embeddings </h4>

We are going to try something a little more sophisticated, using Facebook's library FastText for text classification. In order to that, we are going to need a dataset to train on our classifier, we are going to use the European Parlement Proceedings corpus. 

More information about fastText can be found in the [documentation](https://fasttext.cc/).


```python
from pyfasttext import FastText
from sklearn.model_selection import train_test_split
from nltk import ngrams
```

The fastText library is trained on n-grams (tuples of n words), using a linear classifier on top of a hidden word embedding. Let's create a set of trigrams to learn on.


```python
doc_set = [(language, clean_tokens(europarl_raw.__getattribute__(language).words())) for language in languages]
trigrams_set = [(language, ' '.join(trigram)) for (language, words) in doc_set
                                    for trigram in ngrams(words, 3)]
train_set, test_set = train_test_split(trigrams_set, test_size = 0.30, random_state=0)
```

pyfasttext is a wrapper around command line tool, so we will need to dump the sets to a file before training the classifier.


```python
with open('train_data_europarl.txt', 'w') as f:
    for label, words in train_set:
        f.write('__label__{} {}\n'.format(label, words))

model = FastText()
model.supervised(input='train_data_europarl.txt', output='model_europarl', epoch=10, lr=0.7, wordNgrams=3)
```

We can then evaluate how good is the training error and the test error.


```python
# train accuracy
labels, samples = np.split(np.array(train_set), 2, axis=1)
(np.array(model.predict(samples.T[0])) == labels).sum() / len(train_set)
```
    0.99680029382291524
    
---
```python
# test accuracy
labels, samples = np.split(np.array(test_set), 2, axis=1)
(np.array(model.predict(samples.T[0])) == labels).sum() / len(test_set)
```
    0.98648199595051833

We can now apply this model to our initial dataset.
```python
(model.predict(sentences['sentences'].str.join(' ') + '\n') == sentences['label'][:, None]).sum()/len(sentences)
```
    0.97514662756598236

---
```python
%timeit model.predict(sentences['sentences'].str.join(' ') + '\n')
```

    204 ms ± 22.6 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)


<h4 id="ccl"> Conclusion </h4>

We sum up our findings in the following table.

| Algorithm              | Accuracy | Execution time | Comments                                                    |
|------------------------|----------|----------------|-------------------------------------------------------------|
| Stopwords based        | 92.5%    | 299 ms         | Baseline                                                    |
| Weighted stopwords     | 92.2%    | 413 ms         |                                                             |
| Diacritics             | 65.0%    | 169 ms         |                                                             |
| Diacritics + stopwords | 94.0%    | 463 ms         |                                                             |
| langdetect             | 96.5%    | 51 300 ms      | Too slow to be of any use                                   |
| pycld2                 | 97.3%    | 134 ms         | External library; handles a large number of languages       |
| fastText               | 97.5%    | 204 ms         | Needs a training corpus; can be trained on specialized data |

The only two relevant options are either pycld2, which can handle over 165 languages and does not need any labeled data to be used, and fastText, which might be a worthy alternative if one has specialized data on which to train it.

To be fair, let's note that external libraries can also handle non-european languages, which use non-latin scripts and in which the notion of "words" may be ill-defined. Our custom solution does not have the same ambition, and in addition requires a labeled corpus to be trained on.

Another important thing is that accuracy does not tell the whole story here, and that using a confusion matrix to see what kind of mistakes the classifier makes is paramount. Confusion matrices have not been included here only for the sake of brevity.
