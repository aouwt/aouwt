$CONSOLE:ONLY
_DEST _CONSOLE

IF COMMAND$(1) = "" THEN
    PRINT "HTML Linker v1"
    PRINT "--------------"
    PRINT "USAGE: link <input file> [<output file>]"
    SYSTEM
END IF

o$ = linker$(LoadFile(COMMAND$(1)))
IF COMMAND$(2) = "" THEN
    PRINT o$;
ELSE
    f% = FREEFILE
    OPEN COMMAND$(2) FOR OUTPUT AS #f%
    PRINT #f%, o$;
    CLOSE #f%
END IF
SYSTEM



FUNCTION linker$ (f AS STRING)
    CONST LinkBegin = "<!--LINKER:"
    CONST LinkEnd = "-->"
    TYPE var
        v AS STRING
        n AS STRING
    END TYPE
    DIM vars(100) AS var
    DO
        lstart = INSTR(f, LinkBegin)
        lend = INSTR(f, LinkEnd)
        IF (lstart = 0) OR (lend = 0) THEN EXIT DO

        cmd$ = MID$(f, lstart + LEN(LinkBegin), lend - lstart - LEN(LinkBegin))

        sep% = INSTR(cmd$, ":")
        act$ = LEFT$(cmd$, sep% - 1)
        arg$ = MID$(cmd$, sep% + 1)

        SELECT CASE act$
            CASE "LINK"
                o$ = LoadFile(arg$)

            CASE "SET"
                vars(nextvar%).n = arg$
                vars(nextvar%).v = "TRUE"
                nextvar% = nextvar% + 1

            CASE "IF"
                sep% = INSTR(arg$, ";")
                act$ = MID$(arg$, sep% + 1)
                arg$ = LEFT$(arg$, sep% - 1)
                FOR i% = 0 TO nextvar%
                    IF vars(i%).n = arg$ THEN o$ = act$: EXIT FOR
                NEXT

            CASE "IFN"
                sep% = INSTR(arg$, ";")
                o$ = MID$(arg$, sep% + 1)
                act$ = LEFT$(arg$, sep% - 1)
                FOR i% = 0 TO nextvar%
                    IF vars(i%).n = act$ THEN o$ = "": EXIT FOR
                NEXT

            CASE "STR"
                sep% = INSTR(arg$, "=")
                act$ = MID$(arg$, sep% + 1)
                arg$ = LEFT$(arg$, sep% - 1)
                vars(nextvar%).n = arg$
                vars(nextvar%).v = act$
                nextvar% = nextvar% + 1

            CASE "PUT"
                FOR i% = 0 TO nextvar%
                    IF vars(i%).n = arg$ THEN o$ = vars(i%).v: EXIT FOR
                NEXT

            CASE ELSE
                PRINT "Error: Invalid command " + cmd$
        END SELECT
        f = LEFT$(f, lstart - 1) + o$ + MID$(f, lend + LEN(LinkEnd))
        o$ = ""
    LOOP
    linker$ = f
END FUNCTION

FUNCTION LoadFile$ (file$)
    IF _FILEEXISTS(file$) = 0 THEN
        PRINT "Error: cannot find file "; file$
        EXIT FUNCTION
    END IF
    DIM f AS INTEGER
    f = FREEFILE
    OPEN file$ FOR BINARY AS #f
    f$ = SPACE$(LOF(f))
    GET #f, , f$
    CLOSE #f
    LoadFile$ = f$
END FUNCTION
