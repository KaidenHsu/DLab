# DLab (Digital System Lab)

[![zh-tw](https://img.shields.io/badge/lang-繁體中文-blue.svg)](README.zh-tw.md)

This is an advanced course on the Introduction to Digital Systems offered by **National Yang Ming Chiao Tung University (NYCU)**. The course **balances theory with practical application**, featuring **16 design examples** across the 4th and 7th chapters. Moving beyond basic digital logic theory, the course develops professional design principles. I utilized the **AMD Xilinx Zedboard FPGA** as the implementation platform, navigating the entire FPGA design flow from writing RTL and performing simulation and debugging with ILA in Vivado to 1 hardware configuration, thereby gaining comprehensive familiarity with the FPGA development environment.
<br>
<br>
Regarding the theoretical component, the 1st chapter serves as a review of core digital systems concepts while introducing critical real-world design issues such as hazards and timing. Chapters 2 and 8 cover Verilog syntax; despite having a prior foundation, I used this opportunity to refine my coding style to ensure the synthesized hardware accurately reflects the intended logic. Chapter 3 introduces the classification and evolution of Programmable Logic Devices, tracing the path from ROM, PAL, PLA, and CPLD to the FPGA platforms used today. Chapter 5 explores design methodologies beyond standard finite state machines, including state machine charts and microprogramming, concluding with linked state machines to facilitate the design of complex system controllers. Finally, chapter 6 provides an in-depth explanation of internal FPGA architecture and fundamental EDA tool concepts, offering a concrete understanding of how hardware is physically realized.
<br>
<br>
The practical core of the course is found in chapters 4 and 7. Chapter 4 provides 12 design examples that progress from simple to complex, covering various combinational and sequential circuit design techniques. In the context of the current AI era, chapter 7 introduces the hardware design of floating-point arithmetic units for addition, subtraction, multiplication, and division, providing insight into how these numerical computations are actually implemented in hardware.
<br>
<br>
Completing this course has rounded out my understanding of digital design and laid a robust foundation for future hardware design and system development. When writing RTL, I no longer view it as mere code but can visualize the actual synthesized hardware structures. Simultaneously, I have gained a profound realization of the various digital design theories covered throughout the course.

## Labs

 Labs   | Descriptions
--------|:-----
[Lab1][1]|Sequential Binary Multiplier
[Lab2][2]|3x3 Matrix Multiplier
[Lab3][3]|Simple I/O Control Circuit
[Lab4][4]|UART I/O Circuit
[Lab5][5]|Sieve Algorithm & Standard 1602 Character LCD Display
[Lab7][7]|4x4 Pipelined Matrix Multiplier
[Lab8][8]|MD5 Password Cracking Circuit
[Lab9][9]|Correlation Filter Circuit
[Lab10][10]|VGA Video Interface Circuit

[1]: lab01/
[2]: lab02/
[3]: lab03/
[4]: lab04/
[5]: lab05/
[7]: lab07/
[8]: lab08/
[9]: lab09/
[10]: lab10/

<p align="center"><img src="images/zedboard.png" alt="Zedboard" width="480" /></p>
