%%%----------------------------------------------------------------------
%%% File    : edit_input.erl
%%% Author  : Luke Gorrie <luke@bluetail.com>
%%% Purpose : Keyboard input server
%%% Created : 22 Jan 2001 by Luke Gorrie <luke@bluetail.com>
%%%----------------------------------------------------------------------

-module(edit_input).
-author('luke@bluetail.com').
-include_lib("pie/include/edit.hrl").
-export([start_link/1, loop/1]).

%% Receiver will be sent {key_input, Char} each time a key is pressed.
start_link(Receiver) ->
    Pid = spawn_link(edit_input, loop, [Receiver]),
    register(?MODULE, Pid),
    Pid.

loop(Receiver) ->
    Ch = case ?EDIT_TERMINAL:read() of
        $\n -> $\r;
        145 -> panic(); % C-M-q is reserved for panic 
        219 -> case ?EDIT_TERMINAL:read() of
                    53 -> [219,53,?EDIT_TERMINAL:read()];
                    54 -> [219,54,?EDIT_TERMINAL:read()];
                    X -> Receiver ! {key_input, 219}, X end;
        207 -> case ?EDIT_TERMINAL:read() of
                    70 -> [207,70];
                    72 -> [207,72];
                    X -> Receiver ! {key_input, 207}, X end;
        XXX -> XXX end,
    error_logger:info_msg("Input Char: ~p",[Ch]),
    Receiver ! {key_input, Ch},
    edit_input:loop(Receiver).

panic() -> halt().
