#!perl 04-consonant-study.pl
use strict;

# consonant study (TEMP)

# read from the filter dataset
my %consonantBlends;
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){
	chomp;
	(my $freq, my $reasonCode, my $syb, my $word, my $phones) = split /\t/;
	next if ($reasonCode ne 'PRD_OK');

	# extract consonant blend, special case for squ to simplify
	if( $word !~ /^squ/ && $word =~ /^(?<cblend>[^aeiouy]{2,4})[aeiouy]/ ){		
		$consonantBlends{$+{cblend}}++;
	}

	# qu blends of special interest
	if( $word =~ /^qu/) { $consonantBlends{'qu'}++ }
	if( $word =~ /^squ/) { $consonantBlends{'squ'}++ }
}
close(DATASET);

# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/consonants.txt');

foreach my $cb (sort { $consonantBlends{$b} <=> $consonantBlends{$a} } keys %consonantBlends){
	print OUT join("\t",$cb,$consonantBlends{$cb}) . "\n";
}
close(OUT);
