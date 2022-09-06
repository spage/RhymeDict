#!perl group-study.pl
use strict;
use POSIX qw(ceil);

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


# build phone groups
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';	
my %phoneGroups;
while(<DATASET>){
	chomp;
	(my $freq, my $reasonCode, my $syb, my $word, my $phones) = split /\t/;
	next if ($reasonCode ne 'PRD_OK');
	
	# this expression grabs the last vowel sound to the end of the phones
	if( $phones =~ /(?<phone>[A-Z][A-Z][0-9][^0-9]*)$/ ){		
		push @{$phoneGroups{$+{phone}}}, join("\t",$freq,$word);
	}
}
close(DATASET);


# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}


# gather group stats
my %groupOccurs;
foreach my $grp (sort keys %phoneGroups){
	my $groupCount = 0;
	my $prevWord = '';
	foreach my $freqword (reverse sort @{$phoneGroups{$grp}}){
		(my $freq, my $word) = split(/\t/, $freqword);		
		if (!exists $lookupStop{$word} && $word ne $prevWord){
			$groupCount++;
		}
		$prevWord = $word;
	}
	$groupOccurs{$groupCount}++;
}


# output group stats
open(STAT,'>../out/group-stats.txt');
print STAT join("\t", "CNT", "OC", "OCC", "PG", "WC", "WCC") . "\n";
my $allWords = 0;
my $allGroups = 0;
foreach my $groupCount (reverse sort {$a <=> $b} keys %groupOccurs){
	my $wordCount += $groupCount * $groupOccurs{$groupCount};
	$allWords += $wordCount;
	$allGroups += $groupOccurs{$groupCount};
	my $pageCount = ceil($allGroups / 4);
	print STAT join("\t", $groupCount, $groupOccurs{$groupCount}, $allGroups, $pageCount, $wordCount, $allWords) . "\n";
}
close(STAT);


open(ENDS,'>../out/group-dataset.txt');
foreach my $grp (sort keys %phoneGroups){
	undef my @groupWords;
	undef my @groupEnds;
	undef my %ends;
	my $prevWord = '';
	foreach my $fword (reverse sort @{$phoneGroups{$grp}}){
		(my $freq, my $word) = split(/\t/, $fword);
		if ($word ne $prevWord){
			#mark stopwords, TEMP?
			my $stopmark = '';
			if($lookupStop{$word}){
				$stopmark = '*';
			}
			push(@groupWords, $word . $stopmark);
			$word =~ /(?<end>(([aeiou].*)|(y[^aeiou]*)))$/;
			my $end = $+{end};

			if( $word =~ /^s?qu/ ){
				#squ qu special case, ignore u
				$ends{'-'. substr($end,1)}++;
			}else{
				$ends{'-'. $end}++;
			}
			
		}
		$prevWord = $word;
	}
	foreach my $end (sort keys %ends){
		push(@groupEnds, join(':', $end, $ends{$end}));
	}
	print ENDS join("\t", $grp, scalar(@groupWords), join(',', @groupWords), join(',', @groupEnds)) . "\n";
}
close(ENDS);

