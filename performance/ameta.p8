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
BACKGROUND=BLACK COLLISION=WHITE
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
Brick={spr=Sprite:init({s=TEN-ONE,w=TWO,h=ONE})} Brick.__index=Brick
function Brick:init(b) return setmetatable(b or {},Brick) end
function Brick:draw(poss)
 for pos in all(poss) do
  map(flr(pos.x/CELL),flr(pos.y/CELL),
      flr(pos.x/CELL)*CELL,flr(pos.y/CELL)*CELL,
      Brick.spr.w,Brick.spr.h)
 end
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
 ball.collisions={}
 ball.bounced=false
 return ball
end
function Ball:undraw()
 local x=self.posprev.x while x<self.posprev.x+self.spr.dim.x do
  local y=self.posprev.y while y<self.posprev.y+self.spr.dim.y do
   if pget(x,y)!=COLLIDE then pset(x,y,BACKGROUND) end
   y+=ONE
  end
  x+=ONE
 end
end
function Ball:redraw()
 local sx=self.spr.spos.x local px=self.pos.x
 local dx=ZERO while dx<self.spr.dim.x do
  local sy=self.spr.spos.y local py=self.pos.y
  local dy=ZERO while dy<self.spr.dim.y do
   if pget(px+dx,py+dy)!=BACKGROUND then
    pset(px+dx,py+dy,COLLISION)
    add(self.collisions,Pos:init({x=px+dx,y=py+dy}))
   else pset(px+dx,py+dy,sget(sx+dx,sy+dy)) end
   dy+=ONE
  end
  dx+=ONE
 end
end
function Ball:collide()
 local collidebox=Box:init()
 for pos in all(self.collisions) do
  if pos.x==self.pos.x                    then collidebox.left+=ONE end
  if pos.x==self.pos.x+self.spr.dim.x-ONE then collidebox.right+=ONE end
  if pos.y==self.pos.y                    then collidebox.top+=ONE end
  if pos.y==self.pos.y+self.spr.dim.y-ONE then collidebox.bottom+=ONE end
 end
 if collidebox.left>ONE or collidebox.right>ONE then BALL.vel.x*=-ONE end
 if collidebox.top>ONE or collidebox.bottom>ONE then BALL.vel.y*=-ONE end
end
--[[
PICO8 Base Functionality
--]]
function _init()
 import('spritesheet.png')
 cls(BACKGROUND)
 BALL=Ball:init()
 local bw=Brick.spr.dim.x local bh=Brick.spr.dim.y
 local x=MIN/CELL while x<MAX/CELL do
  local y=MIN/CELL while y<MAX/CELL do
   if x==MIN/CELL or x==(MAX-bw)/CELL or y==MIN/CELL or y==(MAX-bh)/CELL then
    local bi=0 while bi<bw/CELL do
     mset(x+bi,y,Brick.spr.s+bi)
     bi+=ONE
    end
    Brick:draw({Pos:init({x=x*CELL,y=y*CELL})})
   end
   y+=bh/CELL
  end
  x+=bw/CELL
 end
end
function _update60()
 if (not BALL.bounced) then
  BALL:collide()
  BALL.pos.x+=BALL.vel.x BALL.pos.y+=BALL.vel.y
  BALL.bounced=true
 end
end
function _draw()
 BALL:undraw() Brick:draw(BALL.collisions)
 BALL.collisions={}
 BALL:redraw()
 BALL.bounced=false BALL.posprev.x=BALL.pos.x BALL.posprev.y=BALL.pos.y
 if DEBUG then
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
  rectfill(MIN,MIN,peek(CURSOR_X)+THREE*MAX/FOUR,peek(CURSOR_Y),BACKGROUND)
  print(stat(MEM).."..."..stat(TCPU).."..."..stat(FPS).."/"..stat(TFPS),MIN,MIN,PINK)
 end
end
