Lab4 以 UART 通訊與電腦終端 (terminal) 溝通，讓使用者輸入兩個十進位數字，電路計算並回傳它們的 GCD (最大公因數) 結果。UART 模組由lab 提供，而我主要負責將原本的 GCD 遞迴函式改寫成可在硬體上執行的循序電路，並完成整體控制流程的設計與整合。
<br>
<br>
透過這次經驗，我學到把軟體演算法轉成硬體時，需要重新思考控制流程與資料更新的方式。遞迴在硬體中不能直接照搬，所以我將 GCD 改成用暫存器保存中間值、每個 clock 週期更新一次的做法，並用 FSM 來決定何時接收輸入、何時開始運算、以及何時輸出結果。再使用UART 模組讓使用者能透過 PC 提供的虛擬 COM port 與 FPGA 進行互動。
<br>
<br>
另外，我也練習了驗證與除錯的方法。我用基礎的 SystemVerilog 撰寫 testbench 來模擬輸入字元與 Enter 的行為，確認字串轉數字、數字運算、以及輸出格式都符合預期。另外，在 FPGA 板上測試時，我使用 Vivado 的 ILA (Integrated Logic Analyzer) 觀察關鍵暫存器與狀態變化，快速找出問題的起源。透過這個 lab 的經驗，我更熟悉「先用模擬縮小問題範圍，再用 ILA 驗證硬體實際行為」的除錯流程。
<p align="center"><img src="/images/gcd.jpg" alt="gcd calculation" width="720" /></p>
