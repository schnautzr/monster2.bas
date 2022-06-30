REM "GIANT MONSTER ATTACK"
REM BY LEE j. CHAPEL 5/1/1980
REM ADAPTED FOR QBASIC AND MADE EVEN BETTER BY ROB SCHNAUTZ

RANDOMIZE TIMER
SCREEN _NEWIMAGE(640, 480, 32)
_CONTROLCHR OFF
CLS
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

'i = _LOADIMAGE("CASTLE.BMP", 32)
'_PUTIMAGE (40, 80), i
PRINT "*** MONSTER COMBAT"

MINUTE = 60
HOUR = 60 * MINUTE
DAY = 24 * HOUR
WEEK = 7 * DAY

'challenge difficulty values
EASY = 0
MEDIUM = 1
HARD = 2
DEADLY = 3

'world map legend
TREE = 0
PATH = 1
WALL = 2
INN = 3
PIT = 4
CASTLE = 7

'tracker values
ENTERING_INN = 1
CHECKING_MAP = 2
ENTERING_CASTLE = 9
SLEEP_SPELL = 6
CHARM_SPELL = 7
INVISIBILITY_SPELL = 8

'event values
NOTHING_THERE = 1
HAVE_RANDOM_EVENT = 2
NOISY_BATTLE = 3
UNABLE_TO_MASTER_SPELL = 5
GIANT_BAT = 12
FALL_IN_PIT = 13
GIANT_EAGLE = 14
PRIZE_IS_SPELL = 14

CCOMMON = 0
UNCOMMON = 1
RARE = 2
VERY_RARE = 3
LEGENDARY = 4

'j value
NO_GUARDIAN = 100

'num value
SLEEP_SUCCESS = 3

DIM timeInForest AS DOUBLE

TYPE Abilities
    str AS _BYTE
    dex AS _BYTE
    con AS _BYTE
    int AS _BYTE
    wis AS _BYTE
    cha AS _BYTE
END TYPE

TYPE Dice
    sides AS _BYTE
    ct AS INTEGER
END TYPE


TYPE Currency
    cp AS LONG
    sp AS LONG
    ep AS LONG
    gp AS LONG
    pp AS LONG
END TYPE
DIM NO_MONEY AS Currency

TYPE Coordinates
    x AS INTEGER
    y AS INTEGER
END TYPE

TYPE Castle
    coords AS Coordinates
END TYPE

TYPE Entity
    id AS _UNSIGNED INTEGER

    name AS STRING
    plural AS STRING

    cr AS SINGLE

    color AS _BYTE
    disallowBribe AS _BYTE
    disallowSleep AS _BYTE
    disallowCharm AS _BYTE
    disallowInvisibility AS _BYTE
    ac AS _BYTE

    abilities AS Abilities

    hitDice AS Dice

    coins AS Currency
    treasure AS Currency
    treasurePointsPrev AS _UNSIGNED INTEGER

    xp AS _UNSIGNED _INTEGER64

    coords AS Coordinates

    maxCombatStrength AS _UNSIGNED _INTEGER64
    combatStrengthRemaining AS _UNSIGNED _INTEGER64

    invisibilityRemaining AS _UNSIGNED INTEGER
    invisibilityMax AS _UNSIGNED INTEGER
    sleepRemaining AS _UNSIGNED INTEGER
    sleepMax AS _UNSIGNED INTEGER
    charmsRemaining AS _UNSIGNED INTEGER
    charmsMax AS _UNSIGNED INTEGER

    speed AS SINGLE
END TYPE

TYPE Gemstone
    id AS _UNSIGNED INTEGER
    name AS STRING
    color AS _BYTE
    value AS Currency
END TYPE

TYPE Jewelry
    id AS _UNSIGNED INTEGER
    name AS STRING
    color AS _BYTE
    value AS Currency
END TYPE

TYPE Treasure
    id AS _UNSIGNED INTEGER
    name AS STRING
    color AS _BYTE
    value AS Currency
END TYPE

TYPE ArtObject
    id AS _UNSIGNED INTEGER
    name AS STRING
    value AS Currency
    color AS _BYTE
END TYPE

TYPE MagicItem
    id AS _UNSIGNED INTEGER
    name AS STRING
END TYPE

DIM currentTreasure AS Treasure
DIM currentGemstone AS Gemstone
DIM currentJewelry AS Jewelry
DIM currentArtObject AS ArtObject

DATA 10,10,10,10,10,10
DATA 1,8
DATA 10
DATA 1,10
monsterCt = 1000

DIM points AS DOUBLE
DATA a treasure chest,200,6
DATA a sword which might be enchanted,25,7
treasureCt = 2

DATA a sleep spell,5
DATA a charm spell,11
DATA an invisibility spell,1
itemCt = 3

DIM world(100, 100), items$(3), numbers(monsterCt), itemColor(itemCt)
DIM ct(monsterCt), die(monsterCt), hitDie(monsterCt), numHitDice(monsterCt)
DIM player AS Entity
READ player.abilities.str, player.abilities.dex, player.abilities.con, player.abilities.int, player.abilities.wis, player.abilities.cha
READ player.hitDice.ct, player.hitDice.sides

file = 0
i = 0
DIM monster(1000) AS Entity
DIM castle(15) AS Castle
DIM currentMonster AS Entity
DIM mimic AS Entity
DIM giantEagle AS Entity
DIM giantBat AS Entity
DIM pit AS Entity
DIM basilisk AS Entity

pit.name = "pit"
pit.color = 6
CHDIR ("monsters")
file$ = DIR$("*.csv")
DO
    file$ = DIR$("") 'use an empty string parameter to return a list of files!
    IF file$ = "" THEN EXIT DO
    file = file + 1
    OPEN file$ FOR INPUT AS #file
    i = i + 1
    monster(i).id = i
    INPUT #file, monster(i).name
    INPUT #file, monster(i).plural
    INPUT #file, monster(i).cr
    INPUT #file, monster(i).color
    INPUT #file, monster(i).disallowBribe, monster(i).disallowSleep, monster(i).disallowCharm, monster(i).disallowInvisibility
    SELECT CASE monster(i).name
        CASE "mimic"
            mimic = monster(i)
        CASE "giant eagle"
            giantEagle = monster(i)
        CASE "giant bat"
            giantBat = monster(i)
            giantBat.speed = 12
        CASE "basilisk"
            basilisk = monster(i)
    END SELECT
LOOP
monsterCt = i
CLOSE

CHDIR ".."

DIM gemstone(6, 100) AS Gemstone
DIM gemstoneValue(6)
gemstoneValue(0) = 10
gemstoneValue(1) = 50
gemstoneValue(2) = 100
gemstoneValue(3) = 500
gemstoneValue(4) = 1000
gemstoneValue(5) = 5000

DIM gemCt(6) AS INTEGER
FOR j = 0 TO 5
    file = file + 1
    OPEN "gemstones/GEM" + LTRIM$(STR$(gemstoneValue(j))) + ".CSV" FOR INPUT AS #file
    i = 0
    DO UNTIL EOF(file)
        i = i + 1
        gemstone(j, i).id = i
        INPUT #file, gemstone(j, i).name, gemstone(j, i).color
        gemstone(j, i).value.gp = gemstoneValue(j)
    LOOP
    gemCt(j) = i
    CLOSE
NEXT
CLOSE

DIM jewelry(6, 100) AS Jewelry
DIM jewelryCt(6) AS INTEGER
DIM jewelryValue(6)
jewelryValue(0) = 100
jewelryValue(1) = 200
jewelryValue(2) = 300
jewelryValue(3) = 500
jewelryValue(4) = 1000
jewelryValue(5) = 2000

FOR j = 0 TO 5
    file = file + 1
    OPEN "jewelry/JWLR" + LTRIM$(STR$(jewelryValue(j))) + ".CSV" FOR INPUT AS #file
    i = 0
    DO UNTIL EOF(file)
        i = i + 1
        jewelry(j, i).id = i
        INPUT #file, jewelry(j, i).name, jewelry(j, i).color
        jewelry(j, i).value.gp = jewelryValue(j)
    LOOP
    jewelryCt(j) = i
    CLOSE
NEXT
CLOSE

DIM artObject(5, 100) AS ArtObject
DIM artObjectCt(5) AS INTEGER
FOR j = 0 TO 4
    file = file + 1
    SELECT CASE j
        CASE CCOMMON
            rarity$ = "C"
        CASE UNCOMMON
            rarity$ = "U"
        CASE RARE
            rarity$ = "R"
        CASE VERY_RARE
            rarity$ = "V"
        CASE LEGENDARY
            rarity$ = "L"
    END SELECT
    OPEN "art objects/ART" + rarity$ + ".CSV" FOR INPUT AS #file
    i = 0
    DO UNTIL EOF(file)
        i = i + 1
        artObject(j, i).id = i
        INPUT #file, artObject(j, i).name, artObject(j, i).value.gp, artObject(j, i).color
    LOOP
    artObjectCt(j) = i
    CLOSE
NEXT
CLOSE


READ armorClass(0)
READ numHitDice(0), hitDie(0)
DIM treasure(1000) AS Treasure
DIM sword AS Treasure
DIM chest AS Treasure
FOR i = 1 TO treasureCt
    treasure(i).id = i
    READ treasure(i).name, treasure(i).value.gp, treasure(i).color
    SELECT CASE treasure(i).name
        CASE "a sword which might be enchanted"
            sword = treasure(i)
        CASE "a treasure chest"
            chest = treasure(i)
    END SELECT
NEXT
FOR i = 1 TO itemCt
    READ items$(i), itemColor(i)
NEXT

FOR i = 1 TO treasureCt
    IF treasure(i).value.gp = 0 THEN PRINT "WARNING: Treasure #"; i; "is glitched."
NEXT
player.invisibilityRemaining = rollD(1, 3) - 1
player.combatStrengthRemaining = rollD(1, 1501) + 499 '10
player.sleepRemaining = rollD(1, 6) - 1
player.charmsRemaining = rollD(1, 4) - 1
player.speed = 6
PRINT
INPUT "Do you wish to use the strength and magic from a previous game"; X$
IF UCASE$(X$) = "Y" THEN
    DO
        INPUT "COMBAT STRENGTH"; c
    LOOP WHILE c < 500 OR c > 2000
    INPUT "SLEEP SPELLS"; player.sleepRemaining
    INPUT "CHARMS:"; player.charmsRemaining
    INPUT "INVISIBILITY"; player.invisibilityRemaining
    INPUT "PREVIOUS LARGEST TREASURE TOTAL"; player.treasurePointsPrev
END IF

