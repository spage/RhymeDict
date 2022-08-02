#!perl build-merge-dataset.pl
use strict;

# build valid word lookup
my %wordLookup;
open(ENABLE, '<../ext/enable1.txt') || 
	die 'ERROR: external data files required, see readme.';
while(<ENABLE>){
	chomp;
	$wordLookup{$_}=1;
}
close(ENABLE);

# build word freq lookup
my %freqLookup;
open(COUNTS, '../ext/count_1w.txt') || 
	die 'ERROR: external data files required, see readme.';
while(<COUNTS>){
	chomp;
	(my $word, my $count) = /\s/;
	if(exists $wordLookup{$word}){
		# word count out of one trillion in source file	
		$freqLookup{$word} = sprintf("%.12f",$count/1024908267229);
	}
}
close(COUNTS);


# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/merge-dataset.txt');

# filter, extend, reformat pronunciation dictionary
open(CMUDIC, '<../ext/cmudict-0.7b') || 
	die 'ERROR: external data files required, see readme.';
while(<CMUDIC>){
	chomp;
	if( /^[A-Z]/ ){
		(my $word, my$phones) = split /\s\s/;
		$word =~ tr/A-Z/a-z/;
		$word =~ tr/)(0-9//d;
		# count syllables as vowel phones count (012 marks vowels)
		my $syllableCount = $phones =~ tr/012//;
		# discard non-words and two-or-more syllable words
		if(exists $wordLookup{$word} && $syllableCount<2){
			# account for words missing freq data
			my $freq = $freqLookup{$word};
			if(!defined($freq)){
				$freq = "0.000000000001";
			}
			print OUT join("\t", $freq, $word, $phones) . "\n";
		}
	}
}
close(CMUDIC);
close(OUT);
