$CONSOLE:ONLY
_DEST _CONSOLE

PRINT "HTML Linker v1"
PRINT "--------------"
IF COMMAND$(1) = "" THEN
    PRINT "USAGE: link <input file> [<output file>]"
    SYSTEM
END IF
PRINT "Using file "; COMMAND$(1)
o$ = linker$(LoadFile(COMMAND$(1)))
IF COMMAND$(2) = "" THEN
    PRINT o$;
ELSE
    PRINT "Outputting to "; COMMAND$(2)
    f% = FREEFILE
    OPEN COMMAND$(2) FOR OUTPUT AS #f%
    PRINT #f%, o$;
    CLOSE #f%
END IF
SYSTEM



FUNCTION linker$ (f AS STRING)
    CONST LinkBegin = "<!--<LINKER>"
    CONST LinkEnd = "</LINKER>-->"
    DIM vars(100) AS STRING
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
                vars(nextvar%) = arg$
                nextvar% = nextvar% + 1

            CASE "IF"
                sep% = INSTR(arg$, ":")
                act$ = MID$(arg$, sep% + 1)
                arg$ = LEFT$(arg$, sep% - 1)
                FOR i% = 0 TO nextvar%
                    IF vars(i%) = arg$ THEN o$ = act$: EXIT FOR
                NEXT

            CASE "IFN"
                sep% = INSTR(arg$, ":")
                o$ = MID$(arg$, sep% + 1)
                act$ = LEFT$(arg$, sep% - 1)
                FOR i% = 0 TO nextvar%
                    IF vars(i%) = act$ THEN o$ = "": EXIT FOR
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
        PRINT USING "Error! File & does not exist!"; file$
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
