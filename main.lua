--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  theMusicBox

lo   = love
-- 2 letter
la   = lo .audio
le   = lo .event
lf   = lo .filesystem
lg   = lo .graphics
li   = lo .image
lj   = lo .joystick
lk   = lo .keyboard
lm   = lo .math
lp   = lo .physics
ls   = lo .sound
lt   = lo .timer
lv   = lo .video
lw   = lo .window
-- 3 letter
lfo  = lo .font
lmo  = lo .mouse
lsy  = lo .system
lth  = lo .thread
lto  = lo .touch

WW  = lg .getWidth()
HH = lg .getHeight()

x = 0
y = 0
cols = 16
rows = 16
gx = WW / cols
gy = HH / rows

grid = {}
timer = 0
tempo = 2
currentCol = 0
amplitude = 0
lastpos = nil

font = lg .newFont( 22 )
denver  = require 'libs.denver'  -- waveform gen
shine = require 'libs.shine'   -- postprocessing effects
freq = { 'D#5', 'D5', 'C#5', 'C5',
         'B4', 'A#4', 'A4', 'G#4',
         'G4', 'F#4', 'F4', 'E4',
         'D#4', 'D4', 'C#4', 'C4', }
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function lo .load()
  print('Löve App begin')

-- postprocessing effects
  chroma = shine .separate_chroma()
  sketch = shine .sketch()
  sketch .amp = 0

-- populate empty grid
  for y = 1,  rows do
    for x = 1,  cols do
      grid[#grid + 1] = false
    end
  end

  lg .setBackgroundColor( 0, 10, 50 )
  lg .setDefaultFilter( 'nearest', 'nearest', 0 )
end  -- lo .load

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function lo .update(dt)
-- easy exit
  if lk .isDown( 'escape' ) then
    le .push( 'quit' )
  end

-- check for mouse / touch
  if lmo .isDown(1) or #lto .getTouches() > 0 then
    if lmo .isDown(1) then  -- mouse
      x = lmo .getX()
      y = lmo .getY()
    else
      touches = lto .getTouches()  -- phone / tablet
      for i, id in ipairs(touches) do
        x, y = lto .getPosition(id)
      end -- i, id in ipairs
    end -- lmo .isDown  mouse

--  get pos
    xpos = math .floor(x / gx)
    ypos = math .floor(y / gy)
    i = xpos + ypos * cols

--  toggle, if needed
    if lastpos ~= i then
      if grid[i] == true then
        grid[i] = false
      else
        grid[i] = true
      end  -- toggle button
      lastpos = i
    end -- lastpos
    else
      lastpos = nil
  end -- lmo or #lto

  timer = timer + dt * tempo
  currentCol = math .floor( timer % cols )

  chroma .angle = math .sin( timer )
  chroma .radius = chroma .radius - dt
  if chroma .radius < 0 then
    chroma .radius = 0
  end

  -- you can set sketch.amp, but it doesn't return a value
  -- so I'm using the 'amplitude' variable to keep track of it
  amplitude = amplitude - dt / 20
  if amplitude < 0 then
    amplitude = 0
  end
  sketch .amp = amplitude
end -- lo .update(dt)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~

function lo .draw()
  chroma(function()
    sketch(function()
      for yy = 0,  rows -1 do
        for xx = 0,  cols -1 do
          lg .setColor(255,  255,  255)
          if currentCol == xx then
            lg .setColor(255,  0,  0)
          end
          if grid[xx + yy * cols] == true then
            lg .rectangle( 'fill',  gx * xx,  gy * yy,  gx,  gy )
            if currentCol == xx then
              local note  = denver .get({ waveform = 'square',  frequency = freq[yy + 1],  length = .1 })
              la .play(note)
              chroma .radius = 3
              amplitude = lm .random(2,  6) / 1000
            end
          else
            lg .rectangle( 'line',  gx * xx,  gy * yy,  gx,  gy )
          end  -- grid
        end
      end
    end) -- sketch
  end) -- separate_chroma
end  -- lo .draw

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function lo .quit()
  print('Löve App exit')
end  -- lo .quit

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

