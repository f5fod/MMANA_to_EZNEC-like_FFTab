' Using a FF (far field) csv (comma-separated values) file provided by MMANA, the MMANA_FFTab_Vx-x.bas program generates an EZNEC-like FFTab file,
' to feed AGTC programs, for instance.
' These AGTC programs calculate the G/T ratio of antennas.
'
' Here, the program VERIFY_Vx-x is used to verify that the gains from the MMANA FF csv file are correctly transferred to the EZNEC-like FFTab file,
' with the correct values and in the correct 65341 (181 x 361) locations.
'
' Author: F5FOD, Jean-Pierre Waymel.
' Date  : january 2026.
'
' Program name: VERIFY_V1-7.bas
' Version 1.7
'
' To be compiled with qb64 32 bits!
' If compiled with qb64 64 bits, the character size in the console will be smaller ...
'
' MMANA FF csv file format:
'    ZENITH(DEG),AZIMUTH(DEG),VERT(dBi),HORI(dBi),TOTAL(dBi)
'    0.0,0.0,-999.00,-9.08,-9.08
'    or
'    0.0,1.0,-44.25,-9.09,-9.08
'    etc.
'
' EZNEC FFTab format:
'     Deg      V dB      H dB      Tot dB
'      4      -31.72     -8.60     -8.58X
'    136      -19.50    -19.19    -16.33X
'    123456789012345678901234567890123456
'             1         2         3
'                             xxxxxxxxxx
'    (the "X" is a space character)
' "xxxxxxxxxx": AGTC uses positions 26 to 35 to get the "Tot dB".
'
' Angles (in degrees)
' MMANA Azimuth = EZNEC Azimuth        = phi
' MMANA Zenith  = 90 - EZNEC Elevation = theta
' 
' EZNEC Elevation = 90 - MMANA Zenith
'
'
' MMANA FF csv file:
'    Azimuth =   0 and Zenith from 0 to 180
'    Azimuth =   1 and Zenith from 0 to 180
'    ...
'    Azimuth = 360 and Zenith from 0 to 180
'
'
' EZNEC FFTab (for AGTC):
'    Elevation = -90 and Azimuth from 0 to 360
'    Elevation = -89 and Azimuth from 0 to 360
'    ...
'    Elevation =   0 and Azimuth from 0 to 360
'    ... 
'    Elevation = +90 and Azimuth from 0 to 360
'
'
ON ERROR GOTO error_handler
'
DIM   csv(181%, 361%) AS DOUBLE ' To receive the 181 x 361 = 65341 MMANA FF gain values from the MMANA FF csv file.
DIM EZNEC(181%, 361%) AS DOUBLE ' To receive the 181 x 361 = 65341 EZNEC FF gain values from the EZNEC-like FFTab file 
                                ' which has been built from the MMANA FF csv file by the MMANA_FFTab_Vx-x.bas program.
DIM total AS DOUBLE             ' The gain from the MMANA FF csv file.
DIM tot   AS DOUBLE             ' The gain from the EZNEC-like FFTab file
DIM checksum_csv   AS DOUBLE
DIM checksum_FFTab AS DOUBLE
DIM I     AS LONG
DIM alert AS LONG
DIM OK    AS LONG
DIM alert_dot AS LONG
DIM OK_dot    AS LONG
'
'
quote$=CHR$(34%)
'
'
_TITLE "Compare the FF gains between the MMANA and EZNEC-like files"
_DELAY 2
CLS
'
COLOR 14
PRINT " VERIFY_V1-7.bas"
COLOR 7
PRINT " Compare the FF gain values between the MMANA FF csv"
PRINT " and the EZNEC-like FFTab files."
PRINT " By F5FOD. To be used in AGTC context."
PRINT " Version 1.7"
PRINT
'
'' ===> PART 1
' Getting Total_dBi from an MMANA FF csv file.
'
'
FF_csv_file_filename:
PRINT " Enter the MMANA FF csv file name: ";
LINE INPUT FF_csv_file$
filename_length% = LEN(FF_csv_file$)
IF filename_length% = 0% THEN
    'BEEP
    PRINT
    COLOR 12
    PRINT " You did not enter any MMANA FF csv file name!" 'Length of file name is null ...
    PRINT
    COLOR 13
    PRINT " Press any key to continue!"
    COLOR 7
    GOSUB waiting
    CLS
	LOCATE 7%, 1%                          ' To return to the same display line (for the "Y" question).
    GOTO FF_csv_file_filename
