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
> typofind('clasroom', 0.02)

