# Lab 7. 4x4 Pipelined Matrix Multiplier

In lab 7, the requirement was to read pre-initialized 4x4 matrix data from SRAM, complete the calculation, and output the results in text format via UART. The grading criteria for this experiment focused primarily on synthesis area, with an explicit restriction that the design could not use more than 16 multipliers. Therefore, a sequential design was necessary to utilize less hardware and achieve a higher score.
<br>
<br>
During the design process, I paid close attention to partitioning the critical path. If a matrix operation attempts to complete multiple multiplications and additions within 1 cycle, it easily forms an excessively long combinational logic path, leading to timing violations. To avoid this, I broke the calculation flow into multiple stages, using pipeline registers to cut the critical path and keep the combinational logic depth in each cycle under control. Simultaneously, I scheduled the flow so the design could calculate the previous result while reading the next required data from SRAM, reducing unnecessary waiting and avoiding wasted cycles.
<br>
<br>
Regarding data buffer design, I adopted a strategy of buffering only 1 column. Matrix A is fully loaded and saved first, while the other matrix is read from SRAM and calculated column by column. This approach effectively reduces the requirement for registers and control logic when the number of multipliers is limited. If the design were further modified to calculate only 1 matrix element at a time, the area could be reduced even more, but the total number of required cycles would increase significantly. This once again allowed me to experience the trade-offs of PPA in digital design.

<p align="center"><img src="/images/4x4mat_mul.png" alt="4x4 matrix multiplication" width="720" /></p>