END IF
'
'
' Reading the MMANA FF csv file.
'
PRINT
'
CLOSE 1%
20 OPEN FF_csv_file$ FOR INPUT AS #1%
PRINT " Please wait when reading the MMANA FF csv file!"
21 LINE INPUT #1%, header$                    ' To remove the header.
'
'
FOR I = 1 TO 65341
22  LINE INPUT #1%, FF$
'
    length% = LEN(FF$)
	comma0% = 0%
    comma1% = INSTR(comma0% + 1%, FF$, ",")
    comma2% = INSTR(comma1% + 1%, FF$, ",")
    comma3% = INSTR(comma2% + 1%, FF$, ",")
    comma4% = INSTR(comma3% + 1%, FF$, ",")
	'
    zenith$ =  MID$(FF$, comma0% + 1%, comma1% - comma0% - 1%)
    azimuth$ = MID$(FF$, comma1% + 1%, comma2% - comma1% - 1%)
    vert$ =    MID$(FF$, comma2% + 1%, comma3% - comma2% - 1%)
    hori$ =    MID$(FF$, comma3% + 1%, comma4% - comma3% - 1%)
	total$ =   RIGHT$(FF$, length% - comma4%)
	'
	total  =   VAL(total$)
	zenith%  = VAL(zenith$)
	azimuth% = VAL(azimuth$)
	'	
	csv(zenith%, azimuth%) = total
	'PRINT I; "  "; csv(zenith%, azimuth%)                         ! Debugging.
NEXT I
CLOSE 1%
'
checksum_csv = 0
FOR azimuth% = 0% to 360%
    FOR zenith% = 0% to 180%
	    checksum_csv = checksum_csv + csv(zenith%, azimuth%)
	    'PRINT csv(zenith%, azimuth%),                             ! Debugging.
	NEXT zenith%
NEXT azimuth%
PRINT " End of reading!"
PRINT " MMANA FF csv gain checksum =     ";
COLOR 10
PRINT checksum_csv
COLOR 7
PRINT " (the decimals are due to the real number coding norm)"
'
PRINT
'
'PRINT " Press any key to continue!"
'GOSUB waiting
'
lineline% = 14%                             ' The line number where the question is asked.
GOSUB yes                                   ' Waiting for typing "Y <return>" so that the program continues.
PRINT
'
'' ===> PART 2
' Getting Total_dBi from the EZNEC FFTab file.
'
'
FF_EZNEC_file_filename:
PRINT " Enter the EZNEC-like FFTab file name: ";
LINE INPUT EZNEC_FFTab_file$
filename_length% = LEN(EZNEC_FFTab_file$)
IF filename_length% = 0% THEN
    'BEEP
    PRINT
    COLOR 12
    PRINT " You did not enter any EZNEC-like FFTab file name" 'Length of file name is null ...
    PRINT
    COLOR 13
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
	FOR I% = 16% to 25%
		LOCATE I%, 1%
		PRINT SPACE$(80);
	NEXT I%
'    CLS
	LOCATE 16%, 1%
    GOTO FF_EZNEC_file_filename
END IF
'
'
' Reading the EZNEC-like FFTab file.
'
PRINT
'
CLOSE 1%
30 OPEN EZNEC_FFTab_file$ FOR INPUT AS #1%
PRINT " Please wait when reading the EZNEC-like FFTab file!"
FOR I% = 1% to 10%
31  LINE INPUT #1%, header$                           ' To remove the header.
NEXT I%
'
FOR zenith% = 180% to 0% STEP -1%                     ' Equivalent to: from Elevation = -90 to +90.
32  LINE INPUT #1%, elevation_info$                   ' To get the line with elevation value.
    'character_37$ = MID$(elevation_info$, 37%, 1%)   ! Debugging.
    'IF character_37$ =  "-" THEN elevation$ = MID$(elevation_info$, 37%, 3%)
    'IF character_37$ <> "-" THEN elevation$ = MID$(elevation_info$, 37%, 2%)
	'PRINT elevation$
	'_DELAY 1
33	LINE INPUT #1%, legend$                           ' To get the line with "Deg, V dB, ..."
        FOR azimuth% = 0% TO 360%
34          LINE INPUT #1%, FF$
			tot$ = MID$(FF$, 29%, 7%)
			tot = VAL(tot$)
			EZNEC(zenith%, azimuth%) = tot
	    NEXT azimuth%
