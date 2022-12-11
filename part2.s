@ECE 371 Design Project 1, Part 2
@This program will take 16 8-bit temperatures from the array (Fahrenheit_Temps) and average them
@Then store the average in memory (Average_Temp)
@Uses R1 - R3 for Fahreinheit_Temps, Total_Temp and Average_Temp pointers
@Uses R4 - R5, R12 Counters and Rounding Factor
@Uses R6 - R11 to convert, add and average temps
@Phil Nevins, 11/13/2022
@NOTE: With our test values, we should get 1-16 celsius temps in memory,
@and then 8.5 exact, 9 rounded average
@NOTE: Final Answer Yields 0x09 -> 9_decimal

.text
.global _start

_start:

.equ AddCounter, 16			@Set counter for adding temps to 16 (# of temps to be added)
.equ DivideCounter, 4		@Set counter for shifting right to divide by 16 (4 was getting 2x expected value)
.equ RoundingFactor, 5			@Set rounding factor for divide function

LDR R13, =STACK				@Load stack pointer into R13
ADD R13, R13, #0x100		@Point to bottom of the stack
LDR R1, =Celsius_Temps		@Load pointer to Celsius_Temps
LDR R0, =Fahrenheit_Temps	@Load pointer to Fahrenheit_Temps array
LDR R2, =Total_Temp			@Load pointer to Total_Temp array
LDR R3, =Average_Temp		@Load pointer to Average_Temp array
MOV R4, #AddCounter			@Load R4 with AddCounter
MOV R5, #DivideCounter		@Load R5 with DivideCounter
MOV R12, #RoundingFactor	@Load R12 with decimal 5

BL Calculate_Celsius_Temp
MOV R4, #AddCounter			@Reset AddCounter. Doing this allows use in Calculate_Celsius_Temp and Add / Avg temps loop (determined during debugging)
MOV R7, #0					@Clear R7. Keeps loading #9 into it for no reason (determined during debugging)
ADD R2, R2, #32				@Adjust R2 pointer to right after Celsius array (determined during debugging)

Add_Temps_Loop:
	LDRH R6, [R0], #4			@Load a Celsius_Temp half word into R6 then increment to next addr in memory
	@Determine why we are using R0 instead of R1. R1 should be Celsius_Temp array
	LDRH R7, [R2]				@Load a Total_Temp half word into R7. No Need to INC since the total will get overwritten each time
	ADD R8, R6, R7				@Add new temp from R6 and previous total from R7, store in R8
	STR R8, [R2]				@Move new total in R8 into memory pointed to by R2
	SUBS R4, #1					@Decrement AddCounter for Add_Temps_Loop counter by 1
	BNE Add_Temps_Loop			@Branch if zero flag not set
	NOP
	@At the end of this loop, all temps in Celsius_Temps array will be added together and saved memory at R2 EA

ADD R3, R3, #34					@Adjust R3 pointer to display Avg Temp after total temp (deteremined during debugging)
Avg_Temps_Loop:
	LSR R8, #1					@Logical Shift Right R8 by 1 bit (divide by 2)
	STRB R8, [R3]				@Store value in R8 into memory at R3 EA
	SUBS R5, #1					@Decrement DivideCounter for Avg_Temps_Loop counter by 1
	BNE Avg_Temps_Loop			@Branch if zero flag not set
	ADC R8, R8, #0				@Add one to R8 for rounding (will be set if LSR shifts a 1 out)
	STRB R8, [R3]				@Update total if carry added
	B DONE						@Branch to end
	@At the end of this loop, Average_Temp array should contain average temperature of Fahrenheit_Temps

Calculate_Celsius_Temp: STMFD R13!, {R6 - R11, R14}	@Function Call for F->C conversion 7 registers saved
Loop1:     											@Function to convert from F -> C.... C = 5/9 * (F - 32)
	LDRH R10, [R0], #2			@Load a Fahrenheit_Temp half word into R10 then increment to next addr in memory
	SUB R10, #0x20				@R10 - 32
	MUL R11, R10, R12			@Multiply R10 by 5, store in R11
	MOV R9, #0x0 				@Set R9 to 0 for subtract 9 counter

		Divide_By_9: 			@Since we have no division command, we have to do the subtract 9 method
			SUBS R11, #0x9		@Subtract 9
			ADD R9, R9, #0x1	@Add 1 to the division counter. Example: 18 / 9 = 2, so R9 will be 2 when we branch out of loop
			CMP R12, R11		@5 < R11, C = 1
			ADC R11, R11, #0	@Round up (+ 1) if carry set
		BMI Divide_By_9			@Branch if negative flag is not set
		NOP

		Add_Values_To_Memory:
			STR R9, [R1], #0x4			@Store value in R9 in memory at R1 EA, then increment to next memory address
			SUBS R4, #0x1				@Decrement AddCounter for Calculate_Celsius_Temp counter by 1
			BNE Loop1						@Branch if zero flag not set
			NOP
LDMFD R13!, {R6 - R11, R14}				@Restore registers
MOV PC, LR								@Return to mainline

Fahrenheit_Temps:	.HWORD 0x22, 0x24, 0x25, 0x27, 0x29, 0x2B, 0x2D, 0x2E, 0x30, 0x32, 0x34, 0x36, 0x37, 0x39, 0x3B, 0x3D @Test Values Array

Celsius_Temps: 		.HWORD 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0					@Converted To Celsius Array

Total_Temp: 		.HWORD 0x0		@Total Temp Array

Average_Temp: 		.HWORD 0x0		@Temp Average Array

.align 2							@Stack allocation
STACK: .rept 256
		.byte 0x00
		.endr
DONE:
.END								@End of program
