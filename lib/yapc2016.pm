package yapc2016;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/halt' => sub {
    halt "hello";
};

get '/error' => sub {
    send_error "hello2", 400;
};

true;
