# group study

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){
	$line = $_;
	chomp;
	($freq,$word,$phones) = split /\t/;
	

	if( $phones =~ /(?<phone>[A-Z][A-Z][0-9][^0-9]+)$/ ){		
		$phoneGroups{$+{phone}}++;
	}
}
close(DATASET);


foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	print join("\t",$grp,$phoneGroups{$grp}) . "\n";
}
