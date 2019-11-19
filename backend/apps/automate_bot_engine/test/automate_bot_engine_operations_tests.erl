
%%% Automate bot engine operation tests.
%%% @end

-module(automate_bot_engine_operations_tests).
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
-define(TEST_MONITOR, <<"__test_monitor__">>).
-define(TEST_SERVICE, automate_service_registry_test_service:get_uuid()).
-define(TEST_SERVICE_ACTION, test_action).
-define(EMPTY_THREAD, #program_thread{ position = [1]
                                     , program=[undefined]
                                     , global_memory=#{}
                                     , instruction_memory=#{}
                                     , program_id=undefined
                                     }).

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

    %% %% Use a custom node name to avoid overwriting the actual databases
    %% net_kernel:start([testing, shortnames]),

    %% {ok, Pid} = application:ensure_all_started(?APPLICATION),

    {NodeName}.

%% @doc App infrastructure teardown.
%% @end
stop({_NodeName}) ->
    %% application:stop(?APPLICATION),

    ok.


tests(_SetupResult) ->
    %%# Operations
    %% Join
    [ {"[Bot operation][Join] Join two str",        fun join_str_and_str/0}
    , {"[Bot operation][Join] Join str to int",     fun join_str_to_int/0}
    , {"[Bot operation][Join] Join str to float",   fun join_str_to_float/0}
    , {"[Bot operation][Join] Join int to int",     fun join_int_to_int/0}
    , {"[Bot operation][Join] Join int to float",   fun join_int_to_float/0}
    , {"[Bot operation][Join] Join float to float", fun join_float_to_float/0}

      %% Add
    , {"[Bot operation][Add] Add two str",        fun add_str_and_str/0}
    , {"[Bot operation][Add] Add str to int",     fun add_str_and_int/0}
    , {"[Bot operation][Add] Add str to float",   fun add_str_and_float/0}
    , {"[Bot operation][Add] Add int to int",     fun add_int_and_int/0}
    , {"[Bot operation][Add] Add int to float",   fun add_int_and_float/0}
    , {"[Bot operation][Add] Add float to float", fun add_float_and_float/0}

      %% Subtract
    , {"[Bot operation][Sub] Subtract two str",          fun sub_str_and_str/0}
    , {"[Bot operation][Sub] Subtract str from int",     fun sub_str_and_int/0}
    , {"[Bot operation][Sub] Subtract str from float",   fun sub_str_and_float/0}
    , {"[Bot operation][Sub] Subtract int from int",     fun sub_int_and_int/0}
    , {"[Bot operation][Sub] Subtract int from float",   fun sub_int_and_float/0}
    , {"[Bot operation][Sub] Subtract float from float", fun sub_float_and_float/0}

      %% Multiply
    , {"[Bot operation][Multiply] Multiply two str",         fun mult_str_and_str/0}
    , {"[Bot operation][Multiply] Multiply str and int",     fun mult_str_and_int/0}
    , {"[Bot operation][Multiply] Multiply str and float",   fun mult_str_and_float/0}
    , {"[Bot operation][Multiply] Multiply int and int",     fun mult_int_and_int/0}
    , {"[Bot operation][Multiply] Multiply int and float",   fun mult_int_and_float/0}
    , {"[Bot operation][Multiply] Multiply float and float", fun mult_float_and_float/0}

      %% Divide
    , {"[Bot operation][Divide] Divide two str",         fun divide_str_and_str/0}
    , {"[Bot operation][Divide] Divide str and int",     fun divide_str_and_int/0}
    , {"[Bot operation][Divide] Divide str and float",   fun divide_str_and_float/0}
    , {"[Bot operation][Divide] Divide int and int",     fun divide_int_and_int/0}
    , {"[Bot operation][Divide] Divide int and float",   fun divide_int_and_float/0}
    , {"[Bot operation][Divide] Divide float and float", fun divide_float_and_float/0}

      %%# Comparisons
      %% Less than
    , {"[Bot operation][Equals] Less than string and string (true)",  fun lt_string_and_string_true/0}
    , {"[Bot operation][Equals] Less than string and string (false)", fun lt_string_and_string_false/0}
    , {"[Bot operation][Equals] Less than string and int (true)",     fun lt_string_and_int_true/0}
    , {"[Bot operation][Equals] Less than string and int (false)",    fun lt_string_and_int_false/0}
    , {"[Bot operation][Equals] Less than string and float (true)",   fun lt_string_and_float_true/0}
    , {"[Bot operation][Equals] Less than string and float (false)",  fun lt_string_and_float_false/0}
    , {"[Bot operation][Equals] Less than int and int (true)",        fun lt_int_and_int_true/0}
    , {"[Bot operation][Equals] Less than int and int (false)",       fun lt_int_and_int_false/0}
    , {"[Bot operation][Equals] Less than int and float (true)",      fun lt_int_and_float_true/0}
    , {"[Bot operation][Equals] Less than int and float (false)",     fun lt_int_and_float_false/0}
    , {"[Bot operation][Equals] Less than float and float (true)",    fun lt_float_and_float_true/0}
    , {"[Bot operation][Equals] Less than float and float (false)",   fun lt_float_and_float_false/0}

      %% Greater than
    , {"[Bot operation][Equals] Greater than string and string (true)",  fun gt_string_and_string_true/0}
    , {"[Bot operation][Equals] Greater than string and string (false)", fun gt_string_and_string_false/0}
    , {"[Bot operation][Equals] Greater than string and int (true)",     fun gt_string_and_int_true/0}
    , {"[Bot operation][Equals] Greater than string and int (false)",    fun gt_string_and_int_false/0}
    , {"[Bot operation][Equals] Greater than string and float (true)",   fun gt_string_and_float_true/0}
    , {"[Bot operation][Equals] Greater than string and float (false)",  fun gt_string_and_float_false/0}
    , {"[Bot operation][Equals] Greater than int and int (true)",        fun gt_int_and_int_true/0}
    , {"[Bot operation][Equals] Greater than int and int (false)",       fun gt_int_and_int_false/0}
    , {"[Bot operation][Equals] Greater than int and float (true)",      fun gt_int_and_float_true/0}
    , {"[Bot operation][Equals] Greater than int and float (false)",     fun gt_int_and_float_false/0}
    , {"[Bot operation][Equals] Greater than float and float (true)",    fun gt_float_and_float_true/0}
    , {"[Bot operation][Equals] Greater than float and float (false)",   fun gt_float_and_float_false/0}

      %% Equal to
    , {"[Bot operation][Equals] Equal string and string (true)",  fun eq_string_and_string_true/0}
    , {"[Bot operation][Equals] Equal string and string (false)", fun eq_string_and_string_false/0}
    , {"[Bot operation][Equals] Equal string and int (true)",     fun eq_string_and_int_true/0}
    , {"[Bot operation][Equals] Equal string and int (false)",    fun eq_string_and_int_false/0}
    , {"[Bot operation][Equals] Equal string and float (true)",   fun eq_string_and_float_true/0}
    , {"[Bot operation][Equals] Equal string and float (false)",  fun eq_string_and_float_false/0}
    , {"[Bot operation][Equals] Equal int and int (true)",        fun eq_int_and_int_true/0}
    , {"[Bot operation][Equals] Equal int and int (false)",       fun eq_int_and_int_false/0}
    , {"[Bot operation][Equals] Equal int and float (true)",      fun eq_int_and_float_true/0}
    , {"[Bot operation][Equals] Equal int and float (false)",     fun eq_int_and_float_false/0}
    , {"[Bot operation][Equals] Equal float and float (true)",    fun eq_float_and_float_true/0}
    , {"[Bot operation][Equals] Equal float and float (false)",   fun eq_float_and_float_false/0}
    ].

