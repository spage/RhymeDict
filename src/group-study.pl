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
		$wordGroups{$word}++;
		push(@groupWords, $word) if (1);
	}
	#$groupName = join("\t", $grp, $groupCount, join(",", splice(@groupWords,0,3)));
	$groupName = join("\t", $groupCount, $grp, join(",", @groupWords));
	$groupRank{$groupName} = sprintf("%.12f",$freqSum);
	$groupStat{$groupCount}++;
}

foreach my $grp (reverse sort {$a <=> $b} keys %groupStat){
	$sum += $groupStat{$grp};
	$wsum += $grp * $groupStat{$grp};
	print join("\t", $grp, $groupStat{$grp}, $sum, $wsum) . "\n";
}

foreach my $grp (sort { $groupRank{$b} <=> $groupRank{$a} } keys %groupRank){
	$flag = '';
	if($grp =~ /^1\t/){
		($c,$p,$w) = split(/\t/,$grp);
		if($wordGroups{$w}==1){
			$flag = '*';
		}
	}
	print join("\t", $groupRank{$grp}, $grp) . $flag . "\n";
}
# output groups by rank build group index
# output group content separately
