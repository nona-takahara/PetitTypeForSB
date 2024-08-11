'PetitType - Proportional font draw library for SmileBASIC
'---------------------------------------------------------------------------------------------------------------------
'Copyright (c) 2024 Nona Takahara
'
'This software is provided 'as-is', without any express or implied warranty.
'In no event will the authors be held liable for any damages arising from the use of this software.
'
'Permission is granted to anyone to use this software for any purpose,
'including commercial applications, and to alter it and redistribute it
'freely, subject to the following restrictions:
'
'   1. The origin of this software must not be misrepresented; you must not
'      claim that you wrote the original software. If you use this software
'      in a product, an acknowledgment in the product documentation would be
'      appreciated but is not required.
'
'   2. Altered source versions must be plainly marked as such, and must not be
'      misrepresented as being the original software.
'
'   3. This notice may not be removed or altered from any source distribution.
'---------------------------------------------------------------------------------------------------------------------

OPTION STRICT
OPTION DEFINT

DIM BIN_EXPANDER[256*8]
DIM PAL_BIN[2]

PTY_INIT
END

COMMON DEF PTY_INIT
 VAR I,J
 FOR I=0 TO 255
  FOR J=0 TO 7
   BIN_EXPANDER[I*8+J]=(I>>(7-J))&1
  END
 NEXT
 PAL_BIN[0]=RGB(0,0,0,0)
 PAL_BIN[1]=RGB(255,255,255)
END

'文字を一文字描画
COMMON DEF PTY_PUT FONT,X,Y,GLYPH_ID,GCOL
 VAR BMP_BEGIN=FONT[FONT[2]+GLYPH_ID]+3
 VAR G_INFO=FONT[BMP_BEGIN-1]
 'GLYPH INFO
 'BEARING X:INT8|BEARING Y:INT8|WIDTH:UINT8|HEIGHT:UINT8
 VAR BX=G_INFO>>24,BY=(G_INFO<<8)>>24
 VAR GW=(G_INFO>>8)&255,GH=G_INFO&255
 VAR BMP_LAST=FLOOR(GW*GH/32)

 VAR I
 DIM BMP[(BMP_LAST+1)*8]
 FOR I=0 TO BMP_LAST
  COPY BMP,I*8,BIN_EXPANDER,(FONT[BMP_BEGIN+I])*8,8
 NEXT

 GLOAD X+BX,Y-BY,GW,GH,BMP,PAL_BIN,GCOL,#G_NORMAL2
END