35	IF zenith% <> 0% THEN LINE INPUT #1%, empty_line$	 
NEXT zenith%
CLOSE 1%
'
PRINT " End of reading!"
'
CLOSE 2%
OPEN "error_log.txt" FOR OUTPUT AS #2%
'
PRINT #2%, "Error log"
PRINT #2%,
'
PRINT #2%, "MMANA FF csv file    : "; FF_csv_file$
PRINT #2%, "EZNEC-like FFTab file: "; EZNEC_FFTab_file$
PRINT #2%, "";DATE$ ; "(mm-dd-yyyy)"; " at ";time$
'
'
'' ===> PART 3
'  Total_dBi checksums.
'
checksum_FFTab = 0
FOR azimuth% = 0% to 360%
    FOR zenith% = 0% to 180%
	    checksum_FFTab = checksum_FFTab + EZNEC(zenith%, azimuth%)
	NEXT zenith%
NEXT azimuth%
'
PRINT " EZNEC-like FFTab gain checksum = ";
IF checksum_FFTab  = checksum_csv THEN
	COLOR 10
	PRINT checksum_FFTab
	COLOR 7
END IF
IF checksum_FFTab <> checksum_csv THEN
	COLOR 12
	PRINT checksum_FFTab
	COLOR 7
END IF
PRINT " (the decimals are due to the real number coding norm)"
'
PRINT
IF checksum_csv  = checksum_FFTab THEN
	COLOR 10
	PRINT " Perfect: the checksums are equal!"
	COLOR 7
END IF
'
IF checksum_csv <> checksum_FFTab THEN
	COLOR 12
	PRINT " There's a problem: the checksums are not equal!"
	COLOR 7
	PRINT " Check both files manually and/or consult the error_log.txt file"
	PRINT " which will be available once the program has finished running."
END IF
'

PRINT #2%,
PRINT #2%, "Part One: Checksums"
PRINT #2%, "The 65341 gains will be added algebraically and the total will be the checksum."
PRINT #2%, "MMANA FF   csv   checksum = "; checksum_csv
PRINT #2%, "EZNEC-like FFTab checksum = "; checksum_FFTab
'
IF checksum_csv <> checksum_FFTab THEN
	PRINT #2%, "There's a problem: the checksums are not equal!"
	PRINT #2%, "Check both files manually and/or consult Part Two of this error_log file."
END IF
'
PRINT
PRINT " Press any key to continue!"
GOSUB waiting
'PRINT
CLS
'
'' ===> PART 4
'  Comparison of Total_dBi between MMANA FF csv and EZNEC-like FFTab files.
'
PRINT " For the same zenith and azimuth, the gains will now be compared one by one"
PRINT " between the two files."
PRINT " Reminder: elevation = 90 - zenith."
COLOR 13
PRINT " For a given zenith and azimuth, if the gains are not equal,"
PRINT " these zenith and azimuth and the gains will be recorded"
PRINT " in the error_log.txt file."
COLOR 7
'
PRINT
PRINT " Press any key to continue and wait until ";
COLOR 14
PRINT quote$;"End of comparison";quote$;
COLOR 7
PRINT "!"
GOSUB waiting
'PRINT
CLS
'
'
alert = 0
OK    = 0
'
PRINT #2,
PRINT # 2%, "Part Two: Gain difference cases (reminder: elevation = 90 - zenith)"
'
'
FOR zenith% = 180% to 0% STEP -1%
    FOR azimuth% = 0% to 360%
    'PRINT csv(zenith%, azimuth%), EZNEC(zenith%, azimuth%)             ' Debugging.
	IF csv(zenith%, azimuth%) <> EZNEC(zenith%, azimuth%) THEN
    	COLOR 12
		PRINT " Alert!"
		COLOR 7
		alert = alert + 1
		PRINT " At zenith = ";
		PRINT USING "###"; zenith%;
		PRINT " and azimuth = ";
		PRINT USING "###"; azimuth%;
		PRINT " the gains are not equal!"
		PRINT " MMANA FF csv gain     = ";
		PRINT USING "+###.###"; csv(zenith%, azimuth%)
		PRINT " EZNEC-like FFTab gain = ";
		PRINT USING "+###.###"; EZNEC(zenith%, azimuth%)
		PRINT
		'
		PRINT #2%, "At zenith = ";
		PRINT #2%, USING "###"; zenith%;
		PRINT #2%, " and azimuth = ";
		PRINT #2%, USING "###"; azimuth%;
		PRINT #2%, "   MMANA FF csv gain = ";
		PRINT #2%, USING "+###.###"; csv(zenith%, azimuth%);
		PRINT #2%, " and EZNEC-like FFTab gain = ";
		PRINT #2%, USING "+###.###"; EZNEC(zenith%, azimuth%)
	END IF
	IF csv(zenith%, azimuth%) =  EZNEC(zenith%, azimuth%) THEN
 		OK = OK + 1
	END IF
    NEXT azimuth%
