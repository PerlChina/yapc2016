package yapc2016;
use Dancer ':syntax';
use DB;
use Check;
use Common;

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

post '/api/user/register' => sub {
    my $nick = param 'nick';
    my $pass = param 'pass';
    check_required($nick, "昵称必须填写");
    check_required($pass, "密码必须填写");
    db->coll('users')->insert_one({nick => $nick, pass => passwd($pass), createAt => time, updateAt => time, role => 'user'});
    succeed;
};

true;
