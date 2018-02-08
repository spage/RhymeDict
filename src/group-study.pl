# group study

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){
	$line = $_;
	chomp;
	($freq,$word,$phones) = split /\t/;
	

	if( $phones =~ /(?<phone>[A-Z][A-Z][0-9][^0-9]*)$/ ){		
		push @{$phoneGroups{$+{phone}}}, join("\t",$freq,$word);
	}
}
close(DATASET);

# compute group name (top3) and group rank
foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	undef @groupWords;
	$freqSum = 0.0;
	$groupCount = 0;
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		($freq,$word) = split(/\t/, $fword);
		$freqSum += $freq;
		$groupCount++;
		push(@groupWords, $word) if (1);
	}
	#$groupName = join("\t", $grp, $groupCount, join(",", splice(@groupWords,0,3)));
	$groupName = join("\t", $groupCount, $grp, join(",", @groupWords));
	$groupRank{$groupName} = sprintf("%.12f",$freqSum);
}

foreach my $grp (sort { $groupRank{$b} <=> $groupRank{$a} } keys %groupRank){
	print join("\t", $groupRank{$grp}, $grp) . "\n";
}
# output groups by rank build group index
# output group content separately
