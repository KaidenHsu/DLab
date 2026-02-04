# 數位電路實驗 (DLab)

[![en](https://img.shields.io/badge/lang-english-red.svg)](README.md)

DLab 為一堂國立陽明交通大學 (NYCU) 開設，以實作為核心的數位系統設計 (digital design) 課程。每個 lab 都要求參與者獨立完成 RTL 與對應的 testbench，包括從規格理解 (specs) 、設計實作 (design) 到功能驗證 (verification)。我在課程中使用的開發板是 Digilent ZedBoard，搭載 Zynq-7000，一款結合 ARM Cortex-A9 與 FPGA 的 SoC 平台 (本實驗只使用 PL 部分)，並搭配 AMD Xilinx Vivado 進行設計與驗證。
<br>
<br>
整個學期共完成 10 個 lab，內容涵蓋 Verilog RTL 撰寫、FSM 設計、資料路徑 (datapath) 與控制邏輯 (controller) 規劃、記憶體 (SRAM) 與周邊模組整合，以及完整 testbench 的撰寫與驗證流程建立。從一開始單純的行為描述，到後來需要依照 spec 思考架構選擇、資源使用 (utilization) 與時序限制 (timing)，逐步培養將抽象需求轉換為可合成 (synthesize) 電路的能力。在驗證 (verification) 方面，除了透過模擬檢查功能正確性，我也學會在板上實測時搭配 Vivado ILA (Integrated Logic Analyzer) 觀察內部訊號，協助除錯與理解實際硬體行為。
<br>
<br>
經過 DLab 的訓練，我在數位設計上的能力有明顯成長，能依據題目規格思考整體架構，並針對效能、功耗與面積 (PPA) 進行取捨與優化。實際將設計下載到 FPGA 上運作，也讓我體會到模擬與真實電路之間仍會受到電性與物理因素影響，能親眼看到電路在硬體上實際成功運作給我帶來很大的成就感。這堂課讓我在 RTL coding 與 testbench 撰寫能力上都有顯著進步，並對 FPGA 上完整的數位系統設計與驗證流程建立了更紮實的理解。

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
