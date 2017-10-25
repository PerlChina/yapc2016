package DB;

use strict;
use warnings;
use base qw(Exporter);
use MongoDB;
use Dancer qw(:syntax);

our @EXPORT_OK = qw(db db_clear);
our @EXPORT = @EXPORT_OK;

our $_connection;
our $_db;

sub db {
    if (!$_db) {
        $_connection = MongoDB->connect('mongodb://mongo');
        $_db = $_connection->get_database(setting('mongodb_name'));
    }
    return $_db;
}

sub db_clear {
    if ($_connection) {
        $_connection->disconnect();
    }
    undef $_db;
    undef $_connection;
}

1;
