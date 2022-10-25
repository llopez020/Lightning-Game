pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _init()
  poke(0x5f2d,1)
  x=-1000
  y=-1000
  pl={}
  pl.x=50
  pl.y=112
  map={}
  map.targets={}
  target={}
  target.x=nil
  target.y=nil
  target.spr=2
  target.gone=false
  _init_map()

  debugint=0

end

function _update60()
end

function _draw()
cls()
_move_pl()
_draw_pl()
_draw_map()
print(x..","..y)
print(count(map.targets))
spr(0,stat(32),stat(33))
spr(0,x,y)
if (stat(34)==1) then x=stat(32) y=stat(33) end
end

-- simple draw function for the player sprite.
function _draw_pl()
  spr(1,pl.x,112)
end

--fills map.targets with the targets, call in init.
function _init_map()
  lines=0
  top_x=14
  top_y=30
  iter=0
  for i=1,60 do
    if i%10==1 then 
      lines += 1
      iter=0
    end
    add_new_target(top_x+iter*8,top_y+lines*8,2+lines)
    iter +=1
  end
end

-- draws all targets (need to check if they have been removed)
function _draw_map()
  foreach(map.targets,draw_target)
end

-- draws the target
function draw_target(tar)
  spr(tar.spr,tar.x,tar.y)
end

-- adds new target to map.targets
function add_new_target(nx,ny,sprite)
  add(map.targets, {
    x=nx,
    y=ny,
    spr=sprite
  })
end

-- simple move function, only along x axis
function _move_pl()
  if btn(0) and (pl.x > 0) then pl.x -= 1 end
  if btn(1) and (pl.x < 120) then pl.x += 1 end
end

-- fires the projectile onto the board


__gfx__
0000000000000000522222255cccccc5533333350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000022222222cccccccc333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000522222255cccccc5533333350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000511111155eeeeee5588888850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a999999a11111111eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000099999999511111155eeeeee5588888850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
