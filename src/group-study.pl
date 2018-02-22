#!perl group-study.pl

# group study

open(STOP,'<../dat/stopwords.txt') ||
	die 'ERROR: stopwords dataset required';
while(<STOP>){
	chomp;
	if( /^[a-z]/ ) { $lookupStop{$_}=1 }
}
close(STOP);


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

# gather groups and group rank
foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	undef @groupWords;
	$freqSum = 0.0;
	$groupCount = 0;
	$prevWord = '';
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		($freq,$word) = split(/\t/, $fword);
		$freqSum += $freq;			
		if (!exists $lookupStop{$word} && $word ne $prevWord){
			push(@groupWords, $word);
			$groupCount++;
		}
		$prevWord = $word;
	}
	#$groupName = join("\t", $grp, $groupCount, join(",", splice(@groupWords,0,3)));
	$groupName = join("\t", $groupCount, $grp, join(",", @groupWords));
	$groupRank{$groupName} = sprintf("%.12f",$freqSum);
	$groupStat{$groupCount}++;
}

# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(STAT,'>../out/group-stats.txt');

foreach my $grp (reverse sort {$a <=> $b} keys %groupStat){
	$sum += $groupStat{$grp};
	$wsum += $grp * $groupStat{$grp};
	print STAT join("\t", $grp, $groupStat{$grp}, $sum, $wsum) . "\n";
}
close(STAT);

open(ENDS,'>../out/group-ends.txt');
foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	undef @groupWords;
	undef @groupEnds;
	undef %ends;
	$prevWord = '';
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		($freq,$word) = split(/\t/, $fword);
		if ($word ne $prevWord){
			push(@groupWords, $word);
			$word =~ /(?<end>[aeiouy].+)$/;
			$ends{'-'.$+{end}}++;
		}
		$prevWord = $word;
	}
	foreach my $end (sort { $ends{$b} <=> $ends{$a} } keys %ends){
		push(@groupEnds, join(':', $end, $ends{$end}));
	}
	print ENDS join("\t", $grp, join(',',@groupWords), join(',',@groupEnds)) . "\n";
}
close(ENDS);

open(GRP,'>../out/groups.txt');
open(NGRP,'>../out/non-groups.txt');
foreach my $grp (sort { $groupRank{$b} <=> $groupRank{$a} } keys %groupRank){
	next if ($grp =~ /^0\t/);
	if($grp =~ /^[123]\t/){
		print NGRP join("\t", $groupRank{$grp}, $grp) . "\n";
	} else {
		print GRP join("\t", $groupRank{$grp}, $grp) . "\n";
	}	
}
close(NGRP);
close(GRP);
