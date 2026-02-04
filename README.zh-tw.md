# 數位電路實驗 (DLab)

[![en](https://img.shields.io/badge/lang-english-red.svg)](README.md)

DLab 為一堂國立陽明交通大學 (NYCU) 開設，以實作為核心的數位系統設計 (digital design) 課程。每個 lab 都要求參與者獨立完成 RTL 與對應的 testbench，包括從規格理解 (specs) 、設計實作 (design) 到功能驗證 (verification)。我在課程中使用的開發板是 Digilent ZedBoard，搭載 Zynq-7000，一款結合 ARM Cortex-A9 與 FPGA 的 SoC 平台 (本實驗只使用 PL 部分)，並搭配 AMD Xilinx Vivado 進行設計與驗證。
<br>
<br>
整個學期共完成 10 個 lab，內容涵蓋 Verilog RTL 撰寫、FSM 設計、資料路徑 (datapath) 與控制邏輯 (controller) 規劃、記憶體 (SRAM) 與周邊模組整合，以及完整 testbench 的撰寫與驗證流程建立。從一開始單純的行為描述，到後來需要依照 spec 思考架構選擇、資源使用 (utilization) 與時序限制 (timing)，逐步培養將抽象需求轉換為可合成 (synthesize) 電路的能力。在驗證 (verification) 方面，除了透過模擬檢查功能正確性，我也學會在板上實測時搭配 Vivado ILA (Integrated Logic Analyzer) 觀察內部訊號，協助除錯與理解實際硬體行為。
Lab 5 uses a 1602 LCD as the output device, requiring the circuit to calculate and sequentially display prime numbers while allowing users to toggle display direction and content updates via buttons. While the LCD driver module was provided, I was primarily responsible for converting the Sieve Algorithm into a sequential circuit capable of running on an FPGA and designing the control flow to ensure calculation results were properly organized and displayed.
<br>
<br>
I learned that when rewriting an algorithm for hardware, it is essential to split a process that would normally complete all at once in software into multiple clock cycles. This ensures that the combinational logic can finish within a single cycle to avoid timing violations, using an FSM to schedule the calculation sequence and data updates. The Sieve Algorithm in hardware requires a storage structure to track whether each number is prime, working alongside a counter to gradually mark composite numbers and find the next candidate.
<br>
<br>
I also utilized a shift register design to handle the movement and updating of display data. To implement upward and downward scrolling effects on the LCD, I converted the calculated prime results into strings and stored them in a buffer. By shifting the data, I created a continuous update behavior for the display. Since FPGAs typically have more abundant registers compared to LUTs, this shift-based design effectively leverages the hardware's resource distribution characteristics.

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

[1]: lab01/README.zh-tw.md
[2]: lab02/README.zh-tw.md
[3]: lab03/README.zh-tw.md
[4]: lab04/README.zh-tw.md
[5]: lab05/README.zh-tw.md
[7]: lab07/README.zh-tw.md
[8]: lab08/README.zh-tw.md
[9]: lab09/README.zh-tw.md
[10]: lab10/README.zh-tw.md

<p align="center"><img src="images/zedboard.png" alt="Zedboard" width="480" /></p>
