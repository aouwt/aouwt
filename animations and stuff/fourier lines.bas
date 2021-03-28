$NOPREFIX
$CHECKING:OFF
$RESIZE:ON
s& = NEWIMAGE(640, 480, 32)
SCREEN s&

DIM i AS UNSIGNED BYTE
DIM t AS UNSIGNED INTEGER
DIM f AS DOUBLE

DIM HalfHeight AS SINGLE, QuarterHeight AS SINGLE
DIM HalfWidth AS SINGLE
DIM WMult AS SINGLE

HalfHeight = HEIGHT / 2
QuarterHeight = HEIGHT / 4
HalfWidth = WIDTH / 2
WMult = 1

DO
    DISPLAY
    LINE (0, 0)-(WIDTH, HEIGHT), RGBA32(0, 0, 0, 255), BF

    FOR i = 127 TO 255
        LINE (0, HalfHeight)-(0, HalfHeight), 0
        COLOR RGB32(i, i, i)

        FOR t = 0 TO WIDTH STEP 10
            LINE -(t, (Fourier(i - 126, 0.05, ((t / WIDTH) + f)) + 2) * QuarterHeight)
        NEXT
    NEXT

    f = TIMER(0.001)

    IF EXIT THEN SYSTEM
    IF RESIZE THEN
        tmp& = COPYIMAGE(s&, 32)
        SCREEN tmp&

        FREEIMAGE s&

        s& = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32)
        SCREEN s&
        PUTIMAGE , tmp&, s&

        FREEIMAGE tmp&
        WMult = WIDTH
        HalfHeight = HEIGHT / 2
        QuarterHeight = HEIGHT / 4
        HalfWidth = WIDTH / 2
    END IF
    'Limit 30
LOOP


$CHECKING:OFF
FUNCTION Fourier! (q AS UNSIGNED INTEGER, f AS SINGLE, t AS DOUBLE)
    DIM k AS UNSIGNED INTEGER, o AS SINGLE, m AS DOUBLE
    m = 2 * PI * f * t
    FOR k = 1 TO q STEP 2
        o = o + (SIN(m * k) / k)
        'o = o + (SIN(2 * PI * (2 * k - 1) * f * t) / (2 * k - 1))
    NEXT
    Fourier = (4 / PI) * o
END FUNCTION
$CHECKING:ON