INITIALIZE:
DO
    player.maxCombatStrength = player.combatStrengthRemaining
    player.invisibilityMax = player.invisibilityRemaining
    player.sleepMax = player.sleepRemaining
    player.charmsMax = player.charmsRemaining

    castlesLeft = 0
    event = 0
    num2 = 0
    t = 0
    points = 0

    FOR i = 0 TO 99
        FOR j = 0 TO 99
            world(i, j) = 0
        NEXT
    NEXT

    REM castles
    FOR i = 1 TO rollD(1, 7) + 6
        player.coords.x = rollD(1, 100)
        player.coords.y = rollD(1, 100)

        IF world(player.coords.x, player.coords.y) < 7 THEN
            world(player.coords.x, player.coords.y) = 7
            castle(i).coords = player.coords
            castlesLeft = castlesLeft + 1
        ELSE
            i = i - 1
        END IF
    NEXT
    'i=the number of castles left
    REM inns
    FOR i = 1 TO rollD(1, 100) + 100
        player.coords.x = rollD(1, 100)
        player.coords.y = rollD(1, 100)

        IF world(player.coords.x, player.coords.y) < 3 THEN world(player.coords.x, player.coords.y) = 3
    NEXT
    'i=the number of inns
    REM walls
    FOR i = 1 TO rollD(1, 500) + 500
        player.coords.x = rollD(1, 100)
        player.coords.y = rollD(1, 100)

        IF world(player.coords.x, player.coords.y) < 2 THEN world(player.coords.x, player.coords.y) = 2
    NEXT
    'i=the number of walls
    REM paths
    FOR i = 1 TO INT(RND(1) * 5000 + 5000)
        player.coords.x = rollD(1, 100)
        player.coords.y = rollD(1, 100)

        IF world(player.coords.x, player.coords.y) < 1 THEN world(player.coords.x, player.coords.y) = 1
    NEXT
    'i=the number of paths
    RANDOM_LOC:
    DO
        player.coords.x = rollD(1, 80) + 10
        player.coords.y = rollD(1, 80) + 10
    LOOP WHILE world(player.coords.x, player.coords.y) > 1

    DO UNTIL player.coords.x < 1 OR player.coords.x > 100 OR player.coords.y < 1 OR player.coords.y > 100
        'FOR i = 0 TO 99
        'FOR j = 0 TO 99
        'world(i, j) = 0
        'NEXT
        'NEXT
        'i=10, j=10
        CHECK_MAP:
        exitForest = 0
        CLS
        PRINT
        FOR i = (player.coords.y - 5) TO (player.coords.y + 5)
            FOR j = (player.coords.x - 5) TO (player.coords.x + 5)
                IF j = player.coords.x - 5 THEN PRINT TAB(3);
                IF i = player.coords.y AND j = player.coords.x THEN
                    COLOR colors(14)
                    PRINT "";

                ELSE
                    IF i < 1 OR j < 1 OR i > 100 OR j > 100 THEN
                        COLOR colors(2), colors(12)
                        PRINT "±";
                    ELSE
                        SELECT CASE world(j, i)
                            CASE 0
                                COLOR colors(2), colors(6)
                                PRINT "";
                            CASE 1
                                COLOR colors(0), colors(6)
                                PRINT " ";
                            CASE 2
                                COLOR colors(8), colors(6)
                                PRINT "Î";
                            CASE 3
                                COLOR colors(0), colors(6)
                                PRINT "";
                            CASE 4
                                COLOR colors(0), colors(6)
                                PRINT "";
                            CASE 7
                                COLOR colors(3), colors(6)
                                PRINT "ê";
                        END SELECT
                    END IF
                END IF
            NEXT
            COLOR colors(15), colors(0)
            PRINT TAB(18);
            SELECT CASE i - player.coords.y
                CASE -4
                    PRINT "Combat Strength-";
                    IF player.combatStrengthRemaining < 100 THEN COLOR colors(12)
                    PRINT TAB(40); player.combatStrengthRemaining
                CASE -3
                    PRINT "Level"; playerLevel(player.xp); TAB(40); player.xp; "XP"
                CASE -2
                    PRINT "Treasure Total-";
                    PRINT TAB(40); player.treasure.gp
                CASE -1
                    PRINT "Money:";
                    COLOR colors(6)
                    PRINT TAB(41); "þ"; player.coins.cp;
                    COLOR colors(7)
                    PRINT ""; player.coins.sp;
                    COLOR colors(9)
                    PRINT ""; player.coins.ep;
                    COLOR colors(14)
                    PRINT "è"; player.coins.gp;
                    COLOR colors(7)
                    PRINT ""; player.coins.pp
                CASE 0
                    PRINT "Value-";
                    COLOR colors(14)
                    PRINT TAB(52); getWorth(player.coins); "gp"
                CASE 1
                    PRINT "Magic:"
                CASE 2
                    PRINT " Sleep Spells-";
                    PRINT TAB(40); player.sleepRemaining
                CASE 3
                    PRINT " Charms-";
                    PRINT TAB(40); player.charmsRemaining
                CASE 4
                    PRINT " Invisibility-";
                    PRINT TAB(40); player.invisibilityRemaining
                CASE 5
                    PRINT "Time in the Forest-";
                    PRINT TAB(40); getTime$(timeInForest)
                CASE ELSE
                    PRINT
            END SELECT
        NEXT
        PRINT
        'i,j is 5 east and 5 south of person

        SELECT CASE tracker:
            CASE ENTERING_INN
                RETURN
            CASE IS <> CHECKING_MAP
                WHAT_HAPPENS_HERE:
                isChest = 0
                isSword = 0
                event = rollD(1, 10) - 1
                IF event = HAVE_RANDOM_EVENT AND tracker <> ENTERING_CASTLE THEN
                    event = INT(RND(1) * 11 + 1)
                    SELECT CASE event
                        CASE 1
                            PRINT "You stepped into a time warp and lost 7 days."
                            timeInForest = timeInForest + WEEK
                            SLEEP 1
                        CASE 2
                            IF player.combatStrengthRemaining >= player.maxCombatStrength THEN EXIT SELECT
                            PRINT "You met an elf who gave you a magic drink that gave your Combat Strength back."
                            player.combatStrengthRemaining = player.maxCombatStrength
                            SLEEP 1
                        CASE 3
                            DO
                                num = rollD(1, 10)
                            LOOP UNTIL num * DAY < timeInForest
                            timeInForest = timeInForest - num * DAY
                            PRINT "You stepped into a time warp and gained"; num; "days."
                            SLEEP 1
                        CASE 4
                            IF player.invisibilityRemaining + player.charmsRemaining + player.sleepRemaining = player.invisibilityMax + player.charmsMax + player.sleepMax THEN EXIT SELECT
                            PRINT "You ran into a wizard who gave you a potion that restored all your magic."
                            player.invisibilityRemaining = player.invisibilityMax
                            player.charmsRemaining = player.charmsMax
                            player.sleepRemaining = player.sleepMax
                            SLEEP 1
                        CASE 5
                            IF player.treasure.gp < 2 THEN EXIT SELECT
                            PRINT "You fell into some quicksand. You lost half of your"
                            PRINT "treasure."
                            player.treasure.gp = INT(player.treasure.gp / 2)
                            SLEEP 1
                        CASE 6
                            PRINT "You ran into some thick underbrush and used up half"
                            PRINT "your strength."
                            player.combatStrengthRemaining = INT(player.combatStrengthRemaining / 2)
                            PRINT "Your Combat Strength is now "; player.combatStrengthRemaining
                            SLEEP 1
                        CASE 7
                            num = INT(RND(1) * 50 + 1)
                            PRINT "You found"; num;
                            SELECT CASE rollD(1, 1131)
                                CASE 1 TO 1000
                                    COLOR colors(6)
                                    PRINT "copper";
                                    player.coins.cp = player.coins.cp + num
                                CASE 1001 TO 1100
                                    COLOR colors(7)
                                    PRINT "silver";
                                    player.coins.sp = player.coins.sp + num
                                CASE 1101 TO 1120
                                    COLOR colors(9)
                                    PRINT "electrum";
                                    player.coins.ep = player.coins.ep + num
                                CASE 1120 TO 1130
                                    COLOR colors(14)
                                    PRINT "gold";
                                    player.coins.gp = player.coins.gp + num
                                CASE 1131
                                    COLOR colors(7)
                                    PRINT "platinum";
                                    player.coins.pp = player.coins.pp + num
                            END SELECT
                            PRINT " coins";
                            COLOR colors(15)
                            PRINT " lying on the";
                            PRINT " ground and picked them up."
                            SLEEP 1
                        CASE 8
                            IF mirror <> 7 THEN EXIT SELECT
                            PRINT "You tripped over some roots and lost your mirror."
                            mirror = 0
                            SLEEP 1
                        CASE 9
                            PRINT "A hermit told you that there are"; castlesLeft; "castles left."
                            SLEEP 1
                        CASE 10
                            IF player.invisibilityRemaining + player.sleepRemaining + player.charmsRemaining = 0 THEN EXIT SELECT
                            PRINT "You wandered into an area where magic fades."
                            PRINT "You lose all your present magic."
                            player.invisibilityRemaining = 0
                            player.sleepRemaining = 0
                            player.charmsRemaining = 0
                            SLEEP 1
                        CASE 11
                            IF castlesLeft = 0 THEN EXIT SELECT
                            PRINT "You met a hunter who told you of the legend of a"
                            PRINT "castle ";
                            num = INT(RND(1) * castlesLeft) + 1
                            CALL WHERE_IS_IT(castle(num).coords, player.coords)
                            SLEEP 1
                    END SELECT
                END IF
                IF event = NOTHING_THERE THEN
                    SELECT CASE tracker
                        CASE IS <> ENTERING_CASTLE
                            PRINT "There's nothing here."
                        CASE ENTERING_CASTLE
                            ENTER_CASTLE:
                            CLS
                            tracker = 0
                            PRINT "You made it to the enchanted castle!"
                            SLEEP 2.5
                            num = INT(RND(1) * 21) * 100
                            num2 = INT(RND(1) * 9)

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
                            LOCATE Ax, B
                            COLOR colors(15), colors(0)
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT
                            PRINT

                            SLEEP 1
                            IF 1 = 0 THEN
                                PRINT "You found"; num; "gp there."
                                player.coins.gp = player.coins.gp + num
                            ELSE
                                DIM money AS Currency
                                money = NO_MONEY
                                FOR i = 1 TO howManyMonsters
                                    SELECT CASE currentMonster.cr
                                        CASE 0 TO 4
                                            money.cp = money.cp + rollD(6, 6) * 100
                                            money.sp = money.sp + rollD(3, 6) * 100
                                            money.gp = money.gp + rollD(2, 6) * 10
                                        CASE 5 TO 10
                                            money.cp = money.cp + rollD(2, 6) * 100
                                            money.sp = money.sp + rollD(2, 6) * 1000
                                            money.gp = money.gp + rollD(6, 6) * 100
                                            money.pp = money.pp + rollD(3, 6) * 10
                                        CASE 11 TO 16
                                            money.gp = money.gp + rollD(4, 6) * 1000
                                            money.pp = money.pp + rollD(5, 6) * 100
                                        CASE IS >= 17
                                            money.gp = money.gp + rollD(12, 6) * 1000
                                            money.pp = money.pp + rollD(8, 6) * 1000
                                    END SELECT
                                NEXT
                                PRINT "You found"; getWorth(money); "gp there."
                                CALL ADD_CURRENCY(player.coins, money)
                            END IF
                            treasureHoard = rollD(1, 100)
                            SELECT CASE currentMonster.cr
                                CASE 0 TO 4
                                    SELECT EVERYCASE treasureHoard
                                        CASE 7 TO 16, 37 TO 44, 61 TO 65, 76 TO 78
                                            rarity = CCOMMON - 1
                                        CASE 17 TO 36, 45 TO 60, 66 TO 75, 79 TO 100
                                            rarity = CCOMMON
                                        CASE 7 TO 16, 27 TO 44, 53 TO 65, 71 TO 78, 81 TO 85, 93 TO 97, 100
                                            PRINT "You also found the following gemstones:"
                                            roll = rollD(2, 6)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, gemCt(rarity + 1))
                                                currentGemstone = gemstone(rarity + 1, roll2)
                                                COLOR colors(currentGemstone.color)
                                                PRINT " "; currentGemstone.name
                                                CALL ADD_CURRENCY(player.treasure, currentGemstone.value)
                                            NEXT
                                        CASE 17 TO 26, 45 TO 52, 66 TO 70, 98 TO 99

                                            PRINT "You also found the following art objects:"
                                            roll = rollD(2, 4)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, artObjectCt(rarity))
                                                currentArtObject = artObject(rarity, roll2)
                                                COLOR colors(currentArtObject.color)
                                                PRINT " "; currentArtObject.name
                                                CALL ADD_CURRENCY(player.treasure, currentArtObject.value)
                                            NEXT
                                    END SELECT
                                CASE 5 TO 10
                                    SELECT EVERYCASE treasureHoard
                                        CASE 5 TO 16, 29 TO 36, 45 TO 54, 64 TO 69, 75 TO 78, 81 TO 88
                                            rarity = CCOMMON
                                        CASE 17 TO 28, 37 TO 44, 55 TO 63, 70 TO 74, 79 TO 80, 89 TO 100
                                            rarity = UNCOMMON
                                        CASE 11 TO 22, 33 TO 40, 50 TO 59, 67 TO 72, 77 TO 79, 85 TO 91, 95 TO 96, 99
                                            PRINT "You also found the following gemstones:"
                                            roll = rollD(3, 6)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, gemCt(rarity + 1))
                                                currentGemstone = gemstone(rarity + 1, roll2)
                                                COLOR colors(currentGemstone.color)
                                                PRINT " "; currentGemstone.name
                                                CALL ADD_CURRENCY(player.treasure, currentGemstone.value)
                                            NEXT
                                        CASE 5 TO 10, 23 TO 32, 41 TO 49, 60 TO 66, 73 TO 76, 80 TO 84, 92 TO 94, 97 TO 98, 100

                                            PRINT "You also found the following art objects:"
                                            roll = rollD(2, 4)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, artObjectCt(rarity))
                                                currentArtObject = artObject(rarity, roll2)
                                                COLOR colors(currentArtObject.color)
                                                PRINT " "; currentArtObject.name
                                                CALL ADD_CURRENCY(player.treasure, currentArtObject.value)
                                            NEXT
                                    END SELECT
                                CASE 11 TO 16
                                    SELECT EVERYCASE treasureHoard
                                        CASE 4 TO 6, 16 TO 19, 30 TO 35, 51 TO 54, 67 TO 68, 75 TO 76, 83 TO 85, 93 TO 94
                                            rarity = UNCOMMON
                                        CASE 7 TO 12, 20 TO 26, 36 TO 45, 55 TO 62, 69 TO 72, 77 TO 80, 86 TO 90, 95 TO 98
                                            rarity = RARE
                                        CASE 13 TO 15, 27 TO 29, 46 TO 50, 63 TO 66, 73 TO 74, 81 TO 82, 91 TO 92, 99 TO 100
                                            rarity = VERY_RARE
                                        CASE 10 TO 15, 24 TO 29, 41 TO 50, 59 TO 66, 71 TO 74, 79 TO 82, 89 TO 92, 97 TO 100
                                            PRINT "You also found the following gemstones:"
                                            roll = rollD(3, 6)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, gemCt(rarity + 1))
                                                currentGemstone = gemstone(rarity + 1, roll2)
                                                COLOR colors(currentGemstone.color)
                                                PRINT " "; currentGemstone.name
                                                CALL ADD_CURRENCY(player.treasure, currentGemstone.value)
                                            NEXT
                                        CASE 4 TO 9, 16 TO 23, 30 TO 40, 51 TO 58, 67 TO 70, 75 TO 78, 83 TO 88, 93 TO 96
                                            PRINT "You also found the following art objects:"
                                            roll = rollD(1, 10)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, artObjectCt(rarity))
                                                currentArtObject = artObject(rarity, roll2)
                                                COLOR colors(currentArtObject.color)
                                                PRINT " "; currentArtObject.name
                                                CALL ADD_CURRENCY(player.treasure, currentArtObject.value)
                                            NEXT
                                    END SELECT
                                CASE IS >= 17
                                    SELECT EVERYCASE treasureHoard
                                        CASE 3 TO 5, 15 TO 22, 47 TO 52, 69, 73 TO 74, 81 TO 85
                                            PRINT "You also found the following gemstones:"
                                            roll = rollD(3, 6)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, gemCt(VERY_RARE + 1))
                                                currentGemstone = gemstone(VERY_RARE + 1, roll2)
                                                COLOR colors(currentGemstone.color)
                                                PRINT " "; currentGemstone.name
                                                CALL ADD_CURRENCY(player.treasure, currentGemstone.value)
                                            NEXT
                                        CASE 6 TO 8, 23 TO 30, 53 TO 58, 70, 75 TO 76, 86 TO 90
                                            PRINT "You also found the following art objects:"
                                            roll = rollD(3, 6)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, artObjectCt(VERY_RARE))
                                                currentArtObject = artObject(VERY_RARE, roll2)
                                                COLOR colors(currentArtObject.color)
                                                PRINT " "; currentArtObject.name
                                                CALL ADD_CURRENCY(player.treasure, currentArtObject.value)
                                            NEXT
                                        CASE 9 TO 11, 31 TO 38, 59 TO 63, 71, 77 TO 78, 91 TO 95
                                            PRINT "You also found the following art objects:"
                                            roll = rollD(1, 4)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, artObjectCt(LEGENDARY))
                                                currentArtObject = artObject(LEGENDARY, roll2)
                                                COLOR colors(currentArtObject.color)
                                                PRINT " "; currentArtObject.name
                                                CALL ADD_CURRENCY(player.treasure, currentArtObject.value)
                                            NEXT
                                        CASE 12 TO 14, 39 TO 46, 64 TO 68, 72, 79 TO 80, 96 TO 100
                                            PRINT "You also found the following gemstones:"
                                            roll = rollD(1, 8)
                                            FOR i = 1 TO roll
                                                roll2 = rollD(1, gemCt(LEGENDARY + 1))
                                                currentGemstone = gemstone(LEGENDARY + 1, roll2)
                                                COLOR colors(currentGemstone.color)
                                                PRINT " "; currentGemstone.name
                                                CALL ADD_CURRENCY(player.treasure, currentGemstone.value)
                                            NEXT
                                    END SELECT

                            END SELECT
                            COLOR colors(15)
                            IF num2 = 7 AND mirror <> 7 THEN
                                PRINT "You also found a mirror which will kill any "; colored(basilisk, colors()); "s";
                                COLOR colors(15)
                                PRINT " you meet."
                                mirror = 7
                            END IF
                            num2 = INT(RND(1) * 20)
                            IF num2 = 2 THEN player.combatStrengthRemaining = 2 * player.combatStrengthRemaining
                            IF num2 = 2 THEN PRINT "You also found an enchanted sword which doubles ";
                            IF num2 = 2 THEN PRINT "your strength."
                            FOR i = 1 TO castlesLeft - 1
                                IF castle(i).coords.x = player.coords.x AND castle(i).coords.y = player.coords.y THEN
                                    FOR j = i TO castlesLeft - 1
                                        castle(j) = castle(j + 1)
                                    NEXT
                                END IF
                            NEXT
                            PRINT "The castle vanishes."
                            world(player.coords.x, player.coords.y) = 0
                            castlesLeft = castlesLeft - 1
                            IF castlesLeft = 0 THEN PRINT "You found the last of the castles!"
                            EXIT SELECT
                    END SELECT
                    GOTO WHERE_TO
                END IF
                event = rollD(1, 16)
                IF event = GIANT_BAT AND tracker <> ENTERING_CASTLE THEN
                    PRINT "A "; colored(giantBat, colors());
                    COLOR colors(15)
                    PRINT " grabbed you and carried you to a new spot."
                    SLEEP 2.5
                    DIM newCoords AS Coordinates
                    newCoords = player.coords
                    tracker = 0
                    DO
                        newCoords.x = INT(RND(1) * 100) + 1 'random location
                        newCoords.y = INT(RND(1) * 100) + 1
                    LOOP UNTIL world(newCoords.x, newCoords.y) < 2 'we don't want to land on a wall, inn, or castle
                    timeInForest = timeInForest + travelTime(giantBat.speed, asymptote(player.coords, newCoords))
                    player.coords = newCoords
                    GOTO CHECK_MAP
                END IF
                IF event = FALL_IN_PIT AND tracker <> ENTERING_CASTLE THEN
                    PIT:
                    difficultTerrain = 1
                    PRINT "You fell into a "; colored(pit, colors());
                    COLOR colors(15)
                    PRINT ".";
                    world(player.coords.x, player.coords.y) = 4
                    num = INT((RND(1) * 21) + .001 * player.treasure.gp)
                    player.combatStrengthRemaining = player.combatStrengthRemaining - num
                    PRINT "Trying to get out..."
                    SLEEP 2.5
                    IF player.combatStrengthRemaining <= 0 THEN
                        PRINT "You died trying to get out!"
                        LOSS
                        RUN
                    END IF
                    PRINT "You used"; num; "Combat Points to get out."
                    PRINT "Your Combat Strength is now"; player.combatStrengthRemaining
                    num = 11
                    SLEEP 1
                    GOTO DISPLACEMENT
                END IF
                IF event = GIANT_EAGLE AND tracker <> ENTERING_CASTLE AND player.combatStrengthRemaining < 100 THEN
                    GIANT_EAGLE: PRINT "A "; colored(giantEagle, colors());
                    COLOR colors(15)
                    PRINT " carried you to safety.";
                    SLEEP 2.5
                    tracker = 0
                    exitForest = 1
                    EXIT DO
                END IF
                IF event = 15 OR event = 16 THEN
                    howManyMonsters = NO_GUARDIAN
                    GOTO WHAT_HAPPENS_HERE
                ELSE
                    n = event
                    DO
                        M = rollD(1, monsterCt)
                        currentMonster = monster(M)
                        SELECT CASE rollD(1, 4)
                            CASE 1 TO 3
                                difficulty = EASY
                            CASE 4
                                SELECT CASE rollD(1, 4)
                                    CASE 1 TO 3
                                        difficulty = MEDIUM
                                    CASE 4
                                        SELECT CASE rollD(1, 4)
                                            CASE 1 TO 3
                                                difficulty = HARD
                                            CASE 4
                                                SELECT CASE rollD(1, 4)
                                                    CASE 1 TO 3
                                                        difficulty = DEADLY
                                                    CASE ELSE
                                                        IF howManyMonsters = 0 THEN howManyMonsters = 1
                                                        EXIT DO
                                                END SELECT
                                        END SELECT
                                END SELECT
                        END SELECT
                        SELECT CASE difficulty
                            CASE EASY
                                howManyMonsters = 1
                            CASE MEDIUM
                                howManyMonsters = rollD(1, 2)
                            CASE HARD
                                howManyMonsters = rollD(1, 4)
                            CASE DEADLY
                                howManyMonsters = rollD(2, 4)
                            CASE ELSE
                                howManyMonsters = 1
                        END SELECT
                    LOOP UNTIL appropriateChallenge(playerLevel(player.xp), difficulty) >= adjustedXp(currentMonster.cr, xp(currentMonster.cr, howManyMonsters))
                    SELECT CASE howManyMonsters
                        CASE 1
                            monster$ = currentMonster.name
                            startsWith$ = LEFT$(monster$, 1)
                            SELECT CASE startsWith$
                                CASE "a", "e", "i", "o", "u"
                                    PRINT "An ";
                                CASE ELSE
                                    PRINT "A ";
                            END SELECT
                            PRINT colored(currentMonster, colors());
                            PRINT USING " (Challenge Rating&)"; STR$(currentMonster.cr);
                            COLOR colors(15)
                            PRINT " is ";
                        CASE IS <> 1
                            currentMonster.name = currentMonster.plural
                            PRINT howManyMonsters;
                            PRINT colored(currentMonster, colors());
                            PRINT USING " (Challenge Rating&)"; STR$(currentMonster.cr);
                            COLOR colors(15)
                            PRINT " are ";
                    END SELECT
                    PRINT "guarding";
                    monster = currentMonster.cr * howManyMonsters * 10
                    recommendedCombatStrength = INT(monster * 2 + getWeightCarried(player) / 100)
                END IF
                event = rollD(1, 14)
                IF (event = 12 OR event = 13 OR event = PRIZE_IS_SPELL) AND howManyMonsters = NO_GUARDIAN GOTO WHAT_HAPPENS_HERE
                IF (event = 11) AND howManyMonsters = NO_GUARDIAN THEN PRINT "Nothing is guarding ";
                IF event > 11 THEN
                    IF event <> PRIZE_IS_SPELL THEN
                        IF event > 11 THEN PRINT " nothing"
                        points = 0
                    ELSE
                        guardedSpell = rollD(1, 3)
                        tracker = guardedSpell + 5 'SPELL_1_IS_GUARDED,SPELL_2_IS_GUARDED,SPELL_3_IS_GUARDED
                        COLOR colors(itemColor(guardedSpell))
                        PRINT " "; items$(guardedSpell)
                        COLOR colors(15)
                        points = INT(RND(1) * 11)
                    END IF
                ELSE
                    table = rollD(1, 4)
                    SELECT CASE table
                        CASE 1
                            roll = rollD(1, treasureCt)
                            currentTreasure = treasure(roll)
                            COLOR colors(currentTreasure.color)
                            PRINT " "; currentTreasure.name;
                            points = getWorth(currentTreasure.value)
                            SELECT CASE currentTreasure.id
                                CASE sword.id
                                    isSword = 1
                                CASE chest.id
                                    isChest = 1
                            END SELECT
                        CASE 2 'gemstones
                            'for now, entirely random table
                            table = rollD(1, 6) - 1
                            roll = rollD(1, gemCt(table))
                            currentGemstone = gemstone(table, roll)
                            points = getWorth(currentGemstone.value)

                            ignore9and10 = 0

                            DO
                                roll = rollD(1, 8 + 2 * ignore9and10)
                                SELECT CASE roll
                                    CASE 1
                                        ignore9and10 = 1
                                        IF points < .5 THEN
                                            points = .5
                                        ELSEIF points < 1 THEN points = 1
                                        ELSEIF points < 5 THEN points = 5
                                        ELSEIF points < 10 THEN points = 10
                                        ELSEIF points < 50 THEN points = 50
                                        ELSEIF points < 100 THEN points = 100
                                        ELSEIF points < 500 THEN points = 500
                                        ELSEIF points < 1000 THEN points = 1000
                                        ELSEIF points < 5000 THEN points = 5000
                                        ELSEIF points < 10000 THEN points = 10000
                                        ELSEIF points < 25000 THEN points = 25000
                                        ELSEIF points < 50000 THEN points = 50000
                                        ELSEIF points < 100000 THEN points = 100000
                                        ELSEIF points < 250000 THEN points = 250000
                                        ELSEIF points < 500000 THEN points = 500000
                                        ELSE points = 1000000
                                        END IF
                                    CASE 2
                                        points = points * 2
                                        EXIT DO
                                    CASE 3
                                        roll = rollD(1, 6)
                                        points = points + points * roll / 10
                                        EXIT DO
                                    CASE 9
                                        roll = rollD(1, 6)
                                        points = points - points * roll / 10
                                        EXIT DO
                                    CASE 10
                                        ignore9and10 = 1
                                        IF points > 1000000 THEN
                                            points = 1000000
                                        ELSEIF points > 500000 THEN points = 500000
                                        ELSEIF points > 250000 THEN points = 250000
                                        ELSEIF points > 100000 THEN points = 100000
                                        ELSEIF points > 50000 THEN points = 50000
                                        ELSEIF points > 25000 THEN points = 25000
                                        ELSEIF points > 10000 THEN points = 10000
                                        ELSEIF points > 5000 THEN points = 5000
                                        ELSEIF points > 1000 THEN points = 1000
                                        ELSEIF points > 500 THEN points = 500
                                        ELSEIF points > 100 THEN points = 100
                                        ELSEIF points > 50 THEN points = 50
                                        ELSEIF points > 10 THEN points = 10
                                        ELSEIF points > 5 THEN points = 5
                                        ELSEIF points > 1 THEN points = 1
                                        ELSE points = .5
                                        END IF
                                END SELECT
                            LOOP
                            COLOR colors(currentGemstone.color)
                            PRINT " "; currentGemstone.name;
                        CASE 3
                            table = rollD(1, 6) - 1
                            roll = rollD(1, jewelryCt(table))
                            currentJewelry = jewelry(table, roll)
                            points = getWorth(currentJewelry.value)
                            appraising = 1
                            treatAsPlat = 0
                            treatAsGemmedSilver = 0
                            IF getWorth(currentJewelry.value) = 2000 THEN treatAsPlat = 1
                            IF getWorth(currentJewelry.value) = 1000 THEN treatAsGemmedSilver = 1

                            DO
                                roll = rollD(1, 10)
                                SELECT CASE roll
                                    CASE 1
                                        SELECT CASE points
                                            CASE 2000
                                                IF treatAsPlat = 1 THEN
                                                    points = 12000
                                                ELSE points = 8000
                                                END IF
                                            CASE 8000
                                                treatAsPlat = 1
                                                points = 2000
                                            CASE 6000
                                                points = 2000
                                            CASE 1000
                                                IF treatAsGemmedSilver = 1 THEN
                                                    points = 6000
                                                ELSE points = 200
                                                END IF
                                            CASE 3000
                                                points = 1000
                                                treatAsGemmedSilver = 1
                                            CASE 1800
                                                points = 500
                                            CASE 1200
                                                points = 300
                                            CASE 500
                                                points = 3000
                                            CASE 300
                                                points = 1800
                                            CASE 200
                                                points = 1200
                                            CASE 100
                                                points = 1000
                                        END SELECT
                                END SELECT
                            LOOP WHILE roll = 1 AND points < 12000
                            COLOR colors(currentJewelry.color)
                            PRINT " "; currentJewelry.name;
                        CASE 4
                            money = NO_MONEY
                            FOR i = 1 TO howManyMonsters
                                SELECT CASE currentMonster.cr
                                    CASE 0 TO 4
                                        SELECT CASE rollD(1, 100)
                                            CASE 1 TO 30
                                                money.cp = money.cp + rollD(5, 6)
                                            CASE 31 TO 60
                                                money.sp = money.sp + rollD(4, 6)
                                            CASE 61 TO 70
                                                money.ep = money.ep + rollD(3, 6)
                                            CASE 71 TO 95
                                                money.gp = money.gp + rollD(3, 6)
                                            CASE 96 TO 100
                                                money.pp = money.pp + rollD(1, 6)
                                        END SELECT
                                    CASE 5 TO 10
                                        SELECT CASE rollD(1, 100)
                                            CASE 1 TO 30
                                                money.cp = money.cp + rollD(4, 6) * 100
                                                money.ep = money.ep + rollD(1, 6) * 35
                                            CASE 31 TO 60
                                                money.sp = money.sp + rollD(6, 6) * 10
                                                money.gp = money.gp + rollD(2, 6) * 10
                                            CASE 61 TO 70
                                                money.ep = money.ep + rollD(3, 6) * 10
                                                money.gp = money.gp + rollD(2, 6) * 10
                                            CASE 71 TO 95
                                                money.gp = money.gp + rollD(4, 6) * 10
                                            CASE 96 TO 100
                                                money.gp = money.gp + rollD(2, 10) * 10
                                                money.pp = money.pp + rollD(3, 6)
                                        END SELECT
                                    CASE 11 TO 16
                                        SELECT CASE rollD(1, 100)
                                            CASE 1 TO 20
                                                money.sp = money.sp + rollD(4, 6) * 100
                                                money.gp = money.gp + rollD(1, 6) * 100
                                            CASE 21 TO 35
                                                money.ep = money.ep + rollD(1, 6) * 100
                                                money.gp = money.gp + rollD(1, 6) * 100
                                            CASE 36 TO 75
                                                money.gp = money.gp + rollD(2, 6) * 100
                                                money.pp = money.pp + rollD(1, 6) * 10
                                            CASE 76 TO 100
                                                money.gp = money.gp + rollD(2, 6) * 100
                                                money.pp = money.pp + rollD(2, 6) * 10
                                        END SELECT
                                    CASE IS >= 17
                                        SELECT CASE rollD(1, 100)
                                            CASE 1 TO 15
                                                money.ep = money.ep + rollD(2, 6) * 1000
                                                money.gp = money.gp + rollD(8, 6) * 100
                                            CASE 16 TO 55
                                                money.gp = money.gp + rollD(1, 6) * 1000
                                                money.pp = money.pp + rollD(1, 6) * 100
                                            CASE 56 TO 100
                                                money.gp = money.gp + rollD(1, 6) * 1000
                                                money.pp = money.pp + rollD(2, 6) * 100
                                        END SELECT
                                END SELECT
                            NEXT
                            COLOR colors(14)
                            PRINT getWorth(money); "gp"
                            points = 0
                    END SELECT
                    COLOR colors(15)
                    IF points <> 0 THEN PRINT USING " (& gp)."; LTRIM$(STR$(points))
                END IF
                IF currentMonster.id = basilisk.id AND mirror = 7 THEN
                    835 PRINT "Your mirror killed the "; colored(currentMonster, colors())
                    COLOR colors(15)
                    numbers(5) = numbers(5) + 1
                    monster = 0
                    GOTO 500
                END IF

                IF howManyMonsters = 100 THEN
                    PRINT "You get the treasure free!"
                ELSE
                    280
                    DO
                        INPUT "Do you wish to (1)fight, (2)run, (3)bribe, OR (4) cast a spell?"; k280
                    LOOP UNTIL k280 >= 1 AND k280 <= 4
                    SELECT CASE k280
                        CASE 1
                            FIGHT:
                            DO
                                COLOR colors(14), colors(6)
                                PRINT "Recommended Combat Points:"; recommendedCombatStrength + 1
                                COLOR colors(12), colors(4)
                                INPUT "How many Combat Points do you wish to use"; k
                                COLOR colors(15), colors(0)
                                SELECT CASE k
                                    CASE IS > player.combatStrengthRemaining
                                        PRINT "You only have"; player.combatStrengthRemaining; "Combat Points."
                                    CASE IS < .5 * recommendedCombatStrength, IS >= player.combatStrengthRemaining - 20, IS > recommendedCombatStrength + 1
                                        COLOR colors(12), colors(4)
                                        INPUT "Are you sure? Type the number again to confirm."; k2
                                        COLOR colors(15), colors(0)
                                        IF k = k2 THEN EXIT DO
                                    CASE ELSE
                                        EXIT DO
                                END SELECT
                            LOOP
                            IF 0 = 1 THEN
                                monsterHealth = rollD(currentMonster.hitDice.ct, currentMonster.hitDice.sides + modifier(currentMonster.abilities.con))

                                DO
                                    PRINT "the monster ";
                                    IF check(currentMonster.abilities.str, ac(currentMonster)) = 1 THEN
                                        damage = rollD(ct(num), die(num)) + modifier(currentMonster.abilities.str)
                                        player.combatStrengthRemaining = player.combatStrengthRemaining - damage
                                        PRINT "s and deals"; damage; "damage."
                                    ELSE PRINT "es."
                                    END IF

                                    IF player.combatStrengthRemaining <= 0 THEN
                                        CALL DEFEATED_BY(currentMonster, colors())
                                        RUN
                                    END IF
                                    PRINT "You ";
                                    IF check(player.abilities.str, ac(player)) = 1 THEN
                                        damage = rollD(player.hitDice.ct, player.hitDice.sides) + modifier(player.abilities.str)
                                        monsterHealth = monsterHealth - damage
                                        PRINT " and deal"; damage; "damage."
                                    ELSE PRINT
                                    END IF
                                    IF monsterHealth <= 0 THEN EXIT SELECT
                                LOOP
                            ELSE
                                num = INT(RND(1) * 1001)
                                l = 2
                                player.combatStrengthRemaining = player.combatStrengthRemaining - k
                                IF getEncumbrance(player) > 15 THEN k = k - .01 * getWeightCarried(player)

                                FOR i = 1000 TO 0 STEP -50
                                    IF i < num THEN
                                        CALL DEFEATED_BY(currentMonster, colors())
                                        RUN
                                    END IF
                                    IF l * monster <= k THEN EXIT SELECT
                                    l = l - .1
                                NEXT i
                            END IF

                            CALL DEFEATED_BY(currentMonster, colors())
                            RUN
                        CASE 2
                            RUN_AWAY: num = INT(RND(1) * 12)
                            IF num = 11 THEN
                                CALL DEFEATED_BY(currentMonster, colors())
                                RUN
                            END IF
                            FOR i = 0 TO 10
                                IF i * 10 > monster AND i <= num THEN GOTO DISPLACEMENT
                            NEXT
                            CALL COMPELLED
                            GOTO FIGHT

                        CASE 3
                            OFFER:
                            DO
                                COLOR colors(10), colors(2)
                                PRINT "How many gold points do you wish to pay?";
                                INPUT k
                                COLOR colors(15), colors(0)
                                IF k > getWorth(player.coins) THEN
                                    PRINT "You only have"; getWorth(player.coins); "gp."
                                ELSE
                                    EXIT DO
                                END IF
                            LOOP
                            pp = INT(k / 10)
                            gp = INT(k) MOD 10
                            ep = INT(k * 2) MOD 2
                            sp = INT(k * 10) MOD 5
                            cp = INT(k * 100) MOD 10
                            p = 0
                            g = 0
                            e = 0
                            s = 0
                            c = 0
                            WHILE p < pp AND p < player.coins.pp
                                p = p + 1
                            WEND
                            IF p < pp THEN gp = gp + 10 * (pp - p)
                            WHILE g < gp AND g < player.coins.gp
                                g = g + 1
                            WEND
                            IF g < gp THEN ep = ep + 2 * (gp - g)
                            WHILE e < ep AND e < player.coins.ep
                                e = e + 1
                            WEND
                            IF e < ep THEN sp = sp + 10 * (ep - e)
                            WHILE s < sp AND s < player.coins.sp
                                s = s + 1
                            WEND
                            IF s < sp THEN cp = cp + 10 * (sp - s)
                            WHILE c < cp AND c < player.coins.sp
                                c = c + 1
                            WEND
                            IF c < cp THEN
                                PRINT "You don't have exact change!"
                                GOTO OFFER
                            END IF

                            num = INT(RND(1) * 22)
                            l = 0
                            IF num = 21 OR (num > 15 AND k < 2) THEN
                                CALL DEFEATED_BY(currentMonster, colors())
                                RUN
                            END IF
                            num2 = (points + getWorth(money) + (monster * .1)) * howManyMonsters
                            IF k < 2 GOTO 475
                            FOR i = 0 TO 20
                                IF k <= num2 * l AND num >= i GOTO 475
                                l = l + .1
                            NEXT
                            GOTO 485

                            475 PRINT "Your bribe was not accepted.";

                            CALL COMPELLED
                            GOTO FIGHT

                            485 points = 0
                            money = NO_MONEY
                            player.coins.pp = player.coins.pp - p
                            player.coins.gp = player.coins.gp - g
                            player.coins.ep = player.coins.ep - e
                            player.coins.sp = player.coins.sp - s
                            player.coins.cp = player.coins.cp - c
                            bribeCt = bribeCt + 1
                            player.xp = player.xp + xp(monster(n).cr, howManyMonsters)
                            tracker = 0
                            PRINT "Your bribe was accepted.";
                            PRINT "You now have"; getWorth(player.coins); "gp."
                        CASE 4
                            CAST_A_SPELL:
                            DO
                                IF tracker = SLEEP_SPELL OR tracker = CHARM_SPELL OR tracker = INVISIBILITY_SPELL THEN
                                    PRINT "You can't use magic to get magic."
                                    GOTO 280
                                END IF
                                IF player.sleepRemaining + player.invisibilityRemaining + player.charmsRemaining = 0 THEN
                                    PRINT "You have no magic."
                                    GOTO 280
                                END IF
                                COLOR colors(13), colors(5)
                                INPUT "What type of spell-(1)sleep, (2)charm, OR (3)invisibility"; k
                                COLOR colors(15), colors(0)
                                PRINT

                            LOOP WHILE k < 1 OR k > 3
                            ohNo = 0
                            SELECT CASE k
                                CASE 1
                                    IF player.sleepRemaining = 0 THEN
                                        PRINT "You have no sleep spells.";
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    IF currentMonster.disallowSleep = 1 THEN
                                        PRINT "You can't put "; currentMonster.plural; " to sleep.";
                                        player.sleepRemaining = player.sleepRemaining - 1
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    num = rollD(1, 10) - 1
                                    player.sleepRemaining = player.sleepRemaining - 1
                                    IF num < SLEEP_SUCCESS THEN
                                        PRINT "Your spell was unsuccessful.";
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                CASE 2
                                    IF player.charmsRemaining = 0 THEN
                                        PRINT "You have no charms.";
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    IF currentMonster.disallowCharm = 1 THEN
                                        PRINT "You can't charm "; currentMonster.plural; ".";
                                        player.charmsRemaining = player.charmsRemaining - 1
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    num = INT(RND(1) * 10)
                                    player.charmsRemaining = player.charmsRemaining - 1
                                    IF (monster < 60 AND num > 6) OR (monster > 50 AND num < 2) THEN
                                        PRINT "Your charm didn't work.";
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    IF num = 3 THEN
                                        PRINT "The charm wore off too soon."
                                        GOTO 713
                                    END IF
                                    num = 3
                                CASE 3
                                    IF player.invisibilityRemaining = 0 THEN
                                        PRINT "You have no invisibility spells.";
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    IF currentMonster.disallowInvisibility = 1 THEN
                                        PRINT "Oops, "; currentMonster.plural; " can find invisible people!";
                                        player.invisibilityRemaining = player.invisibilityRemaining - 1
                                        ohNo = 1
                                        EXIT SELECT
                                    END IF
                                    num = INT(RND(1) * 10)
                                    player.invisibilityRemaining = player.invisibilityRemaining - 1
                                    IF monster > 50 AND num > 8 THEN
                                        PRINT "The "; colored(currentMonster, colors());
                                        COLOR colors(15)
                                        PRINT " smelled you!"
                                        GOTO 713
                                    END IF
                                    IF monster < 60 AND num = 0 THEN
                                        PRINT "Your invisibility wore off too soon!"
                                        GOTO 713
                                    END IF
                                    num = 3
                            END SELECT
                            IF ohNo = 1 THEN
                                CALL COMPELLED
                                GOTO FIGHT
                            ELSE
                                IF num < 8 THEN
                                    PRINT "You got the treasure safely."
                                    GOTO 500
                                END IF
                                PRINT "The "; colored(currentMonster, colors());
                                COLOR colors(15)
                                PRINT " woke too soon."

                                713 IF getWorth(money) > 0 THEN
                                    money.cp = rollD(1, money.cp) - 1
                                    money.sp = rollD(1, money.sp) - 1
                                    money.ep = rollD(1, money.ep) - 1
                                    money.gp = rollD(1, money.gp) - 1
                                    money.pp = rollD(1, money.gp) - 1
                                    CALL ADD_CURRENCY(player.coins, money)

                                    IF getWorth(money) > 0 THEN
                                        PRINT "You got away with"; getWorth(money); "gp."
                                    END IF
                                ELSE
                                    PRINT "You escaped emptyhanded."
                                END IF
                                GOTO WHERE_TO
                            END IF
                    END SELECT
                    numbers(n) = numbers(n) + howManyMonsters
                    player.xp = player.xp + xp(currentMonster.cr, howManyMonsters)
                    PRINT "You beat the "; colored(currentMonster, colors())
                    COLOR colors(15)
                    PRINT USING "Your Combat Strength is now&."; STR$(player.combatStrengthRemaining)
                END IF

                500 IF n < 12 THEN
                    event = INT(RND(1) * 7)
                    IF event = NOISY_BATTLE THEN
                        DO
                            M = rollD(1, monsterCt)
                            currentMonster = monster(M)
                        LOOP UNTIL appropriateChallenge(playerLevel(player.xp), EASY) >= xp(currentMonster.cr, 1)
                        howManyMonsters = 1
                        monster = currentMonster.cr * 10
                        startsWith$ = LEFT$(currentMonster.name, 1)
                        SELECT CASE startsWith$
                            CASE "a", "e", "i", "o", "u"
                                PRINT "An ";
                            CASE ELSE
                                PRINT "A ";
                        END SELECT
                        PRINT colored(currentMonster, colors());
                        COLOR colors(15)
                        PRINT " heard the noise of the battle and came wandering by."
                        recommendedCombatStrength = INT(currentMonster.cr * 10 * 2 + getWeightCarried(player) / 100) + 1

                        945 IF currentMonster.id = basilisk.id AND mirror = 7 GOTO 835

                        ENGAGED:
                        DO
                            INPUT "Do you wish to (1)fight, (2)run, or (3)cast a spell?"; k
                        LOOP WHILE k < 1 OR k > 3
                        SELECT CASE k
                            CASE 1
                                GOTO FIGHT
                            CASE 2
                                GOTO RUN_AWAY
                            CASE 3
                                GOTO CAST_A_SPELL
                        END SELECT
                    END IF
                END IF
                IF howManyMonsters = NO_GUARDIAN THEN
                    event = INT(RND(1) * 5)
                    IF event = NOISY_BATTLE THEN
                        DO
                            M = rollD(1, monsterCt)
                            currentMonster = monster(M)
                        LOOP UNTIL appropriateChallenge(playerLevel(player.xp), EASY) >= xp(currentMonster.cr, 1)
                        howManyMonsters = 1
                        monster = currentMonster.cr * 10
                        startsWith$ = LEFT$(currentMonster.name, 1)
                        SELECT CASE startsWith$
                            CASE "a", "e", "i", "o", "u"
                                PRINT "An ";
                            CASE ELSE
                                PRINT "A ";
                        END SELECT
                        PRINT colored(currentMonster, colors());
                        COLOR colors(15)
                        PRINT " heard the noise of the battle and came wandering by."
                        recommendedCombatStrength = INT(currentMonster.cr * 10 * 2 + getWeightCarried(player) / 100) + 1
                        GOTO 945
                    END IF
                END IF
                IF points <> 0 THEN
                    IF isSword = 1 THEN
                        num = INT(RND(1) * 2) + 1
                        SELECT CASE num
                            CASE 1
                                player.combatStrengthRemaining = 2 * player.combatStrengthRemaining
                                PRINT "You won an enchanted sword. Your Combat Strength "
                                PRINT "is doubled and is now"; player.combatStrengthRemaining
                            CASE 2
                                PRINT "You won an ordinary sword."
                        END SELECT
                    END IF
                ELSEIF tracker = SLEEP_SPELL OR tracker = CHARM_SPELL OR tracker = INVISIBILITY_SPELL THEN
                    player.treasure.gp = player.treasure.gp - points
                    LEARN_SPELL:
                    event = INT(RND(1) * 10)
                    IF event = UNABLE_TO_MASTER_SPELL THEN
                        PRINT "You were unable to master the spell.";
                        PRINT "You gain no ";
                        COLOR colors(itemColor(tracker - 5)) 'SPELL_#_IS_GUARDED
                        PRINT items$(tracker - 5); 'SPELL_#_IS_GUARDED
                        COLOR colors(15)
                        PRINT "s"
                        GOTO WHERE_TO
                    END IF
                    SELECT CASE tracker
                        CASE SLEEP_SPELL
                            player.sleepRemaining = player.sleepRemaining + 1
                            player.sleepMax = player.sleepMax + 1
                        CASE CHARM_SPELL
                            player.charmsRemaining = player.charmsRemaining + 1
                            player.charmsMax = player.charmsRemaining + 1
                        CASE INVISIBILITY_SPELL
                            player.invisibilityRemaining = player.invisibilityRemaining + 1
                            player.invisibilityMax = player.invisibilityMax + 1
                    END SELECT
                    PRINT "You won the ";
                    COLOR colors(itemColor(tracker - 5)) 'SPELL_#_IS_GUARDED
                    PRINT items$(tracker - 5) 'SPELL_#_IS_GUARDED
                    COLOR colors(15)
                    tracker = 0
                    IF player.sleepMax / 5 + player.charmsMax / 3 + player.invisibilityMax / 2 > 6 THEN
                        INPUT "Your magic total is rather large. Do you wish to convert it to Combat Points?"; X$
                        IF UCASE$(X$) = "Y" THEN
                            player.sleepMax = player.sleepMax - 5
                            player.charmsMax = player.charmsMax - 3
                            player.invisibilityMax = player.invisibilityMax - 2
                            IF player.sleepMax <= 0 THEN player.sleepMax = 1
                            IF player.charmsMax <= 0 THEN player.charmsMax = 1
                            IF player.invisibilityMax <= 0 THEN player.invisibilityMax = 1
                            player.sleepRemaining = player.sleepMax
                            player.charmsRemaining = player.charmsMax
                            player.invisibilityRemaining = player.invisibilityMax
                            buff = 100
                            player.combatStrengthRemaining = player.combatStrengthRemaining + buff
                            player.maxCombatStrength = player.maxCombatStrength + buff
                            PRINT "Your Combat Strength is permanently increased by"; buff
                        END IF
                    END IF
                    GOTO WHERE_TO
                END IF
                IF isChest = 1 THEN
                    num2 = INT(RND(1) * 10)
                    num = INT(RND(1) * 10)
                    IF num2 = 7 AND mirror <> 7 THEN
                        mirror = 7
                        PRINT "There was a mirror in the chest. It'll protect you"
                        PRINT "against any "; colored(basilisk, colors()); "s";
                        COLOR colors(15)
                        PRINT " you may meet."
                        mirror = 7
                        GOTO WHERE_TO
                    END IF
                    IF num = 1 THEN
                        830 PRINT "The treasure chest was a "; colored(mimic, colors());
                        COLOR colors(15)
                        PRINT "!"
                        points = 0
                        currentMonster = mimic
                        monster = mimic.cr * 10
                        recommendedCombatStrength = INT(mimic.cr * 10 * 2 + getWeightCarried(player) / 100) + 1
                        GOTO ENGAGED
                    END IF
                END IF
                IF getWorth(money) > 0 THEN
                    CALL ADD_CURRENCY(player.coins, money)
                    PRINT "You now have"; getWorth(player.coins); "gp."
                    money = NO_MONEY
                END IF
                IF points > 0 THEN
                    player.treasure.gp = player.treasure.gp + points
                    PRINT "You now have"; player.treasure.gp; "Treasure Points."
                    points = 0
                END IF
                IF tracker = ENTERING_CASTLE THEN GOSUB ENTER_CASTLE
        END SELECT

        WHERE_TO:
        INPUT "Which direction? (Press 0 for the map.)"; X$
        IF X$ = "0" THEN
            tracker = CHECKING_MAP
            _CONTINUE
        END IF
        X$ = UCASE$(X$)
        tracker = 0
        k = 1
        IF timeInForest < 30 * DAY THEN

            X$ = UCASE$(X$)
            SELECT CASE VAL(X$)
                CASE 1
                    X$ = "SW"
                CASE 2
                    X$ = "S"
                CASE 3
                    X$ = "SE"
                CASE 4
                    X$ = "W"
                CASE 5
                    GOTO WHERE_TO
                CASE 6
                    X$ = "E"
                CASE 7
                    X$ = "NW"
                CASE 8
                    X$ = "N"
                CASE 9
                    X$ = "NE"
            END SELECT

            IF LEFT$(X$, 1) = "N" THEN
                newCoords.y = player.coords.y - k
            ELSEIF LEFT$(X$, 1) = "S" THEN
                newCoords.y = player.coords.y + k
            ELSE newCoords.y = player.coords.y

            END IF
            IF RIGHT$(X$, 1) = "E" THEN
                newCoords.x = player.coords.x + k
            ELSEIF RIGHT$(X$, 1) = "W" THEN
                newCoords.x = player.coords.x - k
            ELSE newCoords.x = player.coords.x
            END IF
            SELECT CASE world(player.coords.x, player.coords.y)
                CASE 0
                    difficultTerrain = 1
            END SELECT
            timeInForest = timeInForest + travelTime(player.speed, asymptote(player.coords, newCoords))
            IF player.combatStrengthRemaining <= 0 THEN
                PRINT "You died from lack of strength.";
                LOSS
                RUN
            END IF
            IF newCoords.x > 100 OR newCoords.x < 1 OR newCoords.y > 100 OR newCoords.y < 1 THEN
                exitForest = 1
                EXIT DO
            END IF
            IF world(newCoords.x, newCoords.y) = 7 THEN tracker = ENTERING_CASTLE
            IF world(newCoords.x, newCoords.y) = 4 THEN
                player.coords = newCoords
                GOTO PIT
            END IF
            IF world(newCoords.x, newCoords.y) = 2 THEN
                PRINT "You tried to go through a wall."
                player.combatStrengthRemaining = player.combatStrengthRemaining - INT(RND(1) * player.treasure.gp * .005) - 25
                PRINT USING "Your Combat Strength is now&."; STR$(player.combatStrengthRemaining)
                GOTO WHERE_TO
            END IF
            IF world(newCoords.x, newCoords.y) = 3 THEN
                PRINT newCoords.x
                PRINT newCoords.y
                newCoords.x = player.coords.x
                newCoords.y = player.coords.y
                IF player.maxCombatStrength > player.combatStrengthRemaining THEN player.combatStrengthRemaining = player.maxCombatStrength
                world(player.coords.x, player.coords.y) = world(newCoords.x, newCoords.y)
                tracker = ENTERING_INN
                player.invisibilityRemaining = player.invisibilityMax
                player.charmsRemaining = player.charmsMax
                player.sleepRemaining = player.sleepMax
                timeInForest = timeInForest + 8 * HOUR
                GOSUB CHECK_MAP
                PRINT "You stopped at an inn and regained your strength."
                IF getWorth(player.treasure) > 0 THEN
                    WHILE player.treasure.gp >= 10
                        player.treasure.gp = player.treasure.gp - 10
                        player.coins.pp = player.coins.pp + 1
                    WEND

                    WHILE player.treasure.gp >= 1
                        player.treasure.gp = player.treasure.gp - 1
                        player.coins.gp = player.coins.gp + 1
                    WEND

                    WHILE player.treasure.gp >= .5
                        player.treasure.gp = player.treasure.gp - .5
                        player.coins.ep = player.coins.ep + 1
                    WEND

                    WHILE player.treasure.gp >= .1
                        player.treasure.gp = player.treasure.gp - .1
                        player.coins.sp = player.coins.sp + 1
                    WEND
                    WHILE player.treasure.gp >= .01
                        player.treasure.gp = player.treasure.gp - .01
                        player.coins.cp = player.coins.cp + 1
                    WEND
                    PRINT "You exchanged your treasure for coins."
                END IF

                WHILE player.coins.cp >= 10
                    player.coins.cp = player.coins.cp - 10
                    player.coins.sp = player.coins.sp + 1
                    converted = 1
                WEND

                WHILE player.coins.sp >= 5
                    player.coins.sp = player.coins.sp - 5
                    player.coins.ep = player.coins.ep + 1
                    converted = 1
                WEND

                WHILE player.coins.ep >= 2
                    player.coins.ep = player.coins.ep - 2
                    player.coins.gp = player.coins.gp + 1
                    converted = 1
                WEND

                WHILE player.coins.gp >= 10
                    player.coins.gp = player.coins.gp - 10
                    player.coins.pp = player.coins.pp + 1
                    converted = 1
                WEND

                IF converted = 1 THEN PRINT "You converted your coins to lighten your load."
                converted = 0

                DIM charge AS DOUBLE
                charge = CDBL(INT(rollD(1, 100) * RND(1) * (getWorth(player.treasure) + getWorth(player.coins)) * .75)) / 100
                IF charge < 5 THEN
                    SELECT CASE (getWorth(player.treasure) + getWorth(player.coins))
                        CASE IS > 5
                            charge = 5
                        CASE IS <= 5
                            charge = 0
                    END SELECT
                END IF
                IF charge > 0 THEN
                    gp = INT(charge) MOD 10
                    ep = INT(charge * 2) MOD 2
                    sp = INT(charge * 10) MOD 5
                    cp = INT(charge * 100) MOD 10
                    paid = 0.0

                    WHILE charge - paid >= 10 AND player.coins.pp > 0
                        IF player.coins.pp > 0 THEN
                            player.coins.pp = player.coins.pp - 1
                            paid = paid + 10
                            IF paid > charge THEN
                                player.coins.gp = player.coins.gp + 9
                                paid = paid - 9
                            END IF
                        END IF
                    WEND

                    WHILE charge - paid >= 1 AND player.coins.pp + player.coins.gp > 0
                        IF player.coins.gp > 0 THEN
                            player.coins.gp = player.coins.gp - 1
                            paid = paid + 1
                            IF paid > charge THEN
                                player.coins.ep = player.coins.ep + 1
                                paid = paid - .5
                            END IF
                        ELSEIF player.coins.pp > 0 THEN
                            player.coins.pp = player.coins.pp - 1
                            paid = paid + 10
                            IF paid > charge THEN
                                player.coins.gp = player.coins.gp + 9
                                paid = paid - 9
                            END IF
                        END IF
                    WEND

                    WHILE charge - paid >= .5 AND player.coins.pp + player.coins.gp + player.coins.ep > 0
                        IF player.coins.ep > 0 THEN
                            player.coins.ep = player.coins.ep - 1
                            paid = paid + .5
                            IF paid > charge THEN
                                player.coins.sp = player.coins.sp + 4
                                paid = paid - .4
                            END IF
                        ELSEIF player.coins.gp > 0 THEN
                            player.coins.gp = player.coins.gp - 1
                            paid = paid + 1
                            IF paid > charge THEN
                                player.coins.ep = player.coins.ep + 1
                                paid = paid - .5
                            END IF
                        ELSEIF player.coins.pp > 0 THEN
                            player.coins.pp = player.coins.pp - 1
                            paid = paid + 10
                            IF paid > charge THEN
                                player.coins.gp = player.coins.gp + 9
                                paid = paid - 9
                            END IF
                        END IF
                    WEND
                    WHILE charge - paid >= .1 AND player.coins.pp + player.coins.gp + player.coins.ep + player.coins.sp > 0
                        IF player.coins.sp > 0 THEN
                            player.coins.sp = player.coins.sp - 1
                            paid = paid + .1
                            IF paid > charge THEN
                                player.coins.cp = player.coins.cp + 9
                                paid = paid - .9
                            END IF
                        ELSEIF player.coins.ep > 0 THEN
                            player.coins.ep = player.coins.ep - 1
                            paid = paid + .5
                            IF paid > charge THEN
                                player.coins.sp = player.coins.sp + 4
                                paid = paid - .4
                            END IF
                        ELSEIF player.coins.gp > 0 THEN
                            player.coins.gp = player.coins.gp - 1
                            paid = paid + 1
                            IF paid > charge THEN
                                player.coins.ep = player.coins.ep + 1
                                paid = paid - .5
                            END IF
                        ELSEIF player.coins.pp > 0 THEN
                            player.coins.pp = player.coins.pp - 1
                            paid = paid + 10
                            IF paid > charge THEN
                                player.coins.gp = player.coins.gp + 9
                                paid = paid - 9
                            END IF
                        END IF
                    WEND
                    WHILE charge - paid >= .01 AND player.coins.pp + player.coins.gp + player.coins.ep + player.coins.sp + player.coins.cp > 0
                        IF player.coins.cp > 0 THEN
                            player.coins.cp = player.coins.cp - 1
                            paid = paid + .01
                        ELSEIF player.coins.sp > 0 THEN
                            player.coins.sp = player.coins.sp - 1
                            paid = paid + .1
                            IF paid > charge THEN
                                player.coins.cp = player.coins.cp + 9
                                paid = paid - .9
                            END IF
                        ELSEIF player.coins.ep > 0 THEN
                            player.coins.ep = player.coins.ep - 1
                            paid = paid + .5
                            IF paid > charge THEN
                                player.coins.sp = player.coins.sp + 4
                                paid = paid - .4
                            END IF
                        ELSEIF player.coins.gp > 0 THEN
                            player.coins.gp = player.coins.gp - 1
                            paid = paid + 1
                            IF paid > charge THEN
                                player.coins.ep = player.coins.ep + 1
                                paid = paid - .5
                            END IF
                        ELSEIF player.coins.pp > 0 THEN
                            player.coins.pp = player.coins.pp - 1
                            paid = paid + 10
                            IF paid > charge THEN
                                player.coins.gp = player.coins.gp + 9
                                paid = paid - 9
                            END IF
                        END IF
                    WEND
                    PRINT "You paid"; charge; "gp to stay there."
                    PRINT "You now have"; getWorth(player.coins); "gp."
                ELSE
                    PRINT "The innkeeper took pity, and you were not charged for the stay."
                END IF
                num = INT(RND(1) * 3)
                SELECT CASE num
                    CASE 1
                        IF castlesLeft = 0 THEN EXIT SELECT 'innkeeper only tells known castles
                        num = INT(RND(1) * castlesLeft + 1)
                        PRINT "The innkeeper told of a legend of a castle ";
                        CALL WHERE_IS_IT(castle(num).coords, player.coords)
                        GOTO WHERE_TO
                    CASE 2
                        GOTO WHERE_TO
                END SELECT
                num = INT(RND(1) * 4 + 1)
                PRINT "The innkeeper told you that the forest edge is less than"
                SELECT CASE num
                    CASE 1
                        PRINT 2 * (INT(player.coords.y / 10) * 10 + 10); "yards to the north."
                    CASE 2
                        PRINT 2 * (INT((100 - player.coords.y) / 10) * 10 + 10); "yards to the south."
                    CASE 3
                        PRINT 2 * (INT(player.coords.x / 10) * 10 + 10); "yards to the west."
                    CASE 4
                        PRINT 2 * (INT((100 - player.coords.x) / 10) * 10 + 10); "yards to the east."
                END SELECT
                GOTO WHERE_TO

            END IF
            player.coords.x = newCoords.x
            player.coords.y = newCoords.y
        ELSE
            PRINT "Your time's up. 30 days have passed."
            SLEEP 1
            GOTO GIANT_EAGLE
        END IF

    LOOP
    IF exitForest = 1 THEN EXIT DO
