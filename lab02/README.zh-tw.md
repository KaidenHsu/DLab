# Lab 2. 3x3 Matrix Multiplier

在 lab2 中，我學到如何將 3×3 矩陣乘法運算實作成一個以 counter 控制的循序電路。設計中先將 A 與 B 矩陣載入內部暫存器，接著利用 state 在 3 個 cycle 內依序完成三個 column 的計算，並將結果逐步寫入輸出矩陣。我的設計使用了 9 個乘法器與 3 個 cycle 的計算時長。
<br>
<br>
另外，我也學到使用 shift register 來設計 datapath 的方式與其優點。透過 shift register，輸入矩陣的資料可以在每個 cycle 自動位移，讓所需的 operands 依序被送入運算單元，而不必大量依賴 mux 進行選擇。這種設計在 FPGA 上能有效節省邏輯資源與面積，但相對也需要更多的 cycle 才能完成整體矩陣計算。這讓我親身體會到了到硬體設計中面積 (area) 與運算時間 (performance) 之間的取捨 (PPA)。

<p align="center"><img src="/images/3x3mat_mul.png" alt="3x3 mat mul" width="720" /></p>
