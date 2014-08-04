-module(server).
-export([start/0, test/1]).

start() ->
	spawn(fun () -> server(4000) end).

server(Port) ->
	{ok, Socket} = gen_udp:open(Port, [binary, {active, false}]),
	io:format("Listening on ~p", [Port]),
	listen(Socket).

listen(Socket) ->
	inet:setops(Socket, [{active, once}]) % ?
	receive
		{udp, Socket, Host, Port, Bin} ->
			io:format("received ~p~n", [Bin]),
			% convert to http here
			listen(Socket)
	end.

test(Val) ->
	{ok, Socket} = gen_udp:open(0, [binary]),
	io:format("Testing ..."),
	ok = gen_udp:send(Socket, "localhost", 4000, Val),
	%Resp = receive end, % pas de receive car le serveur ne fait que transférer en HTTP
	gen_udp:close(Socket),
	Resp.