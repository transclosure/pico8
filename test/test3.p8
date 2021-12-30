pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
 sprites = 'spritesheet.png'
 import(sprites)
 As=0 Aw=10 Ah=1          -- sprite dimensions
 Ax=40 Ay=64 Adx=1 Ady=1  -- in-game position/velocity
 Bs=52 Bw=9 Bh=9          -- sprite dimensions
 Bdx=1 Bdy=1 Bx=20 By=32  -- in-game position/velocity
end

function _update()
 -- update spriteA
 Ax+=Adx
 Ay+=Ady
 Atouchleft = Ax<1
 Atouchright = Ax>127-Aw*8
 Atouchup = Ay<1
 Atouchdown = Ay>127-Ah*8
 if Atouchleft or Atouchright then Adx*=-1 end
 if Atouchup or Atouchdown then Ady*=-1 end
 -- update spriteB
 Bx+=Bdx
 By+=Bdy
 Btouchleft = Bx<1
 Btouchright = Bx>127-Bw*8
 Btouchup = By<1
 Btouchdown = By>127-Bh*8
 if Btouchleft or Btouchright then Bdx*=-1 end
 if Btouchup or Btouchdown then Bdy*=-1 end
end

function _draw()
 cls(1)
 -- draw spriteA
 spr(As, Ax, Ay, Aw, Ah)
 -- draw spriteB
 spr(Bs, Bx, By, Bw, Bh)
end
