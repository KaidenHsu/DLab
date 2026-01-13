在 DLab Lab10 中，本實驗以 VGA 顯示為主軸，介紹綠幕 (green screen) 移除這種在電影與圖片後製中常見的技巧，並實作其對應的硬體架構。若系統採用 CPU 逐一計算每個 pixel 的 RGB 值，會對處理器造成極大的負擔，因此在實際的 SoC 中，這類影像處理 (video processing) 重複性工作多半交由專門的硬體加速器來完成，本實驗便要求設計硬體達成圖片的疊合與顯示。
<br>
<br>
在系統架構上，實驗提供 VGA controller，其輸入為高頻時脈，因此需透過 clock divider 產生適合顯示用的時脈，接著我進一步理解 VSYNC、HSYNC 與 RGB 輸出等 VGA 訊號在掃描顯示中的功能。此外，實驗也介紹了 retrace 與 cycle stealing 的觀念，說明如何在畫面回掃期間存取記憶體，避免影像讀取與顯示產生衝突，讓整體資料流 (datapath) 能在有限頻寬 (bandwidth) 下順利運作。
<br>
<br>
加上煙火特效則是此次 lab 的另一個重要要求。我需要自行在網路上尋找煙火 GIF，轉換成 PPM，再以 lab 給的 script 產生 24-bit RGB 資料。設計時需注意背景、月亮與煙火三個圖層的顯示先後順序，才能呈現正確的前後景效果。考量到 ZedBoard 上 BRAM 資源有限，我對煙火動畫的解析度與影格率進行了調整。本實驗沒有設計 FSM 。因為在 1 個 cycle 內需要同時取得多個圖層的像素資料，我為三個圖層各配置了一個 SRAM ，方便平行讀取資料。最後成功看到月亮與煙火在螢幕上動起來時，我覺得非常有成就感，這也為 DLab 的最後一個 lab 畫下完美的句點。

<p align="center"><img src="/images/vga_fireworks.png" alt="vga vireworks" width="600" /></p>
