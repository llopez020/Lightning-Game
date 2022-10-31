pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()

  -- debug switch
  debugint=0

  poke(0x5f2d,1)
  mode="start"
end

 
function startgame()
 mode="game"
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
  bl.spd=1
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
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="gameover" then
  update_gameover()
 elseif mode=="win" then
  update_win()
 end
end

function update_game()
end

function update_gameover()
 if btn(❎) then
  startgame()
 end 
end

function update_start()
 if btn(❎) then
  startgame()
 end
end

function update_win()
 if btn(❎) then
  startgame()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="gameover" then
  draw_gameover()
 elseif mode=="win" then
  draw_win()
 end
 
end

function draw_start()
 cls()
 print("brickbreaker",30,40,7)
 print("press ❎ to start",28,80,11)
end
 
function draw_win()
 --cls()
 rectfill(0,60,128,75,0)
 print("you win!",46,62,7)
 print("press ❎ to retry",30,68,6)
end

function draw_gameover()
 --cls()
 rectfill(0,60,128,75,0)
 print("game over",46,62,7)
 print("press ❎ to retry",30,68,6)
end

function draw_game()
cls()
rectfill(1,14,121,150,1)
tarcnt=0

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
if (tarcnt==0) then mode="win" end
if (lives<=0) then mode="gameover" end

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
 // if btn(0) and (pl.x > 0) then pl.x -= 1 pl.movx=-1 
 // elseif btn(1) and (pl.x < 120) then pl.x += 1 pl.movx=1 else pl.movx=0 end  
 pl.x=stat(32)
 if (pl.x<0) then pl.x = 0 end
 if (pl.x>=116) then pl.x = 116 end
end

-- counts remaining targets
function _count_targets(tar)
 if (tar.gone==0) then tarcnt+=1 end
end

-- fires the projectile onto the board
function _move_bl()
  
  -- ball physics
  if (bl.mov == 0) then bl.x=pl.x bl.y=pl.y-1 combo=1 else bl.y+=bl.mov*bl.spd bl.x+=bl.movx*bl.spd end
  if (bl.y<15) then bl.mov=1.2 sfx(0) bl.spd+=.02 end
  if (bl.x<0) then bl.movx=1 sfx(0) bl.spd+=.02 end
  if (bl.x>116) then bl.movx=-1 sfx(0) bl.spd+=.02 end
  
  -- ball collision with paddle
  if (sprcoll(pl.x-1,pl.y+5,9,0,bl.x+2,bl.y+1,3,3)==true) then 
   if (pl.x+1<bl.x) then bl.movx=1 bl.mov=bl.mov*-1
   else bl.movx=-1 bl.mov=bl.mov*-1 end
   combo=1 sfx(0) bl.spd+=.02
  end
  
  -- ball collision with bricks
  for i=0,count(map.targets) do
	  if map.targets[i]!=nil and map.targets[i].gone==0 and (sprcoll(map.targets[i].x,map.targets[i].y,7,2,bl.x+2,bl.y+1,3,3)==true) then 
    if (map.targets[i].x+1<bl.x) then bl.movx=1 bl.mov=bl.mov*-1
    else bl.movx=-1 bl.mov=bl.mov*-1 end
    map.targets[i].gone=1 score+=10*combo combo+=1 sfx(0) bl.spd+=.02
    if (combo%10==0) then lives+=1 end end
 	end
 	
 	-- if 🅾️ is pressed, launch ball 
  if btn(🅾️) and (bl.mov == 0) then bl.mov=-1.2 bl.movx=pl.movx end

  -- more ball physics
  if (bl.y>150) then bl.mov=0 lives-=1 sfx(2) bl.spd=1 end
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
00000000a999999a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
07700770077077707770000000007770000000000000000000000700700077707770077077700000077007707770777007700770000007707770707077700000
70007000707070707000070000007070000000000000000000000700700070707070700070000000700070707770707070707000000070000700707070000000
77707000707077007700000000007070000000000000000000000700700077707700700077000000700070707070770070707770000070000700707077000000
00707000707070707000070000007070000000000000000000000700700070707070707070000000700070707070707070700070000070700700777070000000
77000770770070707770000000007770000000000000000000000700777070707070777077700000077077007070777077007700000077707770070077700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007770707077700770000000007770000077007707770777007700000000077000000007007770707077707770777000007000777070707770077007000000
70000700707070007000070000000070000700070707770707070700700000007000000007007000707007007070707000007000070070707000700007000000
70000700707077007770000000000770000700070707070770070700000000007000000007007700070007007700777000007000070070707700777007000000
70000700777070000070070000000070000700070707070707070700700000007000000007007000707007007070707000007000070077707000007000000000
77707770070077707700000000007770000077077007070777077000000000077700000007007770707007007070707000007770777007007770770007000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111522222255222222552222225522222255222222552222225522222255222222552222225522222251111111111111111111111000000
01111111111111111111222222222222222222222222222222222222222222222222222222222222222222222222222222221111111111111111111111000000
01111111111111111111522222255222222552222225522222255222222552222225522222255222222552222225522222251111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
011111111111111111115cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc51111111111111111111111000000
01111111111111111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111111111000000
011111111111111111115cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc55cccccc51111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111533333355333333553333335533333355333333553333335533333355333333553333335533333351111111111111111111111000000
01111111111111111111333333333333333333333333333333333333333333333333333333333333333333333333333333331111111111111111111111000000
01111111111111111111533333355333333553333335533333355333333553333335533333355333333553333335533333351111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
011111111111111111115aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa51111111111111111111111000000
01111111111111111111aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1111111111111111111111000000
011111111111111111115aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa55aaaaaa51111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
011111111111111111115eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee51111111111111111111111000000
01111111111111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1111111111111111111111000000
011111111111111111115eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee55eeeeee51111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111588888855888888558888885588888855888888558888885588888855888888558888885588888851111111111111111111111000000
01111111111111111111888888888888888888888888888888888888888888888888888888888888888888888888888888881111111111111111111111000000
01111111111111111111588888855888888558888885588888855888888558888885588888855888888558888885588888851111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
011111111111111111115bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb51111111111111111111111000000
01111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111111111111111111000000
011111111111111111115bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb55bbbbbb51111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111599999955999999559999995599999955999999559999995599999955999999559999995599999951111111111111111111111000000
01111111111111111111999999999999999999999999999999999999999999999999999999999999999999999999999999991111111111111111111111000000
01111111111111111111599999955999999559999995599999955999999559999995599999955999999559999995599999951111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111177761111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111177761111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111177761111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111166661111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
0111111111111111111111111111111a999999a11111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111119999999911111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000
01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000

__sfx__
000100001835018350173501735017350143500030000300003000030000300033000330006300043000330001300003000230003300033000130001300013000230001300013000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000d0500d0500c0500b0500a050080500705006050040500305002050000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000