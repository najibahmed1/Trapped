# Trapped - Pico8 Game

In this game, you play as a character trapped in a dangerous environment filled with deadly spikes, moving enemies (bats), moving clouds, and epic parkour. The theme "Trapped" is represented through:
- Confined spaces with hazardous elements
- Need to collect keys to escape, and open a door
- Strategic movement required to avoid enemies
- Challenging level design that creates a sense of being trapped
- Progression through multiple levels to eventually escape being trapped

## Game Features

### Core Mechanics
- **Player Movement**: Smooth platformer controls with jumping mechanics
- **Physics**: Gravity-based movement with collision detection
- **Collectibles**: Keys that must be gathered to progress
- **Enemies**: Multiple types of hazards including:
  - Moving bats with vertical patterns
  - Horizontal killer balls
  - Deadly spikes

### Technical Implementation
1. **Animated Sprites**
   - Player character animations
   - Enemy animations
   - Key animations

2. **Collision Detection**
   - Map collision for solid tiles
   - Enemy collision with death mechanic
   - Item (key) collection
   - Spike detection system

3. **Physics/Movement**
   - Gravity-based jumping
   - Smooth acceleration/deceleration
   - Bounce mechanics for enemies

4. **Sound Effects**
   - Jump sound
   - Death sound
   - Key collection sound
   - Door interaction sound

### Controls
- Left/Right Arrow Keys: Move horizontally
- Up Arrow: Jump
- V: Reset game and death counter

## External Resources Used
1. Sound and some sprite models borrowed and adjusted from Pico-8's "Collide" game created by Zed. 
2. The basic level progression idea by going from left to right through the levels also inspired from Zep's "Collide" game in the tutorial games for Pico-8.

## Code Structure
- Main game loop with separate update and draw functions
- Modular collision detection system
- Actor-based entity system for players and enemies
- State management for game progression

## Development Notes
- Implemented multiple enemy types with different movement patterns
- Created a key collection system with counter
- Added death counter for tracking attempts
- Designed challenging but fair level layout

## Future Improvements
- Additional levels
- More enemy types
- Power-ups
- Background music and more sound effects
