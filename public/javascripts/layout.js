function api_post(url, data, success_cb, failed_cb) {
    $.ajax({
        url: url,
        data: data,
        method: "POST",
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
        api_post("/api/user/register", {nick: nick, pass: pass}, function() {
            registerModal.modal('hide');
        }, function(error) {
            $("span", registerErrorDiv).text(error);
            registerErrorDiv.show();
            $("input,button",registerForm).removeAttr("disabled");
        });
    }
    
    registerForm.submit(registerFormSubmit);
})();
