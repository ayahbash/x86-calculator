.MODEL SMALL
.STACK 100H

; ============= DATA SEGMENT =============
_DATA SEGMENT
    ; ----- Menu Messages -----
    MAIN_MENU_MSG DB 13,10,'==== Calculator Menu ====',13,10
                 DB '1. Addition',13,10
                 DB '2. Subtraction',13,10
                 DB '3. Multiplication',13,10
                 DB '4. Division',13,10
                 DB '5. AND',13,10
                 DB '6. OR',13,10
                 DB '7. Exit',13,10
                 DB 'Choice: $'

    BASE_MENU_MSG DB 13,10,'Choose Base:',13,10
                 DB 'B - Binary',13,10
                 DB 'D - Decimal',13,10
                 DB 'H - Hexadecimal',13,10
                 DB 'Choice: $'

    ; ----- Input Prompts -----
    INPUT_NUM1_MSG DB 13,10,'Enter first number: $'
    INPUT_NUM2_MSG DB 13,10,'Enter second number: $'
    INVALID_INPUT_MSG DB 13,10,'Invalid input! $'
    RESULT_MSG DB 13,10,'Result: $'
    DIV_ZERO_MSG DB 13,10,'Error: Division by zero! $'
    PRESS_ANY_KEY DB 13,10,'Press any key to continue...$'
    
    ; ----- Flags Display -----
    MSG_FLAGS DB 13,10,'FLAGS: CF=0 PF=0 AF=0 ZF=0 SF=0 OF=0',13,10,'$'

    ; ----- Variables -----
    NUM1 DW ?        ; First operand
    NUM2 DW ?        ; Second operand
    RESULT DW ?      ; Calculation result
    INPUT_BASE DB ?  ; Selected number base (B/D/H)
    TEMP_BUFFER DB 6 DUP(0)  ; Temporary buffer for conversions
_DATA ENDS

; ============= CODE SEGMENT =============
.CODE
MAIN PROC FAR
    ; Initialize data segment
    MOV AX, SEG _DATA
    MOV DS, AX

MENU_LOOP:
    ; Display main menu and get user choice
    CALL CLEAR_SCREEN
    CALL DISPLAY_MENU
    MOV AH, 01H
    INT 21H
    
    ; Process menu selection
    CMP AL, '1'
    JE ADDITION
    CMP AL, '2'
    JE SUBTRACTION
    CMP AL, '3'
    JE MULTIPLICATION
    CMP AL, '4'
    JE DIVISION
    CMP AL, '5'
    JE AND_OP
    CMP AL, '6'
    JE OR_OP
    CMP AL, '7'
    JE EXIT
    
    ; Invalid choice handler
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    CALL WAIT_FOR_KEY
    JMP MENU_LOOP

; ----- Operation Handlers -----
ADDITION:
    CALL GET_INPUTS
    CALL ADD_NUMBERS
    JMP MENU_LOOP

SUBTRACTION:
    CALL GET_INPUTS
    CALL SUB_NUMBERS
    JMP MENU_LOOP

MULTIPLICATION:
    CALL GET_INPUTS
    CALL MUL_NUMBERS
    JMP MENU_LOOP

DIVISION:
    CALL GET_INPUTS
    CALL DIV_NUMBERS
    JMP MENU_LOOP

AND_OP:
    CALL GET_INPUTS
    CALL AND_NUMBERS
    JMP MENU_LOOP

OR_OP:
    CALL GET_INPUTS
    CALL OR_NUMBERS
    JMP MENU_LOOP

EXIT:
    ; Terminate program
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; ============= SUPPORT PROCEDURES =============

; Waits for any key press
WAIT_FOR_KEY PROC
    LEA DX, PRESS_ANY_KEY
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    RET
WAIT_FOR_KEY ENDP

; Clears the screen
CLEAR_SCREEN PROC
    MOV AH, 0FH
    INT 10H
    MOV AH, 0
    INT 10H
    RET
CLEAR_SCREEN ENDP

; Displays the main menu
DISPLAY_MENU PROC
    LEA DX, MAIN_MENU_MSG
    MOV AH, 09H
    INT 21H
    RET
DISPLAY_MENU ENDP

; Gets both input numbers
GET_INPUTS PROC
    CALL GET_BASE
    
    ; Get first number
    LEA DX, INPUT_NUM1_MSG
    MOV AH, 09H
    INT 21H
    CALL GET_NUMBER
    MOV NUM1, BX
    
    ; Get second number
    LEA DX, INPUT_NUM2_MSG
    MOV AH, 09H
    INT 21H
    CALL GET_NUMBER
    MOV NUM2, BX
    RET
GET_INPUTS ENDP

; Gets and validates number base selection
GET_BASE PROC
    LEA DX, BASE_MENU_MSG
    MOV AH, 09H
    INT 21H
    
    ; Get base choice
    MOV AH, 01H
    INT 21H
    
    ; Convert to uppercase
    CMP AL, 'a'
    JL NOT_LOWER
    CMP AL, 'z'
    JG NOT_LOWER
    SUB AL, 32
