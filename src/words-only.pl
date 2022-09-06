#!perl words-only.pl
use strict;

# word extract (TEMP)
open(STOP,'<../dat/stopwords.txt') ||
	die 'ERROR: stopwords dataset required';
my %lookupStop;
while(<STOP>){
	chomp;
	if( /^[a-z]/ ) { $lookupStop{$_}=1 }
}
close(STOP);

# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}

# each word only listed once
open(OUT,'>../out/words.txt');

# homographs are words spelled the same with multiple
# pronunciations (bass-fish, bass-instrument)
open(HGO,'>../out/homographs.txt');

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
my %homographs;
my %wordLookup;
while(<DATASET>){	
	chomp;
	(my $freq, my $reasonCode, my $syb, my $word, my $phones) = split /\t/;
	next if ($reasonCode ne 'PRD_OK' || exists $lookupStop{$word});
	if(exists $wordLookup{$word}){
		print HGO "$word\t" . join(':', $wordLookup{$word}, $phones) . "\n" if (!exists $homographs{$word});
		$homographs{$word}=1;
	} else {		
		print OUT "$word\n";
	}
	$wordLookup{$word}=$phones;
}
close(DATASET);
close(OUT);
close(HGO);

