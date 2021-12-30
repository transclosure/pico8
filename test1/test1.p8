pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
 x=40
 y=64
 dx=1
 dy=1
 import('sprites/helloworld.png')
 w = 10
 h = 1
end

function _update()
 x+=dx
 y+=dy
 touchleft = x<1
 touchright = x>128-w*8
 touchup = y<1
 touchdown = y>128-h*8
 if touchleft or touchright then dx*=-1
 elseif touchup or touchdown then dy*=-1
 end
end

function _draw()
 cls(1)
 spr(1, x, y, w, h)
end
