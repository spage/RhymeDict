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


open(HG,'<../out/homographs.txt') ||
	die 'ERROR: homographs dataset required';
my %lookupHg;
while(<HG>){
	chomp;
	(my $word, undef) = split /\t/;
	if( /^[a-z]/ ) { $lookupHg{$word}=1 }
}
close(HG);


open(GO,'<../dat/group-over.txt') ||
	die 'ERROR: group-over dataset required';
my %groupNameOverrides;
while(<GO>){
	chomp;
	(my $phone, my $override) = split /\t/;
	if( /^[A-Z]/ ) { $groupNameOverrides{$phone}=$override }
}
close(GO);


# currently unused, hold for copy/paste to page generation
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


# output group dataset, compute group ends and group names
open(GRP,'>../out/group-dataset.txt');
print GRP "#" . join("\t", "group", "name", "wc", "words", "ends") . "\n";
my %lookupGroups;
foreach my $grp (sort keys %phoneGroups){
	undef my @groupWords;
	undef my @groupEnds;
	undef my %ends;
	my $prevWord = '';
	foreach my $freqword (reverse sort @{$phoneGroups{$grp}}){
		(my $freq, my $word) = split(/\t/, $freqword);
		if ($word ne $prevWord && !exists($lookupStop{$word})){

			push(@groupWords, $word);			
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

	# choose the first word as default
	# falls through if a better word is not found
	my $groupName = $groupWords[0];
	foreach my $w (@groupWords){
		# don't choose a stop word
		next if ($lookupStop{$w});
		# don't choose a homograph (two prons same sp)
		next if ($lookupHg{$w});
		# don't choose a too short word
		next if (length($w)<3);
		# don't choose a word already chosen
		next if ($lookupGroups{$w});
		# take the first word meeting these criteria
		$groupName = $w;
		$lookupGroups{$w}=1;
		#stop looking
		last;
	}

	# drop vowel stress for output
	$grp =~ s/[012]//g;

	# override group name
	if( exists($groupNameOverrides{$grp})){
		$groupName = $groupNameOverrides{$grp};
	}

	print GRP join("\t", $grp, $groupName, scalar(@groupWords), join(',', @groupWords), join(',', @groupEnds)) . "\n";
}
close(GRP);

