# EE 316 Computer Engineering Junior Lab Design Project 3 - Spring 2024

Welcome to the repository for Design Project 3 of the EE 316 Computer Engineering Junior Lab for Spring 2024. This project involves signal generation using sensors with I2C interface. Below you will find all the necessary information, specifications, parts list, and guidelines for the project.

## Specification
- **Signal Generation**: Design a system to sample, store, display, and recreate analog waveforms using sensors with I2C interface.
- **Due Date**:
  - Lab Demo: Thursday, February 29
  - Written Report: Tuesday, March 2
- **Parts List**:
  1. Trenz ZynqBerry board with GPIO Expansion board
  2. One function generator
  3. One 16x2 character I2C LCD display module
  4. A PCF8591 ADC-DAC module with I2C interface
  5. A couple of Op-AMPs (LM741/LM358 compatible), capacitors, resistors, etc.

## Project Description
Design a system capable of sampling, storing, displaying, and recreating analog waveforms using sensors with I2C interface. The system should include functionalities such as Op-Amp adder circuit, ADC, PWM output, clock generation, and LCD display.

## Design Specifications
- **Op-Amp Adder Circuit**: Generate periodic sinusoidal waveforms with a peak-to-peak amplitude of 3.3 Volts. Use an op-amp adder with a gain of 1/2 to add the input waveform to 3.3 volts.
- **ADC**: Connect the output of the Op-Amp Circuit to AIN2 of the PCF8591 module. Connect three sensors (Light Dependent Resistor, Thermistor, Potentiometer) to AIN0, AIN1, and AIN3 respectively.
- **PWM Output**: The duty cycle of the PWM signal will be proportional to the 8-bit value of the data. Use PMOD button (BTN1) to select between 4 inputs for PWM duty-cycle. Pass PWM output through a low-pass filter for signal reconstruction.
- **Clock Generation**: Generate a clock output with a frequency varying between 500 to 1500 Hz, controlled by Potentiometer, Thermistor, and Light Dependent Resistor. Use PMOD LEDs to indicate states. Enable/disable clock generation using BTN2.
- **LCD Display**: Connect an I2C LCD to display the selected source for PWM signal on the first line and indicate clock output status on the second line.

## Other Objectives
- Maximize the bandwidth of analog signals that can be sampled, stored, and analyzed without aliasing.
- Minimize error for the desired frequency.

## Useful Links
- [PCF8591 – 8-bit ADC and DAC converter](https://www.nxp.com/docs/en/data-sheet/PCF8591.pdf)
- [Arduino PCF8591 Digital to Analog Tutorial](https://www.learningaboutelectronics.com/Articles/PCF8591-ADC-and-DAC-Arduino-Tutorial.php)
- [Lesson 12 PCF8591 AD Converter](https://startingelectronics.org/tutorials/arduino/modules/PCF8591-adc/)

## Team Members
- Art
- Ayden Rollins
- Zak Konik
