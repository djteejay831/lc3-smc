

;R0 - current input character / scratch
;R1 - comparison scratch
;R2 - multiply by 10 scratch
;R3 - multiply by 10 scratch
;R4 - digit counter
;R5 - running total
;R6 - stack pointer
;R7 - return address
            .ORIG x3000
            BRnzp START                 ; data section closer to code
;-----------------------------------    ; so labels work ----------------------
STACK_TOP       .FILL xEFFF             ; top of the stack
HEADER1         .STRINGZ "SMC RPN Calculator\n"
HEADER2         .STRINGZ "Enter 0-9 or +,-,*,/, or . to display result on TOS\n"
PROMPT_RDY      .FILL x3E               ; >
ENTER_VAL       .FILL x0A               ; carriage return
CR_VAL          .FILL X0D               ; carriage return to ignore
DIGIT_LO        .FILL x30               ; ASCII 0
DIGIT_HI        .FILL x39               ; ASCII 9
DOT_VAL         .FILL x2E               ; .
;------------------------------------------------------------------------------
; jump over data section
; initialize stack pointer            
START       LD R6, STACK_TOP
; reset - clear active number input registers
RESET       AND R5, R5, #0
            AND R4, R4, #0
            LEA R0, HEADER1
            PUTS
            LEA R0, HEADER2
            PUTS
            BRnzp MAIN_LOOP

MAIN_LOOP   LEA R1, PROMPT_RDY
            LDR R0, R1, #0
            OUT
            GETC
            LD R1, CR_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1
            BRz MAIN_LOOP           ; ignore x0D
            
            ; check for enter
            LD R1, ENTER_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x0A
            BRz IS_ENTER            ;if zero, is enter
            
            ; check if digit is >= x30 (0)
            LD R1, DIGIT_LO         
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus 0
            BRn NOT_DIGIT           ;if negative, is below 0. skip
            
            ; check if digit is <= x39 (9)
            LD R1, DIGIT_HI
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus 9
            BRp NOT_DIGIT           ;if positive, is above 9. skip
            BRnzp IS_DIGIT          ;passed both checks, must be digit
                
NOT_DIGIT   
            ; check for .
            LD R1, DOT_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x2E
            BRz IS_DOT              ;if zero, is .
            
            ; check for +
            LD R1, PLUS_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x2B
            BRz IS_PLUS             ;if zero, is +
            
            ; check for -
            LD R1, MINUS_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x2D
            BRz IS_MINUS            ;if zero, is -
            
            ; check for *
            LD R1, MUL_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x2A
            BRz IS_MULTIPLY         ;if zero, is *
            
            ; check for /
            LD R1, DIV_VAL
            NOT R1, R1
            ADD R1, R1, #1
            ADD R1, R0, R1          ;R0 minus x2F
            BRz IS_DIVIDE           ;if zero, is /
            BRnzp MAIN_LOOP
;subroutines here
; check for 4 digits
IS_DIGIT    
            NOT R1, R4
            ADD R1, R1, #1
            ADD R1, R1, #4
            BRz OVERFLOW                ; reset if over 4 digits
            LD R1, DIGIT_LO             ; subract x30 to check if digit
            NOT R1, R1
            ADD R1, R1, #1              ; r1 = -x30
            ADD R0, R0, R1              ; input - x30 = digit value
; multiply input by 10 for 10s/100s/1000s place
; using r5 * 8 + r5 * 2
            ADD R2, R5, R5
            ADD R3, R5, R5
            ADD R3, R3, R3
            ADD R3, R3, R3
            ADD R3, R3, R2
            ADD R5, R0, R3              ; add new digit to r5
            ADD R4, R4, #1              ; add 1 to counter
            BRnzp MAIN_LOOP
            
IS_ENTER
            ADD R4, R4, #0              ; test digit counter
            BRz SKIP_ENTER
            ADD R0, R5, #0              ; move r5 into r0
            JSR PUSH                    ; push r0 onto stack
            AND R5, R5, #0              ; clear running total
            AND R4, R4, #0              ; clear digit counter
            BRnzp MAIN_LOOP
