package TestApachePeek::basic;

use strict;
use warnings FATAL => 'all';

eval { require mod_perl2 };

use constant MP2 => $@ ? 0 : 1;

BEGIN {
    if (MP2) {
        require Apache2::RequestRec;
        require Apache2::RequestIO;
        require Apache2::Const;
        Apache2::Const->import(-compile => 'OK');
    }
    else {
        require Apache;
        require Apache::Constants;
        Apache::Constants->import('OK');
    }
}

use Apache::Peek;

sub handler {
    my $r = shift;

    $r->content_type('text/plain');

    $r->send_http_header() unless MP2;

    Apache::Peek::Dump(\&Apache2::Const::OK);

    return MP2 ? Apache2::Const::OK : Apache::Constants::OK;
}
1;
__END__
SetHandler perl-script
