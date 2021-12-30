pico-8 cartridge // http://www.pico-8.com
version 34
__lua__

-- Sprite Abstraction
Sprite={} Sprite.__index=Sprite
Sprite.sheet='spritesheet.png'
function Sprite:init(s,w,h,x,y,dx,dy)
   local sprt = {}           -- our object object
   setmetatable(sprt,Sprite) -- make Sprite class lookup
   -- initialize our sprite object
   sprt.s=s sprt.w=w sprt.h=h               -- sprite dimensions in sheet
   sprt.x=x sprt.y=y sprt.dx=dx sprt.dy=dy  -- in-game position/velocity
   return sprt
end
function Sprite:update()
 self.x+=self.dx
 self.y+=self.dy
 local touchleft = self.x<1
 local touchright = self.x>127-self.w*8
 local touchup = self.y<1
 local touchdown = self.y>127-self.h*8
 if touchleft or touchright then self.dx*=-1 end
 if touchup or touchdown then self.dy*=-1 end
end
function Sprite:draw()
 spr(self.s, self.x, self.y, self.w, self.h)
end

-- PICO8 Functions
function _init()
 import(Sprite.sheet)
 spriteA = Sprite:init(0,10,1,40,64,1,1)
 spriteB = Sprite:init(52,9,9,20,32,1,1)
end
function _update()
 spriteA:update()
 spriteB:update()
end
function _draw()
 cls(1)
 spriteA:draw()
 spriteB:draw()
end
