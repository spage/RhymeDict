#!perl reduce-filter-dataset.pl
use strict;

# read list of words to be included (keeps rules simple)
open(INCLUDE,'<../dat/include.txt') ||
	die 'ERROR: include dataset required';
my %lookupInclude;
while(<INCLUDE>){
	chomp;
	if( /^[a-z]/ ) { $lookupInclude{$_}=1 }
}
close(INCLUDE);

# read list of words to be excluded (eliminates unworthy)
open(EXCLUDE,'<../dat/exclude.txt') ||
	die 'ERROR: exclude dataset required';
my %lookupExclude;
while(<EXCLUDE>){
	chomp;
	if( /^[a-z]/ ) {
		(my $exclude, my $reasonCode) = split /\t/;
		$lookupExclude{$exclude}=$reasonCode; 
	}
}
close(EXCLUDE);

open(REPLACE,'<../dat/replace.txt')||
	die 'ERROR: replace dataset required';
my %lookupReplace;
while(<REPLACE>){
	chomp;
	if( /^[a-z]/ ) { 
		(my $srcW, my $srcP, my $destP) = split /\t/;
		if(!defined $destP){
			$destP = '<REMOVE>';
		}
		$lookupReplace{join("\t",$srcW,$srcP)}=$destP;
	}
}
close(REPLACE);


# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/filter-dataset.txt');


open(DATASET,'<../out/merge-dataset.txt') ||
	die 'ERROR: merge dataset required';
while(<DATASET>){
	chomp;
	(my $freq, my $reasonCode, my $syb, my $word, my $phones) = split /\t/;

	# eliminate the unworthy, manual edits
	if (exists $lookupExclude{$word}){
		$reasonCode = $lookupExclude{$word};
	}

	# process rules, (includes simplify rule exceptions)

	# strip out plurals with -s
	if ($word =~ /[^s]s$/ && !exists $lookupInclude{$word}){
		$reasonCode = 'PRD_PLU_S';
	}

	if ($word =~ /[^s]s$/ && exists $lookupInclude{$word}){
		$reasonCode = 'PRD_PLU_S_INC';
	}

	# strip out simple past tense -ed
	if ($word =~ /ed$/ && !exists $lookupInclude{$word}){
		$reasonCode = 'PRD_PST_ED';
	}

	if ($word =~ /ed$/ && exists $lookupInclude{$word}){
		$reasonCode = 'PRD_PST_ED_INC';
	}

	# replace or remove word pronunciation
	if(exists $lookupReplace{join("\t", $word, $phones)}) {		
		$phones = $lookupReplace{join("\t", $word, $phones)};
		if( $phones eq '<REMOVE>'){
			$reasonCode = 'PRD_PRON';
		}
	}

	print OUT join("\t", $freq, $reasonCode, $syb, $word, $phones) . "\n";
}
close(DATASET);
close(OUT);

