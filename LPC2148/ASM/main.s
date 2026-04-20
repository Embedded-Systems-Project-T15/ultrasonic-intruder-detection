    AREA IntruderAlarm, CODE, READONLY
    EXPORT __main

__main
    B Reset_Handler

; --- 2. PIN DEFINITIONS ---
IOPIN0_OFF EQU 0x00
IOSET0_OFF EQU 0x04
IODIR0_OFF EQU 0x08
IOCLR0_OFF EQU 0x0C

TRIG_PIN   EQU (1<<0)   ; P0.0
ECHO_PIN   EQU (1<<1)   ; P0.1
LED_PIN    EQU (1<<2)   ; P0.2
LCD_RS     EQU (1<<10)  ; P0.10
LCD_RW     EQU (1<<11)  ; P0.11
LCD_EN     EQU (1<<12)  ; P0.12

; --- 3. SYSTEM BOOT ---
Reset_Handler
    ; Set Stack Pointer safely inside the middle of the RAM block
    LDR SP, =0x40007F00

    ; Setup Base Address
    LDR R11, =0xE0028000

    ; Configure PINSEL0
    LDR R0, =0xE002C000
    MOV R1, #0
    STR R1, [R0]

    ; Configure IODIR0 (Sensor + LCD Pins)
    LDR R1, [R11, #IODIR0_OFF]
    ORR R1, R1, #TRIG_PIN
    ORR R1, R1, #LED_PIN
    LDR R2, =0x00FF1C00       
    ORR R1, R1, R2
    BIC R1, R1, #ECHO_PIN     
    STR R1, [R11, #IODIR0_OFF]

    ; Initialize the LCD
    BL LCD_INIT

	MOV R8, #0

MAIN_LOOP
    ; --- STEP 1: TRIGGER SENSOR (Your Exact Logic) ---
    MOV R0, #TRIG_PIN
    STR R0, [R11, #IOSET0_OFF]  
    LDR R1, =500                
TRIG_DELAY
    SUBS R1, R1, #1
    BNE TRIG_DELAY
    STR R0, [R11, #IOCLR0_OFF]  

    ; --- STEP 2: WAIT FOR ECHO HIGH (Your Exact Logic) ---
    LDR R4, =0          
WAIT_HIGH
    LDR R1, [R11, #IOPIN0_OFF]
    TST R1, #ECHO_PIN
    BNE ECHO_IS_HIGH    
    ADD R4, R4, #1
    LDR R2, =10000     
    CMP R4, R2
    BGT FAILSAFE        
    B WAIT_HIGH

ECHO_IS_HIGH
    ; --- STEP 3: MEASURE ECHO WIDTH (Your Exact Logic) ---
    LDR R5, =0          
COUNT_PULSE
    LDR R1, [R11, #IOPIN0_OFF]
    TST R1, #ECHO_PIN
    BEQ CHECK_DIST      
    ADD R5, R5, #1
    LDR R2, =20000     
    CMP R5, R2
    BGT CHECK_DIST      
    B COUNT_PULSE

CHECK_DIST
    ; --- STEP 4: INTRUDER LOGIC (Your 3500 Threshold) ---
    CMP R5, #2          
    BLE SET_SAFE
    LDR R2, =3500       
    CMP R5, R2          
    BGE SET_SAFE

SET_INTRUDER
    MOV R8, #1          
    MOV R0, #LED_PIN
    STR R0, [R11, #IOSET0_OFF] 
    B UPDATE_LCD

SET_SAFE
FAILSAFE
    MOV R8, #0          
    MOV R0, #LED_PIN
    STR R0, [R11, #IOCLR0_OFF] 

UPDATE_LCD
    ; --- STEP 5: UPDATE LCD (Only on state change) ---
    CMP R8, R9
    BEQ LOOP_END        
    MOV R9, R8          

    MOV R0, #0x01       ; Clear Display
    BL LCD_CMD
    MOV R0, #0x80       ; Move to line 1
    BL LCD_CMD

    CMP R8, #1
    BEQ PRINT_INTRUDER
PRINT_SAFE
    LDR R0, =MSG_SAFE
    BL LCD_PRINT_STR
    B LOOP_END
PRINT_INTRUDER
    LDR R0, =MSG_INTR
    BL LCD_PRINT_STR

LOOP_END
    LDR R6, =20000
MAIN_DELAY
    SUBS R6, R6, #1
    BNE MAIN_DELAY
    B MAIN_LOOP

; =======================================
; --- LCD SUBROUTINES ---
; =======================================

LCD_CMD
    PUSH {LR}
    LDR R1, =0x00FF0000
    STR R1, [R11, #IOCLR0_OFF] 
    LSL R2, R0, #16
    STR R2, [R11, #IOSET0_OFF] 
    
    MOV R1, #(LCD_RS :OR: LCD_RW)
    STR R1, [R11, #IOCLR0_OFF] 
    
    MOV R1, #LCD_EN
    STR R1, [R11, #IOSET0_OFF] 
    BL DELAY_SHORT
    STR R1, [R11, #IOCLR0_OFF] 
    
    BL DELAY_LONG              
    POP {PC}

LCD_DATA
    PUSH {LR}
    LDR R1, =0x00FF0000
    STR R1, [R11, #IOCLR0_OFF] 
    LSL R2, R0, #16
    STR R2, [R11, #IOSET0_OFF] 
    
    MOV R1, #LCD_RS
    STR R1, [R11, #IOSET0_OFF] 
    MOV R1, #LCD_RW
    STR R1, [R11, #IOCLR0_OFF] 
    
    MOV R1, #LCD_EN
    STR R1, [R11, #IOSET0_OFF] 
    BL DELAY_SHORT
    STR R1, [R11, #IOCLR0_OFF] 
    
    BL DELAY_LONG
    POP {PC}

LCD_INIT
    PUSH {LR}
    BL DELAY_LONG       
    MOV R0, #0x38       
    BL LCD_CMD
    MOV R0, #0x0C       
    BL LCD_CMD
    MOV R0, #0x01       
    BL LCD_CMD
    MOV R0, #0x06       
    BL LCD_CMD
    POP {PC}

LCD_PRINT_STR
    PUSH {R4, LR}
    MOV R4, R0          
PRINT_LOOP
    LDRB R0, [R4], #1   
    CMP R0, #0          
    BEQ PRINT_DONE
    BL LCD_DATA
    B PRINT_LOOP
PRINT_DONE
    POP {R4, PC}

; =======================================
; --- DELAY SUBROUTINES ---
; =======================================
DELAY_SHORT
    LDR R7, =200        
DS_LOOP
    SUBS R7, R7, #1
    BNE DS_LOOP
    BX LR

DELAY_LONG
    LDR R7, =10000     
DL_LOOP
    SUBS R7, R7, #1
    BNE DL_LOOP
    BX LR

; =======================================
; --- DATA POOL ---
; =======================================
    AREA Strings, DATA, READONLY
MSG_SAFE DCB "STATUS: SAFE", 0
MSG_INTR DCB "INTRUDER ALERT!", 0
    ALIGN

    END