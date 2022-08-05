mkdir ..\ext
Invoke-WebRequest -Uri https://norvig.com/ngrams/enable1.txt -OutFile ..\ext\enable1.txt
Invoke-WebRequest -Uri https://norvig.com/ngrams/count_1w.txt -OutFile ..\ext\count_1w.txt
Invoke-WebRequest -Uri https://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/cmudict-0.7b -OutFile ..\ext\cmudict-0.7b