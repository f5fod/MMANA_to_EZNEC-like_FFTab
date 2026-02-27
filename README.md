# MMANA_to_EZNEC-like_FFTab
## To convert an MMANA FF csv file into an EZNEC-like FFTab file to feed AGTC

### Goal
The goal is to convert an MMANA FF csv file into an EZNEC-like FFTab file and verify it!<br>
Next, this EZNEC-like FFTab file can be used with AGTC programs to calculate the antenna's G/T.

### First of all, build your MMANA FF csv file (*myantenna.csv*)
MMANA-GAL version 3.5.3.82, for instance.<br>
File/Table of Angle/Gain(*.csv)<br>
                Start deg.    Step deg.    Num. of steps<br>
     Azimuth    0.0           1.0          361<br>
      Zenith    0.0           1.0          181<br>

### The convertion program
`src/` : QB64 source code `MMANA_FFTab/MMANA_FFTab_V1-8.bas`<br>
`bin/` : Compiled with QB64 32 bits, Windows executable `MMANA_FFTab/MMANA_FFTab_V1-8.exe`

Download this executable and run it.<br>
It will ask you the input MMANA FF csv file name (*myantenna.csv*) and the name you want to give to the output EZNEC-like FFTab file (*myantenna_FFTab.txt*).

### The verify program
`src/` : QB64 source code `VERIFY_V1-7.bas`<br>
`bin/` : Compiled with QB64 32 bits, Windows executable `VERIFY_V1-7.exe`

Download this executable and run it.<br>
It will ask you the MMANA FF csv file name (*myantenna.csv*) and the EZNEC-like FFTab file name (*myantenna_FFTab.txt*).<br>

It checks that MMANA_FFTab_Vx-y has done its job correctly:<br>
- it calculates the checksums (algebraic sum of all the gain values) of both the input MMANA csv file and the output EZNEC-like FFTab file,<br>
- it compares the gains one by one across 181 x 361 points between the two files,<br>
- it finally checks that all the gains in the output EZNEC-like FFTab file have their decimal points at their correct positions.

And error_file.txt indicates the (elevation/azimuth) points which are "in error", with the corresponding gain values in both files or says "All OK!"<br>

As usual, the .bas sources are fully documented, included the file formats (MMANA and EZNEC).<br>

If you need to recompile the source file, prefer QB64 **32 bits** as QB64 64 bits will give you smaller characters in the Console.

### Author
F5FOD

### License Creative Commons BY-NC 4.0
This license CC BY-NC enables reusers to distribute, remix, adapt, and build upon the material in any medium or format for noncommercial purposes only, and only so long as attribution is given to the creator.
Full text in the LICENSE file.

### Reference articles, written by F5FOD with DG7YBN

**Part 1:** An Antenna G/T calculator (*AGTC_lite*) without mathematical rotation calculations, DUBUS, 1/2017

**Part 2:** An Antenna G/T calculator (*AGTC* and *AGTC_fast*) with mathematical rotation calculation, DUBUS, 2/2017

**Part 3:** A brief history of the *AGTC_lite/AGTC* project and some additional references, DUBUS, 3/2017

**Part 4:** Thirty years ago, DJ9BV was 100% correct in his antenna *Effective Noise Temperatures* (…) calculation article; an important consequence for *AGTC_lite*, DUBUS, 4/2017
