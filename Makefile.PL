use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $inc = "";
my $define = "";
my $mod_perl = 1;

if ($mod_perl) {
    eval {
	use mod_perl 1.07_03;
	require Apache::src;
	my $src = Apache::src->new;

	unless (-d $src->dir) {
	    for my $path ($src->find) {
		my $ans = prompt("Configure with $path ?", "y");
		next unless $ans =~ /^y$/i;
		$src->dir($path);
		last;
	    }
	}

	$inc = $src->inc if -d $src->dir;
    };

    die "Please edit Makefile.PL's \$inc\n" unless $inc;

    $define = "-DMOD_PERL";
}

WriteMakefile(
    'NAME'	=> 'Apache::Peek',
    'VERSION_FROM'	=> 'Peek.pm',
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> $define,     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> $inc,     # e.g., '-I/usr/include/other' 
    'dist' => {COMPRESS=>'gzip -9f', SUFFIX=>'gz'},
);
