%%%-------------------------------------------------------------------
%% @doc automate_services_telegram APP API
%% @end
%%%-------------------------------------------------------------------

-module(automate_services_telegram_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    case automate_services_telegram:is_enabled() of
        true ->
            {ok, _} = automate_service_registry:register_public(automate_services_telegram),
            ok = automate_services_telegram_chat_registry:start_link(),
            automate_services_telegram_sup:start_link();
        false ->
            {ok, self()}
    end.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
