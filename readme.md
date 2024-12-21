# BreakPal - Library Generation Tool for Renoise

BreakPal (Breakbeat Palette) is a Renoise tool designed to transform a source phrase into a comprehensive library of chops and phrases, enabling rapid song construction through automated pattern generation and manipulation.

Special shout out to esaruoho(https://github.com/esaruoho) and erlsh(https://github.com/dethine) from the TRACKERCORPS and Renoise Discord servers for their inspiration and feedback!

## Features

### Core Functions

1. **Note Division Generation**
   - Takes your source phrase and creates multiple versions at different note divisions
   - Automatically segments the source into halves, quarters, and eighths
   - Allows quick access to specific portions of your source phrase
   - Generated phrases maintain all sample and effect data from the source

2. **Breakpoint Pattern Generation**
   - Uses slices tagged with "Breakpoint" to reordered breaks
   - Automatically identifies and isolates sections between breakpoints
   - Creates all possible permutations of these breaks
   - Maintains timing relationships between breaks
   - Preserves groove and feel while reordering breaks
   - Supports complex arrangements by handling:
     - Timing transitions between sections
     - Delay value adjustments
     - Line number calculations
     - Volume relationships

3. **Cycle-based Variations**
   - Uses slices tagged with "Cycle" to create permutations
   - Rotates through all possible combinations of tagged slices
   - Creates variations for both the full source phrase and all note divisions
   - Maintains groove while providing rhythmic variations

4. **Roll Pattern Generation**
   - Works with pairs of similarly labeled slices (e.g., "Snare")
   - Requires one slice tagged as "Roll" (primary hit) and another as "Ghost Note" (secondary hit)
   - Generates multiple variations:
     - Volume curves (Linear, Logarithmic, Exponential)
     - Direction (Up/Down)
     - Effects (Upshift, Downshift, Staccato, Stretch, Backwards, Reversal)
   - Creates patterns at multiple timing divisions (1/2 to 1/64)

5. **Shuffle Pattern Generation**
   - Creates patterns using multiple pairs of labeled slices
   - Pairs must share the same label (e.g., "Snare", "Hi-Hat")
   - Combines slices tagged with "Shuffle" (primary) and "Ghost Note" (secondary)
   - Generates various shuffle patterns by combining multiple label pairs
   - Supports different time divisions and variations

6. **Multi-Sample Roll Pattern Generation**
   - Creates complex patterns using multiple samples of the same type
   - Supports roll and ghost note combinations
   - Includes templates for various rhythmic patterns
   - Generates timing variations for each pattern

7. **Complex Roll Pattern Generation**
   - Paradiddles and crossover patterns
   - Complex rolls and multi-instrument patterns
   - Templates for various drumming techniques
   - Supports inverted pattern variations

8. **Beat Pattern Generation**
   - Includes templates for various musical styles:
     - Latin (Samba, Afro-Cuban)
     - Afrobeat
     - Jazz
     - Funk
   - Creates patterns with multiple instruments
   - Supports complex rhythmic structures
   - Generates variations at different time divisions

### Slice Labeling System
- Comprehensive tagging system with five main flags:
  - **Breakpoint**: Marks slices that define section boundaries for break pattern generation
  - **Cycle**: Marks slices for rotation in variation generation
  - **Roll**: Designates primary hits for roll patterns
  - **Ghost Note**: Marks secondary/quieter hits for both rolls and shuffles
  - **Shuffle**: Marks primary hits for shuffle patterns
- Supports standard drum labels (Kick, Snare, Hi-Hat, etc.)
- Labels are used to maintain logical pairing in pattern generation
- Import/Export functionality to save and reapply slice label data

## Usage

### Basic Workflow

1. Start with a source phrase in Renoise
2. Open BreakPal from the Tools menu
3. Label your slices:
   - Click "Label Slices"
   - Assign appropriate instrument labels to each slice
   - Set appropriate flags based on desired functions:
     - Use "Breakpoint" to mark section boundaries
     - Use "Cycle" for variation generation
     - Use "Roll" + "Ghost Note" pairs for roll patterns
     - Use "Shuffle" + "Ghost Note" pairs for shuffle patterns
   - Save your labels

### Generate Patterns

After labeling, use the generation buttons in this recommended order:

1. **Make Breaks**: 
   - Uses slices tagged with "Breakpoint"
   - Creates all possible break permutations
   - Maintains timing relationships

2. **Create Phrases by Division**: 
   - Creates divisions of your source phrase
   - No labels required for this function
   - Forms the base for other generations

3. **Modify Phrases with Labels**: 
   - Uses slices tagged with "Cycle"
   - Creates variations of both source and divided phrases

4. **Make Rolls**: 
   - Works with "Roll" + "Ghost Note" pairs
   - Creates various roll patterns and variations

5. **Make Shuffles**: 
   - Uses "Shuffle" + "Ghost Note" pairs
   - Combines multiple pairs for complex shuffle patterns

6. **Make Complex Rolls**: 
   - Generates paradiddles and crossover patterns
   - Creates multi-sample roll variations
   - Includes multiple roll types and styles
   - Supports advanced rhythmic patterns

7. **Make Beats**:
   - Creates patterns for various musical styles:
     - Latin (Samba, Afro-Cuban)
     - Afrobeat
     - Jazz
     - Funk
   - Generates multi-instrument patterns
   - Supports different time divisions
   - Includes both standard and inverted variations

### Using Generated Patterns

- Access generated patterns through the phrase editor
- Use the `Z` effect command in the pattern editor to trigger phrases
- Recall labels anytime using the "Recall Labels" button
- Import/Export labels for reuse across projects

### Inspection Tools

#### Evaluate Phrase
- Analyzes the currently selected phrase and displays detailed information:
  - Note data for each line
  - Instrument values
  - Distance between notes
  - Useful for understanding phrase structure before modification

#### Show Results
- Available after pattern generation
- Displays a comprehensive list of created phrases with their:
  - Names
  - Index numbers
  - Pattern structure
- Helps navigate large sets of generated patterns
- Particularly useful when using the `Z` effect command in the pattern editor

## Performance Notes

- The roll pattern generation is CPU-intensive, especially for complex variations
- On lower-end systems, you may need to:
  - Work with fewer samples
  - Dismiss any hanging or unresponsive dialogs during generation
  - Be patient during processing
- Consider generating one type of pattern at a time
- Large numbers of slices may affect UI responsiveness
- Limited to 4 breakpoints (5 breaks) per instrument and overflow not handled yet

## Upcoming Features
- Humanize notes toggle
- Break builder menu for multi-measure break creation
- Refined note placement based on slice length
   - Option for best fit
   - Option for strict fit only
   - Option for trimmed fit
- Advanced menu for selecting which types to generate
- More Beat and Roll Types