NEXT zenith%
'
PRINT
COLOR 14
PRINT " End of comparison!"
COLOR 7
'
IF alert <> 0% THEN COLOR 12
IF alert =  0% THEN COLOR 10
IF alert = 0 THEN
	PRINT " There are ";
	PRINT USING "#####"; alert;
	PRINT " cases where the gains are not equal."
	COLOR 7
	PRINT #2%, "There are ";
	PRINT #2%, USING "#####"; alert;
	PRINT #2%, " cases where the gains are not equal."
END IF
'
IF alert = 1 THEN
	PRINT " There  is ";
	PRINT USING "#####"; alert;
	PRINT " case  where the gains are not equal."
	COLOR 7
	PRINT #2%, "There is ";
	PRINT #2%, USING "#####"; alert;
	PRINT #2%, " case  where the gains are not equal."
END IF
'
IF alert > 1 THEN
	PRINT " There are ";
	PRINT USING "#####"; alert;
	PRINT " cases where the gains are not equal."
	COLOR 7
	PRINT #2%, "There are ";
	PRINT #2%, USING "#####"; alert;
	PRINT #2%, " cases where the gains are not equal."
END IF
'
'
PRINT " There are ";
PRINT USING "#####"; OK;
PRINT " cases where the gains are     equal."
'
'
PRINT
PRINT " Press any key to continue!"
GOSUB waiting
'PRINT
CLS
'
'' ===> PART 5
'  Control of the Total_dBi decimal dot position.
'
PRINT " The Total_dBi decimal dot position will now be controled";
COLOR 13
PRINT " For a given zenith and azimuth, if the Total_dBi decimal dot is not";
PRINT " at its right position,these zenith and azimuth and the gains will be"
PRINT " recorded in the error_log.txt file."
COLOR 7
'
PRINT
PRINT " Press any key to continue and wait until ";
COLOR 14
PRINT quote$;"End of control";quote$;
COLOR 7
PRINT "!"
GOSUB waiting
'PRINT
CLS
'
alert_dot = 0
OK_dot    = 0
'
PRINT #2,
PRINT #2%, "Part Three: Control of the Total_dBi decimal dot position"
'
CLOSE 1%
OPEN EZNEC_FFTab_file$ FOR INPUT AS #1%
PRINT
PRINT " Waiting!"
'
FOR I% = 1% to 10%
    LINE INPUT #1%, header$                           ' To remove the header.
NEXT I%
'
FOR zenith% = 180% to 0% STEP -1%                     ' Equivalent to: from Elevation = -90 to +90.
    LINE INPUT #1%, elevation_info$                   ' To get the line with elevation value.
    LINE INPUT #1%, legend$                           ' To get the line with "Deg, V dB, ..."
    FOR azimuth% = 0% TO 360%
        LINE INPUT #1%, FF$
		character_33$ = MID$(FF$, 33%, 1%)        ' Where there must be the decimal dot
		IF character_33$ <> "." THEN
		    COLOR 12
		    PRINT " Alert!"
		    COLOR 7
			alert_dot = alert_dot + 1
			PRINT " At zenith = ";
			PRINT USING "###"; zenith%;
			PRINT " and azimuth = ";
			PRINT USING "###"; azimuth%;
			PRINT " the decimal dot is not at its right position!"
			PRINT
			'
			PRINT #2%, "At zenith = ";
			PRINT #2%, USING "###"; zenith%;
			PRINT #2%, " and azimuth = ";
			PRINT #2%, USING "###"; azimuth%;
			PRINT #2%, " the decimal dot is not at its right position"
		END IF
		'
	    IF character_33$ =  "." THEN
			OK_dot = OK_dot + 1
		END IF
    NEXT azimuth%
	IF zenith% <> 0% THEN LINE INPUT #1%, empty_line$	 
NEXT zenith%
CLOSE 1%
'
COLOR 14
PRINT " End of control"
COLOR 7
'
IF alert_dot <> 0% THEN COLOR 12
IF alert_dot =  0% THEN COLOR 10
IF alert_dot = 0 THEN
	PRINT " There are ";
	PRINT USING "#####"; alert_dot;
	PRINT " cases where the decimal dot is not at its right position."
	COLOR 7
	PRINT #2%, "There are ";
	PRINT #2%, USING "#####"; alert_dot;
	PRINT #2%, " cases where the decimal dot is not at its right position."
