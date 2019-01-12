-module(automate_bot_engine_program_decoder).

%%%% API
%% Exposed functions
-export([ initialize_program/2
        , update_program/2
        ]).

-include("../../automate_storage/src/records.hrl").
-include("program_records.hrl").

%%%===================================================================
%%% API
%%%===================================================================
-spec initialize_program(binary(), #user_program_entry{}) -> {ok, #program_state{}}.
initialize_program(ProgramId,
                   #user_program_entry
                   { user_id=OwnerUserId
                   , program_parsed=Parsed}) ->

    {ok, #{ <<"variables">> := Variables
          , <<"blocks">> := Blocks
          }} = automate_program_linker:link_program(Parsed, OwnerUserId),
    { ok
    , #program_state{ program_id=ProgramId
                    , variables=Variables
                    , threads=[]
                    , permissions=#program_permissions{ owner_user_id=OwnerUserId }
                    , triggers=get_triggers(Blocks)
                    }}.

-spec update_program(#program_state{}, #user_program_entry{}) -> {ok, #program_state{}}.
update_program(State,
               #user_program_entry
               { user_id=OwnerUserId
               , program_parsed=Parsed}) ->
    {ok, #{ <<"variables">> := Variables
          , <<"blocks">> := Blocks
          }} = automate_program_linker:link_program(Parsed, OwnerUserId),
    { ok
    , State#program_state{ variables=Variables %% TODO port old variable values
                         , triggers=get_triggers(Blocks)
                         }}.


%%%===================================================================
%%% Internal functions
%%%===================================================================
-spec get_triggers([map()]) -> [#program_trigger{}].
get_triggers(Blocks) ->
    [get_trigger(Block) || Block <- Blocks].

-spec get_trigger([any() | any()]) -> #program_trigger{}.
get_trigger([Trigger | Program]) ->
    #program_trigger{ condition=Trigger
                    , subprogram=Program
                    }.
