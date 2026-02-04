# Lab 5. Sieve Algorithm & Standard 1602 Character LCD Display

Lab 5 uses a 1602 LCD as the output device, requiring the circuit to calculate and sequentially display prime numbers while allowing users to toggle display direction and content updates via buttons. While the LCD driver module was provided, I was primarily responsible for converting the Sieve Algorithm into a sequential circuit capable of running on an FPGA and designing the control flow to ensure calculation results were properly organized and displayed.
<br>
<br>
I learned that when rewriting an algorithm for hardware, it is essential to split a process that would normally complete all at once in software into multiple clock cycles. This ensures that the combinational logic can finish within a single cycle to avoid timing violations, using an FSM to schedule the calculation sequence and data updates. The Sieve Algorithm in hardware requires a storage structure to track whether each number is prime, working alongside a counter to gradually mark composite numbers and find the next candidate.
<br>
<br>
I also utilized a shift register design to handle the movement and updating of display data. To implement upward and downward scrolling effects on the LCD, I converted the calculated prime results into strings and stored them in a buffer. By shifting the data, I created a continuous update behavior for the display. Since FPGAs typically have more abundant registers compared to LUTs, this shift-based design effectively leverages the hardware's resource distribution characteristics.
