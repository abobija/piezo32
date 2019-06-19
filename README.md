# piezo32
Piezo buzzer Lua [NodeMCU] library

## Demo

[![Piezo buzzer music - ESP32 - piezo32.lua](https://img.youtube.com/vi/962Ot5rB4sI/mqdefault.jpg)](https://www.youtube.com/watch?v=962Ot5rB4sI)

## Usage

```lua
local piezo = require('piezo32')({
    gpio = 13
})
```

### Example 1

Play sound at 1kHz for 10 times with play duration of 100ms and rest duration of 100ms as well

```lua 
piezo.play({
	freq = 1000,
	play_duration = 100,
	pause_duration = 100,
	times = 10
})
```

### Example 2

Two beeps - success sound

```lua 
piezo.success()
```

### Example 3

Low frequency error sound

```lua 
piezo.error()
```

### Example 4

Jingle Bells

```lua 
piezo.play_music('E1E1E2E1E1E2E1G1C1D1E4F1F1F1F1F1E1E1E1E1D1D1E1D2G2')
```

### Example 5

Mary Had a Little Lamb

```lua 
piezo.play_music('B1A1G1A1B1B1B2A1A1A2B1B1B2B1A1G1A1B1B1B2A1A1B1A1G2G2')
```

### Example 6

Twinkle Twinkle Little Star

```lua 
piezo.play_music('C1C1G1G1A1A1G2F1F1E1E1D1D1C2')
```

## Dependencies

Project depends on the following NodeMCU modules:

  - `tmr`
  - `ledc`
