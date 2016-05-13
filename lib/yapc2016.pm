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
    session conference => $conference;
    my @news = db->coll("news")->find({})->sort(['createAt' => -1])->all();
    template 'conference_home' => { page_title => '首页', page_channel => 'home', item => $conference, news => \@news };
};

get '/c/:conferenceName/schedule' => sub {
    template 'schedule' => {page_title => "日程", page_channel => "schedule"};;
};

get '/c/:conferenceName/address' => sub {
    template 'address' => {page_title => "地址", page_channel => "address"};
};

get '/c/:conferenceName/live' => sub {
    template 'live' => {page_title => "直播", page_channel => "live"};
};

get '/c/:conferenceName/sponsor' => sub {
    template 'sponsor' => {page_title => "赞助", page_channel => "sponsor"};
};

get '/c/:conferenceName/quit' => sub {
    my $user = session 'user';
    send_error("未登录", 401) unless $user;
    my $conferenceName = param 'conferenceName';
    my $conference = db->coll('conferences')->find_one({name => $conferenceName});
    send_error("没有这个会议", 404) unless $conference;

    db->coll("conference_members")->delete_one({user_id => $user->{_id}, conference_id => $conference->{_id}});
    db->coll("news")->insert_one({msg => $user->{nick} . " 取消报名了" . $conference->{title}, createAt => time });
    template 'success' => {page_title => "取消报名", page_channel => "join", msg => "您已取消参加该会议", redirect_url => '/c/'.$conferenceName . "/join"};
};

any ['get', 'post'] => '/c/:conferenceName/join' => sub {
    my $user = session 'user';
    send_error("未登录", 401) unless $user;
    my $conferenceName = param 'conferenceName';
    my $conference = db->coll('conferences')->find_one({name => $conferenceName});
    send_error("没有这个会议", 404) unless $conference;

    my $row = db->coll("conference_members")->find_one({user_id => $user->{_id}, conference_id => $conference->{_id}});
    if ($row) {
        return template("joined", {page_title => "报名", page_channel => 'join', row => $row, conferenceName => $conferenceName});
    }
    
    if (request->method() eq 'POST') {
        my $city = param 'city';
        my $size = param 'size';
        eval {
            check_required($city, "城市必须填写");
            check_required($size, "T恤尺寸必须选择");
            check_choice($size, [ 'XXXL', 'XXL', 'XL',  'L', 'M', 'S', 'XS', 'XXS', 'XXXS' ], "T恤尺寸不正确");
        };
        unless ($@) {
            db->coll("conference_members")->insert_one({'user_id' => $user->{_id}, conference_id => $conference->{_id}, city => $city, size => $size, createAt => time});
            db->coll("news")->insert_one({msg => $user->{nick} . " 报名了" . $conference->{title}, createAt => time });
            return template 'success' => { page_title => "报名成功", page_channel => "join", msg => '报名成功，请准时参加会议', redirect_url => '/c/' . $conferenceName };
        }
    }
    template 'join' => {page_title => "报名", page_channel => "join"};
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
