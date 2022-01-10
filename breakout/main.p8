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
 local ball={}                   -- Ball Object
 setmetatable(ball,Ball)         -- Ball Instantiation
 ball.sprite=Sprite:init(13,1,1) -- Ball Sprite
 ball.x=rnd(127-8) ball.y=rnd(127-8) -- Ball random start pos
 ball.dx=1 ball.dy=1             -- Ball Physics
 return ball
end
function Ball:update()
 self.x+=self.dx
 self.y+=self.dy
 local touchleft = self.x<1
 local touchright = self.x>127-self.sprite.w*8
 local touchup = self.y<1
 local touchdown = self.y>127-self.sprite.h*8
 if touchleft or touchright then self.dx*=-1 end
 if touchup or touchdown then self.dy*=-1 end
end
function Ball:draw()
 self.sprite:draw(self.x,self.y)
end
--[[
Brick
--]]
BrickMap={} -- FIXME use pico8 map editor not our own code
Pos={} Pos.__index=Pos
function Pos:init(x,y)
 local pos={}
 setmetatable(pos,Pos)
 pos.x=x pos.y=y
 return pos
end
Brick={} Brick.__index=Brick
function Brick:init(x,y)
 local brick={}                   -- Brick Object
 setmetatable(brick,Brick)        -- Brick Instantiation
 brick.sprite=Sprite:init(24,2,1) -- Brick Sprite
 local pos=Pos:init(x,y)          -- Brick position
 brick.pos=pos
 add(BrickMap,brick) -- TODO index by position
 return brick
end
function Brick:draw()
 self.sprite:draw(self.pos.x,self.pos.y)
end
--[[
PICO8 Functions
--]]
function _init()
 import(Sprite.sheet)
 ball = Ball:init()
 for y=0,127,8 do
  Brick:init(0-14,y)   -- touchleft bricks
  Brick:init(127-2,y) -- touchright bricks
 end
 for x=0,127,16 do
  Brick:init(x,0-6)   -- touchup bricks
  Brick:init(x,127-2) -- touchdown bricks
 end
end
function _update()
 ball:update()
end
function _draw()
 cls(0)
 ball:draw()
 for brick in all(BrickMap) do
  brick:draw()
 end
end
