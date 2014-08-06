-module(server).
-export([start/0, test/1]).
-define(PORT, 4000).
-define(URL, "http://google.fr").

start() ->
    spawn(fun() -> server(?PORT) end).

server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary, {active, false}]),
    io:format("server opened socket:~p~n",[Socket]),
    listen(Socket).

listen(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {udp, Socket, _Host, _Port, Bin} ->
            io:format("server received:~p~n",[Bin]),
            ok = inets:start(), % todo start that more than once ?
            % just send the body as JSON to the URL
            {ok, _} = httpc:request(post, {?URL, [], "application/json", Bin}, [], []),
            listen(Socket)
    end.

% Test it out
test(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("test socket on port ~p: ~p~n",[?PORT, Socket]),
    ok = gen_udp:send(Socket, "localhost", ?PORT, N),
    gen_udp:close(Socket),
    ok.