LOOP
SLEEP 3.75
CLS

PRINT "You survived the forest!"
SLEEP 1
INPUT "Do you wish to see the number of monsters you killed, ran from, and bribed?"; X$

IF UCASE$(X$) = "N" THEN
    PRINT
ELSE
    PRINT "MONSTER"; TAB(11); "NO. SLAIN"; TAB(32); "MONSTER"; TAB(43); "NO. SLAIN"
    FOR i = 1 TO monsterCt / 2
        PRINT monster(i).name; TAB(14); numbers(i); TAB(32); monster(monsterCt / 2 + monsterCt MOD 2 + i).name;
        PRINT TAB(46); numbers(i + 6)
    NEXT
    IF monsterCt MOD 2 = 1 THEN PRINT TAB(32); monster(monsterCt / 2 + 1).name, TAB(46); numbers(13)
    PRINT
    PRINT "BRIBED-"; bribeCt; TAB(32); "RAN FROM"; runCt
END IF
PRINT TAB(10); "TREASURE TOTAL-"; player.treasure.gp
IF treasurePointsPrev <> 0 THEN
    IF treasurePointsPrev < player.treasure.gp THEN PRINT "You won more treasure this time than before."
    IF treasurePointsPrev > player.treasure.gp THEN PRINT "You didn't obtain as much treasure this time."
