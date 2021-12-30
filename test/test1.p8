pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
 x=40
 y=64
 dx=1
 dy=1
 import('spritesheet.png')
 w = 10
 h = 1
 s = 0
end

function _update()
 x+=dx
 y+=dy
 touchleft = x<1
 touchright = x>127-w*8
 touchup = y<1
 touchdown = y>127-h*8
 if touchleft or touchright then dx*=-1 end
 if touchup or touchdown then dy*=-1 end
end

function _draw()
 cls(1)
 spr(s, x, y, w, h)
end
