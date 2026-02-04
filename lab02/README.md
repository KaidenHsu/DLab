# Lab 2. 3x3 Matrix Multiplier

In Lab 2, I learned how to implement a 3x3 matrix multiplication as a sequential circuit controlled by a counter. The design first loads matrices A and B into internal registers, then utilizes states to sequentially complete the computation of 3 columns across 3 cycles, writing the results into the output matrix step by step. My design employed 9 multipliers with a total computation time of 3 cycles.
<br>
<br>
Additionally, I learned the methodology and advantages of using shift registers to design a datapath. By using shift registers, input matrix data can be automatically shifted every cycle, allowing the required operands to be fed into the arithmetic units in sequence without relying heavily on multiplexers (MUX) for selection. This type of design effectively saves logic resources and area on an FPGA, though it requires more cycles to complete the overall matrix calculation. This gave me a firsthand understanding of the trade-off between area and performance (PPA) in hardware design.

<p align="center"><img src="/images/3x3mat_mul.png" alt="3x3 mat mul" width="720" /></p>