END IF
'
IF alert_dot = 1 THEN
	PRINT " There  is ";
	PRINT USING "#####"; alert_dot;
	PRINT " case  where the decimal dot is not at its right position."
	COLOR 7
	PRINT #2%, "There is ";
	PRINT #2%, USING "#####"; alert_dot;
	PRINT #2%, " case  where the decimal dot is not at its right position."
END IF
'
IF alert_dot > 1 THEN
	PRINT " There are ";
	PRINT USING "#####"; alert_dot;
	PRINT " cases where the decimal dot is not at its right position."
	COLOR 7
	PRINT #2%, "There are ";
	PRINT #2%, USING "#####"; alert_dot;
	PRINT #2%, " cases where the decimal dot is not at its right position."
END IF
'
'
PRINT " There are ";
PRINT USING "#####"; OK_dot;
PRINT " cases where the decimal dot is     at its right position."
'
total_cases_dot = alert_dot + OK_dot
IF total_cases_dot  = 65341 THEN
	PRINT " The total number of cases is equal to 65341, which is correct!"
END IF	
IF total_cases_dot <> 65341 THEN
	PRINT " The total number of cases is not equal to 65341, which is not correct!"
	PRINT " Check both files manually and/or consult the error_log.txt file"
	PRINT " which will be available once the program has finished running."
END IF
'
PRINT
PRINT " Press any key now to close the program.";
GOSUB waiting
PRINT
CLOSE 1%
CLOSE 2%
'
SYSTEM                  ' By security!
'
'
' ############################## SUBROUTINES ##############################
'
waiting:
'Waiting for pressing any key
waiting$ = ""
WHILE waiting$ = ""
    waiting$ = INKEY$
WEND
'
RETURN
'
' #########################################################################
'
yes:
1000 PRINT " Type "; quote$;"Y <return>";quote$; " to continue: ";
LINE INPUT A$
IF A$ <> "Y" THEN
	FOR I% = lineline% to 25%
		LOCATE I%, 1%
		PRINT SPACE$(80);
	NEXT I%
	LOCATE lineline%, 1%
	GOTO 1000
	END IF
RETURN
'
' #########################################################################
'
error_handler:
IF (ERR = 53% OR ERR = 70% OR ERR = 76%) AND ERL = 20% THEN            ' MMANA FF csv file not found.
    'BEEP
    'PRINT
    COLOR 12
    PRINT " The MMANA FF csv file has not been found!"
    PRINT
    COLOR 13
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
	LOCATE 7%, 1%
    RESUME FF_csv_file_filename
END IF
'
IF ERR = 62% AND (ERL = 21% OR ERL = 22%) THEN            ' MMANA FF csv file: line(s) missing.
    'BEEP
    PRINT
    COLOR 12
    PRINT " Missing line(s) in the MMANA FF csv file!"
    PRINT
    COLOR 13
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
	LOCATE 7%, 1%
    RESUME FF_csv_file_filename
END IF
'
IF (ERR = 53% OR ERR = 70% OR ERR = 76%) AND ERL = 30% THEN            ' EZNEC-like FFTab file not found.
    'BEEP
    'PRINT
    COLOR 12
    PRINT " The EZNEC-like FFTab file has not been found!"
    PRINT
    COLOR 13
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
	FOR I% = 16% to 25%
		LOCATE I%, 1%
		PRINT SPACE$(80);
	NEXT I%
    'CLS
	LOCATE 16%, 1%
    RESUME FF_EZNEC_file_filename
END IF
'
IF ERR = 62% AND (ERL = 31% OR ERL = 32% OR ERL = 33% OR ERL = 34% OR ERL = 35%) THEN            ' EZNEC-like FFTab file: line(s) missing.
    'BEEP
    PRINT
    COLOR 12
    PRINT " Missing line(s) in the EZNEC-like FFTab file!"
    PRINT
    COLOR 13
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
	FOR I% = 16% to 25%
		LOCATE I%, 1%
		PRINT SPACE$(80);
	NEXT I%
    'CLS
	LOCATE 16%, 1%
    RESUME FF_EZNEC_file_filename
END IF
'
COLOR 12
    PRINT "Error"; ERR; "at line";_ERRORLINE
    PRINT
    COLOR 13
    PRINT " Press any key to close the program!";
    COLOR 7
    GOSUB waiting
    SYSTEM