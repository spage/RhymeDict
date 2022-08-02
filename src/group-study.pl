#!perl group-study.pl
use strict;

# group study

open(STOP,'<../dat/stopwords.txt') ||
	die 'ERROR: stopwords dataset required';
my %lookupStop;
while(<STOP>){
	chomp;
	if( /^[a-z]/ ) { $lookupStop{$_}=1 }
}
close(STOP);


open(CONS,'<../out/consonants.txt') ||
	die 'ERROR: consonants dataset required';
my %consonants;
my @preCons;
while(<CONS>){
	chomp;
	(my $cblend, undef) = split /\t/;
	push(@preCons, $cblend);
}
push(@preCons, split(//,'bcdfghjklmnprstvwxyz'));
close(CONS);

#foreach my $c (@preCons){
#	print "$c\n";
#}


# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
my %phoneGroups;
while(<DATASET>){
	chomp;
	(my $freq, my $word, my $phones) = split /\t/;
	
	if( $phones =~ /(?<phone>[A-Z][A-Z][0-9][^0-9]*)$/ ){		
		push @{$phoneGroups{$+{phone}}}, join("\t",$freq,$word);
	}
}
close(DATASET);

# gather groups and group rank
my %groupRank;
my %groupStat;
foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	undef my @groupWords;
	my $freqSum = 0.0;
	my $groupCount = 0;
	my $prevWord = '';
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		(my $freq, my $word) = split(/\t/, $fword);
		$freqSum += $freq;			
		if (!exists $lookupStop{$word} && $word ne $prevWord){
			push(@groupWords, $word);
			$groupCount++;
		}
		$prevWord = $word;
	}
	#$groupName = join("\t", $grp, $groupCount, join(",", splice(@groupWords,0,3)));
	my $groupName = join("\t", $groupCount, $grp, join(",", @groupWords));
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
	my $sum += $groupStat{$grp};
	my $wsum += $grp * $groupStat{$grp};
	print STAT join("\t", $grp, $groupStat{$grp}, $sum, $wsum) . "\n";
}
close(STAT);

open(ENDS,'>../out/group-ends.txt');
foreach my $grp (sort { $phoneGroups{$b} <=> $phoneGroups{$a} } keys %phoneGroups){
	undef my @groupWords;
	undef my @groupEnds;
	undef my %ends;
	my $prevWord = '';
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		(my $freq, my $word) = split(/\t/, $fword);
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
	print ENDS join("\t", $grp, join(',', @groupWords), join(',', @groupEnds)) . "\n";
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
