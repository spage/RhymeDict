# word extract (TEMP)

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){	
	chomp;
	($freq,$word,$phones) = split /\t/;	
	print "$word\n";
}
close(DATASET);