SKIP_ENTER  BRnzp MAIN_LOOP
            
IS_DOT      
            LDR R0, R6, #0              ; peek at TOS
            AND R1, R1, #0              ; clear quotient
            AND R2, R2, #0              ; clear increment counter register
            ADD R0, R0, #0              ; set condition code to r0
            BRzp DOT_NEXT               ; skip if positive or 0
DOT_NEG     LD R0, NEG_SIGN
            OUT                         ; print - before a negative
            LDR R0, R6, #0              ; reload TOS
            NOT R0, R0
            ADD R0, R0, #1
DOT_NEXT    AND R1, R1, #0              ; clear quotient for next digit            
DIV10_LOOP  ADD R0, R0, #-10            ; subtract 10
            BRn DOT_DIGIT               ; if negative, too far
            ADD R1, R1, #1              ; increment quotient
            BRnzp DIV10_LOOP
DOT_DIGIT   ADD R0, R0, #10             ; add 10 back to get remainder
            JSR PUSH                    ; push digit to stack
            ADD R2, R2, #1              ; increment digit counter
            ADD R0, R1, #0              ; move r1 to r0
            BRz DOT_PRINT
            BRnzp DOT_NEXT              ; else, go back to division loop
            
DOT_PRINT   JSR POP                     ; retrieve remainder digit
            LD R1, DIGIT_LO             ; load x30
            ADD R0, R0, R1              ; convert to ascii
            OUT                         ; print
            ADD R2, R2, #-1             ; decrement digit counter
            BRp DOT_PRINT               ; keep printing if more digits
            AND R0, R0, #0
            ADD R0, R0, #10             ; new line
            OUT
            BRnzp MAIN_LOOP             ; done, back to main
