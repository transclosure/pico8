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
function Ball:update()
 self.x+=self.dx self.y+=self.dy
 local collidebox=_collide(self)
 if collidebox.l>ONE or collidebox.r>ONE then self.dx*=-ONE end
 if collidebox.t>ONE or collidebox.b>ONE then self.dy*=-ONE end
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
 FIRSTDRAW=true
 DRAW=Map:init()
 COLLIDE=Map:init()
 local brickw=Brick.sprite.dimensions.r
 local brickh=Brick.sprite.dimensions.b
 for x=MIN,MAX,brickw do
  for y=MIN,MAX,brickh do
   local onscreen=(x>=MIN and x<MAX and y>=MIN and y<MAX)
   local onedge=(x==MIN or x==MAX-brickw or y==MIN or y==MAX-brickh)
   if onscreen and onedge then
    local brick=Brick:init(x,y)
    local hitbox=brick.sprite:box(x,y)
    DRAW:put(x,y,ZERO,brick)
    for xs=hitbox.l,hitbox.r do
     for ys=hitbox.t,hitbox.b do
      COLLIDE:put(xs,ys,ZERO,brick)
     end
    end
   end
  end
 end
 BALL=Ball:init()
end
function _update60()
 BALL:update()
end
function _draw()
 if FIRSTDRAW then
  cls(BACKGROUND)
  for x=MIN,MAX do
   for y=MIN,MAX do
    local obj = DRAW:get(x,y,ZERO)
    if obj then obj.sprite:draw(x,y) end
   end
  end
  FIRSTDRAW=false
 end
 local xd=BALL.sprite.dimensions.r
 local yd=BALL.sprite.dimensions.b
 local x0=min(BALL.xprev,BALL.x)
 local y0=min(BALL.yprev,BALL.y)
 local x1=max(BALL.xprev,BALL.x)+xd-ONE
 local y1=max(BALL.yprev,BALL.y)+yd-ONE
 rectfill(x0,y0,x1,y1,BLACK)
 BALL.sprite:draw(BALL.x,BALL.y)
 BALL.xprev=BALL.x BALL.yprev=BALL.y
 if DEBUG then
  print(stat(MEM).."\n"..stat(TCPU).."\n"..stat(FPS).."|"..stat(TFPS),MIN,MIN,PINK)
  rectfill(MIN,MIN,peek(CURSOR_X)+MAX/THREE,peek(CURSOR_Y),BACKGROUND)
  print(stat(MEM).."\n"..stat(TCPU).."\n"..stat(FPS).."|"..stat(TFPS),MIN,MIN,PINK)
 end
end
--[[
PICO8 Extended Functions
--]]
function _collide(obj)
 local hitbox=obj.sprite:box(obj.x,obj.y)
 local collidebox=Box:init()
 for y=hitbox.t,hitbox.b do
  if COLLIDE:get(hitbox.l,y,ZERO) then collidebox.l+=ONE end
  if COLLIDE:get(hitbox.r,y,ZERO) then collidebox.r+=ONE end
 end
 for x=hitbox.l,hitbox.r do
  if COLLIDE:get(x,hitbox.t,ZERO) then collidebox.t+=ONE end
  if COLLIDE:get(x,hitbox.b,ZERO) then collidebox.b+=ONE end
 end
 return collidebox
end
