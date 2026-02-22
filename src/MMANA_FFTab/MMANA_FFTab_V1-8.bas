' Using an MMANA FF (Far Field) csv (comma-separated values) file, this program generates an EZNEC-like FFTab file capable of feeding AGTC programs.
' These AGTC programs calculate the G/T ratios of antennas.
'
' Author: F5FOD, Jean-Pierre Waymel.
' Date  : february 2026.
'
' Program name: MMANA_FFTab_V1-8.bas
' Version 1.8
'
' To be compiled with qb64 32 bits!
' If compiled with qb64 64 bits, the character size in the console will be smaller ...
'
' MMANA-GAL version 3.5.3.82
'
' To get the FF csv file from MMANA:
'    File/Table of Angle/Gain(*.csv)
'               Start deg.    Step deg.    Num. of steps
'    Azimuth    0.0           1.0          361
'     Zenith    0.0           1.0          181
'
' MMANA FF csv file format:
'    ZENITH(DEG),AZIMUTH(DEG),VERT(dBi),HORI(dBi),TOTAL(dBi)
'    0.0,0.0,-999.00,-9.08,-9.08
'    or
'    27.0,245.0,-14.29,-19.91,-13.24
'    etc.
'
' EZNEC FFTab format (from another antenna):
'     Deg      V dB      H dB      Tot dB
'      4      -31.72     -8.60     -8.58X
'    136      -19.50    -19.19    -16.33X
'    123456789012345678901234567890123456
'             1         2         3
'                             xxxxxxxxxx
'    (the "X" is a space character)
' "xxxxxxxxxx": AGTC uses positions 26 to 35 to obtain the "Tot dB".
'
' Angles (in degrees)
' MMANA Azimuth = EZNEC Azimuth        = phi
' MMANA Zenith  = 90 - EZNEC Elevation = theta
' 
' EZNEC Elevation = 90 - MMANA Zenith
'
'
' MMANA FF csv file:
'    Azimuth =   0 then Zenith from 0 to 180
'    Azimuth =   1 then Zenith from 0 to 180
'    ...
'    Azimuth = 360 then Zenith from 0 to 180
'
'
' EZNEC FFTab (settings for AGTC):
'    Elevation = -90 then Azimuth from 0 to 360
'    Elevation = -89 then Azimuth from 0 to 360
'    ...
'    Elevation =   0 then Azimuth from 0 to 360
'    ...
'    Elevation = +90 then Azimuth from 0 to 360
'
'
ON ERROR GOTO error_handler
'
DIM Total_dBi(181%, 361%) ' For FF Table: 181 x 361 = 65341 lines. Azimuth is the array second dimension.
DIM I AS LONG             ' Because the I variable will count until 65341!
'
quote$=CHR$(34%)
'
_TITLE "Converter from MMANA FF csv file to EZNEC-like FFTab file"
_DELAY 2
CLS
'
COLOR 14
PRINT " MMANA_FFTab_V1.8.bas"
COLOR 7
PRINT " Converter from MMANA FF csv file to EZNEC-like FFTab file, by F5FOD."
PRINT " To be used for AGTC."
PRINT " Version 1.8"
PRINT
'
'' ===> PART 1
' Getting Total_dBi from an MNANA FF csv file.
'
FF_csv_file_filename:
PRINT " Enter MMANA FF csv file name: ";
LINE INPUT FF_csv_file$
filename_length% = LEN(FF_csv_file$)
IF filename_length% = 0% THEN
    'BEEP
    PRINT
    COLOR 12
    PRINT " You did not enter any MMANA FF csv file name" 'Length of file name is null ...
    PRINT
    COLOR 9
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
	PRINT
    GOTO FF_csv_file_filename