NOT_LOWER:
    MOV INPUT_BASE, AL
    
    ; Validate input
    CMP AL, 'B'
    JE VALID_BASE
    CMP AL, 'D'
    JE VALID_BASE
    CMP AL, 'H'
    JE VALID_BASE
    
    ; Invalid base
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    JMP GET_BASE
    
VALID_BASE:
    RET
GET_BASE ENDP

; Routes to appropriate number input method
GET_NUMBER PROC
    CMP INPUT_BASE, 'B'
    JE GET_BIN
    CMP INPUT_BASE, 'D'
    JE GET_DEC
    CMP INPUT_BASE, 'H'
    JE GET_HEX
    
    JMP INVALID_INPUT

GET_BIN:
    CALL GET_BINARY
    RET

GET_DEC:
    CALL GET_DECIMAL
    RET

GET_HEX:
    CALL GET_HEXADECIMAL
    RET

INVALID_INPUT:
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    JMP GET_NUMBER
GET_NUMBER ENDP

; ============= INPUT METHODS =============

; Gets binary number input
GET_BINARY PROC
    XOR BX, BX
    MOV CX, 16
    
BIN_LOOP:
    ; Get each binary digit
    MOV AH, 01H
    INT 21H
    
    CMP AL, 13
    JE BIN_DONE
    
    ; Validate 0 or 1
    CMP AL, '0'
    JB BIN_ERROR
    CMP AL, '1'
    JA BIN_ERROR
    
    ; Shift and add digit
    SHL BX, 1
    SUB AL, '0'
    OR BL, AL
    LOOP BIN_LOOP
    
BIN_DONE:
    RET

BIN_ERROR:
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    JMP GET_BINARY
GET_BINARY ENDP

; Gets decimal number input
GET_DECIMAL PROC
    XOR BX, BX
    MOV CX, 0
    
DEC_LOOP:
    ; Get each digit
    MOV AH, 01H
    INT 21H
    
    CMP AL, 13
    JE DEC_DONE
    
    ; Validate 0-9
    CMP AL, '0'
    JB DEC_ERROR
    CMP AL, '9'
    JA DEC_ERROR
    
    ; Convert to value and push
    SUB AL, '0'
    MOV AH, 0
    PUSH AX
    INC CX
    JMP DEC_LOOP
    
DEC_DONE:
    JCXZ DEC_ERROR      ; No input
    
    ; Convert digits to number
    MOV BX, 0
    MOV SI, 1           ; Place value
    
DEC_CONVERT:
    POP AX
    MUL SI              ; digit * place value
    ADD BX, AX
    
    ; Calculate next place value
    MOV AX, SI
    MOV SI, 10
    MUL SI
    MOV SI, AX
    
    LOOP DEC_CONVERT
    RET

DEC_ERROR:
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    JMP GET_DECIMAL
GET_DECIMAL ENDP

; Gets hexadecimal number input
GET_HEXADECIMAL PROC
    XOR BX, BX
    MOV CX, 4
    
HEX_LOOP:
    ; Get each hex digit
    MOV AH, 01H
    INT 21H
    
    CMP AL, 13
    JE HEX_DONE
    
    ; Convert to uppercase
    CMP AL, 'a'
    JL NOT_LOWER_HEX
    CMP AL, 'f'
    JG NOT_LOWER_HEX
    SUB AL, 32
NOT_LOWER_HEX:
    
    ; Validate hex digit
    CMP AL, '0'
    JB HEX_ERROR
    CMP AL, '9'
    JBE HEX_DIGIT
    CMP AL, 'A'
    JB HEX_ERROR
    CMP AL, 'F'
    JA HEX_ERROR
    
HEX_DIGIT:
    ; Convert to 0-15 value
    SUB AL, '0'
    CMP AL, 9
    JBE IS_DIGIT
    SUB AL, 7       ; Adjust for A-F
    
IS_DIGIT:
    ; Shift and add digit
    MOV CL, 4
    SHL BX, CL
    OR BL, AL
    LOOP HEX_LOOP
    
HEX_DONE:
    RET

HEX_ERROR:
    LEA DX, INVALID_INPUT_MSG
    MOV AH, 09H
    INT 21H
    JMP GET_HEXADECIMAL
GET_HEXADECIMAL ENDP

; ============= MATH OPERATIONS =============

; Performs addition
ADD_NUMBERS PROC
    CLC
    MOV AX, NUM1
    ADD AX, NUM2
    MOV RESULT, AX
    PUSHF 
    CALL SHOW_RESULT
    POPF
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
ADD_NUMBERS ENDP

; Performs subtraction
SUB_NUMBERS PROC
    CLC
    MOV AX, NUM1
    SUB AX, NUM2
    MOV RESULT, AX
    PUSHF 
    CALL SHOW_RESULT
    POPF 
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
SUB_NUMBERS ENDP

; Performs multiplication
MUL_NUMBERS PROC
    CLC
    MOV AX, NUM1
    MUL NUM2
    MOV RESULT, AX
    TEST AX, AX 
    PUSHF 
    CALL SHOW_RESULT
    POPF 
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
MUL_NUMBERS ENDP

