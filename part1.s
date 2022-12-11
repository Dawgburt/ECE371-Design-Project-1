@ECE 371 Design Project 1, Part 1
@This program will take 16 8-bit temperatures from the array (Fahrenheit_Temps) and average them
@Then store the average in memory (Average_Temp)
@Uses R1-R3 for Fahreinheit_Temps, Total_Temp and Average_Temp pointers
@Uses R4 - R5 for counters
@Uses R6 - R8 to add and average temps
@Phil Nevins, 11/13/2022
@NOTE: With our test values, we expect the answer to be 39.5 -> 40
@NOTE: Final Answer Yields 0x28 -> 40_decimal

.text
.global _start

_start:

.equ AddCounter, 16			@Set counter for adding temps to 16 (# of temps to be added)
.equ DivideCounter, 4		@Set counter for shifting right to divide to 4 (# of shifts to divide by 16)

LDR R1, =Fahrenheit_Temps	@Load pointer to Fahrenheit_Temps array
LDR R2, =Total_Temp			@Load pointer to Total_Temp array
LDR R3, =Average_Temp		@Load pointer to Average_Temp array
MOV R4, #AddCounter			@Load R4 with AddCounter
MOV R5, #DivideCounter		@Load R5 with DivideCounter

Add_Temps_Loop:
	LDRH R6, [R1], #2		@Load a Fahrenheit_Temp half word into R6 then increment to next addr in memory
	LDRH R7, [R2]			@Load a Total_Temp half word into R7. No Need to INC since the total will
							@get overwritten each time, which is what we want
	ADD R8, R6, R7			@Add new temp from R6 and previous total from R7, store in R8
	STR R8, [R2]			@Move new total in R8 into memory pointed to by R2
	SUBS R4, #1				@Decrement AddCounter for Add_Temps_Loop counter by 1
	BNE Add_Temps_Loop
	NOP
	@At the end of this loop, all temps in Fahrenheit_Temps array
	@will be added together and saved memory at R2 EA

Avg_Temps_Loop:
	LSR R8, #1				@Logical Shift Right memory value at R3 EA by 1 bit (divide by 2)
	STRB R8, [R3], #4		@Store value from R8 into EA at R3
	SUBS R5, #1				@Decrement DivideCounter for Avg_Temps_Loop counter by 1
	BNE Avg_Temps_Loop
	ADC R8, R8, #0			@Add one to R8 if there is a carry from shift right
	STRB R8, [R3]			@Store Value + Carry in R3
	NOP
	@At the end of this loop, Average_Temp array
	@will contain average temperature of Fahrenheit_Temps

Fahrenheit_Temps:	.HWORD 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F
									@Test Values Array ^^^^

Total_Temp: 		.HWORD 0x0		@Total Temp Array

Average_Temp: 		.HWORD 0x0		@Temp Average Array

.END		@End of program
