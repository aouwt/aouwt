$RESIZE:ON
'CONST __menuBorderW = 1, __menuBorderH = 1
CONST __menuBorderW = 10, __menuBorderH = 0
'CONST __menuSizeMultX = 1, __menuSizeMultY = 1
'$LET .MENUBORDERMULT = 1
DIM SHARED __menuSizeMultX AS SINGLE, __menuSizeMultY AS SINGLE
DIM undoimgs&(-127 TO 128)
GOTO start

errorhandler:
dump$= "ERR=" + STR$(ERR) + ";  _ERRORLINE=" + STR$(_ERRORLINE) + ";  _INCLERRORLINE=" + STR$(_INCLERRORLINE) + ";  _INCLERRORFILE$=" + _INCLERRORFILE$ + ";  paintArea&=" + STR$(paintarea&) + ";  menu&=" + STR$(menu&) _
     + ";  ui$=" + ui$ + ";  colorMixer&=" + STR$(colormixer&) + ";  undoptr%%=" + STR$(undoptr%%) + ";  undoimgs&={..." + STR$(undoimgs&(undoptr%% - 1)) + "," + STR$(undoimgs&(undoptr%%)) + "," + STR$(undoimgs&(undoptr%%)) + "...}"
IF menu& = -1 OR menu& = 0 THEN
    _DEST 0
    PRINT "an error occurred (and we cannot use the ui for some reason)"
    PRINT "error info:"; dump$
    SLEEP
    RESUME NEXT
END IF
errorDialog "QB64 internal error #" + LTRIM$(STR$(ERR)), "see qb64.org/wiki/ERROR_codes", dump$
RESUME NEXT


start:
screenH& = _NEWIMAGE(640, 480, 32)
paintarea& = _NEWIMAGE(640, 480, 32)
menu& = _NEWIMAGE(400, 220, 32)
colormixer& = genColorMixer
ui$ = "file options"
ON ERROR GOTO errorhandler
DO
    uiPrt
    ON ERROR GOTO errorhandler
    IF ui$ <> "" THEN genUI ELSE doStuff
    ON ERROR GOTO errorhandler
    DO: _LIMIT 60: LOOP UNTIL _SCREENEXISTS
LOOP

SUB uiPrt
    SHARED paintC&, paintarea&, ui$, menu&, screenH&
    IF _RESIZE THEN
        DO: _LIMIT 2: LOOP UNTIL NOT _RESIZE
        IF (_RESIZEWIDTH >= 640) AND (_RESIZEHEIGHT >= 480) THEN
            SCREEN 0
            screenF& = _FONT(screenH&)
            _FREEIMAGE screenH&
            screenH& = _NEWIMAGE(_ROUND(_RESIZEWIDTH / _FONTWIDTH(screenF&)) * _FONTWIDTH(screenF&), _ROUND(_RESIZEHEIGHT / _FONTHEIGHT(screenF&)) * _FONTHEIGHT(screenF&), 32)
            SCREEN screenH&
            __menuSizeMultX = _CEIL(_RESIZEWIDTH / 2000)
            __menuSizeMultY = __menuSizeMultX
            ON ERROR GOTO errorhandler
        ELSE
            SCREEN 0
            screenF& = _FONT(screenH&)
            _FREEIMAGE screenH&
            screenH& = _NEWIMAGE(_ROUND(640 / _FONTWIDTH(screenF&)) * _FONTWIDTH(screenF&), _ROUND(480 / _FONTHEIGHT(screenF&)) * _FONTHEIGHT(screenF&), 32)
            SCREEN screenH&
            __menuSizeMultX = _CEIL(_RESIZEWIDTH / 2000)
            __menuSizeMultY = __menuSizeMultX
            ON ERROR GOTO errorhandler
        END IF
    END IF

    _DEST screenH&
    COLOR , _RGB(255, 255, 255)
    CLS

    LOCATE (_HEIGHT / 16)
    COLOR _RGB32(255, 255, 255), _RGB32(128, 128, 128): PRINT "stupidpaint";
    COLOR _RGB32(128, 128, 128), _RGB32(0, 0, 0)
    ON ERROR GOTO errorhandler
    IF LEFT$(ui$, 1) = "!" THEN
        PRINT "   "; MID$(ui$, 2);
        PRINT SPACE$((_WIDTH / 8) - POS(0));
    ELSEIF ui$ <> "" THEN
        PRINT "   [Esc] dismiss";
        PRINT SPACE$((_WIDTH / 8) - POS(0));
    ELSE
        PRINT "   [F]ile  [U]ndo  [R]edo  [P]ages  [B]rush";
        a$ = "[C]olor A" + LTRIM$(STR$(_ALPHA32(paintC&))) + ", R" + LTRIM$(STR$(_RED32(paintC&))) + ", G" + LTRIM$(STR$(_GREEN32(paintC&))) + ", B" + LTRIM$(STR$(_BLUE32(paintC&))) + ""
        COLOR _RGB32(0, 0, 0), _RGB32(0, 0, 0): PRINT SPACE$((_WIDTH / 8) - (POS(0) + LEN(a$) - 1));
        COLOR _RGB32(_RED32(paintC&), _GREEN32(paintC&), _BLUE32(paintC&)), _RGB32(255 - _RED32(paintC&), 255 - _GREEN32(paintC&), 255 - _BLUE32(paintC&)): PRINT a$;
    END IF
    ON ERROR GOTO errorhandler
    _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT - _FONTHEIGHT(_FONT(screenH&))), paintarea&, screenH&, , _SMOOTH
    ON ERROR GOTO errorhandler

    IF ui$ <> "" THEN genUI
    _DISPLAY