END IF
PRINT "Congratulations";
IF treasurePointsPrev <> 0 AND treasurePointsPrev > player.treasure.gp THEN
    PRINT " anyway"
    PRINT
END IF
PRINT
X$ = ""
IF timeInForest < DAY * 30 THEN INPUT "Do you wish to return to the forest"; X$
timeInForest = 0
player.sleepRemaining = player.sleepMax
player.invisibilityRemaining = player.invisibilityMax
player.charmsRemaining = player.charmsMax
player.combatStrengthRemaining = player.maxCombatStrength
IF UCASE$(X$) <> "Y" THEN
    SLEEP 2
    PRINT
    INPUT "Do you wish to go to a new forest with the same strength and magic?"; X$
    IF UCASE$(X$) = "Y" THEN GOTO INITIALIZE
    INPUT "Do you wish to go to a new forest with a new strength and magic?"; X$
    IF UCASE$(X$) = "Y" THEN RUN
    INPUT "Do you want to see your strength and magic so you can record it?"; X$
    IF UCASE$(X$) = "Y" THEN
        PRINT "COMBAT STRENGTH-"; player.maxCombatStrength
        PRINT "SLEEP SPELLS-"; player.sleepMax
        PRINT "CHARMS-"; player.charmsMax
        PRINT "INVISIBILITY-"; player.invisibilityMax
        PRINT
    END IF
    PRINT
    PRINT "Once again, your Treasure Total was"; player.treasure.gp
    IF player.treasure.gp > treasurePointsPrev THEN treasurePointsPrev = player.treasure.gp
    IF treasurePointsPrev <> 0 THEN PRINT "The largest Treasure Total you got with this strength and magic was"; treasurePointsPrev
    END
