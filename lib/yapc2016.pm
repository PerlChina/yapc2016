package yapc2016;
use Dancer ':syntax';
use DB;
use Check;

our $VERSION = '0.1';

get '/' => sub {
    redirect '/c/2016';
};

get '/halt' => sub {
    halt "hello";
};

get '/error' => sub {
    send_error "hello2", 400;
};

get '/c/:conferenceName' => sub {
    my $conferenceName = param 'conferenceName';
    check_required($conferenceName);
    my $conference = db->coll('conferences')->find_one({name => $conferenceName});
    check_required($conference);
    template 'conference_home' => { page_title => '首页', page_channel => 'home', item => $conference };
};

true;
