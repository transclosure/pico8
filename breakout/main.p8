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
   setmetatable(sprite,Sprite)       -- Sprite Class lookup
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
   setmetatable(ball,Ball)         -- Ball Class lookup
   ball.x=rnd(127) ball.y=rnd(127) -- Ball random start pos
   ball.sprite=Sprite:init(13,1,1) -- Ball Sprite
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
PICO8 Functions
--]]
function _init()
 import(Sprite.sheet)
 ball = Ball:init()
end
function _update()
 ball:update()
end
function _draw()
 cls(0)
 ball:draw()
end