;---------------------------------------------------------------------------
            BRnzp SKIP_DATA_2            ; code 2 big :(
STACK_TWO       .FILL xEFFE             ; 2 less than the top of the stack
PROMPT_ERR      .FILL x3F               ; ?
PROMPT_OVER     .FILL x21               ; !
PROMPT_STK      .FILL x24               ; $
PLUS_VAL        .FILL x2B               ; +
MINUS_VAL       .FILL x2D               ; -
MUL_VAL         .FILL x2A               ; *
DIV_VAL         .FILL x2F               ; /
NEG_SIGN        .FILL x2D               ; -
SKIP_DATA_2
;---------------------------------------------------------------------------
; addition loop
IS_PLUS
            LD R3, STACK_TWO
            NOT R3, R3
            ADD R3, R3, #1              ; r3 is -xEFFE
            ADD R3, R6, R3              ; if 0 or positive, less than 2 items on stack
            BRzp STACK_ERROR            ; branch away to error handler
            JSR POP                     ; pop 2nd number entered
            ADD R3, R0, #0              ; store in r3
            JSR POP                     ; pop 1st number entered
            ADD R0, R0, R3              ; add to 1st and store in r0
            JSR PUSH                    ; push sum back on stack
            BRnzp MAIN_LOOP
            
; subtraction loop
IS_MINUS
            LD R3, STACK_TWO
            NOT R3, R3
            ADD R3, R3, #1              ; r3 is -xEFFE
            ADD R3, R6, R3              ; if 0 or positive, less than 2 items on stack
            BRzp STACK_ERROR            ; branch away to error handler
            JSR POP                     ; pop 2nd number entered
            NOT R0, R0
            ADD R0, R0, #1              ; negate 2nd number
            ADD R3, R0, #0              ; store in r3
            JSR POP                     ; pop 1st number entered
            ADD R0, R0, R3              ; add 1st and negated 2nd numbers
            JSR PUSH                    ; push sum back on stack
            BRnzp MAIN_LOOP            
            
; multiplication loop
IS_MULTIPLY
            LD R3, STACK_TWO
            NOT R3, R3
            ADD R3, R3, #1
            ADD R3, R6, R3
            BRzp STACK_ERROR
            AND R2, R2, #0              ; clear r2
            JSR POP                     ; 2nd number in r0
            ADD R0, R0, #0
            ADD R3, R0, #0              ; save to r3
            BRzp FIRST_POS_M            ; skip negation if positive or zero
            ADD R2, R2, #1              ; increment sign flag
            NOT R3, R3
            ADD R3, R3, #1              ; makes r3 positive
            
            FIRST_POS_M
            JSR POP                     ; 1st number in r0
            ADD R0, R0, #0              ; set branch to r0
            BRzp SECOND_POS_M           ; skip negation if pos or zero
            ADD R2, R2, #1              ; increment sign flag
            NOT R0, R0
            ADD R0, R0, #1              ; make r0 positive
            
            SECOND_POS_M
            AND R1, R1, #0              ; clear accumulator
            ADD R0, R0, #0
            BRz DONE_MUL                ; skip loop if zero
            
MUL_LOOP    ADD R1, R1, R3              ; accumulator + 1st number
            ADD R0, R0, #-1             ; decrement counter
            BRp MUL_LOOP                ; keep looking if positive
            
DONE_MUL    ADD R2, R2, #-1             ; r2 - 1
            BRz NEGATE_M                ; if 0, r2 was 1, so negate
            BRnzp MUL_DONE
NEGATE_M    NOT R1, R1
            ADD R1, R1, #1
MUL_DONE    ADD R0, R1, #0              ; move result to r0 to PUSH
            JSR PUSH
            BRnzp MAIN_LOOP
            
; division loop
IS_DIVIDE   
            LD R3, STACK_TWO
            NOT R3, R3
            ADD R3, R3, #1              ; r3 is -xEFFE
            ADD R3, R6, R3              ; if 0 or positive, less than 2 items on stack
            BRzp STACK_ERROR            ; branch away to error handler
            
            AND R2, R2, #0
            JSR POP                     ; 2nd number in stack
            ADD R0, R0, #0
            ADD R3, R0, #0              ; save to r3
            BRzp FIRST_POS_D            ; skip negation if positive or zero
            ADD R2, R2, #1              ; increment sign flag
            NOT R3, R3
            ADD R3, R3, #1              ; makes r3 positive
            
FIRST_POS_D 
            JSR POP                     ; 1st number in stack
            ADD R0, R0, #0              
            BRzp SECOND_POS_D           ; skip negation if pos or zero
            ADD R2, R2, #1              ; increment sign flag
            NOT R0, R0
            ADD R0, R0, #1              ; make r0 positive
            
SECOND_POS_D
            ADD R3, R3, #0              ; check divisor for zero
            BRz ERROR_OP
            NOT R3, R3
            ADD R3, R3, #1              ; negate divisor for subtraction
            AND R1, R1, #0              ; clear quotient counter
            
DIV_LOOP    ADD R0, R0, R3              ; subtract divisor from dividend
            BRn DONE_DIV                ; if negative, done
            ADD R1, R1, #1              ; increment quotient
            BRnzp DIV_LOOP
            
DONE_DIV    ADD R2, R2, #-1             ; r2 - 1
            BRz NEGATE_D                ; if 0, r2 was 1, so negate
            BRnzp DIV_DONE
            
NEGATE_D    NOT R1, R1
            ADD R1, R1, #1
DIV_DONE    ADD R0, R1, #0              ; move result to r0 to PUSH
            JSR PUSH
            BRnzp MAIN_LOOP            
            
PUSH        ADD R6, R6, #-1
            STR R0, R6, #0
            RET

POP         LDR R0, R6, #0
            ADD R6, R6, #1
            RET
; error handlers
OVERFLOW    LD R0, PROMPT_OVER
            OUT
            AND R0, R0, #0
            ADD R0, R0, #10
            OUT
            BRnzp RESET
STACK_ERROR LD R0, PROMPT_STK
            OUT
            AND R0, R0, #0
            ADD R0, R0, #10             ; new line
            OUT
            BRnzp RESET
            
ERROR_OP    LD R0, PROMPT_ERR
            OUT
            AND R0, R0, #0
            ADD R0, R0, #10             ; new line
            OUT
            BRnzp RESET

            HALT
                .END
            
            
                        
            
            
            
            
