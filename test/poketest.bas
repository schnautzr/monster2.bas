CLS

a = CSRLIN
b = POS(0)
c$ = "?"
s$ = " "

1400 COLOR 0, 1
FOR row = 8 TO 12
    1410 LOCATE row, 21
    FOR i = 1 TO 13
        PRINT c$;
    NEXT
    1415 IF row = 11 THEN COLOR 5, 2
NEXT

1420 COLOR 1, 1
FOR i = 21 TO 33 STEP 3
    LOCATE 9, i
    PRINT c$
NEXT

1425 COLOR 9, 3
FOR row = 7 TO 11
    LOCATE row, 34
    PRINT c$
NEXT

1430 COLOR 9, 0
LOCATE 8, 24
PRINT c$; c$
LOCATE 8, 30
PRINT c$; c$

1435 LOCATE 6, 27
PRINT c$
COLOR 0, 4
LOCATE 11, 27
PRINT c$; c$

1440 COLOR 9, 3
LOCATE 6, 29
PRINT c$
COLOR 9, 2
LOCATE 6, 26
PRINT c$
LOCATE 6, 28
PRINT c$

1445 COLOR 1, 2
LOCATE 7, 27
PRINT c$
COLOR 5, 2
LOCATE 10, 27
PRINT c$; c$

1450 COLOR 0, 4
LOCATE 12, 27
PRINT c$; c$
COLOR 13, 4
LOCATE 12, 26
PRINT c$

1455 COLOR 9, 0
LOCATE 7, 21
PRINT c$
LOCATE 7, 33
PRINT c$
COLOR 13, 0
LOCATE 7, 22
PRINT c$

1460
LOCATE 7, 32
PRINT c$
COLOR 9, 3
LOCATE 7, 23
PRINT c$
LOCATE 7, 35
PRINT c$

1465 COLOR 5, 2
LOCATE 10, 23
PRINT c$
COLOR 10, 0
LOCATE 11, 23
PRINT c$

1470 COLOR 9, 3
LOCATE 11, 26
PRINT c$
COLOR 1, 2
LOCATE 10, 26
PRINT c$
COLOR 13, 4
LOCATE 12, 34
PRINT c$

1475 COLOR 9, 0
LOCATE 8, 23
PRINT c$
COLOR 1, 0
LOCATE 7, 26
PRINT c$
LOCATE 7, 28
PRINT c$

1480 COLOR 9, 3
LOCATE 7, 29
PRINT c$
COLOR 1, 2
LOCATE 10, 31
PRINT c$;
COLOR 5, 0
PRINT c$

1485 COLOR 9, 0
LOCATE 11, 31
PRINT c$;
COLOR 1, 0
PRINT c$
COLOR 9, 0
LOCATE 8, 29
PRINT c$

COLOR 15, 0
LOCATE a, b
