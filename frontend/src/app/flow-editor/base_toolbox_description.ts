import { PLATFORM_ICON } from './definitions';
import { AtomicFlowBlockOptions } from './atomic_flow_block';

interface Category {
    id: string,
    name: string,
    blocks: AtomicFlowBlockOptions[],
}

export type ToolboxDescription = Category[];

export const OP_PRELOAD_BLOCK: AtomicFlowBlockOptions = {
    icon: PLATFORM_ICON,
    message: 'Preload getter',
    block_function: 'op_preload_getter',
    type: 'operation',
    inputs: [
        {
            name: "getter",
            type: "any",
        },
    ],
    outputs: [],
};

export const BaseToolboxDescription: ToolboxDescription = [
    {
        id: 'control',
        name: 'Control',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'Wait',
                block_function: 'control_wait',
                type: 'operation',
                inputs: [
                    {
                        name: "seconds to wait",
                        type: "integer",
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Check',
                block_function: 'control_if_else',
                type: 'operation',
                inputs: [
                    {
                        name: "check",
                        type: "boolean",
                    },
                ],
                outputs: [
                    {
                        name: 'if true',
                        type: 'pulse',
                    },
                    {
                        name: 'if false',
                        type: 'pulse',
                    }
                ],
            },
            {
                icon: PLATFORM_ICON,
                message: 'Wait for %i1 to be true',
                block_function: 'control_wait_until',
                type: 'operation',
                inputs: [
                    {
                        name: "check",
                        type: "boolean",
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'On new %i1 value',
                block_function: 'trigger_on_signal',
                type: 'trigger',
                inputs: [
                    {
                        name: "signal",
                        type: "any",
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Wait for next value',
                block_function: 'control_wait_for_next_value',
                type: 'operation',
                inputs: [
                    {
                        type: "any",
                    },
                ],
                outputs: [
                    {
                        name: "value",
                        type: "any",
                    }
                ],
            },
            {
                icon: PLATFORM_ICON,
                message: 'Repeat times',
                block_function: 'control_repeat',
                type: 'operation',
                inputs: [
                    {
                        name: "start loop",
                        type: "pulse",
                    },
                    {
                        name: "repetition times",
                        type: "integer",
                    },
                    {
                        name: "back to loop",
                        type: "pulse",
                    },
                ],
                outputs: [
                    {
                        name: "loop continues",
                        type: "pulse",
                    },
                    {
                        name: "iteration #",
                        type: "integer",
                    },
                    {
                        name: "loop completed",
                        type: "pulse",
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'When all true',
                block_function: 'trigger_when_all_true',
                type: 'trigger',
                inputs: [
                    {
                        type: "boolean",
                    },
                    {
                        type: "boolean",
                    },
                ],
                extra_inputs: {
                    type: "boolean",
                    quantity: "any",
                },
            }
        ]
    },
    {
        id: 'parallelization',
        name: 'Parallelization',
        blocks: [
                        {
                icon: PLATFORM_ICON,
                message: 'Run on parallel',
                block_function: 'op_fork_execution',
                type: 'operation',
                outputs: [
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                ],
                // TODO: Implement extra_outputs
                // extra_outputs: {
                //     type: "boolean",
                //     quantity: "any",
                // },
            },
            {
                icon: PLATFORM_ICON,
                message: 'When all completed',
                block_function: 'trigger_when_all_completed',
                type: 'trigger',
                inputs: [
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                ],
                extra_inputs: {
                    type: "pulse",
                    quantity: "any",
                },
            },
            {
                icon: PLATFORM_ICON,
                message: 'When first completed',
                block_function: 'trigger_when_first_completed',
                type: 'trigger',
                inputs: [
                    {
                        type: "pulse",
                    },
                    {
                        type: "pulse",
                    },
                ],
                extra_inputs: {
                    type: "pulse",
                    quantity: "any",
                },
            }
        ]
    },
    {
        id: 'operators',
        name: 'Operators',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: '%i1 + %i2',
                block_function: 'operator_add',
                type: 'getter',
                inputs: [
                    {
                        type: "float",
                    },
                    {
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'float',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: '%i1 - %i2',
                block_function: 'operator_subtract',
                type: 'getter',
                inputs: [
                    {
                        type: "float",
                    },
                    {
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'float',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: '%i1 × %i2',
                block_function: 'operator_multiply',
                type: 'getter',
                inputs: [
                    {
                        type: "float",
                    },
                    {
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'float',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: '%i1 / %i2',
                block_function: 'operator_divide',
                type: 'getter',
                inputs: [
                    {
                        name: 'dividend',
                        type: "float",
                    },
                    {
                        name: 'divisor',
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'float',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: '%i1 modulo %i2',
                block_function: 'operator_modulo',
                type: 'getter',
                inputs: [
                    {
                        name: 'dividend',
                        type: "float",
                    },
                    {
                        name: 'divisor',
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'float',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Is %i1 greater (>) than %i2 ?',
                block_function: 'operator_gt',
                type: 'getter',
                inputs: [
                    {
                        name: "bigger",
                        type: "float",
                    },
                    {
                        name: "smaller",
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Are all equals?',
                block_function: 'operator_equals',
                type: 'getter',
                inputs: [
                    {
                        type: "any",
                    },
                    {
                        type: "any",
                    },
                ],
                extra_inputs: {
                    type: "any",
                    quantity: "any",
                },
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Is %i1 less (<) than %i2?',
                block_function: 'operator_lt',
                type: 'getter',
                inputs: [
                    {
                        name: "smaller",
                        type: "float",
                    },
                    {
                        name: "bigger",
                        type: "float",
                    },
                ],
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'All true',
                block_function: 'operator_and',
                type: 'getter',
                inputs: [
                    {
                        type: "boolean",
                    },
                    {
                        type: "boolean",
                    },
                ],
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Any true',
                block_function: 'operator_or',
                type: 'getter',
                inputs: [
                    {
                        type: "boolean",
                    },
                    {
                        type: "boolean",
                    },
                ],
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Inverse',
                block_function: 'operator_not',
                type: 'getter',
                inputs: [
                    {
                        type: "boolean",
                    },
                ],
                outputs: [
                    {
                        type: 'boolean',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Join texts',
                block_function: 'operator_join',
                type: 'getter',
                inputs: [
                    {
                        name: "beginning",
                        type: "string",
                    },
                    {
                        name: "end",
                        type: "string",
                    },
                ],
                outputs: [
                    {
                        type: 'string',
                    },
                ]
            },
            // Advanced block
            {
                icon: PLATFORM_ICON,
                message: 'Get key %i1 of %i2',
                block_function: 'operator_json_parser',
                type: 'getter',
                inputs: [
                    {
                        type: "string",
                    },
                    {
                        type: "any",
                    },
                ],
                outputs: [
                    {
                        type: 'any',
                    },
                ]
            },
        ]
    },
    {
        id: 'debug',
        name: 'Debug',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'Log value %i1',
                block_function: 'logging_add_log',
                type: 'operation',
                inputs: [
                    {
                        type: "any",
                    },
                ],
            },
        ]
    },
    {
        id: 'time',
        name: 'Time',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'UTC date',
                block_function: 'flow_utc_date',
                type: 'getter',
                outputs: [
                    {
                        name: 'year',
                        type: 'integer',
                    },
                    {
                        name: 'month',
                        type: 'integer',
                    },
                    {
                        name: 'day',
                        type: 'integer',
                    },
                    {
                        name: 'day of week',
                        type: 'any',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'UTC time',
                block_function: 'flow_utc_time',
                type: 'getter',
                outputs: [
                    {
                        name: 'hour',
                        type: 'integer',
                    },
                    {
                        name: 'minute',
                        type: 'integer',
                    },
                    {
                        name: 'second',
                        type: 'integer',
                    },
                ]
            }
        ]
    },
    {
        id: 'variables',
        name: 'Variables',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'Get %(variable) value',
                block_function: 'data_variable',
                type: 'getter',
                outputs: [
                    {
                        type: 'any'
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Set %(variable) to %i1',
                block_function: 'data_setvariableto',
                type: 'operation',
                inputs: [
                    {
                        name: 'new value',
                        type: "any",
                    },
                ],
                outputs: [
                    {
                        name: 'saved value',
                        type: 'any',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Increment %(variable) by %i1',
                block_function: 'data_changevariableby',
                type: 'operation',
                inputs: [
                    {
                        type: "float",
                    },
                ]
            }
        ]
    },
    {
        id: 'lists',
        name: 'Lists',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'Add %i1 to %(list)',
                block_function: 'data_addtolist',
                inputs: [
                    {
                        type: 'any',
                    }
                ],
                type: 'operation'
            },
            {
                icon: PLATFORM_ICON,
                message: 'Delete entry # %i1 to %(list)',
                block_function: 'data_deleteoflist',
                type: 'operation',
                inputs: [
                    {
                        type: 'integer',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Delete all of %(list)',
                block_function: 'data_deletealllist',
                type: 'operation'
            },
            {
                icon: PLATFORM_ICON,
                message: 'Insert %i1 at position %i2 of %(list)',
                block_function: 'data_insertatlist',
                type: 'operation',
                inputs: [
                    {
                        type: 'any',
                    },
                    {
                        type: 'integer',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Replace item at position %i1 of %(list) with %i2',
                block_function: 'data_replaceitemoflist',
                type: 'operation',
                inputs: [
                    {
                        type: 'integer',
                    },
                    {
                        type: 'any',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Item number %i1 of %(list)',
                block_function: 'data_itemoflist',
                type: 'getter',
                inputs: [
                    {
                        type: 'integer',
                    },
                ],
                outputs: [
                    {
                        type: 'any',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Position of item %i1 in %(list)',
                block_function: 'data_itemnumoflist',
                type: 'getter',
                inputs: [
                    {
                        type: 'any',
                    },
                ],
                outputs: [
                    {
                        type: 'integer',
                    },
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Number of items in %(list)',
                block_function: 'data_lengthoflist',
                type: 'getter',
                outputs: [
                    {
                        type: 'integer',
                    }
                ]
            },
            {
                icon: PLATFORM_ICON,
                message: 'Does %(list) contain %i1?',
                block_function: 'data_listcontainsitem',
                type: 'getter',
                inputs: [
                    {
                        type: 'any',
                    }
                ],
                outputs: [
                    {
                        type: 'boolean',
                    }
                ]
            },
        ]
    },
    {
        id: 'advanced',
        name: 'Advanced',
        blocks: [
            {
                icon: PLATFORM_ICON,
                message: 'Get thread ID',
                block_function: 'flow_get_thread_id',
                type: 'getter',
                outputs: [
                    {
                        type: "string",
                    },
                ],
            },
            OP_PRELOAD_BLOCK,
        ]
    }
];
