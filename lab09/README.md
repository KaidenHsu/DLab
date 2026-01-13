# Lab 9. Correlation Filter Circuit

在 lab9 中，本實驗實作一個 correlation filter 電路，用來在一段訊號中找出與樣板最相似的位置，並將結果顯示在 LCD 上。整體流程包含從記憶體讀取資料、進行相關 (correlation) 運算，以及比較並記錄最大值，讓我實際體會到如何將數位訊號處理 (DSP) 演算法轉換為可在 FPGA 上執行的循序電路。
<br>
<br>
Correlation filter 的核心是利用 dot product 來計算兩段訊號之間的相似度，因此同一套運算架構即可用於 cross correlation 與 auto correlation。在設計上，我將輸入訊號以 shift register 的方式逐步推入，形成固定長度的滑動視窗，讓每個 clock 都能對目前視窗進行一次相關計算。最初設計時，我設計組合邏輯在單個 cycle 內將 correlation 算完，但大量的乘加運算導致嚴重的 timing violation，導致上板時跑不出正確行為。因此我將此 critical path 加上了許多 pipeline register，將 correlation 運算切成 64 個 cycle，才解決了這個問題。
<br>
<br>
此外，我使用 SRAM 來儲存原始訊號資料，並透過 $readmemh 在 FPGA 配置 (configuration) 時載入測試樣本 (test samples)，使電路在模擬與實作時都能直接使用相同資料來源。SRAM 在 Vivado 中會被合成 (synthesize) 為 BRAM (Block RAM)，讓我更清楚了解如何善用 FPGA 內建記憶體資源來支援循序式的訊號處理流程。

<p align="center"><img src="/images/correlation_filter.jpg" alt="correlation filter" width="480" /></p>