END IF
'
'
' Verifying that the MMANA FF csv file is really step 1 deg.
CLOSE 1%
20 OPEN FF_csv_file$ FOR INPUT AS #1%
LINE INPUT #1%, first_line$ ' To remove the header.
'
LINE INPUT #1%, A$          ' To get the Zenith = 0 and Azimuth = 0 line.
zenith_0$ = LEFT$(A$,3%)
zenith_0  = VAL(zenith_0$)  ' The decimal part is null: no Round problem.
LINE INPUT #1%, A$          ' To get the Zenith = 1 and Azimuth = 0 line.
zenith_1$ = LEFT$(A$,3%)
zenith_1  = VAL(zenith_1$)  ' The decimal part is null: no Round problem.
IF zenith_1 - zenith_0 <> 1% THEN
    'BEEP
    PRINT
    COLOR 12
    PRINT " The MMANA FF csv file must be of 1 deg. resolution but is not!"
	PRINT
    COLOR 9
	PRINT " Press any key to continue!";
    COLOR 7
	GOSUB waiting
    CLS
	PRINT
    GOTO FF_csv_file_filename
END IF
CLOSE 1%
'
'
' Reading the MMANA FF csv file.
'
'
PRINT " The line numbers will be displayed, from l to 181 x 361 = 65341."
    PRINT
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
'
CLOSE 1%
OPEN FF_csv_file$ FOR INPUT AS #1%
21  LINE INPUT #1%, header$ ' To remove the header.
FOR I = 1 TO 65341
22  LINE INPUT #1%, FF$
'
' Below is just an example to help calculate the position of characters on a line of the file.
' This is an imaginary line in terms of the number of characters in the fields, fields which are separated by commas.
' However, there are indeed 5 fields per line of the MMANA FF csv file.
'
' 123,1234,12345,123456,1234567
'
' 1st field length = 3
' 2nd field length = 4
' 3rd field length = 5
' 4th field length = 6
' 5th field length = 7

' comma1% = position of the 1st comma, here comma1% =      3 + 1 =  4
' comma2% = position of the 2nd comma, here comma2% =  4 + 4 + 1 =  9
' comma3% = position of the 3rd comma, here comma3% =  9 + 5 + 1 = 15
' comma4% = position of the 4th comma, here comma4% = 15 + 6 + 1 = 22
' 
' total length = 29
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
	zenith%  = VAL(zenith$)         ' The decimal part is null: no Round problem.
	azimuth% = VAL(azimuth$)        ' The decimal part is null: no Round problem.
	'	
	vert  = VAL(vert$)              ' The decimal part is not null: Round problem not taken into account!
	hori  = VAL(hori$)              ' The decimal part is not null: Round problem not taken into account!
	total = VAL(total$)             ' The decimal part is not null: Round problem not taken into account but this numerical value will be further converted to a string !
	'
	Total_dBi(zenith%, azimuth%) = total
	PRINT I,
NEXT I
CLOSE 1%
'
PRINT " Press any key to continue!";
GOSUB waiting
'
'
' ===> PART 2
' Saving Total_dBi values in an EZNEC-like FFTab file.
'
save_data:
CLS
PRINT
PRINT " Please type the full file name for saving results as an EZNEC-like FFTab file."
PRINT " Be careful if this file name is already in use in your directory"
PRINT " as this file will be erased!"
PRINT
PRINT " Enter EZNEC-like FFTab file name for Output: ";
LINE INPUT FFTab_file$
'
filename_length% = LEN(FFTab_file$)
IF filename_length% = 0% THEN
    'BEEP
    PRINT
    COLOR 12
    PRINT " You did not enter any EZNEC-like FFTab file name" 'Length of file name is null ...
    COLOR 7
    PRINT
    COLOR 9
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
    GOTO save_data
END IF
'
PRINT
'
'
CLOSE 2%
200 OPEN FFTab_file$ FOR OUTPUT AS #2%
PRINT " Please wait!"
PRINT
'
sub_header1$ = "Azimuth Pattern   Elevation angle ="
sub_header2$ = " Deg      V dB      H dB      Tot dB"
'
For I% = 1% to 10%
    PRINT #2%, "empty line"        ' EZNEC header.
