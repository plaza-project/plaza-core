%%% @doc
%%% Automate bot engine tests.
%%% @end

-module(automate_bot_engine_tests).
-include_lib("eunit/include/eunit.hrl").

%% Data structures
-include("../../automate_storage/src/records.hrl").
-include("../src/program_records.hrl").
-include("../src/instructions.hrl").
-include("../../automate_channel_engine/src/records.hrl").

%% Test data
-include("single_line_program.hrl").

-define(APPLICATION, automate_bot_engine).
-define(TEST_NODES, [node()]).
-define(TEST_SERVICE, automate_service_registry_test_service:get_uuid()).
-define(TEST_SERVICE_ACTION, test_action).

%%====================================================================
%% Test API
%%====================================================================

session_manager_test_() ->
    {setup
    , fun setup/0
    , fun stop/1
    , fun tests/1
    }.

%% @doc App infrastructure setup.
%% @end
setup() ->
    NodeName = node(),

    %% Use a custom node name to avoid overwriting the actual databases
    net_kernel:start([testing, shortnames]),

    {ok, Pid} = application:ensure_all_started(?APPLICATION),

    {NodeName}.

%% @doc App infrastructure teardown.
%% @end
stop({_NodeName}) ->
    %% application:stop(?APPLICATION),

    ok.


tests(_SetupResult) ->
    [ {"[Bot runner][Initialization] Single line program initialization", fun single_line_program_initialization/0}
    , {"[Bot runner][Signals] Wait for channel signal", fun wait_for_channel_signal/0}
    , {"[Bot runner][Resolution] Constant argument resolution", fun constant_argument_resolution/0}
    , {"[Bot runner][Triggers] Trigger thread with channel signal", fun trigger_thread_with_channel_signal/0}
    , {"[Bot runner][Threads] Run a thread a single tick", fun run_thread_single_tick/0}
    ].



remove_permissions(Program=#program_state{}) ->
    Program#program_state{ permissions=undefined }.

%%%% Bot runner
%% Initialization
single_line_program_initialization() ->
    Program  = ?SINGLE_LINE_PROGRAM,
    Expected = ?SINGLE_LINE_PROGRAM_INITIALIZATION,
    {ok, Obtained} = automate_bot_engine_program_decoder:initialize_program(?SINGLE_LINE_PROGRAM_ID, Program),

    ?assertMatch(Expected, remove_permissions(Obtained)).

%% Signals
wait_for_channel_signal() ->
    {ok, ChannelId} = automate_channel_engine:create_channel(),
    Program = #program_state{ triggers=[#program_trigger{ condition=#{ ?TYPE => ?WAIT_FOR_MONITOR
                                                                     , ?ARGUMENTS =>
                                                                           #{ ?MONITOR_ID => ChannelId
                                                                            , ?MONITOR_EXPECTED_VALUE => ?MONITOR_ANY_VALUE
                                                                            }
                                                                     }
                                                        }]},
    Expected = [?TRIGGERED_BY_MONITOR],

    ?assertMatch({ok, Expected},
                 automate_bot_engine_triggers:get_expected_signals(Program)).

%% Argument resolution
constant_argument_resolution() ->
    Value = example,
    ?assertMatch({ok, Value, _}, automate_bot_engine_variables:resolve_argument(#{ ?TYPE => ?VARIABLE_CONSTANT
                                                                                 , ?VALUE => Value
                                                                                 }, #program_thread{},
                                                                                undefined)).

%% Threads
trigger_thread_with_channel_signal() ->
    {ok, ChannelId} = automate_channel_engine:create_channel(),
    Program = #program_state{ triggers=[#program_trigger{
                                           condition=#{ ?TYPE => ?WAIT_FOR_MONITOR
                                                      , ?ARGUMENTS => #{ ?MONITOR_ID => ChannelId
                                                                       , ?MONITOR_EXPECTED_VALUE =>
                                                                             #{ ?TYPE => ?VARIABLE_CONSTANT
                                                                              , ?VALUE => example
                                                                              }
                                                                       }
                                                      }
                                          , subprogram=[#{ ?TYPE => example }]
                                          }]},

    {ok, [Thread]} = automate_bot_engine_triggers:get_triggered_threads(Program,
                                                                        { ?TRIGGERED_BY_MONITOR
                                                                        , { ChannelId,
                                                                            #{ ?CHANNEL_MESSAGE_CONTENT => example } }}),
    ?assertMatch(#program_thread{ position=[1], program=[#{ ?TYPE := example }] }, Thread).

run_thread_single_tick() ->
    {ok, ChannelId} = automate_channel_engine:create_channel(),
    WaitForMonitorInstruction = #{ ?TYPE => ?WAIT_FOR_MONITOR
                                 , ?ARGUMENTS => #{ ?MONITOR_ID => ChannelId
                                                  , ?MONITOR_EXPECTED_VALUE => #{ ?TYPE => ?VARIABLE_CONSTANT
                                                                                , ?VALUE => example
                                                                                }
                                                  }
                                 },

    %% Register test service
    {ok, ServiceId} = automate_service_registry:register_public(automate_service_registry_test_service),

    CallServiceInstruction = #{ ?TYPE => ?COMMAND_CALL_SERVICE
                              , ?ARGUMENTS => #{ ?SERVICE_ID => ServiceId
                                               , ?SERVICE_ACTION => ?TEST_SERVICE_ACTION
                                               , ?SERVICE_CALL_VALUES => [#{ ?TYPE => ?VARIABLE_CONSTANT
                                                                           , ?VALUE => answer
                                                                           }]
                                               }
                              },
    TriggerMonitorSignal = { ?TRIGGERED_BY_MONITOR
                           , { ChannelId, #{ ?CHANNEL_MESSAGE_CONTENT => example }}},

    ProgramId = create_anonymous_program(),

    Program = #program_state{ triggers=[#program_trigger{ condition=WaitForMonitorInstruction
                                                        , subprogram=[CallServiceInstruction]
                                                        }]
                            , program_id=ProgramId
                            },
    {ok, [Thread]} = automate_bot_engine_triggers:get_triggered_threads(Program, TriggerMonitorSignal),

    %% Unexpected signal (for the thread already started), does not run
    #program_thread{ position=[1], program=[CallServiceInstruction] } = Thread,
    {did_not_run, waiting} = automate_bot_engine_operations:run_thread(Thread, TriggerMonitorSignal, undefined),

    %% Expected signal, does run
    {ran_this_tick, NewThreadState, _} = automate_bot_engine_operations:run_thread(Thread, {?SIGNAL_PROGRAM_TICK, none}, undefined),
    ?assertMatch(#program_thread{position=[]}, NewThreadState).



%%====================================================================
%% Util functions
%%====================================================================
create_anonymous_program() ->
    {ok, ProgramId} = automate_storage:create_program(undefined, <<"Test program">>),
    ProgramId.
