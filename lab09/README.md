# Lab 9. Correlation Filter Circuit

In Lab 9, I implemented a correlation filter circuit designed to identify the position in a signal that most closely matches a given sample, displaying the results on the LCD. This project involved reading data from memory, performing correlation calculations, and comparing results to record the maximum value. This experience provided practical insight into converting Digital Signal Processing (DSP) algorithms into sequential circuits capable of running on an FPGA.
<br>
<br>
The core of a correlation filter uses a dot product to calculate the similarity between two signal segments; thus, the same operational architecture can be applied to both cross-correlation and auto-correlation. In my design, I used a shift register to gradually push the input signal forward, creating a fixed-length sliding window that allows a correlation calculation to be performed on the current window every clock cycle.
<br>
<br>
Initially, I designed the combinational logic to complete the entire correlation in a single cycle. However, the massive volume of multiplications and additions caused severe timing violations, preventing the hardware from functioning correctly. To resolve this, I added multiple pipeline registers to the critical path, breaking the correlation operation into 64 cycles, which successfully met the timing requirements.
<br>
<br>
Furthermore, I used SRAM to store the raw signal data and utilized the $readmemh task to load test samples during FPGA configuration, ensuring that the circuit used the same data source for both simulation and hardware implementation. In Vivado, this SRAM is synthesized into BRAM (Block RAM), which gave me a clearer understanding of how to effectively leverage built-in FPGA memory resources to support sequential signal processing workflows.

<p align="center"><img src="/images/correlation_filter.jpg" alt="correlation filter" width="480" /></p>
