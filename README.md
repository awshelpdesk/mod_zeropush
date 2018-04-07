# mod_zeropush

1. MongooseIM module used to POST a chat message to an API, if the user is offline.
2. Add following line in ejabberd.cfg,
 {mod_zeropush, [ {sound, "default"}, {auth_token, "auth-token"}, {post_url, "https://localhost/api"} ]}

- MongooseIM 2.1.1 is used with erlang/OTP v 20.
- MongooseIM latest source can be fetch from https://github.com/esl/MongooseIM.git
- Erlang can be fetch from http://www.erlang.org/downloads
- IDE enviroments used are Intellij Idea (with erlang plugin) and VIM (https://github.com/search?utf8=%E2%9C%93&q=vim-erlang&type=)
