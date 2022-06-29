SCREEN _NEWIMAGE(640, 480, 32)
DIM colors(16) AS LONG
colors(0) = &HFF000000
colors(1) = &HFF0000AA
colors(2) = &HFF00AA00
colors(3) = &HFF00AAAA
colors(4) = &HFFAA0000
colors(5) = &HFFAA00AA
colors(6) = &HFFAA5500
colors(7) = &HFFAAAAAA
colors(8) = &HFF5A5A5A
colors(9) = &HFF5555FF
colors(10) = &HFF55FF55
colors(11) = &HFF55FFFF
colors(12) = &HFFFF5555
colors(13) = &HFFFF55FF
colors(14) = &HFFFFFF55
colors(15) = &HFFFFFFFF
1 CLS
_CONTROLCHR OFF
CLS
tracker = 0
PRINT "You made it to the enchanted castle!"
'SLEEP 2.5
num = INT(RND(1) * 21) * 100
num2 = INT(RND(1) * 9)
Ax = x
B = Y

Ax = CSRLIN
B = POS(0)
c$ = "Û"
COLOR blend(colors(0), colors(1))
FOR row = 8 TO 12
    LOCATE row, 21
    FOR i = 1 TO 13
        PRINT c$;
    NEXT
    IF row = 11 THEN COLOR blend(colors(5), colors(2))
NEXT

COLOR blend(colors(1), colors(1))
FOR i = 21 TO 33 STEP 3
    LOCATE 9, i
    PRINT c$
NEXT

COLOR blend(colors(9), colors(3))
FOR row = 7 TO 11
    LOCATE row, 34
    PRINT c$
NEXT
COLOR blend(colors(9), colors(0))
LOCATE 8, 24
PRINT c$; c$
LOCATE 8, 30
PRINT c$; c$

LOCATE 6, 27
PRINT c$
COLOR blend(colors(0), colors(4))
LOCATE 11, 27
PRINT c$; c$

COLOR blend(colors(9), colors(3))
LOCATE 6, 29
PRINT c$
COLOR blend(colors(9), colors(2))
LOCATE 6, 26
PRINT c$
LOCATE 6, 28
PRINT c$

COLOR blend(colors(1), colors(2))
LOCATE 7, 27
PRINT c$
COLOR blend(colors(5), colors(2))
LOCATE 10, 27
PRINT c$; c$

COLOR blend(colors(0), colors(4))
LOCATE 12, 27
PRINT c$; c$
COLOR blend(colors(13), colors(4))
LOCATE 12, 26
PRINT c$

COLOR blend(colors(9), colors(0))
LOCATE 7, 21
PRINT c$
LOCATE 7, 33
PRINT c$
COLOR blend(colors(13), colors(0))
LOCATE 7, 22
PRINT c$


LOCATE 7, 32
PRINT c$
COLOR blend(colors(9), colors(3))
LOCATE 7, 23
PRINT c$
LOCATE 7, 35
PRINT c$

COLOR blend(colors(5), colors(2))
LOCATE 10, 23
PRINT c$
COLOR blend(colors(10), colors(0))
LOCATE 11, 23
PRINT c$

COLOR blend(colors(9), colors(3))
LOCATE 11, 26
PRINT c$
COLOR blend(colors(1), colors(2))
LOCATE 10, 26
PRINT c$
COLOR blend(colors(13), colors(4))
LOCATE 12, 34
PRINT c$

COLOR blend(colors(9), colors(0))
LOCATE 8, 23
PRINT c$
COLOR blend(colors(1), colors(0))
LOCATE 7, 26
PRINT c$
LOCATE 7, 28
PRINT c$

COLOR blend(colors(9), colors(3))
LOCATE 7, 29
PRINT c$
COLOR blend(colors(1), colors(2))
LOCATE 10, 31
PRINT c$;
COLOR blend(colors(5), colors(0))
PRINT c$

COLOR blend(colors(9), colors(0))
LOCATE 11, 31
PRINT c$;
COLOR blend(colors(1), colors(0))
PRINT c$
COLOR blend(colors(9), colors(0))
LOCATE 8, 29
PRINT c$

FUNCTION blend& (c1 AS LONG, c2 AS LONG)
    blend = _RGB32((_RED32(c1) + _RED32(c2)) / 2, (_GREEN32(c1) + _GREEN32(c2)) / 2, (_BLUE32(c1) + _BLUE32(c2)) / 2)
END FUNCTION

