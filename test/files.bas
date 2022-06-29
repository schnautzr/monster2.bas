file$ = DIR$("*.bas")
IF DIRCount% > 1 THEN
    DO
        file$ = DIR$("") 'use an empty string parameter to return a list of files!
        PRINT file$
    LOOP UNTIL LEN(file$) = 0 'file list ends with an empty string
END IF

FUNCTION DIR$ (spec$)
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

