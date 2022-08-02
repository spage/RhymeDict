#!perl name-study.pl
use strict;

# name study (TEMP)

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
	if( /^[a-z]/ ) { $lookupHg{$_}=1 }
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

	my $nm = $words[0];
	foreach my $w (@words){
		next if ($lookupStop{$w});
		next if ($lookupHg{$w});
		next if (length($w)<3);
		next if ($lookupGroups{$w});
		$nm = $w;
		$lookupGroups{$w}=1;
		last;
	}
	print join("\t", $nm, sort @words) . "\n";
}
close(DATASET);

