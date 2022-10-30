pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _init()

  -- debug switch
  debugint=0

  mode="start"
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
  lives=3
  map={}
  map.targets={}
  target={}
  target.x=nil
  target.y=nil
  target.spr=2
  target.gone=false
  _init_map()
  score=0
  combo=1
end

function _update60()
  if mode == "start" and btn(4) then
    mode = "game"
  end
end

function _draw()
cls()
rectfill(1,14,121,150,1)
tarcnt=0

if mode=="start" then
  draw_start()
else 

-- function calls
_move_pl()
_move_bl()
_draw_pl()
_draw_bl()
_draw_map()

-- print functions
print("score: "..score,0,0,7)
print("lives: "..lives,0,8,7)
print("combo: "..combo,35,8,7)
print("|large combos give",52,0,7)
print("     |extra lives!",52,8,7)

-- count remaining targets
foreach(map.targets,_count_targets)


-- win lose screens
if (tarcnt==0) then cls() print("you win",0,0,7) print("final score: "..score,0,8,7) stop() end
if (lives<=0) then cls() print("game over",0,0,7) print("final score: "..score,0,8,7) stop() end
end
end

-- simple draw function for the player sprite.
function _draw_pl()
  spr(1,pl.x,112)
  spr(1,pl.x+8,112,1,1,true,false)
end

-- simple draw function for the ball.
function _draw_bl()
  spr(16,bl.x,bl.y)
end

--fills map.targets with the targets, call in init.
function _init_map()
  lines=0
  top_x=20
  top_y=30
  iter=0
  for i=1,80 do
    if i%10==1 then 
      lines += 1
      iter=0
    end
    add_new_target(top_x+iter*8,top_y+lines*4,1+lines)
    iter +=1
  end
end

-- draws all targets (need to check if they have been removed)
function _draw_map()
  foreach(map.targets,draw_target)
end

-- draws the target
function draw_target(tar)
  if tar.gone==0 then spr(tar.spr,tar.x,tar.y,1,.5) end
end

-- adds new target to map.targets
function add_new_target(nx,ny,sprite)
  add(map.targets, {
    x=nx,
    y=ny,
    spr=sprite,
    gone=0
  })
end

-- simple move function, only along x axis
function _move_pl()
  if btn(0) and (pl.x > 0) then pl.x -= 1 pl.movx=-1 
  elseif btn(1) and (pl.x < 120) then pl.x += 1 pl.movx=1 else pl.movx=0 end  
end

-- counts remaining targets
function _count_targets(tar)
 if (tar.gone==0) then tarcnt+=1 end
end

-- fires the projectile onto the board
function _move_bl()
  
  -- ball physics
  if (bl.mov == 0) then bl.x=pl.x+4 bl.y=pl.y-1 combo=1 else bl.y+=bl.mov bl.x+=bl.movx end
  if (bl.y<15) then bl.mov=1.2 end
  if (bl.x<0) then bl.movx=1 end
  if (bl.x>116) then bl.movx=-1 end
  
  -- ball collision with paddle
  if (sprcoll(pl.x-1,pl.y+5,17,0,bl.x+2,bl.y+1,3,3)==true) then 
   if (pl.x+1<bl.x) then bl.movx=1 bl.mov=bl.mov*-1
   else bl.movx=-1 bl.mov=bl.mov*-1 end
   combo=1
   sfx(0)
  end
  
  -- ball collision with bricks
  for i=0,count(map.targets) do
	  if map.targets[i]!=nil and map.targets[i].gone==0 and (sprcoll(map.targets[i].x,map.targets[i].y,7,2,bl.x+2,bl.y+1,3,3)==true) then 
    if (map.targets[i].x+1<bl.x) then bl.movx=1 bl.mov=bl.mov*-1
    else bl.movx=-1 bl.mov=bl.mov*-1 end
    map.targets[i].gone=1 score+=10*combo combo+=1 
    if (combo%10==0) then lives+=1 end 
    sfx(1) 
    end
 	end
 	
 	-- if 🅾️ is pressed, launch ball 
  if btn(🅾️) and (bl.mov == 0) then bl.mov=-1.2 bl.movx=pl.movx end

  -- more ball physics
  if (bl.y>150) then bl.mov=0 lives-=1 sfx(2) end
end

function draw_start()
  cls()
  print("brickbreaker",30,40,7)
  print("press ❎ to start",28,80,11)
 end

 function draw_gameover()
  --cls()
  rectfill(0,60,128,75,0)
  print("game over",46,62,7)
  print("press ❎ to retry",30,68,6)
 end

-- checks for collision between sprites, and returns whether it is colliding or not
function sprcoll(x,y,w,h,x2,y2,w2,h2)
   
 col=false
 
 -- debug show hitboxes
 if (debugint==1) then rectfill(x,y,x+w,y+h,8) rectfill(x2,y2,x2+w2,y2+h2,8) end

 if ((x<x2+w2) and (x+w>x2) and (y<y2+h2) and (y+h>y2)) then
  col=true return col
 end
   
 return col
    
end
__gfx__
0000000000000000522222255cccccc5533333355aaaaaa55eeeeee5588888855bbbbbb559999995000000000000000000000000000000000000000000000000
000000000000000022222222cccccccc33333333aaaaaaaaeeeeeeee88888888bbbbbbbb99999999000000000000000000000000000000000000000000000000
0070070000000000522222255cccccc5533333355aaaaaa55eeeeee5588888855bbbbbb559999995000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaa99990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a99999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000019750197501975019750197501b7501e7502175023600236002360023600236000d200236002360023600236002360000000000000000000000000000000000000000000000000000000000000000000
00010000297502975029750297502a7502c750357502170024700267002e700183001a3001c3001e30022300253002e400000002e400000000000000000000000000000000000000000000000000000000000000
000500002c0602906025060210601d0601f06026060250601e060110701307017070190601a06018060100500c0500a050080500a0500d0500d05009050040500405004050040300402003010000100200001000
