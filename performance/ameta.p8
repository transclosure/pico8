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
Dimensional Utilities
--]]
Pos={x=ZERO,y=ZERO} Pos.__index=Pos
function Pos:init(p) return setmetatable(p or {},Pos) end
Box={left=ZERO,right=ZERO,top=ZERO,bottom=ZERO} Box.__index=Box
function Box:init(b) return setmetatable(b or {},Box) end
function Box:randpos()
 return Pos:init({
  x=flr(self.left+rnd(self.right-self.left)),
  y=flr(self.top+rnd(self.bottom-self.top))})
end
--[[
Sprites and Hitboxes
--]]
Sprite={s=ZERO,w=ONE,h=ONE,dim=Pos:init()} Sprite.__index=Sprite
function Sprite:init(s)
 local sprite = s or {}
 setmetatable(sprite,Sprite)
 sprite.spos=Pos:init({x=(sprite.s%SIXTEEN)*CELL,y=flr(sprite.s/SIXTEEN)*CELL})
 sprite.dim=Pos:init({x=sprite.w*CELL,y=sprite.h*CELL})
 return sprite
end
function Sprite:hitbox(pos)
 return Box:init({
  left=pos.x,right=pos.x+self.spr.dim.x,
  top=pos.y,bottom=pos.y+self.spr.dim.y})
end
--[[
Breakout Game
--]]
Brick={spr=Sprite:init({s=TEN-ONE,w=TWO,h=ONE}),pos=Pos:init()}
Brick.__index=Brick
function Brick:init(b) return setmetatable(b or {},Brick) end
function Brick:draw()
 spr(self.spr.s, self.pos.x, self.pos.y, self.spr.w, self.spr.h)
end
Ball={spr=Sprite:init({s=SIXTEEN-ONE,w=ONE,h=ONE}),vel=Pos:init({x=ONE,y=ONE})}
Ball.__index=Ball
function Ball:init()
 local ball={}
 setmetatable(ball,Ball)
 ball.pos=Box:init({
  left=MAX*ONE/FIVE,right=MAX*FOUR/FIVE,
  top=MAX*ONE/FIVE,bottom=MAX*THREE/FIVE}):randpos()
 ball.posprev=Pos:init({x=ball.pos.x,y=ball.pos.y})
 return ball
end
function Ball:undraw()
 local x=self.posprev.x while x<self.posprev.x+self.spr.dim.x do
  local y=self.posprev.y while y<self.posprev.y+self.spr.dim.y do
   if pget(x,y)!=GREEN then pset(x,y,BACKGROUND)
   else
    -- FIXME redraw pico8 map cells
   end
   y+=ONE
  end
  x+=ONE
 end
end
function Ball:redraw()
 local collisions={}
 local sx=self.spr.spos.x local px=self.pos.x
 local dx=ZERO while dx<self.spr.dim.x do
  local sy=self.spr.spos.y local py=self.pos.y
  local dy=ZERO while dy<self.spr.dim.y do
   if pget(px+dx,py+dy)!=BACKGROUND then
    pset(px+dx,py+dy,GREEN)
    add(collisions,Pos:init({x=px+dx,y=py+dy}))
   else pset(px+dx,py+dy,sget(sx+dx,sy+dy)) end
   dy+=ONE
  end
  dx+=ONE
 end
 if count(collisions)!=ZERO then self:collide(collisions) end
 self.posprev.x=self.pos.x self.posprev.y=self.pos.y
end
function Ball:collide(poss)
 local collidebox=Box:init()
 for pos in all(poss) do
  if pos.x==self.pos.x                    then collidebox.left+=ONE end
  if pos.x==self.pos.x+self.spr.dim.x-ONE then collidebox.right+=ONE end
  if pos.y==self.pos.y                    then collidebox.top+=ONE end
  if pos.y==self.pos.y+self.spr.dim.y-ONE then collidebox.bottom+=ONE end
 end
 if collidebox.left>ONE or collidebox.right>ONE then BALL.vel.x*=-ONE end
 if collidebox.top>ONE or collidebox.bottom>ONE then BALL.vel.y*=-ONE end
end
--[[
FIXME replace with pico8 map prims
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
PICO8 Base Functionality
--]]
function _init()
 import('spritesheet.png')
 BACKGROUND=BLACK
 BALL=Ball:init()
 cls(BACKGROUND)
 local brickw=Brick.spr.dim.x local brickh=Brick.spr.dim.y
 local x=MIN while x<MAX do
  local y=MIN while y<MAX do
   if x==MIN or x==MAX-brickw or y==MIN or y==MAX-brickh then
    Brick:init({pos=Pos:init({x=x,y=y})}):draw()
   end
   y+=brickh
  end
  x+=brickw
 end
end
function _update60() BALL.pos.x+=BALL.vel.x BALL.pos.y+=BALL.vel.y end
function _draw()
 BALL:undraw()
 BALL:redraw()
 if DEBUG then
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
  rectfill(MIN,MIN,peek(CURSOR_X)+THREE*MAX/FOUR,peek(CURSOR_Y),BACKGROUND)
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
 end
end
