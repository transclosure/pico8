pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
 msg="hello pico-8"
 x=40 y=64
 dx=1 dy=1
 -- load art assets (TODO hot swap sprite sheet, overloads currently)
 import('sprites/helloworld.png')
 import('sprites/jamie.png')
end

function _update()
 x+=dx y+=dy
 if x<1 or x>128-#msg*4 then
  dx*=-1
 elseif y<1 or y>127-5 then
  dy*=-1
 end
end

function _draw()
 cls(1)
 print(msg,x,y,8+dx+dy)
end
