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
Data Structures
--]]
Map={} Map.__index=Map
function Map:init() return setmetatable({},Map) end
function Map:put(x,y,v)
 if not self[x] then self[x]={} end
 self[x][y]=v
end
function Map:get(x,y)
 if self[x] then return self[x][y]
 else return nil end
end
Set={} Set.__index=Set
function Set:init() return setmetatable({map=Map.init()},Set) end
function Set:add(pos) self.map:put(pos.x,pos.y,true) end
function Set:all()
 local set={}
 for x,ys in pairs(self.map) do
  for y,v in pairs(ys) do
   add(set,Pos:init({x=x,y=y}))
  end
 end
 return set
end
--[[
Dimensional Utilities
--]]
Pos={x=ZERO,y=ZERO} Pos.__index=Pos
function Pos:init(p)
 local pos = p or {}
 setmetatable(pos,Pos)
 pos.x=flr(pos.x) pos.y=flr(pos.y)
 return pos
end
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
function Sprite:box(pos,border)
 return Box:init({
  left=pos.x-border,right=pos.x+self.dim.x-ONE+border,
  top=pos.y-border,bottom=pos.y+self.dim.y-ONE+border})
end
--[[
Breakout Game
--]]
Brick={spr=Sprite:init({s=TEN-ONE,w=TWO,h=ONE}),inplay=ONE}
Brick.__index=Brick
function Brick:init(pos,inplay)
 local brick = b or {}
 setmetatable(brick,Brick)
 if inplay then
  brick.spr=Sprite:init({s=Brick.inplay,w=Brick.spr.w,h=Brick.spr.h})
 end
 mset(pos.x/CELL,pos.y/CELL,brick.spr.s)
 mset((pos.x+CELL)/CELL,pos.y/CELL,brick.spr.s+CELL/CELL)
end
function Brick:update(cells)
 -- XXX cells -> bricks... need object mapping framework
 bricks=Set:init()
 for cell in all(cells) do
  cell.x=flr(cell.x/Brick.spr.w)*Brick.spr.w
  bricks:add(Pos:init({x=cell.x,y=cell.y}))
 end
 -- XXX with object mapping, updating brick states should be cleaner than this
 for brick in all(bricks:all()) do
  local bricks=mget(brick.x,brick.y)
  if bricks!=Brick.spr.s then
   newbricks=mget(brick.x,brick.y)+TWO
   if newbricks==Brick.spr.s then
    mset(brick.x,brick.y,EMPTY)
    mset(brick.x+ONE,brick.y,EMPTY)
    local undraw=Brick.spr:box(Pos:init({x=brick.x*CELL,y=brick.y*CELL}),ZERO)
    rectfill(undraw.left,undraw.top,undraw.right,undraw.bottom,BACKGROUND)
   else
    mset(brick.x,brick.y,mget(brick.x,brick.y)+TWO)
    mset(brick.x+ONE,brick.y,mget(brick.x+ONE,brick.y)+TWO)
    map(brick.x,brick.y,brick.x*CELL,brick.y*CELL,Brick.spr.w,Brick.spr.h)
   end
  end
 end
end
function Brick:draw()
 map(MIN/CELL,MIN/CELL,MIN,MIN,MAX/CELL,MAX/CELL)
end
Ball={spr=Sprite:init({s=SIXTEEN-ONE,w=ONE,h=ONE}),vel=Pos:init({x=ONE,y=ONE})}
Ball.__index=Ball
function Ball:init()
 local ball={}
 setmetatable(ball,Ball)
 ball.pos=Box:init({
  left=MAX*ONE/FIVE,right=MAX*FOUR/FIVE,
  top=MAX*THREE/SIX,bottom=MAX*FOUR/SIX}):randpos()
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
 local undraw=self.spr:box(self.posprev,ZERO)
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
    Brick:init(Pos:init({x=x,y=y}),false)
   else
    if y<MAX-bh*EIGHT then
     Brick:init(Pos:init({x=x,y=y}),true)
    end
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
 local hitbox=obj.spr:box(obj.pos,ONE)
 local collidebox=Box:init()
 -- XXX pixels->cells/CELL bleeding out of sprite... need object mapping
 local collidecells=Set:init()
 for y=hitbox.top,hitbox.bottom do
  local leftcell=Pos:init({x=hitbox.left/CELL,y=y/CELL})
  if mget(leftcell.x,leftcell.y)!=EMPTY then
   collidebox.left+=ONE
   collidecells:add(leftcell)
  end
  local rightcell=Pos:init({x=hitbox.right/CELL,y=y/CELL})
  if mget(rightcell.x,rightcell.y)!=EMPTY then
   collidebox.right+=ONE
   collidecells:add(rightcell)
  end
 end
 for x=hitbox.left,hitbox.right do
  local topcell=Pos:init({x=x/CELL,y=hitbox.top/CELL})
  if mget(topcell.x,topcell.y)!=EMPTY then
   collidebox.top+=ONE
   collidecells:add(topcell)
  end
  local bottomcell=Pos:init({x=x/CELL,y=hitbox.bottom/CELL})
  if mget(bottomcell.x,bottomcell.y)!=EMPTY then
   collidebox.bottom+=ONE
   collidecells:add(bottomcell)
  end
 end
 local collidecells=collidecells:all()
 if count(collidecells)!=EMPTY then Brick:update(collidecells) end
 return collidebox
end
