%%% @doc
%%% Auto-mate REST API server.
%%% @end

-module(automate_rest_api_server).

%% API
-export([start_link/0]).

%%====================================================================
%% API functions
%%====================================================================

-spec start_link() -> {ok, pid()}.
start_link() ->
    Dispatch = cowboy_router:compile(
                 [{'_', [ %% Metrics
                          {"/metrics", automate_rest_api_metrics, []}

                          %% API
                        , {"/api/v0/sessions/register", automate_rest_api_sessions_register, []}
                        , {"/api/v0/sessions/check", automate_rest_api_sessions_check, []}
                        , {"/api/v0/sessions/login", automate_rest_api_sessions_login, []}

                        , {"/api/v0/ping", automate_rest_api_ping, []}

                        , {"/api/v0/users", automate_rest_api_users_root, []}
                        , {"/api/v0/users/:user_id", automate_rest_api_users_specific, []}

                        , {"/api/v0/users/:user_id/chats", automate_rest_api_chats_root, []}
                        , {"/api/v0/users/:user_id/programs", automate_rest_api_programs_root, []}
                        , {"/api/v0/users/:user_id/programs/:program_id", automate_rest_api_programs_specific, []}

                        , {"/api/v0/users/:user_id/services", automate_rest_api_services_root, []}
                        , {"/api/v0/users/:user_id/services/id/:service_id/how-to-enable", automate_rest_api_services_how_to_enable, []}
                        , {"/api/v0/users/:user_id/monitors", automate_rest_api_monitors_root, []}
                        ]}
                 ]),

    Port = get_port(),
    Start = cowboy:start_clear(http, [{port, Port}],
                                   #{
                                      env => #{dispatch => Dispatch}
                                    }
                                  ),

    case Start of
        {ok, Pid} ->
            {ok,
             spawn(fun () -> handler(Pid) end)};

        %% For debug purposes
        {error, eaddrinuse} ->
            {ok, spawn(fun() -> handler(none) end)}
    end.



%%====================================================================
%% Internal functions
%%====================================================================

%%--------------------------------------------------------------------
%% @doc Wrap cowboy HTTP server to be supervisor-friendly.
%%      Just wait for an exit call, and stop the cowboy HTTP server.
%% @end
handler(none) ->
    %% For debug purposes
    try timer:sleep(infinity)
    catch exit:_Reason ->
            ok
    end;

handler(Pid) ->
    %% Wait for an exit call
    try timer:sleep(infinity)
    catch exit:_Reason ->
            %% Stop the server
            cowboy:stop_listener(Pid)
    end.


get_port() ->
    {ok, Port} = application:get_env(automate_rest_api, port),
    Port.
