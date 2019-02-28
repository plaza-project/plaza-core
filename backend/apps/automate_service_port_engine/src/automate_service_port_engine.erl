%%%-------------------------------------------------------------------
%% @doc automate_service_port_engine APP API
%% @end
%%%-------------------------------------------------------------------

%% @doc automate_service_port_engine APP API
-module(automate_service_port_engine).

%% Application callbacks
-export([ create_service_port/2
        , register_service_port/1
        , from_service_port/3
        , call_service_port/4
        , get_how_to_enable/2
        , send_registration_data/3
        , send_oauth_return/2

        , list_custom_blocks/1
        , internal_user_id_to_service_port_user_id/2
        , get_user_service_ports/1
        , delete_bridge/2
        , callback_bridge/3
        ]).

-include("records.hrl").

-define(BACKEND, automate_service_port_engine_mnesia_backend).
-define(ROUTER, automate_service_port_engine_router).

%%====================================================================
%% API
%%====================================================================

-spec create_service_port(binary(), boolean()) -> {ok, binary()} | {error, term(), string()}.
create_service_port(UserId, ServicePortName) ->
    ?BACKEND:create_service_port(UserId, ServicePortName).

-spec register_service_port(binary()) -> ok.
register_service_port(ServicePortId) ->
    ?ROUTER:connect_bridge(ServicePortId).

-spec call_service_port(binary(), binary(), binary(), binary()) -> {ok, any()}.
call_service_port(ServicePortId, FunctionName, Arguments, UserId) ->
    ?ROUTER:call_bridge(ServicePortId, #{ <<"type">> => <<"FUNCTION_CALL">>
                                        , <<"user_id">> => UserId
                                        , <<"value">> => #{ <<"function_name">> => FunctionName
                                                          , <<"arguments">> => Arguments
                                                          }
                                        }).

-spec get_how_to_enable(binary(), binary()) -> {ok, any()}.
get_how_to_enable(ServicePortId, UserId) ->
    ?ROUTER:call_bridge(ServicePortId, #{ <<"type">> => <<"GET_HOW_TO_SERVICE_REGISTRATION">>
                                        , <<"user_id">> => UserId
                                        , <<"value">> => #{}
                                        }).

-spec send_registration_data(binary(), map(), binary()) -> {ok, map()}.
send_registration_data(ServicePortId, Data, UserId) ->
    ?ROUTER:call_bridge(ServicePortId, #{ <<"type">> => <<"REGISTRATION">>
                                        , <<"user_id">> => UserId
                                        , <<"value">> => #{ <<"form">> => Data }
                                        }).

-spec send_oauth_return(binary(), binary()) -> {ok, map()}.
send_oauth_return(Qs, ServicePortId) ->
    ?ROUTER:call_bridge(ServicePortId, #{ <<"type">> => <<"OAUTH_RETURN">>
                                        , <<"value">> => #{ <<"query_string">> => Qs }
                                        }).


-spec from_service_port(binary(), binary(), binary()) -> ok.
from_service_port(ServicePortId, UserId, Msg) ->
    ChannelId = ServicePortId,
    Unpacked = jiffy:decode(Msg, [return_maps]),
    case Unpacked of
        #{ <<"message_id">> := MessageId } ->
            io:fwrite("[~p] Answer: ~p~n", [MessageId, Unpacked]),
            ?ROUTER:answer_message(MessageId, Unpacked);

        #{ <<"type">> := <<"configuration">>
         , <<"value">> := Configuration
         } ->
            set_service_port_configuration(ServicePortId, Configuration, UserId)
    end.

-spec list_custom_blocks(binary()) -> {ok, [_]}.
list_custom_blocks(UserId) ->
    ?BACKEND:list_custom_blocks(UserId).

-spec internal_user_id_to_service_port_user_id(binary(), binary()) -> {ok, binary()}.
internal_user_id_to_service_port_user_id(UserId, ServicePortId) ->
    ?BACKEND:internal_user_id_to_service_port_user_id(UserId, ServicePortId).


-spec get_user_service_ports(binary()) -> {ok, [#service_port_entry_extra{}]}.
get_user_service_ports(UserId) ->
    {ok, Bridges} = ?BACKEND:get_user_service_ports(UserId),
    {ok, lists:map(fun add_service_port_extra/1, Bridges)}.

-spec delete_bridge(binary(), binary()) -> ok | {error, binary()}.
delete_bridge(UserId, BridgeId) ->
    ok = case ?BACKEND:get_bridge_service(UserId, BridgeId) of
        {ok, undefined} ->
            ok;
        {ok, ServiceId} ->
            automate_service_registry:delete_service(UserId, ServiceId)
    end,
    ?BACKEND:delete_bridge(UserId, BridgeId).


-spec callback_bridge(binary(), binary(), binary()) -> {ok, [map()]} | {error, binary()}.
callback_bridge(UserId, BridgeId, Callback) ->
    ?ROUTER:call_bridge(BridgeId, #{ <<"type">> => <<"CALLBACK">>
                                   , <<"user_id">> => UserId
                                   , <<"value">> => #{ <<"callback">> => Callback
                                                     }
                                   }).

%%====================================================================
%% Internal functions
%%====================================================================

-spec add_service_port_extra(#service_port_entry{}) -> #service_port_entry_extra{}.
add_service_port_extra(#service_port_entry{ id=Id
                                          , name=Name
                                          , owner=Owner
                                          , service_id=ServiceId
                                          }) ->
    {ok, IsConnected} = ?ROUTER:is_bridge_connected(Id),
    #service_port_entry_extra{ id=Id
                             , name=Name
                             , owner=Owner
                             , service_id=ServiceId
                             , is_connected=IsConnected
                             }.

set_service_port_configuration(ServicePortId, Configuration, UserId) ->
    SPConfiguration = parse_configuration_map(ServicePortId, Configuration),
    ?BACKEND:set_service_port_configuration(ServicePortId, SPConfiguration, UserId),
    ok.

parse_configuration_map(ServicePortId,
                        #{ <<"blocks">> := Blocks
                         , <<"is_public">> := IsPublic
                         , <<"service_name">> := ServiceName
                         }) ->
    #service_port_configuration{ id=ServicePortId
                               , is_public=IsPublic
                               , service_id=undefined
                               , service_name=ServiceName
                               , blocks=lists:map(fun(B) -> parse_block(B) end, Blocks)
                               }.

parse_block(#{ <<"arguments">> := Arguments
             , <<"function_name">> := FunctionName
             , <<"message">> := Message
             , <<"id">> := BlockId
             , <<"block_type">> := BlockType
             , <<"block_result_type">> := BlockResultType
             }) ->
    #service_port_block{ block_id=BlockId
                       , function_name=FunctionName
                       , message=Message
                       , arguments=lists:map(fun parse_argument/1, Arguments)
                       , block_type=BlockType
                       , block_result_type=BlockResultType
                       }.

parse_argument(#{ <<"default">> := DefaultValue
                , <<"type">> := Type
                }) ->
    #service_port_block_static_argument{ default=DefaultValue
                                , type=Type
                                };

parse_argument(#{ <<"type">> := Type
                , <<"values">> := #{ <<"callback">> := Callback
                                   }
                }) ->
    #service_port_block_dynamic_argument{ callback=Callback
                                        , type=Type
                                        }.

generate_id() ->
    binary:list_to_bin(uuid:to_string(uuid:uuid4())).