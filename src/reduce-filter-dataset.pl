#!perl reduce-filter-dataset.pl

# read list of words to be included (keeps rules simple)
open(INCLUDE,'<../dat/include.txt') ||
	die 'ERROR: include dataset required';
while(<INCLUDE>){
	chomp;
	if( /^[a-z]/ ) { $lookupInclude{$_}=1 }
}
close(INCLUDE);

# read list of words to be excluded (eliminates unworthy)
open(EXCLUDE,'<../dat/exclude.txt') ||
	die 'ERROR: exclude dataset required';
while(<EXCLUDE>){
	chomp;
	if( /^[a-z]/ ) { $lookupExclude{$_}=1 }
}
close(EXCLUDE);


# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/filter-dataset.txt');


open(DATASET,'<../out/merge-dataset.txt') ||
	die 'ERROR: merge dataset required';
while(<DATASET>){
	$line = $_;
	chomp;
	($freq,$word,$phones) = split /\t/;

	# eliminate the unworthy
	next if (exists $lookupExclude{$word});

	# strip out plurals with -s
	next if ($word =~ /[^s]s$/ && !exists $lookupInclude{$word});

	# strip out simple past tense -ed
	next if ($word =~ /ed$/ && !exists $lookupInclude{$word});

	print OUT $line;
}
close(DATASET);
close(OUT);

