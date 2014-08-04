-module(server).
-export([start/0, test/1]).

start() ->
    spawn(fun() -> server(4000) end).

server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary, {active, false}]),
    io:format("server opened socket:~p~n",[Socket]),
    listen(Socket).

listen(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {udp, Socket, _Host, _Port, Bin} ->
            io:format("server received:~p~n",[Bin]),
            %gen_udp:send(Socket, Host, Port, Bin),
            listen(Socket)
    end.

% Client code
test(N) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("test socket=~p~n",[Socket]),
    ok = gen_udp:send(Socket, "localhost", 4000, N),
    gen_udp:close(Socket),
    ok.