END SUB

FUNCTION genColorMixer&
    genColorMixer& = _NEWIMAGE(255, 3, 32)
    _DEST genColorMixer&
    FOR x% = 0 TO 255
        PSET (x%, 0), _RGB32(x%, 0, 0, 255)
    NEXT
    FOR x% = 0 TO 255
        PSET (x%, 1), _RGB32(0, x%, 0, 255)
    NEXT
    FOR x% = 0 TO 255
        PSET (x%, 2), _RGB32(0, 0, x%, 255)
    NEXT
    FOR x% = 0 TO 255
        PSET (x%, 3), _RGB32(0, 0, 0, x%)
    NEXT
END FUNCTION

SUB doStuff STATIC
    SHARED ui$, paintarea&, paintC&, screenH&, undoimgs&(), undoptr%%
    keypress$ = INKEY$
    SELECT CASE keypress$
        CASE "f": ui$ = "file options"
        CASE "u"
            IF (undoimgs&(undoptr%%) <> 0) AND (undoimgs&(undoptr%%) <> -1) THEN _FREEIMAGE undoimgs&(undoptr%%)
            undoimgs&(undoptr%%) = paintarea&
            undoptr%% = undoptr%% - 1
            paintarea& = undoimgs&(undoptr%%)
        CASE "r"
            IF (undoimgs&(undoptr%% + 1) <> 0) AND (undoimgs&(undoptr%% + 1) <> -1) THEN
                undoimgs&(undoptr%%) = paintarea&
                undoptr%% = undoptr%% + 1
                paintarea& = undoimgs&(undoptr%%)
            END IF
    END SELECT
    IF _MOUSEINPUT THEN
        x! = _MOUSEX / (_WIDTH(screenH&) / _WIDTH(paintarea&))
        y! = _MOUSEY / ((_HEIGHT(screenH&) - _FONTHEIGHT(_FONT(screenH&))) / _HEIGHT(paintarea&))
        IF _MOUSEBUTTON(1) THEN
            IF (undoimgs&(undoptr%%) <> 0) AND (undoimgs&(undoptr%%) <> -1) THEN _FREEIMAGE undoimgs&(undoptr%%)
            undoimgs&(undoptr%%) = paintarea&
            paintarea& = _COPYIMAGE(paintarea&)
            undoptr%% = undoptr%% + 1
            DO
                _DEST paintarea&
                a~%% = _MOUSEINPUT
                LINE (x!, y!)-(_MOUSEX / (_WIDTH(screenH&) / _WIDTH(paintarea&)), _MOUSEY / ((_HEIGHT(screenH&) - _FONTHEIGHT(_FONT(screenH&))) / _HEIGHT(paintarea&))), _RGB(0, 0, 0)
                x! = _MOUSEX / (_WIDTH(screenH&) / _WIDTH(paintarea&))
                y! = _MOUSEY / ((_HEIGHT(screenH&) - _FONTHEIGHT(_FONT(screenH&))) / _HEIGHT(paintarea&))
                IF (TIMER - t#) > 0.05 THEN uiPrt: t# = TIMER
                a~%% = _MOUSEINPUT
            LOOP UNTIL NOT _MOUSEBUTTON(1)
        ELSE DO: LOOP UNTIL NOT _MOUSEINPUT
        END IF
    END IF
END SUB

SUB genUI STATIC
    SHARED menu&, filename$, ui$, paintarea&
    _DEST menu&
    CLS _RGB32(0, 0, 0, 0)

    COLOR _RGB32(255, 255, 255), _RGB32(64, 64, 64)
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("   " + ui$ + "   ")) / 2, 0), "   " + ui$ + "   "

    COLOR _RGB32(255, 255, 255), _RGB32(0, 0, 0, 0)
    PRINT
    keypress$ = INKEY$
    IF keypress$ <> "" THEN _LIMIT 10
    IF keypress$ = CHR$(27) THEN ui$ = "": EXIT SUB
    '_TITLE ui$ + " - stupidpaint v1"
    ON ERROR GOTO errorhandler
    SELECT CASE ui$
        CASE "file options"
            PRINT " [S]ave", "[F]ilename:", filename$
            'PRINT " [E]xport..."
            PRINT " [N]ew"
            PRINT " [I]mport..."
            PRINT ""
            PRINT " e[X]it stupidpaint"
            PRINT " [P]references"
            PRINT " [A]bout"
            SELECT CASE keypress$
                CASE "a": ui$ = "about stupidpaint"
                CASE "p": ui$ = "preferences"
                CASE "n": ui$ = "new project"
                    ' CASE "e": ui$ = "export project"
                CASE "i": ui$ = "import"
            END SELECT

        CASE "new project"
            PRINT
            PRINT "[X] resolution:"; npsx%
            PRINT "[Y] resolution:"; npsy%
            PRINT
            PRINT "[F]ilename: "; newfilename$
            PRINT
            PRINT "[Enter] create"
            SELECT CASE keypress$
                CASE "x"
                    npsx% = setFieldNum("x resolution", npsx%)
                CASE "y"
                    npsy% = setFieldNum("y resolution", npsy%)
                CASE "f"
                    newfilename$ = setFieldStr("filename", newfilename$)
                CASE CHR$(13)
                    _FREEIMAGE paintarea&
                    paintarea& = _NEWIMAGE(npsx%, npsy%, 32)
                    ui$ = ""
            END SELECT

        CASE "import"
            PRINT
            PRINT "[F]ilename: "; importfilename$
            PRINT
            IF import256` THEN PRINT "(#) load with [2]56 colors" ELSE PRINT "( ) load with [2]56 colors"
            IF import33` THEN PRINT "(#) load with [H]W accelleration (experimental)" ELSE PRINT "( ) load with [H]W accelleration (experimental)"
            IF impscale` THEN
                PRINT "(#) [S]cale image"
                PRINT , "scale [X]:"; impsx%
                PRINT , "scale [Y]:"; impsy%
            ELSE
                PRINT "( ) [S]cale image"
                PRINT
                PRINT
            END IF
            PRINT
            PRINT "[Enter] import"
            SELECT CASE keypress$
                CASE "2"
                    IF import33` THEN import33` = 0
                    import256` = NOT import256`
                CASE "h"
                    IF import256` THEN import256` = 0
                    import33` = NOT import33`
                CASE "s"
                    impscale` = NOT impscale`
                CASE "f"
                    importfilename$ = setFieldStr("path to file to import", importfilename$)
                CASE "x"
                    IF impscale` THEN impsx% = setFieldNum("scale image to x", impsx%)
                CASE "y"
                    IF impscale` THEN impsy% = setFieldNum("scale image to y", impsy%)
                CASE CHR$(13)
                    _FREEIMAGE paintarea&
                    IF import33` THEN
                        a& = _LOADIMAGE(importfilename$, 33)
                    ELSEIF import256` THEN a& = _LOADIMAGE(importfilename$, 256)
                    ELSE a& = _LOADIMAGE(importfilename$, 32)
                    END IF
                    IF a& = -1 THEN
                        errorDialog "import: _LOADIMAGE returned invalid handle", "corrupted image...?", "ui$=" + ui$ + ";  a&=-1;  importfilename$='" + importfilename$ + "';  import33`=" + STR$(import33`) + ";  import256`=" + STR$(import256`) + ";  impscale`=" + STR$(impscale`) + ";  impsx%=" + STR$(impsx%) + ";  impsy%=" + STR$(impsy%)
                        EXIT SUB
                    END IF
                    IF impscale` THEN paintarea& = scaleimg&(a&, impsx%, impsy%) ELSE paintarea& = a&

            END SELECT

        CASE "about stupidpaint"
            PRINT "                stupidpaint v1 by"
            PRINT "          all-other-usernames-were-taken"
            PRINT "    <all-other-usernames-were-taken.github.io>"
            PRINT ""
            PRINT "                   made in qb64"
            PRINT "                    <qb64.org>"
            PRINT ""
            PRINT "            licensed under GNU AGPLv3"
            PRINT "                 (view [L]icense)"
            IF keypress$ = "l" THEN ui$ = "license"

        CASE "license"
            PRINT "stupidpaint, a stupid paint thing"
            PRINT "Copyright (C) 2021 all-other-usernames-were-taken"
            PRINT ""
            PRINT " read [S]hort license"
            PRINT " read [L]ong license"
            SELECT CASE keypress$
                CASE "s": ui$ = "license (pg 1)"
                CASE "l": ui$ = "view full license"
            END SELECT

        CASE "license (pg 1)"
            PRINT "This program is free software: you can"
            PRINT "redistribute it and/or modify it under the terms"
            PRINT "of the GNU Affero General Public License as"
            PRINT "published by the Free Software Foundation,"
            PRINT "either version 3 of the License, or (at your"
            PRINT "option) any later version."
            IF keypress$ <> "" THEN ui$ = "license (pg 2)"

        CASE "license (pg 2)"
            PRINT "This program is distributed in the hope that it"
            PRINT "will be useful, but WITHOUT ANY WARRANTY; without"
            PRINT "even the implied warranty of ERCHANTABILITY or"
            PRINT "FITNESS FOR A PARTICULAR PURPOSE.  See the GNU"
            PRINT "Affero General Public License for more details."
            IF keypress$ <> "" THEN ui$ = "license (pg 3)"

        CASE "license (pg 3)"
            PRINT "You should have received a copy of the GNU Affero"
            PRINT "General Public License along with this program."
            PRINT "If not, see <https://www.gnu.org/licenses/>."
            IF keypress$ <> "" THEN ui$ = "license"


        CASE "view full license"
            IF _FILEEXISTS(_STARTDIR$ + "LICENSE.txt") THEN
                PRINT "  the full license should appear in a new window"
                PRINT "         if not, you can find it here:"
                PRINT
                PRINT " "; _STARTDIR$
                PRINT ""
                PRINT "        or you can find it online here:"
                PRINT "    https://www.gnu.org/licenses/agpl-3.0.txt"
                $IF LINUX THEN
                    SHELL "cat " + _STARTDIR$ + "LICENSE.txt | more"
                $ELSEIF WIN THEN
                    SHELL "notepad " + _STARTDIR$ + "LICENSE.txt"
                $END IF
                ui$ = "license"
            ELSE
                PRINT "   the full license file seems to be missing..."
                PRINT "               find it online here:"
                PRINT "    https://www.gnu.org/licenses/agpl-3.0.txt"
            END IF

        CASE ELSE
            errorDialog "genUI: invalid page name", "internal error, minor severity", "ui$=" + ui$
    END SELECT
    ON ERROR GOTO errorhandler
END SUB


FUNCTION setFieldNum! (fieldname$, currentval!)
    SHARED ui$
    uiLast$ = ui$
    ui$ = "!" + fieldname$ + ": " + field$
    uiPrt
    DO
        k$ = INKEY$
        IF k$ <> "" THEN
            SELECT CASE ASC(k$)
                CASE 27
                    setFieldNum! = currentval!
                    ui$ = uiLast$
                    EXIT SUB
                CASE 13
                    setFieldNum! = VAL(field$)
                    ui$ = uiLast$
                    EXIT SUB
                CASE ASC("0") TO ASC("9"), ASC(".")
                    field$ = field$ + k$
                CASE 8
                    field$ = LEFT$(field$, LEN(field$) - 1)
            END SELECT
            ui$ = "!" + fieldname$ + ": " + field$
            uiPrt
        END IF
        _LIMIT 30
        ON ERROR GOTO errorhandler
    LOOP
END SUB

FUNCTION setFieldStr$ (fieldname$, currentval$)
    SHARED ui$
    uiLast$ = ui$
    ui$ = "!" + fieldname$ + ": " + field$
    uiPrt
    DO
        k$ = INKEY$
        IF k$ <> "" THEN
            SELECT CASE ASC(k$)
                CASE 27
                    setFieldStr$ = currentval$
                    ui$ = uiLast$
                    EXIT SUB
                CASE 13
                    setFieldStr$ = field$
                    ui$ = uiLast$
                    EXIT SUB
                CASE 32 TO 126
                    field$ = field$ + k$
                CASE 8
                    field$ = LEFT$(field$, LEN(field$) - 1)
            END SELECT
            ui$ = "!" + fieldname$ + ": " + field$
            uiPrt
        END IF
        _LIMIT 30
        ON ERROR GOTO errorhandler
    LOOP
END SUB

FUNCTION scaleimg& (img&, sx%, sy%)
    i& = _NEWIMAGE(sx%, sy%, 32)
    _PUTIMAGE , img&, i&, , _SMOOTH
    ON ERROR GOTO errorhandler
    scaleimg& = i&
END FUNCTION

SUB errorDialog (error$, errcause$, dump$)
    SHARED menu&, ui$
    _DEST menu&
    CLS _RGB32(0, 0, 0, 0)

    COLOR _RGB32(255, 255, 255), _RGB32(64, 64, 64)
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("   uh oh   ")) / 2, 0), "   uh oh   "

    COLOR _RGB32(255, 255, 255), _RGB32(0, 0, 0, 0)
    PRINT
    PRINT "an error occurred:"
    PRINT error$
    PRINT errcause$
    PRINT
    PRINT "[Enter] view more details"
    PRINT "[Esc] exit"
    printUI

    DO
        k$ = INKEY$
        IF k$ = CHR$(27) THEN EXIT SUB
        IF k$ = CHR$(13) THEN
            PRINT
            PRINT "debug info:"
            PRINT dump$
            printUI
            DO: _LIMIT 10: LOOP UNTIL INKEY$ = CHR$(27)
        END IF
        _LIMIT 10
    LOOP
END SUB

SUB printUI
    SHARED menu&, screenH&
    LINE ((_WIDTH - __menuBorderW - (_WIDTH(menu&) * __menuSizeMultX)) / 2, (_HEIGHT - __menuBorderH - (_HEIGHT(menu&) * __menuSizeMultY)) / 2)-((_WIDTH + __menuBorderW + (_WIDTH(menu&) * __menuSizeMultX)) / 2, (_HEIGHT + __menuBorderH + (_HEIGHT(menu&) * __menuSizeMultY)) / 2), _RGB(128, 128, 128), BF
    _PUTIMAGE ((_WIDTH - (_WIDTH(menu&) * __menuSizeMultX)) / 2, (_HEIGHT - (_HEIGHT(menu&) * __menuSizeMultY)) / 2)-STEP(_WIDTH(menu&) * __menuSizeMultX, _HEIGHT(menu&) * __menuSizeMultY), menu&, screenH&, (0, 0)-(_WIDTH(menu&), _HEIGHT(menu&)), _SMOOTH
    ON ERROR GOTO errorhandler
    _DISPLAY
END SUB
