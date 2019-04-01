# Typo-finder

A simple function in R that takes a string and returns the most likely intended word based on the string (including, potentially, itself).

## Principles

We would want to make a decision on which string was intended to be typed by how similarity a given string is to a word in the dictionary. This "similarity" boils down to a distance metric which must satisfy a few axioms:

* `d(x,y) = 0` if and only if x = y
* A string that is more unlikely to result from typo-ing a certain word should have a higher distance

Thinking about how typographical errors occur in real life, a simple model on how typos occur would be to consider atomic typos, or a set of transformations which can be considered "one mistake". All possible results from typo-ing a given intended word would just be the composition of the atomic typo transformations.

An initial model can make use of 4 atomic typos:

* **Deletion**: `something -> somthing`
* **Substitution**: `something -> somrthing`
* **Transposition**: `something -> soemthing`
* **Insertion**: `something -> sopmething`

These particular typos are convenient to use as atomic typos because they form a closed group under composition; a deletion is the reverse of an insertion, and a transposition is the inverse of itself. This means that we can search for intended words by brute force applying all possible atomic typos to a given string.

Suppose we run into a situation where both the original string and a string of distance 1 are dictionary words and hence are candidates for the intended word. Which is a better choice for the intended word?

We would first have to consider how likely an intended word is to be typo'd in the first place. A simple model would be each word has a constant probability, `typoprob`, of being typo'd regardless of length or anything else.

We use a model where the probability of a dictionary word being intended as proportional to the word frequency in the dictionary built. Under this model, a one-off typo has a `typoprob * freq / totalfreq` chance of being the output while the original word simply has a `freq / totalfreq` chance. Hence we choose the one-off if its frequency is more than `(1 / typoprob)` times that of the original string.

## How to use

Running the code in `code.R` will build the Corpus, Term-Document Matrix and subsequent dictionary from scratch, the latter being stored in `dict` as a numeric vector with names equal to the 50,000 most frequent words and entries equal to their total frequency in the data given.

It will also define a function `typofind`, taking two parameters, `string` the intended string and `typoprob` the above-mentioned typo probability. Subsequently, calling `typofind(string,typoprob)` will run the search algorithm and return the most likely intended word under this model.

## Examples



```
> typofind('classroom',0.02)
[1] "classroom"
> typofind('meering',0.02)
[1] "meeting"
> typofind('meeting',0.02)
[1] "meeting"
> typofind('he',0.02)
[1] "he"
> typofind('he',0.2)
[1] "the"
```

The last examples show the importance of `typoprob`; in the dataset given `the` is more than 5 times as frequent as `he` but less than 50 times. So the decision between whether `he` was typo'd or not comes down to this probability.

## Future improvements

* **Punctuation**: With a larger dataset, some punctuation can also be corrected (e.g. `is'nt` to `isn't`).
* **More sophisticated distance metric**: Not all typos are born equal. Insertion typos are more likely if the keys for each other are closer together (`somerthing` being more likely than `somezthing` on the most common QWERTY keyboards). On top of that, under a Poisson model for typos the probability of a longer word having a typo is more likely than that of shorter words. Under such models the score would have to be adjusted individually based on the likelihood of the specific typo being made, since the metric is no longer contained in the integers. 
* **Different dictionary**: Under this model each word is assumed to be independently likely. A more complicated model may include the use of n-grams to increase or decrease the likelihood of a word based on adjacent words in the sentence.