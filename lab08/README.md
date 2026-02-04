# Lab 8. MD5 Password Cracking Circuit

Lab 8 involves cracking MD5 hashing. Given a known input range, the goal is to use software-hardware co-design to implement a password search process as a decoding circuit on the FPGA, displaying the cracked results and elapsed time on the LCD. The example C program provided the MD5 calculation flow and test hash values, serving as a golden reference for verifying hardware correctness.
<br>
<br>
In optimizing the software-hardware co-design, I leveraged the characteristic that inputs are fixed 8-digit numbers with a consistent message format to simplify the hardware pre-processing. The padding and message composition, which require general-purpose handling in software, were reduced to generating only the necessary data in hardware, with the rest treated as constants or zeros. This reduced the complexity of the datapath and control logic. Additionally, since the passwords consist only of numeric characters, I performed the binary-to-decimal string conversion directly in hardware to avoid unnecessary general string processing, making the design easier to meet timing and resource constraints.
<br>
<br>
I specifically addressed the difference in endianness between C code and Verilog. While software often interprets 32-bit words using little-endian memory arrangement, hardware bit-slicing and concatenation can lead to inconsistencies. Therefore, I explicitly performed byte-level reordering in hardware to ensure the hash results aligned perfectly with the golden values from the C environment. To ensure the combinational logic could complete within one cycle and avoid timing violations, I broke the main MD5 loop operations into multiple clock cycles, keeping the critical path of each stage within an acceptable range.
<br>
<br>
Furthermore, I designed an rkRAM to centrally manage the rotation amounts (r table) and constants (k table) required for each round. By outputting parameters for the current round in a sequential, rotating manner, multiple computation cores could synchronize their settings without duplicating constant tables. Regarding performance, I used 10 parallel MD5 modules to scan segments of the search space simultaneously, trading throughput for a reduction in total cracking time. Once any MD5 module finds a result, all other operations are halted to avoid wasting resources.

<p align="center"><img src="/images/MD5_cracker.jpg" alt="MD5_cracker" width="480" /></p>
