pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- FIXME remove all magic numbers
--[[
Position
--]]
Pos={} Pos.__index=Pos
function Pos:init(l,r,t,b)
 local pos={}                -- Position Object
 setmetatable(pos,Pos)       -- Position Instantiation
 pos.left=l pos.right=r      -- Position x space
 pos.top=t pos.bottom=b      -- Position y space
 return pos
end
--[[
Sprite
--]]
Sprite={} Sprite.__index=Sprite
Sprite.sheet='spritesheet.png'
function Sprite:init(s,w,h)
 local sprite={}                   -- Sprite Object
 setmetatable(sprite,Sprite)       -- Sprite Instantiation
 sprite.s=s sprite.w=w sprite.h=h  -- Sprite dimensions in sheet
 return sprite
end
function Sprite:pos(x,y)
 -- DEBUG pico8 gives floats not ints on update calls
 return Pos:init(flr(x),flr(x+(self.w*8)-1),flr(y),flr(y+(self.h*8)-1))
end
function Sprite:draw(x,y)
 spr(self.s, x, y, self.w, self.h)
end
--[[
Ball
--]]
Ball={} Ball.__index=Ball
function Ball:init()
 local ball={}                       -- Ball Object
 setmetatable(ball,Ball)             -- Ball Instantiation
 ball.sprite=Sprite:init(13,1,1)     -- Ball Sprite
 ball.x=rnd(127-8) ball.y=rnd(127-8) -- Ball random start pos
 ball.dx=1 ball.dy=1                 -- Ball Physics
 return ball
end
function Ball:update(map)
 self.x+=self.dx
 self.y+=self.dy
 local objs=map:collides(self.sprite:pos(self.x,self.y))
 if count(objs)>0 then -- TODO update velocity correctly
  self.dx=0
  self.dy=0
 end
end
--[[
Brick
--]]
Brick={} Brick.__index=Brick
function Brick:init(x,y)
 local brick={}                   -- Brick Object
 setmetatable(brick,Brick)        -- Brick Instantiation
 brick.sprite=Sprite:init(24,2,1) -- Brick Sprite
 return brick
end
--[[
Map
--]]
Map={} Map.__index=Map
function Map:init()
 local map={}           -- Map Object
 setmetatable(map,Map)  -- Map Instantiation
 map.dynamic={}         -- Map Objects that do update, also draw
 map.static={}          -- Map Objects that don't update, just draw
 map.collide={}         -- Map Objects that don't update, but affect updates
 for x=0,127 do         -- Screen width
  map.static[x]={}      -- XXX Usability over Space Performance
  map.collide[x]={}     -- XXX Usability over Space Performance
  for y=0,127 do        -- Screen height
   map.static[x][y]={}  -- XXX Usability over Space Performance
   map.collide[x][y]={} -- XXX Usability over Space Performance
  end
 end
 return map
end
function Map:load()
 -- load dynamic (ball)
 add(self.dynamic,Ball:init())
 -- load static/collide (bricks)
 for x=0,127,16 do                          -- Screen width by Brick width
  for y=0,127,8 do                          -- Screen height by Brick height
   if x==0 or x==112 or y==0 or y==120 then -- Screen Edges
    local brick=Brick:init(x,y)
    local bpos=brick.sprite:pos(x,y)
    self.static[x][y][0]=brick              -- Gray Bricks to draw
    for xs=bpos.left,bpos.right do
     for ys=bpos.top,bpos.bottom do
      self.collide[xs][ys][0]=brick         -- Gray Bricks hitboxes
     end
    end
   end
  end
 end
end
function Map:update()
 -- update dynamic (ball)
 for obj in all(self.dynamic) do
  obj:update(self)
 end
end
function Map:draw()
 -- draw static (bricks)
 for x=0,127 do                      -- Screen width
  for y=0,127 do                     -- Screen height
   if self.static[x][y][0]!=nil then -- Screen depth
    self.static[x][y][0].sprite:draw(x,y)
   end
  end
 end
 -- draw dynamic (ball)
 for obj in all(self.dynamic) do
  obj.sprite:draw(obj.x,obj.y)
 end
end
function Map:collides(pos)
 -- TODO pass back position object with # collisions on each of the 4 sides
 local collides={}
 for x=pos.left,pos.right do          -- hitbox width
  for y=pos.top,pos.bottom do         -- hitbox height
   if self.collide[x][y][0]!=nil then -- hitbox depth
    add(collides,self.collide[x][y][0])
   end
  end
 end
 return collides
end
--[[
PICO8 Functions
--]]
function _init()
 import(Sprite.sheet)
 map = Map:init()
 map:load()
end
function _update()
 map:update()
end
function _draw()
 cls(0)
 map:draw()
 print(stat(7),3)
end
