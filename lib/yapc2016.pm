package yapc2016;
use Dancer ':syntax';
use DB;
use Check;
use Common;

our $VERSION = '0.1';

db->coll('users')->indexes->create_one( [ nick => 1 ], { unique => 1 } );
db_clear();

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
    my $o = {nick => $nick, pass => passwd($pass), createAt => time, updateAt => time, role => 'user'};
    my $res;
    eval {
        $res= db->coll('users')->insert_one($o);
    };
    if ($@) {
        if ($@ =~ /E11000 duplicate/) {
            fail("昵称已被占用");
        }
        fail("网络不给力啊");
    }
    $o->{_id} = $res->inserted_id;
    delete $o->{'pass'};
    session 'user' => $o;
    succeed($o);
};

post '/api/user/login' => sub {
    my $nick = param 'nick';
    my $pass = param 'pass';
    check_required($nick, "昵称必须填写");
    check_required($pass, "密码必须填写");
    my $user = db->coll('users')->find_one({nick => $nick, pass => passwd($pass)});
    if ($user) {
        delete $user->{pass};
        session 'user' => $user;
        succeed $user;
    } else {
        fail("昵称或密码错误");
    }
};

get '/api/account/info' => sub {
    my $user = session 'user';
    if ($user) {
        succeed($user);
    } else {
        fail("没有这个用户");
    }
};

get '/api/user/logout' => sub {
    session 'user' => undef;
    succeed;
};

true;
