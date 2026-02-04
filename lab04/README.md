# Lab 4. UART I/O Circuit

Lab 4 focuses on communicating with a computer terminal via UART, allowing a user to input two decimal numbers for the circuit to calculate and return their Greatest Common Divisor (GCD). While the UART module was provided, my primary responsibility was rewriting the original recursive GCD function into a sequential circuit capable of running on hardware, as well as designing and integrating the overall control flow.
<br>
<br>
Through this experience, I learned that when translating software algorithms into hardware, one must rethink control flow and data update methods. Recursion cannot be directly mapped to hardware, so I modified the GCD logic to store intermediate values in registers that update every clock cycle. I implemented a Finite State Machine (FSM) to manage the timing for receiving inputs, starting computations, and outputting results. Additionally, I used the UART module to enable user interaction with the FPGA through a virtual COM port on a PC.
<br>
<br>
Furthermore, I practiced verification and debugging methodologies. I wrote a testbench using basic SystemVerilog to simulate input characters and Enter key behavior, ensuring that string-to-integer conversion, numerical operations, and output formatting met expectations. During on-board testing, I utilized Vivado Integrated Logic Analyzer (ILA) to observe critical registers and state transitions, which allowed me to quickly pinpoint the source of issues. This lab familiarized me with the debugging workflow of first narrowing down problems via simulation and then verifying actual hardware behavior with ILA.

<p align="center"><img src="/images/gcd.png" alt="gcd calculation" width="720" /></p>