END IF
CLS
GOTO RANDOM_LOC

DISPLACEMENT:
newCoords = player.coords
k = 0
tracker = 0
DO
    player.coords.x = newCoords.x + rollD(1, 3) - 2
    player.coords.y = newCoords.y + rollD(1, 3) - 2
    IF player.coords.x = newCoords.x AND player.coords.y = newCoords.y THEN _CONTINUE
    speed = player.speed
    IF difficultTerrain = 1 THEN speed = speed / 2
    IF num <> 11 THEN speed = speed * 4 / 3
    timeInForest = timeInForest + travelTime(speed, asymptote(player.coords, newCoords))
    difficultTerrain = 0
LOOP WHILE world(player.coords.x, player.coords.y) > 1 AND k = 0
IF num <> 11 THEN runCt = runCt + 1
GOTO CHECK_MAP

SUB ADD_CURRENCY (c1 AS Currency, c2 AS Currency)
    c1.cp = c1.cp + c2.cp
    c1.sp = c1.sp + c2.sp
    c1.ep = c1.ep + c2.ep
    c1.gp = c1.gp + c2.gp
    c1.pp = c1.pp + c2.pp
END SUB

SUB WHERE_IS_IT (castleCoords AS Coordinates, myCoords AS Coordinates):
    IF ABS(castleCoords.x - myCoords.x) < 5 AND ABS(castleCoords.y - myCoords.y) < 5 THEN
        PRINT "very close by."
        EXIT SUB
    END IF
    num2 = myCoords.x - castleCoords.x
    num = myCoords.y - castleCoords.y
    IF ABS(ABS(num) - ABS(num2)) < 5 THEN
        PRINT "directly to the ";
    ELSE
        PRINT "somewhere to the ";
    END IF
    SELECT CASE num
        CASE IS < 0
            PRINT "south";
        CASE IS > 0
            PRINT "north";
    END SELECT
    SELECT CASE num2
        CASE IS > 0
            PRINT "west.";
        CASE IS < 0
            PRINT "east.";
        CASE ELSE
            PRINT ".";
    END SELECT
    PRINT
