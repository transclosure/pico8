pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
Constants
--]]
FPS=7
CELL=8 MIN=0 MAX=128 FGZ=0
BLACK=0 DARKBLUE=1 PURPLE=2 DARKGREEN=3 BROWN=4 DARKGREY=5 LIGHTGREY=6 WHITE=7
RED=8 ORANGE=9 YELLOW=10 GREEN=11 BLUE=12 LAVENDER=13 PINK=14 PEACH=15
--[[
Sprite
--]]
Sprite={} Sprite.__index=Sprite
function Sprite:init(s,w,h)
 local sprite={}                   -- Sprite Object
 setmetatable(sprite,Sprite)       -- Sprite Instantiation
 sprite.s=s sprite.w=w sprite.h=h  -- Sprite dimensions in sheet
 return sprite
end
function Sprite:draw(x,y)
 spr(self.s, x, y, self.w, self.h)
end
Box={} Box.__index=Box
function Box:init(l,r,t,b)
 local box={}                -- Box Object
 setmetatable(box,Box)       -- Box Instantiation
 box.left=l box.right=r      -- Box x space
 box.top=t box.bottom=b      -- Box y space
 return box
end
function Sprite:box(x,y)
 -- DEBUG pico8 gives floats not ints on update calls
 return Box:init(flr(x),flr(x+self.w*CELL),flr(y),flr(y+self.h*CELL))
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
Ball
--]]
Ball={} Ball.__index=Ball
function Ball:init()
 local ball={}                   -- Ball Object
 setmetatable(ball,Ball)         -- Ball Instantiation
 ball.sprite=Sprite:init(13,1,1) -- Ball Sprite
 ball.x=MAX/2 ball.y=MAX/2       -- FIXME Ball random start
 ball.dx=1 ball.dy=1             -- Ball Physics
 return ball
end
function Ball:update()
 self.x+=self.dx
 self.y+=self.dy
 local collidebox=_collide(self)
 if collidebox.left>1 or collidebox.right>1 then self.dx*=-1 end
 if collidebox.top>1 or collidebox.bottom>1 then self.dy*=-1 end
end
--[[
PICO8
--]]
function _init()
 import('spritesheet.png')
 DRAW={}            -- Map Objects that don't update, just draw
 COLLIDE={}         -- Map Objects that don't update, but affect updates
 for x=MIN,MAX do   -- Screen width
  DRAW[x]={}        -- XXX Usability over Space Performance
  COLLIDE[x]={}     -- XXX Usability over Space Performance
  for y=MIN,MAX do  -- Screen height
   DRAW[x][y]={}    -- XXX Usability over Space Performance
   COLLIDE[x][y]={} -- XXX Usability over Space Performance
  end
 end
 -- FIXME abstract brick with predefined sprite dimensions
 for x=MIN,MAX,16 do                          -- Screen width by Brick width
  for y=MIN,MAX,8 do                          -- Screen height by Brick height
   local offscreen=(x==MAX or y==MAX)
   local onedge=(x==MIN or x==MAX-16 or y==MIN or y==MAX-8)
   if (not offscreen) and onedge then -- Screen Edges
    local brick=Brick:init(x,y)
    local bbox=brick.sprite:box(x,y)
    DRAW[x][y][FGZ]=brick              -- Gray Bricks to draw
    for xs=bbox.left,bbox.right do
     for ys=bbox.top,bbox.bottom do
      COLLIDE[xs][ys][FGZ]=brick         -- Gray Bricks hitboxes
     end
    end
   end
  end
 end
 BALL=Ball:init()
end
function _update()
 BALL:update()
end
function _draw()
 cls(BLACK)
 -- draw static (bricks)
 for x=MIN,MAX do                      -- Screen width
  for y=MIN,MAX do                     -- Screen height
   if DRAW[x][y][FGZ] then -- Screen depth
    DRAW[x][y][FGZ].sprite:draw(x,y)
   end
  end
 end
 BALL.sprite:draw(BALL.x,BALL.y)
 print(stat(FPS),YELLOW)
end
function _collide(obj)
 local hitbox=obj.sprite:box(obj.x,obj.y)
 local collidebox=Box:init(0,0,0,0) -- FIXME Box default arguments
 for y=hitbox.top,hitbox.bottom do
  if COLLIDE[hitbox.left][y][FGZ] then collidebox.left+=1 end
  if COLLIDE[hitbox.right][y][FGZ] then collidebox.right+=1 end
 end
 for x=hitbox.left,hitbox.right do
  if COLLIDE[x][hitbox.top][FGZ] then collidebox.top+=1 end
  if COLLIDE[x][hitbox.bottom][FGZ] then collidebox.bottom+=1 end
 end
 return collidebox
end
