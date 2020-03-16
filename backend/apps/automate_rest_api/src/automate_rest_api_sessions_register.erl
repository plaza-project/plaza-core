%%% @doc
%%% REST endpoint to manage knowledge collections.
%%% @end

-module(automate_rest_api_sessions_register).
-export([init/2]).
-export([ allowed_methods/2
        , content_types_accepted/2
        , options/2
        ]).
-export([resource_exists/2]).

-export([accept_json_modify_collection/2]).

-define(UTILS, automate_rest_api_utils).
-include("./records.hrl").

-record(registration_seq, { rest_session,
                            registration_data
                          }).

-spec init(_,_) -> {'cowboy_rest',_,_}.
init(Req, _Opts) ->
    io:format("Added CORS: ok~n", []),
    Res = automate_rest_api_cors:set_headers(Req),
    {cowboy_rest, Res
    , #registration_seq{ rest_session=undefined
                       , registration_data=undefined}}.

resource_exists(Req, State) ->
    {false, Req, State}.

%% -spec is_authorized(cowboy_req:req(),_) -> {'true' | {'false', binary()}, cowboy_req:req(),_}.
%% is_authorized(Req, State) ->
%%     rest_is_authorized:is_authorized(Req, State).

%% CORS
options(Req, State) ->
    {ok, Req, State}.

-spec allowed_methods(cowboy_req:req(),_) -> {[binary()], cowboy_req:req(),_}.
allowed_methods(Req, State) ->
    io:fwrite("Asking for methods~n", []),
    {[<<"POST">>, <<"GET">>, <<"OPTIONS">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, accept_json_modify_collection}],
     Req, State}.

%%%% POST
                                                %
-spec accept_json_modify_collection(cowboy_req:req(),#registration_seq{})
                                   -> {'false' | {'true', binary()},cowboy_req:req(),#registration_seq{}}.
accept_json_modify_collection(Req, Session) ->
    case cowboy_req:has_body(Req) of
        true ->
            {ok, Body, Req2} = ?UTILS:read_body(Req),
            Parsed = [jiffy:decode(Body, [return_maps])],
            case to_register_data(Parsed) of
                { ok, RegistrationData } ->
                    case automate_rest_api_backend:register_user(RegistrationData) of
                        { ok, NextStatus } ->

                            Output = case NextStatus of
                                         continue ->
                                             jiffy:encode(#{ success => true, ready => true });
                                         wait_for_mail_verification ->
                                             jiffy:encode(#{ success => true, ready => false })
                                     end,
                            Res1 = cowboy_req:set_resp_body(Output, Req2),
                            Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
                            Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
                            { true, Res3, Session#registration_seq{
                                            registration_data=RegistrationData} };
                        {error, Reason} ->
                            io:format("Error registering: ~p~n", [Reason]),
                            { false, Req2, Session}
                    end;
                { error, _Reason } ->
                    { false, Req2, Session }
            end;
        false ->
            {false, Req, Session }
    end.

to_register_data([#{ <<"email">> := Email
                   , <<"password">> := Password
                   , <<"username">> := Username
                   }]) ->
    { ok, #registration_rec{ password=Password
                           , username=Username
                           , email=Email
                           } };

to_register_data(X) ->
    io:format("Found on register: ~p~n", [X]),
    { error, "Data structures not matching" }.