%%%% Operations
%%% Join
join_str_and_str()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"22">>}, R).

join_str_to_int()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"22">>}, R).

join_str_to_float()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"22.2">>}, R).

join_int_to_int()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"22">>}, R).

join_int_to_float()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"22.2">>}, R).

join_float_to_float()->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_JOIN
                                                   , ?ARGUMENTS => [ constant_val(2.2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, <<"2.22.2">>}, R).


%%% Add
add_str_and_str() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

add_str_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

add_str_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.2}, R).

add_int_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

add_int_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.2}, R).

add_float_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_ADD
                                                   , ?ARGUMENTS => [ constant_val(2.2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.4}, R).

%%% Substract
sub_str_and_str() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 0}, R).

sub_str_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 0}, R).

sub_str_and_float() ->
    {ok, R} = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assert(approx(R, -0.2)).

sub_int_and_int() ->
    {ok, R} = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assert(approx(R, -0.2)).

sub_int_and_float() ->
    {ok, R} = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assert(approx(R, -0.2)).

sub_float_and_float() ->
    {ok, R} = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_SUBTRACT
                                                   , ?ARGUMENTS => [ constant_val(2.1)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assert(approx(R, -0.1)).

%%% Multiply
mult_str_and_str() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

mult_str_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

mult_str_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.4}, R).