NEXT I%
'
FOR zenith% = 180% to 0% STEP -1%  ' Equivalent to: from Elevation = -90 to +90.
    IF 90% - zenith% <  0% THEN PRINT #2%, sub_header1$;" "; 90% - zenith%; "deg."   ' Due to minus sign.
	IF 90% - zenith% >= 0% THEN PRINT #2%, sub_header1$;     90% - zenith%; "deg."
    PRINT #2%, sub_header2$
        FOR azimuth% = 0% to 360%
			format% = 0%           ' Initialization of the format of the "Tot dB" number (11 formats from 1 to 11).
            PRINT #2%, USING "###"; azimuth%;
			Total_dBi = Total_dBi(zenith%, azimuth%)
			Total_dBi$ = STR$(Total_dBi)
			'
			'
			' In each of the comments of the 11 formats encountered:
			' - field 1: csv file         format
			' - field 2: QBasic numerical format
			' - field 3: Qbasic string    format
			' - field 4: final FFTab      format	
			'
			'
			dot_exists% = INSTR(1%,Total_dBi$,".")
			'
			IF dot_exists% = 0% AND LEN(Total_dBi$) = 2% THEN
			    Total_dBi$ = " " + Total_dBi$ + ".00"
				format% = 1%
				'-9/-9 /-9/ -9.00
				 '0/ 0 / 0/  0.00
				 '5/ 5 / 5/  5.00
			END IF
			'
			IF dot_exists% = 0% AND LEN(Total_dBi$) = 3% THEN
			    Total_dBi$ =       Total_dBi$ + ".00"
				format% = 2%
				'-16/-16 /-16/-16.00
				 '10/ 10 / 10/ 10.00
			END IF
			'
			IF dot_exists% = 0% AND LEN(Total_dBi$) = 4% THEN
   			    Total_dBi$ =       Total_dBi$ + ".00"
				format% = 3%                     ' So: 7 characters.
				'-100/-100 /-100/-100.00
			 	 '100/ 100 / 100/ 100.00
			END IF	
			'
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%)="" AND LEN(Total_dBi$) = 4% THEN
   			    Total_dBi$ = " "  + Total_dBi$ + "0"
			    format% = 4%
				'-9.9/-9.9 /-9.9/ -9.90
				 '9.9/ 9.9 / 9.9/  9.90
			END IF
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%)="" AND LEN(Total_dBi$) = 5% THEN
			    Total_dBi$ =        Total_dBi$ + "0"
				format% = 5%
				'-15.1/-15.1 /-15.1/-15.10
				 '10.2/ 10.2 / 10.2/ 10.20
			END IF
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%)="" AND LEN(Total_dBi$) = 6% THEN
			    Total_dBi$ =        Total_dBi$ + "0"
				format% = 6%                     ' So: 7 characters.
				'-100.1/-100.1 /-100.1/-100.10
				 '100.1/ 100.1 / 100.1/ 100.10
			END IF	
			'
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%)="" AND LEN(Total_dBi$) = 3% THEN
			    Total_dBi$ = " " + MID$(Total_dBi$,1%,1%) + "0" + MID$(Total_dBi$,2%,2%) + "0"
				format% = 7%
				'-0.6/-.6 /-.6/ -0.60
				 '0.1/ .1 / .1/  0.10
			END IF
			'
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%) <> "" AND LEN(Total_dBi$) = 5% THEN
			    Total_dBi$ = " "  + Total_dBi$
				format% = 8%
				'-9.76/-9.76 /-9.76/ -9.76
				 '9.84/ 9.84 / 9.84/  9.84
			END IF
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%) <> "" AND LEN(Total_dBi$) = 6% THEN
			    Total_dBi$ =        Total_dBi$
				format% = 9%
				'-15.78/-15.78 /-15.78/-15.78
				 '10.24/ 10.24 / 10.24/ 10.24
			END IF
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%) <> "" AND LEN(Total_dBi$) = 7% THEN
			    Total_dBi$ =        Total_dBi$
				format% = 10%                    ' So: 7 characters.
				'-100.12/-100.12 /-100.12/-100.12
				 '100.12/ 100.12 / 100.12/ 100.12
			END IF	
			'
			'
			IF dot_exists% <> 0% AND MID$(Total_dBi$, dot_exists% + 2%, 1%) <> "" AND LEN(Total_dBi$) = 4% THEN
			    Total_dBi$ = " " + MID$(Total_dBi$,1%,1%) + "0" + MID$(Total_dBi$,2%,3%)
				format% = 11%
				'-0.01/-.01 /-.01/ -0.01
				 '0.54/ .54 / .54/  0.54
			END IF	
			'
			'
			IF format% = 0% THEN
				PRINT
			    PRINT " The program has encountered an unexpected gain value!"
				PRINT " Gain = ";Total_dBi;"dBi at zenith = ";zenith%;"deg. and azimuth = ";azimuth%;"deg."
				PRINT
				PRINT " Please save your MMANA FF csv file and contact the program's author."
				PRINT
				PRINT
				PRINT " Press any key now to close the program."
				GOSUB waiting
				CLOSE 1%                ' By security!
				CLOSE 2%                ' By security!
				SYSTEM                  ' By security!
			END IF
			'
			'			
	        IF Total_dBi >= 100  OR Total_dBi <= -100 THEN PRINT #2%, SPACE$(25%);   ' Total_dBi$ occupies 7 characters.
			IF Total_dBi <  100 AND Total_dBi >  -100 THEN PRINT #2%, SPACE$(26%);   ' Total_dBi$ occupies 6 characters.
			'PRINT "here";Total_dBi;"here";Total_dBi$;"here"                         ' In case of debugging.
			PRINT #2%, Total_dBi$
            '	
        NEXT azimuth%
	IF 90% - zenith% <> 90% THEN PRINT #2%,""	' Elevation +90 deg. is the last elevation in the EZNEC-like FFTab and there is no empty line at the end of the FFTab.
