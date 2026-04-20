#include <lpc214x.h>

// --- LCD Control Pin Macros ---
#define RS (1<<10) // P0.10
#define RW (1<<11) // P0.11
#define EN (1<<12) // P0.12

// YOUR EXACT WORKING DELAY
void delay(unsigned int loops) {
    volatile unsigned int i, j;
    for(i = 0; i < loops; i++) {
        for(j = 0; j < 2000; j++); 
    }
}

// --- LCD FUNCTIONS ---
void lcd_cmd(unsigned char cmd) {
    IOCLR0 = 0x00FF0000;                 // Clear D0-D7 (P0.16 to P0.23)
    IOSET0 = ((unsigned int)cmd << 16);  // Shift 8-bit command
    IOCLR0 = RS;                         // RS = 0 for Command
    IOCLR0 = RW;                         // RW = 0 for Write
    IOSET0 = EN;                         // EN = 1
    delay(1);                            // Short pulse
    IOCLR0 = EN;                         // EN = 0 to latch
    delay(2);                            // Wait for LCD to process
}

void lcd_data(unsigned char data) {
    IOCLR0 = 0x00FF0000;                 // Clear D0-D7
    IOSET0 = ((unsigned int)data << 16); // Shift 8-bit data
    IOSET0 = RS;                         // RS = 1 for Data
    IOCLR0 = RW;                         // RW = 0 for Write
    IOSET0 = EN;                         // EN = 1
    delay(1);
    IOCLR0 = EN;                         // EN = 0 to latch
    delay(2);
}

void lcd_init(void) {
    IODIR0 |= 0x00FF1C00; // Set LCD pins as Output (P0.10-12, P0.16-23)
    delay(20);            // Power-up delay

    lcd_cmd(0x38);        // 8-bit mode, 2 lines
    lcd_cmd(0x0C);        // Display ON, Cursor OFF
    lcd_cmd(0x01);        // Clear display
    delay(5);
    lcd_cmd(0x06);        // Auto-increment cursor
}

void lcd_print(char *str) {
    while(*str != '\0') {
        lcd_data(*str);
        str++;
    }
}

int main() {
    unsigned int distance_counter;
    unsigned int timeout;
    
    int current_state = 0; // 0 = Safe, 1 = Intruder
    int last_state = -1;   // Force initial LCD print

    // Pin Setup (YOUR EXACT SETUP)
    PINSEL0 = 0x00000000;
    IODIR0 |= (1<<0);   // P0.0 = Trigger (OUT)
    IODIR0 &= ~(1<<1);  // P0.1 = Echo (IN)
    IODIR0 |= (1<<2);   // P0.2 = Alarm LED (OUT)

    // Ensure LED is OFF to start
    IOCLR0 = (1<<2);

    // Initialize the Screen
    lcd_init();

    while(1) {
        // 1. Send Trigger Pulse (YOUR EXACT LOGIC)
        IOSET0 = (1<<0);
        delay(1);       
        IOCLR0 = (1<<0);

        // 2. Wait for Echo to go HIGH (YOUR EXACT LOGIC)
        timeout = 0;
        while(!(IOPIN0 & (1<<1))) {
            timeout++;
            if(timeout > 50000) break; 
        }

        // 3. Measure how long Echo stays HIGH (YOUR EXACT LOGIC)
        if(timeout <= 50000) {
            distance_counter = 0;
            while(IOPIN0 & (1<<1)) {
                distance_counter++;
                if(distance_counter > 50000) break;
            }

            // 4. Check Threshold (YOUR EXACT LOGIC)
            if(distance_counter > 2 && distance_counter < 3300) {
                current_state = 1;
                IOSET0 = (1<<2);  // ALARM ON
            } else {
                current_state = 0;
                IOCLR0 = (1<<2);  // ALARM OFF
            }
        } else {
            current_state = 0;
            IOCLR0 = (1<<2);
        }

        // 5. UPDATE LCD (ONLY ON CHANGE)
        if(current_state != last_state) {
            lcd_cmd(0x01); // Clear Screen
            delay(5);      // Give it time to clear
            lcd_cmd(0x80); // Move cursor to start
            
            if(current_state == 1) {
                lcd_print("INTRUDER ALERT!");
            } else {
                lcd_print("STATUS: SAFE");
            }
            
            last_state = current_state; 
        }
        
        delay(10); // Short pause before next ping
    }
}
