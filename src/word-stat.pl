#!perl word-stat.pl
use strict;

# MUST get target word from command line
die 'ERROR: specify target word' unless (@ARGV eq 1);
my $targetWord = $ARGV[0];

# start Banner, absolutely frivilous, delete 
use Text::Banner;
my $ban = Text::Banner->new();
$ban->set($targetWord);
#$ban->size(3);
$ban->fill('*');
#$ban->rotate('h');
print $ban->get();
# end Banner

print "Word:$targetWord\n";
print "---\n";


# filter data set
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';	

my $foundInSet = 0;
while(<DATASET>){
	chomp;
	(my $freq, my $reasonCode, my $syb, my $word, my $phones) = split /\t/;

	if( $word eq $targetWord ){
		$foundInSet++;		
		print "ReasonCode:$reasonCode\n";
		print "Phones:$phones\n";
		print "Syllables:$syb\n";
		print "Frequency:$freq\n";
		print "---\n" if( $foundInSet > 0 );
	}
}
print "ExcludeBy:FILTER\n" if( $foundInSet == 0); 
close(DATASET);


# load group dataset
open(DATASET,'<../out/group-dataset.txt') ||
	die 'ERROR: group dataset required';
$foundInSet = 0;
while(<DATASET>){
	chomp;
	next unless( /^[A-Z]/ );

	(my $group, my $name, my $wc, my $words, my $ends) = split /\t/;

	if( $words =~ /\b$targetWord\b/){
		$foundInSet++;
		print 'Group:' . join("\t", $name . "(" . $wc . ")", $words) . "\n";
	}			
}
print "Group:NONE\nExcludeBy:GROUP\n" if( $foundInSet == 0); 
print "---\n"; 
close(DATASET);


# read list of words to be included (keeps rules simple)
open(INCLUDE,'<../dat/include.txt') ||
	die 'ERROR: include dataset required';
my $IncludeReason = '';
while(<INCLUDE>){
	chomp;
	if( /^#/ ){
		$IncludeReason = substr($_,1);
	}
	print "Include:$IncludeReason\n" if( $_ eq $targetWord ); 
}
close(INCLUDE);


# read list of words to be excluded (eliminates unworthy)
open(EXCLUDE,'<../dat/exclude.txt') ||
	die 'ERROR: exclude dataset required';
while(<EXCLUDE>){
	chomp;
	if( /^[a-z]/ ) {
		(my $exclude, my $reasonCode) = split /\t/;
		print "Exclude:$reasonCode\n" if( $exclude eq $targetWord );
	}
}
close(EXCLUDE);


# pronunciation replaces and removes
open(REPLACE,'<../dat/replace.txt')||
	die 'ERROR: replace dataset required';
while(<REPLACE>){
	chomp;
	if( /^[a-z]/ ) { 
		(my $srcW, my $srcP, my $destP) = split /\t/;
		if(!defined $destP){
			print "Remove:$srcP\n" if ($srcW eq $targetWord);
		}
		print "Replace:$srcP=>$destP\n" if ($srcW eq $targetWord);
	}
}
close(REPLACE);


# count addtions
my $countFileAdds = '../dat/count.adds.txt';
if( -e $countFileAdds ){
	open(WORDS, "<$countFileAdds");
	while(<WORDS>){
		chomp;
		if( /^[a-z]/ ){
			(my $word, my $count) = split /\s/;	
			print "Infrequent:$count\n" if ($word eq $targetWord);
		}
	}
	close(WORDS);
}


# process dict additions
my $dictFileAdds = '../dat/cmudict.adds.txt';
if( -e $dictFileAdds ){
	open(WORDS, "<$dictFileAdds");
	while(<WORDS>){
		chomp;
		if( /^[A-Z]/ ){
			(my $word, my $phones) = split /\s\s/;
			$word =~ tr/A-Z/a-z/;
			print "DictAdd:$word $phones\n"	if ($word eq $targetWord);
		}
	}
	close(WORDS);
}


# stopwords
open(STOP,'<../dat/stopwords.txt') ||
	die 'ERROR: stopwords dataset required';
my %lookupStop;
while(<STOP>){
	chomp;
	if( /^[a-z]/ ) 
	{ 
		print "Stopword:Yes\n" if ($_ eq $targetWord);
	}
}
close(STOP);





