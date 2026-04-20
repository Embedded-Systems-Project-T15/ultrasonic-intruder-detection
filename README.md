# Real-Time Ultrasonic Intrusion Detection System

An embedded systems project that detects intrusions using ultrasonic sensing and provides real-time alerts via LCD and LED indicators.

The system is implemented using:
- 8051 microcontroller (Assembly)
- ARM7 LPC2148 microcontroller (Embedded C and Assembly)

---

## Overview

This project implements a real-time intrusion detection system using an ultrasonic sensor. The system continuously monitors its environment and detects objects within a predefined threshold range.

It is based on the principle of acoustic reflection, where the time taken for an emitted ultrasonic wave to return as an echo is measured and evaluated.

---

## Features

- Real-time intrusion detection
- Low-level hardware interfacing using GPIO
- Threshold-based decision logic
- LCD-based status display ("SAFE" / "INTRUDER")
- LED alert mechanism (LPC2148 implementation)
- State-based LCD updates to reduce redundant operations

---

## System Architecture

### LPC2148-Based System

Components:
- LPC2148 (ARM7) Microcontroller
- HC-SR04 Ultrasonic Sensor
- 16×2 LCD Display
- LED Indicator

### 8051-Based System

Components:
- AT89C51 Microcontroller
- HC-SR04 Ultrasonic Sensor
- 16×2 LCD Display

---

## Working Principle

1. The microcontroller sends a trigger pulse to the ultrasonic sensor.
2. The sensor emits ultrasonic waves into the environment.
3. Reflected waves return as an echo signal.
4. The duration of the echo pulse is measured using software-based timing.
5. The measured value is compared against a predefined threshold.

Decision Logic:
- If the measured value is within the threshold range → Intruder detected
- Otherwise → Safe condition

---

## Pin Configuration

### LPC2148

- Trigger: P0.0  
- Echo: P0.1  
- LED: P0.2  
- LCD Data: P0.16 – P0.23  
- LCD Control: P0.10 – P0.12  

### 8051

- Trigger: P3.1  
- Echo: P3.2  
- LCD Data: Port 2  
- LCD Control:
  - RS: P1.0  
  - RW: P1.1  
  - EN: P1.2  

---

## Implementation Details

### 8051 Implementation

- Language: Assembly
- Echo pulse measured using register-based counting
- Fixed threshold value: 150
- Continuous monitoring loop

### LPC2148 Implementation

- Language: Embedded C and ARM Assembly
- Pulse duration measured using loop-based counting
- Threshold range: 2 < count < 3500
- Includes:
  - Timeout handling for missing echo
  - LED alert for intrusion
  - State-change-based LCD updates

---

## Results

- The system successfully performs real-time intrusion detection.
- The LPC2148 implementation provides:
  - Faster processing
  - Improved accuracy
  - More stable detection compared to 8051

---

## Comparison

| Feature | 8051 | LPC2148 |
|--------|------|--------|
| Architecture | 8-bit | 32-bit ARM7 |
| Processing Speed | Moderate | High |
| Threshold Type | Fixed | Range-based |
| LCD Update Strategy | Continuous | On state change |

---

## Technologies Used

- Embedded C
- ARM Assembly
- 8051 Assembly
- Proteus (Simulation)
- Keil uVision

---

## Repository Structure
```
8051/ # Source codes for 8051
LPC2148/ # Source codes for LPC2148
```

---

## Future Improvements

- Interrupt-based echo capture instead of polling
- Conversion of pulse duration to actual distance (in cm)
- Wireless alert system (IoT / GSM integration)
- Multi-sensor configuration for wider coverage

---

## Authors

- M.V Raghupathi Sai ([@M-V-RAGHUPATHI-SAI](https://github.com/M-V-RAGHUPATHI-SAI))
- Inchara M P
- Mohammed Sabeeh ([@sabbyX](https://github.com/sabbyX))
- Tippanawar Yash Shital
- Aryan Raju Pasalwad
- Abin V Tomy
- Karthik P

---

## Academic Context

This project was developed as part of the Embedded Systems Design course at the Indian Institute of Information Technology Kottayam.