NEXT zenith%
CLOSE 2%
'
COLOR 10
PRINT " Your EZNEC-like FFTab file has been built!"
COLOR 7
PRINT
PRINT " Press any key now to close the program.";
GOSUB waiting
'
SYSTEM                  ' By security!
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
error_handler:
IF (ERR = 53% OR ERR = 70% OR ERR = 76%) AND ERL = 200% THEN ' Error when creating the output EZNEC-like FFTab file.
    'BEEP
    COLOR 12
    PRINT " The EZNEC-like FFTab file name is not adequate!"
    PRINT
    COLOR 9
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
	PRINT
    RESUME save_data
END IF
'
IF (ERR = 53% OR ERR = 70% OR ERR = 76%) AND ERL = 20% THEN            ' MMANA FF csv file not found.
    'BEEP
    PRINT
    COLOR 12
    PRINT " The MMANA FF csv file has not been found!"
    PRINT
    COLOR 9
    PRINT " Press any key to continue!";
    COLOR 7
    GOSUB waiting
    CLS
	PRINT
    RESUME FF_csv_file_filename
END IF
'
IF ERR = 62% AND (ERL = 21 OR ERL = 22) THEN   ' MMANA FF csv file input past end of file.
    'BEEP
    PRINT
    COLOR 12
    PRINT " The MMANA FF csv file is not in accordance with the right format"
    PRINT " (number of lines and/or content of lines)."
    PRINT
    COLOR 9
	PRINT " Press any key to continue!";
	COLOR 7
    GOSUB waiting
    CLS
	PRINT
    RESUME FF_csv_file_filename
END IF
'
COLOR 12
    PRINT "Error"; ERR; "at line";_ERRORLINE
    PRINT
    COLOR 9
    PRINT " Press any key to close the windows!";
    COLOR 7
    GOSUB waiting
    SYSTEM