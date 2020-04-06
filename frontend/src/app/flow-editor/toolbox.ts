import { AtomicFlowBlock } from './atomic_flow_block';
import { FlowBlock, Position2D, InputPortDefinition, MessageType, OutputPortDefinition } from './flow_block';
import { BlockExhibitor } from './block_exhibitor';
import { BlockManager } from './block_manager';
import { FlowWorkspace } from './flow_workspace';
import { CustomBlockService } from '../custom_block.service';
import { ResolvedCustomBlock } from '../custom_block';

export type BlockGenerator = (manager: BlockManager) => FlowBlock;

export class Toolbox {
    baseElement: HTMLElement;
    toolboxDiv: HTMLDivElement;
    blockShowcase: HTMLDivElement;
    workspace: FlowWorkspace;

    public static BuildOn(baseElement: HTMLElement, workspace: FlowWorkspace): Toolbox {
        let toolbox: Toolbox;
        try {
            toolbox = new Toolbox(baseElement, workspace);
            toolbox.init();
        }
        catch(err) {
            toolbox.dispose();

            throw err;
        }

        return toolbox;
    }


    private constructor(baseElement: HTMLElement, workspace: FlowWorkspace) {
        this.baseElement = baseElement;
        this.workspace = workspace;
    }

    onResize() {}

    dispose() {
        this.baseElement.removeChild(this.toolboxDiv);
    }

    init() {
        this.toolboxDiv = document.createElement('div');
        this.toolboxDiv.setAttribute('class', 'toolbox');
        this.baseElement.appendChild(this.toolboxDiv);

        this.blockShowcase = document.createElement('div');
        this.blockShowcase.setAttribute('class', 'showcase');
        this.toolboxDiv.appendChild(this.blockShowcase);
    }

    addBlockGenerator(generator: BlockGenerator) {
        const block_exhibitor = BlockExhibitor.FromGenerator(generator, this.blockShowcase);
        const element = block_exhibitor.getElement();
        element.onmousedown = (ev: MouseEvent) => {
            try {
                const rect = block_exhibitor.getInnerElementRect();

                if (!rect) {
                    // Hidden block, ignore
                    return;
                }

                const block = generator(this.workspace);
                element.classList.add('hidden');
                this.toolboxDiv.classList.add('subsumed');

                this.workspace.drawAbsolute(block, rect);
                (this.workspace as any)._mouseDownOnBlock(ev, block, () => {
                    element.classList.remove('hidden');
                    this.toolboxDiv.classList.remove('subsumed');
                });
            }
            catch (err) {
                console.error(err);
            }
        };
    }
}

export function buildBaseToolbox(baseElement: HTMLElement, workspace: FlowWorkspace): Toolbox {
    const tb = Toolbox.BuildOn(baseElement, workspace);
    tb.addBlockGenerator((manager) => {
        return new AtomicFlowBlock({
            message: 'wait',
            type: 'operation',
            inputs: [
                {
                    name: "seconds to wait",
                    type: "integer",
                },
            ],
            on_io_selected: manager.onIoSelected.bind(manager),
            on_dropdown_extended: manager.onDropdownExtended.bind(manager),
            on_inputs_changed: manager.onInputsChanged.bind(manager),
        });
    });

    return tb;
}

export async function fromCustomBlockService(baseElement: HTMLElement,
                                             workspace: FlowWorkspace,
                                             customBlockService: CustomBlockService): Promise<Toolbox> {
    const base = buildBaseToolbox(baseElement, workspace);

    const blocks = await customBlockService.getCustomBlocks();
    for (const block of blocks) {
        base.addBlockGenerator((manager) => {
            return new AtomicFlowBlock({
                message: block.message,
                type: (block.block_type as any),
                inputs: get_block_inputs(block),
                outputs: get_block_outputs(block),
                on_io_selected: manager.onIoSelected.bind(manager),
                on_dropdown_extended: manager.onDropdownExtended.bind(manager),
                on_inputs_changed: manager.onInputsChanged.bind(manager),
            })
        });
    }

    return base;
}

function get_block_inputs(block: ResolvedCustomBlock): InputPortDefinition[] {
    // Remove save_to
    let skipped_indexes = [];
    if (block.save_to) {
        if (block.save_to === 'undefined') {
            console.warn('Serialization error on block.save_to');
        }
        else if (((block.save_to as any).type !== 'argument')
            || !(((block.save_to as any).index) || ((block.save_to as any).index === 0))) {

            console.error('BLOCK save to', block);
        }
        else {
            skipped_indexes.push((block.save_to as any).index);
        }
    }

    return (block.arguments
        .filter((_value, index) => skipped_indexes.indexOf(index) < 0)
        .map((value) => ({
            type: get_arg_type(value)
        } as InputPortDefinition) ));
}

function get_block_outputs(block: ResolvedCustomBlock): OutputPortDefinition[] {
    if (block.block_type === 'getter') {
        let result_type: MessageType = 'any';

        switch (block.block_result_type) {
            case 'string':
            case 'boolean':
            case 'integer':
                result_type = block.block_result_type;
                break

            case 'number':
            case 'float':
                // TODO Not supported yet
                break;

            case null:
                console.warn('Return type not set on', block);
                break;

            default:
                console.error("Unknown type", block.block_result_type);
        }

        return [{
            type: result_type,
        }];
    }


    // Derive from save_to
    if (!block.save_to) {
        return [];
    }
    if (block.save_to === 'undefined') {
        console.warn('Serialization error on block.save_to');
        return [];
    }

    if (((block.save_to as any).type !== 'argument')
        || !(((block.save_to as any).index) || ((block.save_to as any).index === 0))) {

        console.error('BLOCK save to', block);
    }

    const arg = block.arguments[(block.save_to as any).index];
    if (!arg) {
        console.error('BLOCK save to', block);
        return [];
    }

    return [{
        type: get_arg_type(arg),
    }];
}

function get_arg_type(arg: any): MessageType  {
    if (arg.type === 'variable') {
        return 'any';
    }

    let result_type = 'any';
    switch (arg.type) {
        case 'string':
        case 'boolean':
        case 'integer':
            result_type = arg.type;
            break

        case 'number':
        case 'float':
            // TODO Not supported yet
            break;

        case null:
            console.warn('Return type not set on', arg);
            break;

        default:
            console.error("Unknown type", arg.type);
    }

    return 'any';
}
