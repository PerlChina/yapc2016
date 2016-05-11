package Dancer::Session::MyMongoDB;

use DB;
use base 'Dancer::Session::Abstract';
use Dancer qw(:syntax);

sub create {
    return $_[0]->new->flush;
}

sub flush {
    my $self = shift;
    my %obj = %$self;
    delete $obj{'id'};
    db->coll('sessions')->replace_one({_id => $self->id}, {data => \%obj, updateAt => time, _id => $self->id}, {'upsert' => 1});
    return $self;
}

sub destroy {
    my $self = shift;
    db->coll('sessions')->delete_one({_id => $self->id});
}

sub retrieve {
    my ($class, $id) = @_;
    my $row = db->coll('sessions')->find_one({_id => $id});
    my $obj = $row->{'data'};
    $obj->{'id'} = $id;
    return bless $obj, $class;
}

1;
