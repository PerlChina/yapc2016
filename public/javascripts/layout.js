function api_get(url, data, success_cb, failed_cb) {
    api_request("GET", url, data, success_cb, failed_cb);
}

function api_post(url, data, success_cb, failed_cb) {
    api_request("POST", url, data, success_cb, failed_cb);
}

function api_request(method, url, data, success_cb, failed_cb) {
    $.ajax({
        url: url,
        data: data,
        method: method,
        dataType: "JSON",
        success: function(o, status, xhr) {
            if (o.success) {
                if (success_cb) {
                    success_cb(o);
                }
            } else {
                if (failed_cb) {
                    failed_cb(o.error);
                }
            }
        },
        error: function() {
            if (failed_cb) {
                failed_cb("网络不给力啊");
            }
        },
    });
}

(function() {
    var registerModal = $("#registerModal");
    var registerForm = $("#registerForm");
    var registerNick = $("#registerNick");
    var registerPass = $("#registerPass");
    var registerErrorDiv = $("#registerErrorDiv");
    
    function registerFormSubmit() {
        var nick = registerNick.val();
        var pass = registerPass.val();
        $("input,button", registerForm).attr("disabled", "disabled");
        registerErrorDiv.hide();
        api_post("/api/user/register", {nick: nick, pass: pass}, function(o) {
            registerModal.modal('hide');
            $("input,button",registerForm).removeAttr("disabled");
            $("#navUserNick").text(o.nick);
            $(".js-login-links").hide();
            $(".js-user-links").show();
            alert("注册成功");
        }, function(error) {
            $("span", registerErrorDiv).text(error);
            registerErrorDiv.show();
            $("input,button",registerForm).removeAttr("disabled");
        });
        return false;
    }

    function getUserInfo() {
        api_get("/api/account/info", {}, function(o) {
            $("#navUserNick").text(o.nick);
            $(".js-login-links").hide();
            $(".js-user-links").show();
        }, function() {

        });
    }

    function logout() {
        if (window.confirm("确定要退出登录吗？")) {
            api_get("/api/user/logout", {}, function(o) {
                $(".js-user-links").hide();
                $(".js-login-links").show();
            });
        }
    }

    // events
    registerForm.submit(registerFormSubmit);
    $("#navLogout").click(logout);
    
    // init
    getUserInfo();
})();
