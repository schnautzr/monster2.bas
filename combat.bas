DATA player,0,10
DATA 10,10,10,10,10

DATA monster,0,10
DATA 10,10,10,10,10
n = 1

DIM players$(n), surprise(n), strength(n), dexterity(n), constitution(n), intelligence(n), wisdom(n), charisma(n)
FOR i = 0 TO n
    READ players$(i), surprise(i)
    READ strength(i), dexterity(i), constitution(i), intelligence(i), wisdom(i), charisma(i)
NEXT i


'determine surprise

'establish positions

'roll initiative
playerInit = rollD(1, 20, modifier(dexterity(0)))
monsterInit = rollD(1, 20, modifier(dexterity(1)))

'player's turn
IF check(strength(0), ac(1)) = 1 THEN
    hp(1) = hp(1) - rollD(1, 8, modifier(strength(0)))
ELSE
    PRINT "You missed!"
END IF

'monster's turn
IF check(strength(1), ac(0)) = 1 THEN
    hp(0) = hp(0) - rollD(1, 8, modifier(strength(1)))
ELSE
    PRINT "You missed!"
END IF

FUNCTION rollD (quantity, sides, rollModifier)
    total = 0
    FOR i = 1 TO quantity
        total = total + INT(RND * sides) + 1
    NEXT
    rollD = total + rollModifier
END FUNCTION

FUNCTION check (ability, target)
    IF rollD(1, 20, modifier(ability)) < target THEN
        check = 1
    ELSE
        check = -1
    END IF
END FUNCTION

FUNCTION ac (player)
    ac = 10 + modifier(dexterity(player))
END FUNCTION

FUNCTION modifier (ability)
    modifier = INT(ability / 2) - 5
END FUNCTION
