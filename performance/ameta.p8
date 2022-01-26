pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
Constants
--]]
ZERO=0 ONE=1 TWO=2 THREE=3 FOUR=4 FIVE=5 SIX=6 SEVEN=7 EIGHT=8
NINE=9 TEN=10 ELEVEN=11 TWELVE=12 THIRTEEN=13 FOURTEEN=14 FIFTEEN=15 SIXTEEN=16
CELL=8 MIN=0 MAX=128
DEBUG=true MEM=0 TCPU=1 SCPU=2 DISP=3 CLIP=4 VER=5 PARAMS=6 FPS=7 TFPS=8
CURSOR_X=0x5f26 CURSOR_Y=0x5f27
BLACK=0 DARKBLUE=1 PURPLE=2 DARKGREEN=3 BROWN=4 DARKGREY=5 LIGHTGREY=6 WHITE=7
RED=8 ORANGE=9 YELLOW=10 GREEN=11 BLUE=12 LAVENDER=13 PINK=14 PEACH=15
--[[
Box
--]]
Box={l=ZERO,r=ZERO,t=ZERO,b=ZERO} Box.__index=Box
function Box:init(box) return setmetatable(box or {},Box) end
function Box:randpos()
 return {x=flr(self.l+rnd(self.r-self.l)),y=flr(self.t+rnd(self.b-self.t))}
end
--[[
Sprite
--]]
Sprite={s=ZERO,w=ONE,h=ONE} Sprite.__index=Sprite
function Sprite:init(s)
 local sprite = s or {}
 setmetatable(sprite,Sprite)
 sprite.dimensions=sprite:box(ZERO,ZERO)
 return sprite
end
function Sprite:draw(x,y) spr(self.s, x, y, self.w, self.h) end
function Sprite:box(x,y)
 return Box:init({l=x,r=x+self.w*CELL,t=y,b=y+self.h*CELL})
end
--[[
Brick
--]]
Brick={sprite=Sprite:init({s=TEN-ONE,w=TWO,h=ONE})} Brick.__index=Brick
function Brick:init() return setmetatable({},Brick) end
--[[
Ball
--]]
Ball={sprite=Sprite:init({s=SIXTEEN-ONE,w=ONE,h=ONE})} Ball.__index=Ball
function Ball:init()
 local ball={}
 setmetatable(ball,Ball)
 local play={l=MAX*ONE/FIVE,r=MAX*FOUR/FIVE,t=MAX*ONE/FIVE,b=MAX*THREE/FIVE}
 local playbox=Box:init(play)
 local playpos=playbox:randpos()
 ball.x=playpos.x ball.y=playpos.y
 ball.xprev=ball.x ball.yprev=ball.y
 ball.dx=ONE ball.dy=ONE
 return ball
end
function Ball:collide(collisions)
 local collidebox=Box:init()
 for c in all(collisions) do
  if c.x==self.x then collidebox.l+=ONE end
  if c.x==self.x+self.sprite.dimensions.r-ONE then collidebox.r+=ONE end
  if c.y==self.y then collidebox.t+=ONE end
  if c.y==self.y+self.sprite.dimensions.b-ONE then collidebox.b+=ONE end
 end
 if collidebox.l>ONE or collidebox.r>ONE then BALL.dx*=-ONE end
 if collidebox.t>ONE or collidebox.b>ONE then BALL.dy*=-ONE end
end
--[[
Map
--]]
Map={} Map.__index=Map
function Map:init() return setmetatable({},Map) end
function Map:put(x,y,z,v)
 if not self[x] then self[x]={} end
 if not self[x][y] then self[x][y]={} end
 self[x][y][z]=v
end
function Map:get(x,y,z)
 if self[x] and self[x][y] then return self[x][y][z]
 else return nil
 end
end
--[[
PICO8 Base Functions
--]]
function _init()
 import('spritesheet.png')
 BACKGROUND=BLACK
 --DRAW=Map:init()
 BALL=Ball:init()
 cls(BACKGROUND)
 -- FIXME while loops would be nicer looking, replace with pico8 map prims
 local brickw=Brick.sprite.dimensions.r
 local brickh=Brick.sprite.dimensions.b
 for x=MIN,MAX,brickw do
  for y=MIN,MAX,brickh do
   local onscreen=(x>=MIN and x<MAX and y>=MIN and y<MAX)
   local onedge=(x==MIN or x==MAX-brickw or y==MIN or y==MAX-brickh)
   if onscreen and onedge then
    local brick=Brick:init(x,y)
    local hitbox=brick.sprite:box(x,y)
    --DRAW:put(x,y,ZERO,brick)
    brick.sprite:draw(x,y)
   end
  end
 end
end
function _update60() BALL.x+=BALL.dx BALL.y+=BALL.dy end
function _draw()
 -- FIXME clean up this experiement
 -- FIXME brick handle redraws at collisions
 local x=BALL.xprev
 while x<BALL.xprev+BALL.sprite.dimensions.r do
  local y=BALL.yprev
  while y<BALL.yprev+BALL.sprite.dimensions.b do
   if pget(x,y)!=GREEN then pset(x,y,BACKGROUND) end
   y+=ONE
  end
  x+=ONE
 end
 --rectfill(x0,y0,x1,y1,BLACK)
 local collisions={}
 local sx=(SIXTEEN-ONE)*CELL
 local px=BALL.x
 local dx=ZERO
 while dx<CELL do
  local sy=ZERO*CELL
  local py=BALL.y
  local dy=ZERO
  while dy<CELL do
   if pget(px+dx,py+dy)!=BACKGROUND then
    pset(px+dx,py+dy,GREEN)
    add(collisions,{x=px+dx,y=py+dy})
   else pset(px+dx,py+dy,sget(sx+dx,sy+dy)) end
   dy+=ONE
  end
  dx+=ONE
 end
 if count(collisions)!=ZERO then BALL:collide(collisions) end
 --BALL.sprite:draw(BALL.x,BALL.y)
 BALL.xprev=BALL.x BALL.yprev=BALL.y
 if DEBUG then
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
  rectfill(MIN,MIN,peek(CURSOR_X)+THREE*MAX/FOUR,peek(CURSOR_Y),BACKGROUND)
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
 end
end
