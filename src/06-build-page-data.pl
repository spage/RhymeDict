#!perl 06-build-page-data.pl
use strict;

# build page data files

# load group dataset
open(DATASET,'<../out/group-dataset.txt') ||
	die 'ERROR: group dataset required';	
while(<DATASET>){
	chomp;
	next unless( /^[A-Z]/ );

	(my $group, my $name, my $wc, my $words, my $ends) = split /\t/;

	# only build for pages with more than 5 words
	#next if ($wc =~ /^[12345]$/);
	
	# only build for pages with 2-5 words
	#next unless ($wc =~ /^[2345]$/);

	# only build for pages with 1 word
	next unless ($wc eq '5');

	print join("\t", $name . "(" . $wc . ")", $words) . "\n";
}
close(DATASET);