END SUB

SUB COMPELLED
    PRINT "You must fight."
END SUB

SUB DEFEATED_BY (monster AS Entity, colors() AS LONG)
    PRINT "The "; colored(monster, colors());
    COLOR colors(15)
    PRINT " killed you. ";
    LOSS
END SUB

SUB LOSS
    INPUT "You lose everything! Wish to try again?"; X$
    PRINT
    IF UCASE$(X$) = "Y" THEN EXIT SUB
    PRINT
    PRINT "So long... Better luck next time!"
    END
END SUB

FUNCTION travelTime# (speed AS SINGLE, distance AS DOUBLE)
    travelTime = distance / speed
END FUNCTION

FUNCTION asymptote# (c1 AS Coordinates, c2 AS Coordinates)
    asymptote = SQR((c1.x - c2.x) ^ 2 + (c1.y - c2.y) ^ 2)
END FUNCTION

FUNCTION getSpeed# (player AS Entity)
    SELECT CASE getEncumbrance(player)
        CASE 0
            getSpeed = player.speed
        CASE 5
            getSpeed = 2 * player.speed / 3
        CASE IS >= 10
            getSpeed = player.speed / 3
    END SELECT
END FUNCTION

FUNCTION blend& (c1 AS LONG, c2 AS LONG)
    blend = _RGB32((_RED32(c1) + _RED32(c2)) / 2, (_GREEN32(c1) + _GREEN32(c2)) / 2, (_BLUE32(c1) + _BLUE32(c2)) / 2)