mult_int_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4}, R).

mult_int_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(2.2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.4}, R).

mult_float_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_MULTIPLY
                                                   , ?ARGUMENTS => [ constant_val(1.5)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 2.25}, R).

%%% Divide
divide_str_and_str() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(<<"10">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 5.0}, R).

divide_str_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(<<"10">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 5.0}, R).

divide_str_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(<<"10">>)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.0}, R).

divide_int_and_int() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(10)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 5.0}, R).

divide_int_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(10)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 4.0}, R).

divide_float_and_float() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_DIVIDE
                                                   , ?ARGUMENTS => [ constant_val(10.5)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, 5.25}, R).

%%%% Comparisons
%%% Less than
lt_string_and_string_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_string_and_string_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(<<"0">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

lt_string_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"0">>)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_string_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

lt_string_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_string_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1.5">>)
                                                                   , constant_val(1.1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

lt_int_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_int_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(0)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

lt_int_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(0)
                                                                   , constant_val(0.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_int_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

lt_float_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(1.5)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

lt_float_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_LESS_THAN
                                                   , ?ARGUMENTS => [ constant_val(1.5)
                                                                   , constant_val(0.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

%%% Greater than
gt_string_and_string_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(<<"1">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_string_and_string_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"0">>)
                                                                   , constant_val(<<"1">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

gt_string_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(0)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_string_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

gt_string_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"2">>)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_string_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(<<"1.1">>)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

gt_int_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(2)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_int_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(0)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

gt_int_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(0.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_int_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

gt_float_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(2.5)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

gt_float_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_GREATER_THAN
                                                   , ?ARGUMENTS => [ constant_val(0.5)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

%%% Equal to
eq_string_and_string_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(<<"1">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_string_and_string_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(<<"2">>)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

eq_string_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_string_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1">>)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

eq_string_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1.5">>)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_string_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(<<"1.1">>)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

eq_int_and_int_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(1)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_int_and_int_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(2)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

eq_int_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(1.0)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_int_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

eq_float_and_float_true() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1.5)
                                                                   , constant_val(1.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, true}, R).

eq_float_and_float_false() ->
    R = automate_bot_engine_operations:get_result(#{ ?TYPE => ?COMMAND_EQUALS
                                                   , ?ARGUMENTS => [ constant_val(1.5)
                                                                   , constant_val(2.5)
                                                                   ]
                                                   }, ?EMPTY_THREAD),
    ?assertMatch({ok, false}, R).

%%====================================================================
%% Util functions
%%====================================================================
constant_val(Val) ->
    #{ ?TYPE => ?VARIABLE_CONSTANT
     , ?VALUE => Val
     }.

-define(MARGIN, 0.000001).
approx(Val, Ref) ->
    (Val + ?MARGIN > Ref) and (Val - ?MARGIN < Ref).