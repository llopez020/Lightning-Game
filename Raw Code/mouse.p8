pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
  poke(0x5f2d,1)
  x=-1000
  y=-1000
  pl={}
  pl.x=50
  pl.y=112
  pl.movx=0
  bl={}
  bl.x=-100
  bl.y=-100
  bl.mov=0
  bl.movx=0
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
_move_bl()
_draw_pl()
_draw_bl()
_draw_map()
//print(x..","..y)
print(count(map.targets))
//spr(0,stat(32),stat(33))
//spr(0,x,y)
//if (stat(34)==1) then x=stat(32) y=stat(33) end
end

-- simple draw function for the player sprite.
function _draw_pl()
  spr(1,pl.x,112)
end

-- simple draw function for the ball.
function _draw_bl()
  spr(16,bl.x,bl.y)
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
  if btn(0) and (pl.x > 0) then pl.x -= 1 pl.movx=-1 
  elseif btn(1) and (pl.x < 120) then pl.x += 1 pl.movx=1 else pl.movx=0 end  
end

-- fires the projectile onto the board
function _move_bl()
  if (bl.mov == 0) then bl.x=pl.x bl.y=pl.y-10 else bl.y+=bl.mov bl.x+=bl.movx end
  if (bl.y<0) then bl.mov=1.2 end
  if (bl.y>150) then bl.mov=0 end
  if (bl.x<0) then bl.movx=1 end
  if (bl.x>120) then bl.movx=-1 end
  if (sprcoll(pl.x,pl.y+5,8,1,bl.x+1,bl.y+1+bl.mov,3,3)==true) then 
   if (pl.x+1<bl.x) then bl.movx=1 bl.mov=bl.mov*-1
   else bl.movx=-1 bl.mov=bl.mov*-1 end
  end
  if btn(🅾️) and (bl.mov == 0) then bl.mov=-1.2 bl.movx=pl.movx end
end


-- checks for collision between sprites, and returns whether it is colliding or not
function sprcoll(x,y,w,h,x2,y2,w2,h2)
   
 col=false
    
 if ((x<x2+w2) and (x+w>x2) and (y<y2+h2) and (y+h>y2)) then
  col=true return col
 end
   
 return col
    
end
__gfx__
0000000000000000522222255cccccc5533333350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000022222222cccccccc333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000522222255cccccc5533333350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000511111155eeeeee5588888850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a999999a11111111eeeeeeee888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000099999999511111155eeeeee5588888850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
