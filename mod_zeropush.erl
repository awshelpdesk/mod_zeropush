-module(mod_zeropush).
-author("mongooseim").
-behaviour(gen_mod).
-export([start/2, stop/1, send_notice/4]).

-define(PROCNAME, ?MODULE).

-include("mongoose.hrl").
-include("jlib.hrl").

%%-include("Z://MongooseIM/_build/prod/rel/mongooseim/lib/mongooseim-tech-rel-3.0.0-4-5-gbc241be/include/mongoose.hrl").
%%-include("Z://MongooseIM/_build/prod/rel/mongooseim/lib/mongooseim-tech-rel-3.0.0-4-5-gbc241be/include/jlib.hrl").

start(Host, _Opts) ->
  inets:start(),
  ssl:start(),
  ?INFO_MSG("Starting mod_zeropush", [] ),
  ejabberd_hooks:add(offline_message_hook, Host, ?MODULE, send_notice, 10),
  ok.

stop(Host) ->
  ejabberd_hooks:delete(offline_message_hook, Host, ?MODULE, send_notice, 10),
  ?INFO_MSG("Stopping mod_zeropush", [] ),
  ok.

send_notice(Acc, From, To, Packet) ->

  Type = xml:get_tag_attr_s(<<"type">>, Packet),
  Id = xml:get_tag_attr_s(<<"id">>, Packet),
  Body = xml:get_path_s(Packet, [{elem, <<"body">>}, cdata]),
  Token = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, auth_token, [] ),
  Sound = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, sound, [] ),
  PostUrl = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, post_url, [] ),
  ?INFO_MSG("Sending  push......", [] ),

  if (Type == <<"chat">>) and (Body /= <<"">>) ->
    Sep = "&",
    Post = [
      "alert=", url_encode(binary_to_list(Body)), Sep,
      "badge=", url_encode("+1"), Sep,
      "sound=", Sound, Sep,
      "channel=", To#jid.luser, Sep,
      "info[from]=", From#jid.luser, Sep,
      "auth_token=", Token],
    ?INFO_MSG("Sending post request to ~s with body \"~s\"", [PostUrl, Post]),
    httpc:request(post, {PostUrl, [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
    Acc;
    true ->
      ok
  end.

url_encode([H|T]) when is_list(H) ->
  [url_encode(H) | url_encode(T)];
url_encode([H|T]) ->
  if
    H >= $a, $z >= H ->
      [H|url_encode(T)];
    H >= $A, $Z >= H ->
      [H|url_encode(T)];
    H >= $0, $9 >= H ->
      [H|url_encode(T)];
    H == $_; H == $.; H == $-; H == $/; H == $: -> % FIXME: more..
      [H|url_encode(T)];
    true ->
      case integer_to_hex(H) of
        [X, Y] ->
          [$%, X, Y | url_encode(T)];
        [X] ->
          [$%, $0, X | url_encode(T)]
      end
  end;

url_encode([]) ->
  [].

integer_to_hex(I) ->
  case catch erlang:integer_to_list(I, 16) of
    {'EXIT', _} -> old_integer_to_hex(I);
    Int         -> Int
  end.

old_integer_to_hex(I) when I < 10 ->
  integer_to_list(I);
old_integer_to_hex(I) when I < 16 ->
  [I-10+$A];
old_integer_to_hex(I) when I >= 16 ->
  N = trunc(I/16),
  old_integer_to_hex(N) ++ old_integer_to_hex(I rem 16).
