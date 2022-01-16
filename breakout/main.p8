pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
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
function Ball:update()
 -- TODO replace with 2d array collision lookup
 self.x+=self.dx
 self.y+=self.dy
 local touchleft = self.x<1
 local touchright = self.x>127-self.sprite.w*8
 local touchup = self.y<1
 local touchdown = self.y>127-self.sprite.h*8
 if touchleft or touchright then self.dx*=-1 end
 if touchup or touchdown then self.dy*=-1 end
end
--[[
Brick
--]]
Brick={} Brick.__index=Brick
function Brick:init(x,y)
 -- TODO support multiple colors / game logic
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
 local map={}          -- Map Object
 setmetatable(map,Map) -- Map Instantiation
 map.static={}         -- Map Objects that don't update, just draw
 for x=0,127 do        -- Screen width
  map.static[x]={}     -- XXX Usability over Space Performance
  for y=0,127 do       -- Screen height
   map.static[x][y]={} -- XXX Usability over Space Performance
  end
 end
 map.dynamic={}        -- Map Objects that do update, also draw
 return map
end
function Map:load()
 -- load static (bricks)
 for x=0,127,16 do                          -- Screen width by Brick width
  for y=0,127,8 do                          -- Screen height by Brick height
   if x==0 or x==112 or y==0 or y==120 then -- Screen Edges
    self.static[x][y][0]=Brick:init(x,y)    -- Gray Bricks
   end
   -- TODO other colors
  end
 end
 -- load dynamic (ball)
 add(self.dynamic,Ball:init())
end
function Map:update()
 -- update dynamic (ball)
 for obj in all(self.dynamic) do
  obj:update()
 end
end
function Map:draw()
 -- draw static (bricks)
 for x=0,127 do                      -- Screen width
  for y=0,127 do                     -- Screen height
   if self.static[x][y][0]!=nil then -- Screen Depth
    self.static[x][y][0].sprite:draw(x,y)
   end
  end
 end
 -- draw dynamic (ball)
 for obj in all(self.dynamic) do
  obj.sprite:draw(obj.x,obj.y)
 end
end
-- TODO get objects in pixel space
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
