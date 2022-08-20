#!perl build-merge-dataset.pl
use strict;

# build valid word lookup
my @allWords;
my %wordLookup;
my $wordsFile = '<../ext/enable1.txt';

# comparative word list study
#$wordsFile = '<../ext/word.list';

open(WORDS, $wordsFile) || 
	die 'ERROR: external data files required, see readme.';
while(<WORDS>){
	chomp;
	my $w = $_;
	$wordLookup{$w}=1;
	push(@allWords, $w);	
}
close(WORDS);

# process word additions
my $wordsFileAdds = '../dat/enable1.adds.txt';
if( -e $wordsFileAdds ){
	#print "word.adds\n";
	open(WORDS, "<$wordsFileAdds");
	while(<WORDS>){
		chomp;
		if( /^[a-z]/ ){
			my $w = $_;
			$wordLookup{$w}=1;
			push(@allWords, $w);
		}	
	}
	close(WORDS);
}

# build word freq lookup
my %freqLookup;
my $limit;
open(COUNTS, '../ext/count_1w.txt') || 
	die 'ERROR: external data files required, see readme.';
while(<COUNTS>){
	# limit to first 100000 words only
	last if $limit++ > 100000;
	chomp;
	(my $word, my $count) = split /\s/;
	if(exists $wordLookup{$word}){
		# word count out of one trillion in source file	
		my $freq = sprintf("%.12f",$count/1024908267229);
		$freqLookup{$word} = $freq;
	}
}
close(COUNTS);

# count addtions
my $countFileAdds = '../dat/count.adds.txt';
if( -e $countFileAdds ){
	#print "count.adds\n";
	open(WORDS, "<$countFileAdds");
	while(<WORDS>){
		chomp;
		if( /^[a-z]/ ){
			(my $word, my $count) = split /\s/;	
			my $freq = sprintf("%.12f",$count/1024908267229);
			$freqLookup{$word} = $freq;
		}
	}
	close(WORDS);
}

# build phones lookup
my %phoneLookup;
open(CMUDIC, '<../ext/cmudict-0.7b') || 
	die 'ERROR: external data files required, see readme.';
while(<CMUDIC>){
	chomp;
	if( /^[A-Z]/ ){
		(my $word, my $phones) = split /\s\s/;
		$word =~ tr/A-Z/a-z/;

		# remove count of pronunciations
		$word =~ tr/)(0-9//d;

		# discard non-words 
		if(exists $wordLookup{$word} ){
			# append pronunciation
			if(exists $phoneLookup{$word}){
				$phoneLookup{$word} = $phoneLookup{$word} . ':' . $phones;
			}else{
				$phoneLookup{$word} = $phones;
			}
		}
	}
}
close(CMUDIC);

# process dict additions
my $dictFileAdds = '../dat/cmudict.adds.txt';
if( -e $dictFileAdds ){
	#print "cmu.adds\n";
	open(WORDS, "<$dictFileAdds");
	while(<WORDS>){
		chomp;
		if( /^[A-Z]/ ){
			(my $word, my $phones) = split /\s\s/;
			$word =~ tr/A-Z/a-z/;
			$phoneLookup{$word} = $phones;
		}
	}
	close(WORDS);
}

# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/merge-dataset.txt');


#open(WORDS, $wordsFile);
#while(@allWords){
	#chomp;
	#my $word = $_;
foreach my $word (sort @allWords){	
	my $reasonCode = 'PRD_OK';

	my $freq = $freqLookup{$word};
	if($reasonCode eq 'PRD_OK' && !defined($freq)){
		$freq = '0.000000000000';
		$reasonCode = 'PRD_FREQ';
		print OUT join("\t", $freq, $reasonCode, $word) . "\n";
	}

	my $phones = $phoneLookup{$word};
	if($reasonCode eq 'PRD_OK' && !defined($phones)){
		$reasonCode = 'PRD_DICT';
		print OUT join("\t", $freq, $reasonCode, $word) . "\n";
	}

	# write each pronunciation on its own line
	if($reasonCode eq 'PRD_OK'){
		foreach my $phone (split(':',$phones)){
			# count syllables as vowel phones count (012 marks vowels)
			my $syllableCount = $phone =~ tr/012//;
			my $syb = 'SYB_' . $syllableCount;
			print OUT join("\t", $freq, $reasonCode, $syb, $word, $phone) . "\n";
		}
	}

}
#close(WORDS);


# filter, extend, reformat pronunciation dictionary
##open(CMUDIC, '<../ext/cmudict-0.7b') || 
##	die 'ERROR: external data files required, see readme.';
##while(<CMUDIC>){
##	chomp;
##	if( /^[A-Z]/ ){
##		(my $word, my $phones) = split /\s\s/;
##		$word =~ tr/A-Z/a-z/;
##		$word =~ tr/)(0-9//d;
##		# count syllables as vowel phones count (012 marks vowels)
##		my $syllableCount = $phones =~ tr/012//;
##		# discard non-words and two-or-more syllable words
##		if(exists $wordLookup{$word} && $syllableCount<2){
##			# account for words missing freq data
##			my $freq = $freqLookup{$word};
##			if(!defined($freq)){
##				$freq = "0.000000000001";
##			}
##			print OUT join("\t", $freq, $word, $phones) . "\n";
##		}
##	}
##}
##close(CMUDIC);
close(OUT);
