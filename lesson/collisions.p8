pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
Constants
--]]
ZERO=0 ONE=1 TWO=2 THREE=3 FOUR=4 FIVE=5 SIX=6 SEVEN=7 EIGHT=8
NINE=9 TEN=10 ELEVEN=11 TWELVE=12 THIRTEEN=13 FOURTEEN=14 FIFTEEN=15 SIXTEEN=16
CELL=8 MIN=0 MAX=128
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
PICO8 Base Functions
--]]
function _init()
 import('spritesheet.png')
 DRAW={}
 COLLIDE={}
 -- XXX Accessibility over Space Performance
 for x=MIN,MAX do
  DRAW[x]={}
  COLLIDE[x]={}
  for y=MIN,MAX do
   DRAW[x][y]={}
   COLLIDE[x][y]={}
  end
 end
 local brickw=Brick.sprite.dimensions.r
 local brickh=Brick.sprite.dimensions.b
 for x=MIN,MAX,brickw do
  for y=MIN,MAX,brickh do
   local onscreen=(x>=MIN and x<MAX and y>=MIN and y<MAX)
   local onedge=(x==MIN or x==MAX-brickw or y==MIN or y==MAX-brickh)
   if onscreen and onedge then
    local brick=Brick:init(x,y)
    local hitbox=brick.sprite:box(x,y)
    DRAW[x][y][ZERO]=brick
    for xs=hitbox.l,hitbox.r do
     for ys=hitbox.t,hitbox.b do
      COLLIDE[xs][ys][ZERO]=brick
     end
    end
   end
  end
 end
 BALL=Ball:init()
end
function _update()
 BALL:update()
end
function _draw()
 cls(BLACK)
 -- XXX Accessibility over Time Performance
 for x=MIN,MAX do
  for y=MIN,MAX do
   if DRAW[x][y][ZERO] then DRAW[x][y][ZERO].sprite:draw(x,y) end
  end
 end
 BALL.sprite:draw(BALL.x,BALL.y)
end
--[[
PICO8 Extended Functions
--]]
function _collide(obj)
 local hitbox=obj.sprite:box(obj.x,obj.y)
 local collidebox=Box:init()
 for y=hitbox.t,hitbox.b do
  if COLLIDE[hitbox.l][y][ZERO] then collidebox.l+=ONE end
  if COLLIDE[hitbox.r][y][ZERO] then collidebox.r+=ONE end
 end
 for x=hitbox.l,hitbox.r do
  if COLLIDE[x][hitbox.t][ZERO] then collidebox.t+=ONE end
  if COLLIDE[x][hitbox.b][ZERO] then collidebox.b+=ONE end
 end
 return collidebox
end
