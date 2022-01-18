pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- FIXME remove all magic numbers
--[[
Box
--]]
Box={} Box.__index=Box
function Box:init(l,r,t,b)
 local box={}                -- Box Object
 setmetatable(box,Box)       -- Box Instantiation
 box.left=l box.right=r      -- Box x space
 box.top=t box.bottom=b      -- Box y space
 return box
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
function Sprite:box(x,y)
 -- DEBUG pico8 gives floats not ints on update calls
 return Box:init(flr(x),flr(x+(self.w*8)-1),flr(y),flr(y+(self.h*8)-1))
end
function Sprite:draw(x,y)
 spr(self.s, x, y, self.w, self.h)
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
 local ball={}                                         -- Ball Object
 setmetatable(ball,Ball)                               -- Ball Instantiation
 ball.sprite=Sprite:init(13,1,1)                       -- Ball Sprite
 ball.x=flr(24+rnd(127-48)) ball.y=flr(16+rnd(127-32)) -- Ball random start
 ball.dx=1 ball.dy=1                                   -- Ball Physics
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
 import(Sprite.sheet)
 -- init game
 DRAW={}          -- Map Objects that don't update, just draw
 COLLIDE={}         -- Map Objects that don't update, but affect updates
 for x=0,127 do         -- Screen width
  DRAW[x]={}      -- XXX Usability over Space Performance
  COLLIDE[x]={}     -- XXX Usability over Space Performance
  for y=0,127 do        -- Screen height
   DRAW[x][y]={}  -- XXX Usability over Space Performance
   COLLIDE[x][y]={} -- XXX Usability over Space Performance
  end
 end
 -- load game
 for x=0,127,16 do                          -- Screen width by Brick width
  for y=0,127,8 do                          -- Screen height by Brick height
   if x==0 or x==112 or y==0 or y==120 then -- Screen Edges
    local brick=Brick:init(x,y)
    local bbox=brick.sprite:box(x,y)
    DRAW[x][y][0]=brick              -- Gray Bricks to draw
    for xs=bbox.left,bbox.right do
     for ys=bbox.top,bbox.bottom do
      COLLIDE[xs][ys][0]=brick         -- Gray Bricks hitboxes
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
 cls(0)
 -- draw static (bricks)
 for x=0,127 do                      -- Screen width
  for y=0,127 do                     -- Screen height
   if DRAW[x][y][0]!=nil then -- Screen depth
    DRAW[x][y][0].sprite:draw(x,y)
   end
  end
 end
 BALL.sprite:draw(BALL.x,BALL.y)
 print(stat(7),3)
end
function _collide(obj)
 local hitbox=obj.sprite:box(obj.x,obj.y)
 local collidebox=Box:init(0,0,0,0)
 for y=hitbox.top,hitbox.bottom do
  if COLLIDE[hitbox.left][y][0]!=nil then collidebox.left+=1 end
  if COLLIDE[hitbox.right][y][0]!=nil then collidebox.right+=1 end
 end
 for x=hitbox.left,hitbox.right do
  if COLLIDE[x][hitbox.top][0]!=nil then collidebox.top+=1 end
  if COLLIDE[x][hitbox.bottom][0]!=nil then collidebox.bottom+=1 end
 end
 return collidebox
end
