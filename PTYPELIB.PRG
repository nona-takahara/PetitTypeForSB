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

CONST #CID2GID_OFFSET=1
CONST #GID2GIX_OFFSET=2
CONST #MAPSIZE_OFFSET=3
CONST #KERNMAP_OFFSET=4
CONST #LIGATUREMAP_OFFSET=5
CONST #META_OFFSET=6

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
 VAR BMP_BEGIN=FONT[FONT[#GID2GIX_OFFSET]+GLYPH_ID]+3
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

COMMON DEF PTY_PRINT FONT,X,Y,T$,GCOL
 VAR I,XP,TEND=LEN(T$)-1
 VAR UPDATE_CHAR,UPDATE_GID
 VAR GID,NXGID=-1,GIX
 VAR CODE,CODEIX,OPERAND,MAPSIZE
 
 MAPSIZE=FONT[#MAPSIZE_OFFSET]
 XP=X

 GID=PTY_GET_GRYPH_ID(FONT,ASC(T$[0]))
 FOR I=1 TO TEND
  UPDATE_CHAR=0
  NXGID=PTY_GET_GRYPH_ID(FONT,ASC(T$[I]))
  
  @CONT_UPDATE_GID
  UPDATE_GID=0
  GIX=FONT[FONT[#GID2GIX_OFFSET]+GID]
  CODEIX=FONT[GIX]*MAPSIZE+FONT[FONT[FONT[#GID2GIX_OFFSET]+NXGID]]
  
  CODE=FONT[#LIGATUREMAP_OFFSET+CODEIX]
  OPERAND=CODE&(&HFFFFFF)
  CASE (CODE>>24)&255
   WHEN 0
   UPDATE_GID=OPERAND!=0
   GID=GID+OPERAND

   WHEN 1
   UPDATE_GID=OPERAND!=0
   GID=GID-OPERAND

   WHEN 2
   UPDATE_GID=GID!=OPERAND
   GID=OPERAND

   WHEN 3
   UPDATE_CHAR=1
   GID=OPERAND

   WHEN 4
   UPDATE_CHAR=1
   GID=GID+OPERAND

   WHEN 5
   UPDATE_CHAR=1
   GID=GID-OPERAND

   WHEN 6
   UPDATE_CHAR=1
   GID=NXGID+OPERAND

   WHEN 7
   UPDATE_CHAR=1
   GID=NXGID-OPERAND

  ENDCASE
  IF UPDATE_CHAR THEN CONTINUE
  IF UPDATE_GID THEN GOTO @CONT_UPDATE_GID

  PTY_PUT FONT,XP,Y,GID,GCOL

  INC XP,FONT[GIX+1]+FONT[#KERNMAP_OFFSET+CODEIX]
  GID=NXGID:NXGID=-1
 NEXT

 PTY_PUT FONT,XP,Y,GID,GCOL
 
 IF NXGID!=-1 THEN
  INC XP,FONT[GIX+1]+FONT[#KERNMAP_OFFSET+CODEIX]
  PTY_PUT FONT,XP,Y,NXGID,GCOL
 ENDIF

END

COMMON DEF PTY_GET_GRYPH_ID(FONT,CODEPOINT)
 VAR P=FONT[#CID2GID_OFFSET+((CODEPOINT>>8)&255)]
 IF P THEN
  RETURN FONT[P+(CODEPOINT & 255)]
 ELSE
  RETURN 0
 ENDIF
END
