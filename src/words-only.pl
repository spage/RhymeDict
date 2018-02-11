# word extract (TEMP)

# create output dataset, check output dir exists
use File::Path qw( make_path );
if( !-d '../out') {
	make_path('../out') || die "ERROR: Creating out path.";
}
open(OUT,'>../out/words.txt');
open(HGO,'>../out/homographs.txt');

# read from the filter dataset
open(DATASET,'<../out/filter-dataset.txt') ||
	die 'ERROR: filter dataset required';
while(<DATASET>){	
	chomp;
	($freq,$word,$phones) = split /\t/;
	if(exists $wordLookup{$word}){
		print HGO "$word\n" if (!exists $homographs{$word});
		$homographs{$word}=1;
	} else {		
		print OUT "$word\n";
	}
	$wordLookup{$word}=1;
}
close(DATASET);
close(OUT);
close(HGO);

