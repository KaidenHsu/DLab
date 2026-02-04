# Lab 5. Sieve Algorithm & Standard 1602 Character LCD Display

Lab5 以 1602 LCD 為輸出，要求電路計算並依序展示質數序列，並能透過按鍵切換顯示方向與內容更新。LCD 驅動模組由 lab 提供，而我主要負責將 Sieve Algorithm 轉成可在 FPGA 上運作的循序電路，並設計控制流程讓計算結果能穩定地被整理與顯示。
<br>
<br>
我學到將演算法改寫成硬體時，為了確保組合邏輯能在一個 cycle 內完成、避免 timing violation，需要把原本在軟體中一次完成的流程拆成多個 clock 週期逐步執行，並透過 FSM 來安排計算順序與資料更新。Sieve Algorithm 在硬體中必須使用暫存結構記錄每個數是否為質數，並配合計數器逐步標記合數與尋找下一個候選值，使整個運算流程能依序完成。
<br>
<br>
我也用到 shift register 的設計來處理顯示資料的移動與更新。為了在 LCD 上實作往上與往下的瀏覽效果，我將計算出的質數結果轉成字串後存入緩衝區，並透過位移的方式讓資料循序移動，形成連續更新的顯示行為。對於 register 相對 LUT 充裕的 FPGA 來說，這種以位移為主的設計能有效利用硬體資源配置的特性。
DLab 為一堂國立陽明交通大學 (NYCU) 開設，以實作為核心的數位系統設計 (digital design) 課程。每個 lab 都要求參與者獨立完成 RTL 與對應的 testbench，包括從規格理解 (specs) 、設計實作 (design) 到功能驗證 (verification)。我在課程中使用的開發板是 Digilent ZedBoard，搭載 Zynq-7000，一款結合 ARM Cortex-A9 與 FPGA 的 SoC 平台 (本實驗只使用 PL 部分)，並搭配 AMD Xilinx Vivado 進行設計與驗證。
<br>
<br>
整個學期共完成 10 個 lab，內容涵蓋 Verilog RTL 撰寫、FSM 設計、資料路徑 (datapath) 與控制邏輯 (controller) 規劃、記憶體 (SRAM) 與周邊模組整合，以及完整 testbench 的撰寫與驗證流程建立。從一開始單純的行為描述，到後來需要依照 spec 思考架構選擇、資源使用 (utilization) 與時序限制 (timing)，逐步培養將抽象需求轉換為可合成 (synthesize) 電路的能力。在驗證 (verification) 方面，除了透過模擬檢查功能正確性，我也學會在板上實測時搭配 Vivado ILA (Integrated Logic Analyzer) 觀察內部訊號，協助除錯與理解實際硬體行為。