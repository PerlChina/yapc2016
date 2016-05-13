package Common;

use strict;
use warnings;
use base qw(Exporter);
use Dancer qw(:syntax);
use Digest::SHA1 qw(sha1_hex);
use Data::UUID;
use Digest::MD5 qw(md5_hex);

our @EXPORT_OK = qw(succeed fail passwd hash_dir get_ext);
our @EXPORT = @EXPORT_OK;

sub passwd {
    sha1_hex("sdfsglkg3rolkjg;dlftttt" . $_[0]);
}

sub succeed {
    my $o = $_[0] || {};
    $o->{success} = 1;
    halt($o);
}

sub fail {
    var error => $_[0];
    halt({error => $_[0]});
}

sub hash_dir {
    my $id = shift;
    if (!$id) {
        my $ug = Data::UUID->new;
        $id = $ug->create_str;
    }
    my $idmd5 = md5_hex($id);
    my $dir = substr($idmd5, 10, 2) . "/" . substr($idmd5, 20, 2);
    return ($dir, $id);
}

sub get_ext {
    my $filename = shift;
    if ($filename =~ /(\.[^\.]+)$/) {
        my $ext = $1;
        return $ext;
    } else {
        return undef;
    }
}

1;