; Performs division
DIV_NUMBERS PROC
    CLC
    CMP NUM2, 0
    JE DIV_ERROR
    MOV AX, NUM1
    XOR DX, DX
    DIV NUM2
    MOV RESULT, AX
    PUSHF 
    CALL SHOW_RESULT
    POPF 
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
    
DIV_ERROR:
    LEA DX, DIV_ZERO_MSG
    MOV AH, 09H
    INT 21H
    CALL WAIT_FOR_KEY
    RET
DIV_NUMBERS ENDP

; Performs bitwise AND
AND_NUMBERS PROC
    CLC
    MOV AX, NUM1
    AND AX, NUM2
    MOV RESULT, AX
    PUSHF 
    CALL SHOW_RESULT
    POPF 
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
AND_NUMBERS ENDP

; Performs bitwise OR
OR_NUMBERS PROC
    CLC
    MOV AX, NUM1
    OR AX, NUM2
    MOV RESULT, AX
    PUSHF 
    CALL SHOW_RESULT
    POPF 
    CALL SHOW_FLAGS
    CALL WAIT_FOR_KEY
    RET
OR_NUMBERS ENDP

; ============= OUTPUT METHODS =============

; Displays result in appropriate base
SHOW_RESULT PROC
    LEA DX, RESULT_MSG
    MOV AH, 09H
    INT 21H
    
    CMP INPUT_BASE, 'B'
    JE SHOW_BIN
    CMP INPUT_BASE, 'D'
    JE SHOW_DEC
    CMP INPUT_BASE, 'H'
    JE SHOW_HEX
    
    RET

; Binary output
SHOW_BIN:
    MOV BX, RESULT
    MOV CX, 16
BIN_SHOW:
    ROL BX, 1
    JC SHOW_1
    MOV DL, '0'
    JMP PRINT_BIT
SHOW_1:
    MOV DL, '1'
PRINT_BIT:
    MOV AH, 02H
    INT 21H
    LOOP BIN_SHOW
    RET

; Decimal output (handles negative numbers)
SHOW_DEC:
    MOV AX, RESULT
    TEST AX, 8000h       ; Check sign bit
    JZ POSITIVE_NUMBER
    
    ; Handle negative number
    PUSH AX
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    POP AX
    NEG AX
    
POSITIVE_NUMBER:
    XOR CX, CX
    MOV BX, 10
DEC_SHOW:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ DEC_SHOW
PRINT_DEC:
    POP DX
    MOV AH, 02H
    INT 21H
    LOOP PRINT_DEC
    RET

; Hexadecimal output
SHOW_HEX:
    MOV BX, RESULT
    MOV CX, 4
HEX_SHOW:
    MOV DL, BH
    MOV CL, 4
    SHR DL, CL
    CALL PRINT_HEX_DIGIT
    
    MOV DL, BH
    AND DL, 0FH
    CALL PRINT_HEX_DIGIT
    
    MOV CL, 8
    ROL BX, CL
    LOOP HEX_SHOW
    RET

; Helper for hex digit printing
PRINT_HEX_DIGIT:
    CMP DL, 10
    JB IS_NUM
    ADD DL, 7
IS_NUM:
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    RET
SHOW_RESULT ENDP

; Displays CPU flags after operation
SHOW_FLAGS PROC
    ; Save registers
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH DI

    ; Initialize flags display to all zeros
    MOV DI, OFFSET MSG_FLAGS
    MOV BYTE PTR [DI+7], '0'   ; CF
    MOV BYTE PTR [DI+12], '0'  ; PF
    MOV BYTE PTR [DI+17], '0'  ; AF
    MOV BYTE PTR [DI+22], '0'  ; ZF
    MOV BYTE PTR [DI+27], '0'  ; SF
    MOV BYTE PTR [DI+32], '0'  ; OF

    ; Get current flags
    PUSHF
    POP AX

    ; Test and update each flag display:
    
    ; Carry Flag
    TEST AX, 0001h
    JZ CF_ZERO
    MOV BYTE PTR [DI+7], '1'
CF_ZERO:

    ; Parity Flag
    TEST AX, 0004h
    JZ PF_ZERO
    MOV BYTE PTR [DI+12], '1'
PF_ZERO:

    ; Auxiliary Flag
    TEST AX, 0010h
    JZ AF_ZERO
    MOV BYTE PTR [DI+17], '1'
AF_ZERO:

    ; Zero Flag
    TEST AX, 0040h
    JZ ZF_ZERO
    MOV BYTE PTR [DI+22], '1'
ZF_ZERO:

    ; Sign Flag
    TEST AX, 0080h
    JZ SF_ZERO
    MOV BYTE PTR [DI+27], '1'
SF_ZERO:

    ; Overflow Flag
    TEST AX, 0800h
    JZ OF_ZERO
    MOV BYTE PTR [DI+32], '1'
OF_ZERO:

    ; Display flags
    MOV AH, 09h
    MOV DX, OFFSET MSG_FLAGS
    INT 21h

    ; Restore registers
    POP DI
    POP DX
    POP BX
    POP AX
    RET
SHOW_FLAGS ENDP

END MAIN