-module(automate_rest_api_utils_formatting).

-export([ format_message/1
        , serialize_logs/1
        , serialize_log_entry/1
        ]).

-include("./records.hrl").
-include("../../automate_storage/src/records.hrl").
-include("../../automate_bot_engine/src/program_records.hrl").

format_message(Log=#user_program_log_entry{}) ->
    {ok, #{ type => program_log
          , value => serialize_log_entry(Log)
          }};
format_message(_) ->
    {error, unknown_format}.


serialize_logs(Logs) ->
    lists:map(fun (Entry) -> serialize_log_entry(Entry) end, Logs).

serialize_log_entry(#user_program_log_entry{ program_id=ProgramId
                                           , thread_id=ThreadId
                                           , user_id=UserId
                                           , block_id=BlockId
                                           , event_data=EventData
                                           , event_message=EventMessage
                                           , event_time=EventTime
                                           , severity=Severity
                                           , exception_data=_ExceptionData
                                           }) ->
    #{ program_id => ProgramId
     , thread_id => serialize_string_or_none(ThreadId)
     , user_id => serialize_string_or_none(UserId)
     , block_id => serialize_string_or_none(BlockId)
     , event_data => serialize_event_error(EventData)
     , event_message => EventMessage
     , event_time => EventTime
     , severity => Severity
     }.

serialize_string_or_none(none) ->
    null;
serialize_string_or_none(String) ->
    String.

serialize_event_error(#program_error{ error=Error
                                    , block_id=BlockId
                                    }) ->
    #{ error => serialize_error_subtype(Error)
     , block_id => BlockId
     };
serialize_event_error(_) ->
    unknown_error.

serialize_error_subtype(#variable_not_set{variable_name=VariableName}) ->
    #{ type => variable_not_set
     , variable_name => VariableName
     };

serialize_error_subtype(#list_not_set{list_name=ListName}) ->
    #{ type => list_not_set
     , list_name => ListName
     };

serialize_error_subtype(#index_not_in_list{ list_name=ListName
                                          , index=Index
                                          , max=MaxIndex
                                          }) ->
    #{ type => index_not_in_list
     , list_name => ListName
     , index => Index
     , length => MaxIndex
     };

serialize_error_subtype(#invalid_list_index_type{ list_name=ListName
                                                , index=Index
                                                }) ->
    #{ type => invalid_list_index_type
     , list_name => ListName
     , index => Index
     };

serialize_error_subtype(#unknown_operation{}) ->
    #{ type => unknown_operation
     }.