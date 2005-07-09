use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;
use Apache::TestRequest;

plan tests => 2;

my $location = "/TestApachePeek__basic";
my $str = GET_BODY $location;

ok $str;

eval { require mod_perl2 };
unless ($@) {
    ok t_cmp($str, qr/Apache2::Const.*?OK/);
}
else {
    ok t_cmp($str, qr/Apache::Const.*?OK/);
}

