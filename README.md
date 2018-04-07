# mod_zeropush

MongooseIM module used to POST a chat message to an API, if the user is offline.
Add following line in ejabberd.cfg,
{mod_zeropush, [ {sound, "default"}, {auth_token, "auth-token"}, {post_url, "https://localhost/api"} ]},
