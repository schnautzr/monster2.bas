DIM lc AS LONG, ls AS LONG, le AS LONG, lg AS LONG, lp AS LONG
DIM fc AS _FLOAT, fs AS _FLOAT, fe AS _FLOAT, fg AS _FLOAT, fp AS _FLOAT
DIM dc AS DOUBLE, ds AS DOUBLE, de AS DOUBLE, dg AS DOUBLE, dp AS DOUBLE
DIM sc AS SINGLE, ss AS SINGLE, se AS SINGLE, sg AS SINGLE, sp AS SINGLE

lc = 9: ls = 1: le = 0: lg = 2: lp = 822
fc = lc: fs = ls: fe = le: fg = lg: fp = lp
dc = lc: ds = ls: de = le: dg = lg: dp = lp
sc = lc: ss = ls: se = le: sg = lg: sp = lp
PRINT .01 * lc + .1 * ls + .5 * le + lg + 10 * lp - 8222
PRINT .01 * fc + .1 * fs + .5 * fe + fg + 10 * fp - 8222
PRINT .01 * dc + .1 * ds + .5 * de + dg + 10 * dp - 8222
PRINT .01 * sc + .1 * ss + .5 * se + sg + 10 * sp - 8222

