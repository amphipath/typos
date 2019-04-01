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

