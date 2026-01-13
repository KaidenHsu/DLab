# Lab 7. 4x4 Pipelined Matrix Multiplier

在 DLab Lab7 中，題目要求是從 SRAM 讀出初始化好的 4×4 矩陣資料完成運算，並透過 UART 以文字格式輸出結果。本實驗的評分條件以合成面積為主，且明確限制設計中不能使用超過 16 個乘法器，因此循序的設計能使用更少硬體，獲得更高的評分。
<br>
<br>
我在設計時特別注意 critical path 的切割。矩陣運算若嘗試在 1 個 cycle 內完成多個乘法與加法，容易形成過長的組合邏輯路徑，進而造成 timing violation。為了避免這個問題，我將運算流程拆成多個階段，透過暫存器 (pipeline registers) 切割 critical path，使每個 cycle 內的組合邏輯深度受到控制。同時，在流程安排上，我的設計能一邊計算前一筆結果，一邊從 SRAM 讀取下一筆所需資料，減少不必要的等待，避免 cycle 的浪費。
<br>
<br>
在資料緩衝 (buffer) 的設計上，我採用只 buffer 一個 column 的策略：A 矩陣先完整載入後保存，另一個矩陣則以 column 為單位從 SRAM 依序讀取並計算。這樣的作法在乘法器數量受限的情況下，能有效降低暫存器與控制邏輯的需求。若進一步改成一次只計算一個矩陣元素（element），面積還可以再下降，但相對地會使整體所需的 cycle 數明顯上升，這也再次讓我體驗到了數位設計中 PPA 的取捨。

<p align="center"><img src="/images/4x4mat_mul.png" alt="4x4 matrix multiplication" width="720" /></p>
