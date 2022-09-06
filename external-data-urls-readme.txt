# External Data Files

This project depends on three external data files not included within the repository.

- **enable1.txt** : The Enable Scrabble Word List (2mb)
- **count_1w.txt** : English Word Frequency Data from Google (5mb)
- **cmudict-0.7b** : Carnegie Mellon University Pronouncing Dictionary (4mb)

## Fetching the Files
After first cloning the repository, the external data files won't be present. You can download them to the /ext/ folder manually using the following command:

    wget --input-file=dat\external-data-urls.txt --directory-prefix=ext

The application script code checks for the presence of these files before processing.

Alternate Windows Powershell commands:
mkdir ..\ext
Invoke-WebRequest -Uri https://norvig.com/ngrams/enable1.txt -OutFile ..\ext\enable1.txt
Invoke-WebRequest -Uri https://norvig.com/ngrams/count_1w.txt -OutFile ..\ext\count_1w.txt
Invoke-WebRequest -Uri https://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/cmudict-0.7b -OutFile ..\ext\cmudict-0.7b

## More Information

You can read more about the CMU Pronouncing Dictionary here: [Speech at CMU](http://www.speech.cs.cmu.edu/cgi-bin/cmudict).

The Word Frequency and Enable word list come from Peter Norvig's website:
 [https://norvig.com/ngrams/](https://norvig.com/ngrams/) 

Should the external files disappear from the expected locations, they can widely be found by searching for the exact base file name. 