END FUNCTION


FUNCTION colored$ (e AS Entity, colors() AS LONG)
    COLOR colors(e.color)
    colored$ = "" + e.name
END FUNCTION

FUNCTION playerLevel% (experiencePoints AS LONG)
    SELECT CASE experiencePoints
        CASE IS < 300
            playerLevel = 1
        CASE IS < 900
            playerLevel = 2
        CASE IS < 2700
            playerLevel = 3
        CASE IS < 6500
            playerLevel = 4
        CASE IS < 14000
            playerLevel = 5
        CASE IS < 23000
            playerLevel = 6
        CASE IS < 34000
            playerLevel = 7
        CASE IS < 48000
            playerLevel = 8
        CASE IS < 64000
            playerLevel = 9
        CASE IS < 85000
            playerLevel = 10
        CASE IS < 100000
            playerLevel = 11
        CASE IS < 120000
            playerLevel = 12
        CASE IS < 140000
            playerLevel = 13
        CASE IS < 165000
            playerLevel = 14
        CASE IS < 195000
            playerLevel = 15
        CASE IS < 225000
            playerLevel = 16
        CASE IS < 265000
            playerLevel = 17
        CASE IS < 305000
            playerLevel = 18
        CASE IS < 355000
            playerLevel = 19
        CASE IS < 410000
            playerLevel = 20
    END SELECT
