#!perl name-study.pl
use strict;

# name study (TEMP)
# pick the word that best represents the list of words
# words should be in usage frequency order to penalize obscure words

open(STOP,'<../dat/stopwords.txt') ||
	die 'ERROR: stopwords dataset required';
my %lookupStop;
while(<STOP>){
	chomp;
	if( /^[a-z]/ ) { $lookupStop{$_}=1 }
}
close(STOP);

open(HG,'<../out/homographs.txt') ||
	die 'ERROR: homographs dataset required';
my %lookupHg;
while(<HG>){
	chomp;
	(my $word, undef) = split /\t/;
	if( /^[a-z]/ ) { $lookupHg{$word}=1 }
}
close(HG);


# read from the filter dataset
open(DATASET,'<../out/groups.txt') ||
	die 'ERROR: groups dataset required';
my %lookupGroups;
while(<DATASET>){
	chomp;
	(my $freq, my $wordCount, my $phones, my $wordList) = split /\t/;
	my @words = split(/,/, $wordList);

	# choose the first word as default
	# falls through if a better word is not found
	my $nm = $words[0];
	foreach my $w (@words){
		# don't choose a stop word
		next if ($lookupStop{$w});
		# don't choose a homograph (two prons same sp)
		next if ($lookupHg{$w});
		# don't choose a too short word
		next if (length($w)<3);
		# don't choose a word already chosen
		next if ($lookupGroups{$w});
		# take the first word meeting these criteria
		$nm = $w;
		$lookupGroups{$w}=1;
		#stop looking
		last;
	}
	print join("\t", $nm, sort @words) . "\n";
}
close(DATASET);

