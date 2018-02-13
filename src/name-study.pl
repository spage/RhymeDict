#!perl build-merge-dataset.pl

# name study (TEMP)



# read from the filter dataset
open(DATASET,'<../out/groups.txt') ||
	die 'ERROR: groups dataset required';
while(<DATASET>){
	$line = $_;
	chomp;
	($freq,$wordCount,$phones,$wordList) = split /\t/;
	@words = split(/,/, $wordList);
	print join("\t",@words) . "\n";
}
close(DATASET);