END FUNCTION

FUNCTION appropriateChallenge% (characterLevel, encounterDifficulty)
    SELECT CASE encounterDifficulty
        CASE EASY
            SELECT CASE characterLevel
                CASE 1
                    appropriateChallenge = 25
                CASE 2
                    appropriateChallenge = 50
                CASE 3
                    appropriateChallenge = 75
                CASE 4
                    appropriateChallenge = 125
                CASE 5
                    appropriateChallenge = 250
                CASE 6
                    appropriateChallenge = 300
                CASE 7
                    appropriateChallenge = 350
                CASE 8
                    appropriateChallenge = 450
                CASE 9
                    appropriateChallenge = 550
                CASE 10
                    appropriateChallenge = 600
                CASE 11
                    appropriateChallenge = 800
                CASE 12
                    appropriateChallenge = 1000
                CASE 13
                    appropriateChallenge = 1100
                CASE 14
                    appropriateChallenge = 1250
                CASE 15
                    appropriateChallenge = 1400
                CASE 16
                    appropriateChallenge = 1600
                CASE 17
                    appropriateChallenge = 2000
                CASE 18
                    appropriateChallenge = 2100
                CASE 19
                    appropriateChallenge = 2400
                CASE 20
                    appropriateChallenge = 2800
            END SELECT
        CASE MEDIUM
            SELECT CASE characterLevel
                CASE 1
                    appropriateChallenge = 50
                CASE 2
                    appropriateChallenge = 100
                CASE 3
                    appropriateChallenge = 150
                CASE 4
                    appropriateChallenge = 250
                CASE 5
                    appropriateChallenge = 500
                CASE 6
                    appropriateChallenge = 600
                CASE 7
                    appropriateChallenge = 750
                CASE 8
                    appropriateChallenge = 900
                CASE 9
                    appropriateChallenge = 1100
                CASE 10
                    appropriateChallenge = 1200
                CASE 11
                    appropriateChallenge = 1600
                CASE 12
                    appropriateChallenge = 2000
                CASE 13
                    appropriateChallenge = 2200
                CASE 14
                    appropriateChallenge = 2500
                CASE 15
                    appropriateChallenge = 2800
                CASE 16
                    appropriateChallenge = 3200
                CASE 17
                    appropriateChallenge = 3900
                CASE 18
                    appropriateChallenge = 4200
                CASE 19
                    appropriateChallenge = 4900
                CASE 20
                    appropriateChallenge = 5700
            END SELECT
        CASE HARD
            SELECT CASE characterLevel
                CASE 1
                    appropriateChallenge = 75
                CASE 2
                    appropriateChallenge = 150
                CASE 3
                    appropriateChallenge = 225
                CASE 4
                    appropriateChallenge = 375
                CASE 5
                    appropriateChallenge = 750
                CASE 6
                    appropriateChallenge = 900
                CASE 7
                    appropriateChallenge = 1100
                CASE 8
                    appropriateChallenge = 1400
                CASE 9
                    appropriateChallenge = 1600
                CASE 10
                    appropriateChallenge = 1900
                CASE 11
                    appropriateChallenge = 2400
                CASE 12
                    appropriateChallenge = 3000
                CASE 13
                    appropriateChallenge = 3400
                CASE 14
                    appropriateChallenge = 3800
                CASE 15
                    appropriateChallenge = 4300
                CASE 16
                    appropriateChallenge = 4800
                CASE 17
                    appropriateChallenge = 5900
                CASE 18
                    appropriateChallenge = 6300
                CASE 19
                    appropriateChallenge = 7300
                CASE 20
                    appropriateChallenge = 8500
            END SELECT
        CASE DEADLY
            SELECT CASE characterLevel
                CASE 1
                    appropriateChallenge = 100
                CASE 2
                    appropriateChallenge = 200
                CASE 3
                    appropriateChallenge = 400
                CASE 4
                    appropriateChallenge = 500
                CASE 5
                    appropriateChallenge = 1100
                CASE 6
                    appropriateChallenge = 1400
                CASE 7
                    appropriateChallenge = 1700
                CASE 8
                    appropriateChallenge = 2100
                CASE 9
                    appropriateChallenge = 2400
                CASE 10
                    appropriateChallenge = 2800
                CASE 11
                    appropriateChallenge = 3600
                CASE 12
                    appropriateChallenge = 4500
                CASE 13
                    appropriateChallenge = 5100
                CASE 14
                    appropriateChallenge = 5700
                CASE 15
                    appropriateChallenge = 6400
                CASE 16
                    appropriateChallenge = 7200
                CASE 17
                    appropriateChallenge = 8800
                CASE 18
                    appropriateChallenge = 9500
                CASE 19
                    appropriateChallenge = 10900
                CASE 20
                    appropriateChallenge = 12700
            END SELECT
    END SELECT
END FUNCTION
FUNCTION xp&& (cr, numMonsters)
    SELECT CASE cr
        CASE 0
            xp = 10 * numMonsters
        CASE 1 / 8
            xp = 25 * numMonsters
        CASE 1 / 4
            xp = 50 * numMonsters
        CASE 1 / 2
            xp = 100 * numMonsters
        CASE 1
            xp = 200 * numMonsters
        CASE 2
            xp = 450 * numMonsters
        CASE 3
            xp = 700 * numMonsters
        CASE 4
            xp = 1100 * numMonsters
        CASE 5
            xp = 1800 * numMonsters
        CASE 6
            xp = 2300 * numMonsters
        CASE 7
            xp = 2900 * numMonsters
        CASE 8
            xp = 3900 * numMonsters
        CASE 9
            xp = 5000 * numMonsters
        CASE 10
            xp = 5900 * numMonsters
        CASE 11
            xp = 7200 * numMonsters
        CASE 12
            xp = 8400 * numMonsters
        CASE 13
            xp = 10000 * numMonsters
        CASE 14
            xp = 11500 * numMonsters
        CASE 15
            xp = 13000 * numMonsters
        CASE 16
            xp = 15000 * numMonsters
        CASE 17
            xp = 18000 * numMonsters
        CASE 18
            xp = 20000 * numMonsters
        CASE 19
            xp = 20000 * numMonsters
        CASE 20
            xp = 25000 * numMonsters
        CASE 21
            xp = 33000 * numMonsters
        CASE 22
            xp = 41000 * numMonsters
        CASE 23
            xp = 50000 * numMonsters
        CASE 24
            xp = 62000 * numMonsters
        CASE 25
            xp = 75000 * numMonsters
        CASE 26
            xp = 90000 * numMonsters
        CASE 27
            xp = 105000 * numMonsters
        CASE 28
            xp = 120000 * numMonsters
        CASE 29
            xp = 135000 * numMonsters
        CASE 30
            xp = 155000 * numMonsters
    END SELECT
END FUNCTION

FUNCTION adjustedXp&& (numberOfMonsters, xPoints AS LONG)
    SELECT CASE numberOfMonsters
        CASE 1
            multiplier = 1
        CASE 2
            multiplier = 1.5
        CASE 3 TO 6
            multiplier = 2
        CASE 7 TO 10
            multiplier = 2.5
        CASE 11 TO 14
            multiplier = 3
        CASE IS >= 15
            multiplier = 4
    END SELECT
    adjustedXp = xPoints * numberOfMonsters * multiplier
END FUNCTION

FUNCTION getWorth# (currency AS Currency)
    getWorth = CDBL(FIX((CDBL(currency.cp) * .01 + CDBL(currency.sp) * .1 + CDBL(currency.ep) * .5 + CDBL(currency.gp) + CDBL(currency.pp) * 10) * 100)) / 100
END FUNCTION

FUNCTION getWeightCarried# (entity AS Entity)
    getWeightCarried = (entity.coins.cp + entity.coins.sp + entity.coins.ep + entity.coins.gp + entity.coins.pp + entity.treasure.cp + entity.treasure.sp + entity.treasure.ep + entity.treasure.gp + entity.treasure.pp) / 50
END FUNCTION

FUNCTION getEncumbrance%% (entity AS Entity)
    carriedWeight = getWeightCarried(entity)
    IF carriedWeight < entity.abilities.str * 5 THEN getEncumbrance = 0
    IF carriedWeight < entity.abilities.str * 10 THEN getEncumbrance = 5
    IF carriedWeight < entity.abilities.str * 15 THEN getEncumbrance = 10
    getEncumbrance = 15
END FUNCTION

FUNCTION rollD% (ct, sides) 'in: number of sides on die. out: total result
    FOR i = 1 TO ct
        total = total + INT(RND * sides) + 1
    NEXT
    rollD = total
END FUNCTION

FUNCTION check` (ability, target)
    IF rollD(1, 20) + modifier(ability) < target THEN
        check = 1
        PRINT "hit";
    ELSE
        check = 0
        PRINT "miss";
    END IF
END FUNCTION

FUNCTION ac%% (entity AS Entity)
    ac = 10 + modifier(entity.abilities.dex)
END FUNCTION

FUNCTION modifier%% (ability)
    modifier = INT(ability / 2) - 5
END FUNCTION

FUNCTION DIR$ (spec$) '  Code by Ted Weissgerber
    CONST TmpFile$ = "DIR$INF0.INF", ListMAX% = 500 'change maximum to suit your needs
    SHARED DIRCount% 'returns file count if desired
    STATIC Ready%, Index%, DirList$()
    IF NOT Ready% THEN REDIM DirList$(ListMAX%): Ready% = -1 'DIM array first use
    IF spec$ > "" THEN 'get file names when a spec is given
        SHELL _HIDE "DIR " + spec$ + " /b > " + TmpFile$
        Index% = 0: DirList$(Index%) = "": ff% = FREEFILE
        OPEN TmpFile$ FOR APPEND AS #ff%
        size& = LOF(ff%)
        CLOSE #ff%
        IF size& = 0 THEN KILL TmpFile$: EXIT FUNCTION
        OPEN TmpFile$ FOR INPUT AS #ff%
        DO WHILE NOT EOF(ff%) AND Index% < ListMAX%
            Index% = Index% + 1
            LINE INPUT #ff%, DirList$(Index%)
        LOOP
        DIRCount% = Index% 'SHARED variable can return the file count
        CLOSE #ff%
        KILL TmpFile$
    ELSE IF Index% > 0 THEN Index% = Index% - 1 'no spec sends next file name
    END IF
    DIR$ = DirList$(Index%)
END FUNCTION

FUNCTION getTime$ (t AS DOUBLE) 't is time in seconds
    DIM s AS DOUBLE, m AS DOUBLE, h AS DOUBLE, d AS DOUBLE
    t = CDBL(INT(t))
    s = CDBL(INT(t) MOD 60)
    m = CDBL(INT(t / 60) MOD 60)
    h = CDBL(INT(t / 3600) MOD 24)
    d = CDBL(INT(t / 86400))
    s$ = ""
    SELECT EVERYCASE 0
        CASE IS < d
            s$ = STR$(d) + " days"
            IF h + m + s > 0 THEN s$ = s$ + ", "
        CASE IS < h
            s$ = s$ + STR$(h) + " hours"
            IF m + s > 0 THEN s$ = s$ + ", "
        CASE IS < m
            IF m > 0 THEN s$ = s$ + STR$(m) + " minutes"
            IF s > 0 THEN s$ = s$ + ", "
        CASE IS < s
            IF s > 0 THEN s$ = s$ + STR$(s) + " seconds"
    END SELECT
    IF s$ = "" THEN s$ = " 0 seconds"
    getTime$ = s$
END FUNCTION
