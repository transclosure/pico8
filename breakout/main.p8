pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
Constants
--]]
ZERO=0 ONE=1 TWO=2 THREE=3 FOUR=4 FIVE=5 SIX=6 SEVEN=7 EIGHT=8
NINE=9 TEN=10 ELEVEN=11 TWELVE=12 THIRTEEN=13 FOURTEEN=14 FIFTEEN=15 SIXTEEN=16
CELL=8 MIN=0 MAX=128 CURSOR_X=0x5f26 CURSOR_Y=0x5f27
DEBUG=true MEM=0 TC=1 SCPU=2 DISP=3 CLIP=4 VER=5 PARAMS=6 FPS=7 TF=8
BLACK=0 DARKBLUE=1 PURPLE=2 DARKGREEN=3 BROWN=4 DARKGREY=5 LIGHTGREY=6 WHITE=7
RED=8 ORANGE=9 YELLOW=10 GREEN=11 BLUE=12 LAVENDER=13 PINK=14 PEACH=15
BACKGROUND=BLACK EMPTY=ZERO
--[[
Positions, Boxes, Sprites
--]]
Pos={x=ZERO,y=ZERO} Pos.__index=Pos
function Pos:init(p) return setmetatable(p or {},Pos) end
Box={left=ZERO,right=ZERO,top=ZERO,bottom=ZERO} Box.__index=Box
function Box:init(b) return setmetatable(b or {},Box) end
function Box:randpos()
 return Pos:init({
  x=self.left+rnd(self.right-self.left),
  y=self.top+rnd(self.bottom-self.top)})
end
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
Object Map (Positions<->Cells<->Objects)
--]]
Map={updates={},draws={}} Map.__index=Map
function Map:init() return setmetatable({},Map) end
function Map:put(obj,add_else_del)
 local celli=flr(obj.pos.y/CELL)
 local cellj=flr(obj.pos.x/CELL)
 local i=ZERO
 while i<obj.spr.h do
  local j=ZERO
  while j<obj.spr.w do
   local s = add_else_del and obj.spr.s+j+(i*SIXTEEN) or EMPTY
   local o = add_else_del and obj or nil
   mset(cellj+j,celli+i,s)
   if not self[celli] then self[celli]={} end
   self[celli+i][cellj+j]=o
   j+=ONE
  end
  i+=ONE
 end
 add(self.draws,{
  celx=cellj,cely=celli,
  sx=cellj*CELL,sy=celli*CELL,
  celw=obj.spr.w,celh=obj.spr.h})
end
function Map:get(pos)
 local celli=flr(pos.y/CELL)
 local cellj=flr(pos.x/CELL)
 if self[celli] then return self[celli][cellj]
 else return nil end
end
function Map:schedule(poss)
 local objs={}
 for pos in all(poss) do
  local obj=self:get(pos)
  if obj then
   self:put(obj,false)
   add(objs,obj)
  end
 end
 for obj in all(objs) do
  self:put(obj,true)
  add(self.updates,obj)
 end
end
function Map:update()
 for obj in all(self.updates) do obj:update() end
 self.updates={}
end
function Map:draw()
 for d in all(self.draws) do
  rectfill(d.sx,d.sy,(d.sx+d.celw*CELL)-ONE,(d.sy+d.celh*CELL)-ONE,BACKGROUND)
  map(d.celx,d.cely,d.sx,d.sy,d.celw,d.celh)
 end
 self.draws={}
end
--[[
Breakout Game
--]]
Brick={spr=Sprite:init({s=TEN-ONE,w=TWO,h=ONE}),play=false}
Brick.__index=Brick
function Brick:init(b)
 local brick = b or {}
 setmetatable(brick,Brick)
 if brick.play then -- FIXME bad sprite change needs data structure
  brick.spr=Sprite:init({s=ONE,w=Brick.spr.w,h=Brick.spr.h})
 end
 MAP:put(brick,true) -- XXX who adds the brick, self or init caller?
 return brick
end
function Brick:update()
 if self.play then
  self.spr.s+=TWO -- FIXME bad sprite change needs data structure
  if self.spr.s!=Brick.spr.s then MAP:put(self,true)
  else MAP:put(self,false) end
 else MAP:put(self,true) end -- XXX who adds the brick, self or init caller?
end
Ball={spr=Sprite:init({s=SIXTEEN-ONE,w=ONE,h=ONE}),v=THREE}
Ball.__index=Ball
function Ball:init()
 local ball={}
 setmetatable(ball,Ball)
 assert(Ball.v<EIGHT)
 ball.d=Pos:init({x=Ball.v,y=Ball.v})
 ball.pos=Box:init({
  left=MAX*ONE/FIVE,right=MAX*FOUR/FIVE,
  top=MAX*THREE/SIX,bottom=MAX*FOUR/SIX}):randpos()
 ball.posprev=Pos:init({x=ball.pos.x,y=ball.pos.y})
 return ball
end
function Ball:update()
 local collidebox=_collide(self)
 if collidebox.left>Ball.v or collidebox.right>Ball.v then self.d.x*=-ONE end
 if collidebox.top>Ball.v or collidebox.bottom>Ball.v then self.d.y*=-ONE end
 self.pos.x+=self.d.x self.pos.y+=self.d.y
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
 MAP=Map:init()
 BALL=Ball:init()
 local bw=Brick.spr.dim.x local bh=Brick.spr.dim.y
 for x=MIN,MAX-bw,bw do
  for y=MIN,MAX-bh,bh do
   if x==MIN or x==MAX-bw or y==MIN or y==MAX-bh then
    Brick:init({pos=Pos:init({x=x,y=y})})
   else
    if y<MAX-bh*EIGHT then
     Brick:init({pos=Pos:init({x=x,y=y}),play=true})
    end
   end
  end
 end
end
function _update60()
 BALL:update()
 MAP:update()
end
function _draw()
 BALL:draw()
 MAP:draw()
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
 local collisions={}
 for y=hitbox.top,hitbox.bottom do
  local leftpos=Pos:init({x=hitbox.left,y=y})
  if MAP:get(leftpos) then
   collidebox.left+=ONE
   add(collisions,leftpos)
  end
  local rightpos=Pos:init({x=hitbox.right,y=y})
  if MAP:get(rightpos) then
   collidebox.right+=ONE
   add(collisions,rightpos)
  end
 end
 for x=hitbox.left,hitbox.right do
  local toppos=Pos:init({x=x,y=hitbox.top})
  if MAP:get(toppos) then
   collidebox.top+=ONE
   add(collisions,toppos)
  end
  local bottompos=Pos:init({x=x,y=hitbox.bottom})
  if MAP:get(bottompos) then
   collidebox.bottom+=ONE
   add(collisions,bottompos)
  end
 end
 if count(collisions)!=EMPTY then MAP:schedule(collisions) end
 return collidebox
end
