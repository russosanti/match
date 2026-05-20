# Match 3

A Match-3 puzzle game developed in Lua using LÖVE2D.

## Overview

This project expands the classic Match-3 gameplay by adding progression mechanics, special tiles, dynamic difficulty scaling, and additional interaction systems.

The main focus of the project was to practice:

- Grid-based game logic
- Match detection algorithms
- Procedural difficulty progression
- Particle systems
- Chain reactions
- State and animation management
- User interaction systems

## Features

### Time and Score Scaling System

Implemented a dynamic reward system where successful matches increase the remaining play time.

#### Match Rewards

- Each tile involved in a match grants **1 additional second**
- Tile variants provide:
  - Additional bonus time
  - Higher score values

This rewards larger and higher-value matches while increasing gameplay progression.

## Dynamic Level Progression

Difficulty scales gradually as the player advances through levels.

### Color Progression

- Level 1 starts with:
  - 3 tile colors
  - 1 tile variant

- Beginning at Level 2:
  - A new color is added each level
  - Maximum: **16 colors**

### Variant Progression

- Variants begin appearing at Level 3
- Every 2 levels a new variant is introduced
- Maximum: **6 variants**

This progressively increases board complexity and match difficulty.

## Shiny Special Blocks

Implemented special shiny blocks using a particle system that creates sparkle/shining visual effects.

### Shiny Block Behavior

When a shiny block is destroyed:

- The entire row is destroyed
- The entire column is destroyed

If another shiny block is destroyed during the chain reaction:

- The effect is applied again recursively

This creates chain reactions and larger board-clearing combinations.

The decision to destroy both rows and columns was made to create more impactful gameplay and visually satisfying effects.

## Valid Swap System

Players can only perform swaps that create a valid match.

### Swap Rules

- If the swap creates a match:
  - The move is accepted
- If no match is created:
  - Tiles revert using the same swap animation
  - An error sound effect is played

This reproduces the behavior commonly found in modern Match-3 games.

## Board Shuffle System

Implemented automatic board reshuffling when no valid matches remain.

### Shuffle Behavior

- Detects when no possible matches exist
- Automatically reshuffles the board
- Applies a fade-out / fade-in transition effect during the process

This provides visual feedback while preventing unwinnable board states.

## Mouse Interaction Support

Implemented tile swapping using mouse clicks.

### Mouse Controls

- Detect mouse click position
- Convert screen coordinates into board coordinates
- Select and swap tiles through mouse interaction

This adds an additional input method beyond keyboard controls.

## Technologies

- Lua
- LÖVE2D