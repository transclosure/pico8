pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
Constants
--]]
ZERO=0 ONE=1 TWO=2 THREE=3 FOUR=4 FIVE=5 SIX=6 SEVEN=7 EIGHT=8
NINE=9 TEN=10 ELEVEN=11 TWELVE=12 THIRTEEN=13 FOURTEEN=14 FIFTEEN=15 SIXTEEN=16
CELL=8 MIN=0 MAX=128 CURSOR_X=0x5f26 CURSOR_Y=0x5f27 BACKGROUND=BLACK EMPTY=ZERO
DEBUG=true MEM=0 TC=1 SCPU=2 DISP=3 CLIP=4 VER=5 PARAMS=6 FPS=7 TF=8
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
 sprite.dim=Pos:init({x=sprite.w*CELL,y=sprite.h*CELL})
 return sprite
end
function Sprite:box(pos)
 return Box:init({
  left=pos.x,right=pos.x+self.dim.x,
  top=pos.y,bottom=pos.y+self.dim.y})
end
--[[
Breakout Game
--]]
Brick={spr=Sprite:init({s=TEN-ONE,w=TWO,h=ONE})} Brick.__index=Brick
function Brick:init(pos)
 local brick = b or {}
 setmetatable(brick,Brick)
 mset(pos.x/CELL,pos.y/CELL,brick.spr.s)
 mset((pos.x+CELL)/CELL,pos.y/CELL,brick.spr.s+CELL/CELL)
end
function Brick:draw() map(MIN/CELL,MIN/CELL,MIN,MIN,MAX/CELL,MAX/CELL) end
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
function Ball:update()
 self.pos.x+=self.vel.x self.pos.y+=self.vel.y
 local collidebox=_collide(self)
 if collidebox.left>ONE or collidebox.right>ONE then self.vel.x*=-ONE end
 if collidebox.top>ONE or collidebox.bottom>ONE then self.vel.y*=-ONE end
end
function Ball:draw()
 local undraw=self.spr:box(self.posprev)
 rectfill(undraw.left,undraw.top,undraw.right,undraw.bottom,BACKGROUND)
 spr(self.spr.s,self.pos.x,self.pos.y,self.spr.w,self.spr.h)
 self.posprev.x=self.pos.x self.posprev.y=self.pos.y
end
--[[
PICO8 Base Functionality
--]]
function _init()
 import('spritesheet.png')
 cls(BACKGROUND)
 BALL=Ball:init()
 local bw=Brick.spr.dim.x local bh=Brick.spr.dim.y
 for x=MIN,MAX-bw,bw do
  for y=MIN,MAX-bh,bh do
   if x==MIN or x==MAX-bw or y==MIN or y==MAX-bh then
    Brick:init(Pos:init({x=x,y=y}))
   end
  end
 end
 Brick:draw()
end
function _update60() BALL:update() end
function _draw()
 BALL:draw()
 if DEBUG then
  print(stat(MEM).."\t"..stat(TC).."\t"..stat(FPS).."/"..stat(TF),MIN,MIN,PINK)
  rectfill(MIN,MIN,peek(CURSOR_X)+TWO*MAX/THREE,peek(CURSOR_Y)-ONE,BACKGROUND)
  print(stat(MEM).."\t"..stat(TC).."\t"..stat(FPS).."/"..stat(TF),MIN,MIN,PINK)
 end
end
--[[
PICO8 Extended Functionality
--]]
function _collide(obj)
 local hitbox=obj.spr:box(obj.pos)
 local collide=Box:init()
 for y=hitbox.top,hitbox.bottom do
  if mget((hitbox.left-ONE)/CELL,y/CELL)!=EMPTY then collide.left+=ONE end
  if mget((hitbox.right+ONE)/CELL,y/CELL)!=EMPTY then collide.right+=ONE end
 end
 for x=hitbox.left,hitbox.right do
  if mget(x/CELL,(hitbox.top-ONE)/CELL)!=EMPTY then collide.top+=ONE end
  if mget(x/CELL,(hitbox.bottom+ONE)/CELL)!=EMPTY then collide.bottom+=ONE end
 end
 return collide
end
