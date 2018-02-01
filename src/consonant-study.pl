# consonant study

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){
	$line = $_;
	chomp;
	($freq,$word,$phones) = split /\t/;
	

	if( $word =~ /^(?<cblend>[^aeiouy]{2,4})[aeiouy]/ ){		
		$consonantBlends{$+{cblend}}++;
	}

	# of special interest
	if( $word =~ /^qu/) { $consonantBlends{'qu'}++ }
}
close(DATASET);


foreach my $cb (sort { $consonantBlends{$b} <=> $consonantBlends{$a} } keys %consonantBlends){
	print join("\t",$cb,$consonantBlends{$cb}) . "\n";
}
