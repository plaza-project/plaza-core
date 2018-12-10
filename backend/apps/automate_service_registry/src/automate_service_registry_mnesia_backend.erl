%%%-------------------------------------------------------------------
%% @doc automate_channel_engine_mnesia_backend public API
%% @end
%%%-------------------------------------------------------------------

-module(automate_service_registry_mnesia_backend).

-export([ start_link/0
        , register/3
        , list_all_public/0
        ]).

-define(SERVICE_REGISTRY_TABLE, automate_service_registry_services_table).
-define(SELECTOR_VALUES, '_' | '$1' | '$2').

-record(services_table_entry, { id :: binary()          | ?SELECTOR_VALUES
                              , public :: boolean()     | ?SELECTOR_VALUES
                              , name :: binary()        | ?SELECTOR_VALUES
                              , description :: binary() | ?SELECTOR_VALUES
                              , module :: module()      | ?SELECTOR_VALUES
                              }).

-type service_info_map() :: #{ binary() := #{ name := binary()
                                            , description := binary()
                                            , module := module()
                                            } }.

%%====================================================================
%% API
%%====================================================================
start_link() ->
    Nodes = [node()],

    %% Live channels table
    ok = case mnesia:create_table(?SERVICE_REGISTRY_TABLE,
                                  [ { attributes, record_info(fields, services_table_entry)}
                                  , { disc_copies, Nodes }
                                  , { record_name, services_table_entry }
                                  , { type, set }
                                  ]) of
             { atomic, ok } ->
                 ok;
             { aborted, { already_exists, _ }} ->
                 ok
         end,
    ignore.

-spec register(binary(), boolean(), #{ name := binary(), description := binary(), module := module()}) -> ok | {error, term(), string()}.
register(ServiceUuid, Public, #{ name := Name, description := Description, module := Module }) ->
    Entry = #services_table_entry{ id=ServiceUuid
                                 , public=Public
                                 , name=Name
                                 , description=Description
                                 , module=Module
                                 },

    Transaction = fun() ->
                          ok = mnesia:write(?SERVICE_REGISTRY_TABLE, Entry, write)
                  end,

    case mnesia:transaction(Transaction) of
        {atomic, Result} ->
            Result;
        {aborted, Reason} ->
            {error, Reason, mnesia:error_description(Reason)}
    end.

-spec list_all_public() -> {ok, [service_info_map()]} | {error, term(), string()}.
list_all_public() ->
    MatchHead = #services_table_entry{ id='_'
                                     , public='$1'
                                     , name='_'
                                     , description='_'
                                     , module='_'
                                     },
    %% Check that the public setting is the one selected
    Guards = [{'==', '$1', true}],
    ResultColumn = '$_',
    Matcher = [{MatchHead, Guards, [ResultColumn]}],

    Transaction = fun() ->
                          mnesia:select(?SERVICE_REGISTRY_TABLE, Matcher)
                  end,

    case mnesia:transaction(Transaction) of
        {atomic, Result} ->
            {ok, convert_to_map(Result)};
        {aborted, Reason} ->
            {error, Reason, mnesia:error_description(Reason)}
    end.

%%====================================================================
%% Internal functions
%%====================================================================

-spec convert_to_map([#services_table_entry{}]) -> service_info_map().
convert_to_map(TableEntries) ->
    convert_to_map(TableEntries, #{}).

-spec convert_to_map([#services_table_entry{}], service_info_map()) ->
    service_info_map().
convert_to_map([], Acc) ->
    Acc;

convert_to_map([#services_table_entry{ id=Id
                                     , name=Name
                                     , description=Description
                                     , module=Module}
                | T], Acc) ->
    convert_to_map(
      T,
      maps:put(Id,
               #{ name => Name, description => Description, module => Module },
               Acc)).
