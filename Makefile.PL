use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use Apache::src ();

WriteMakefile(
    'NAME'	=> 'Apache::Peek',
    'VERSION_FROM'	=> 'Peek.pm',
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '-DMOD_PERL',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> Apache::src->new->inc,     # e.g., '-I/usr/include/other' 
    'dist' => {COMPRESS=>'gzip -9f', SUFFIX=>'gz'},
);
