package TestApachePeek::basic;

use strict;
use warnings FATAL => 'all';

use mod_perl;
use constant MP2 => $mod_perl::VERSION < 1.99 ? 0 : 1;

BEGIN {
    if (MP2) {
        require Apache::RequestRec;
        require Apache::RequestIO;
        require Apache::Const;
        Apache::Const->import(-compile => 'OK');
    }
    else {
        require Apache;
        require Apache::Constants;
        Apache::Constants->import('OK');
    }
}

BEGIN { warn join "\n", @INC; }

use Apache::Peek;

sub handler {
    my $r = shift;

    $r->content_type('text/plain');

    $r->send_http_header() unless MP2;

    Apache::Peek::Dump(\&Apache::Const::OK);

    return MP2 ? Apache::OK : Apache::Constants::OK;
}
1;
__END__
SetHandler perl-script
