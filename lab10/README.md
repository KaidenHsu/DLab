# Lab 10. VGA Video Interface Circuit

In DLab Lab 10, the experiment focuses on VGA display, introducing the green screen removal technique commonly used in film and photo post-production, and implementing its corresponding hardware architecture. If a system relies on a CPU to calculate the RGB values for every pixel sequentially, it places an immense burden on the processor. Therefore, in actual SoC designs, repetitive tasks like video processing are typically offloaded to dedicated hardware accelerators. This lab required designing hardware to handle image overlay and display.
<br>
<br>
Regarding system architecture, the lab provides a VGA controller. Since its input is a high-frequency clock, a clock divider must be used to generate a suitable display clock. I furthered my understanding of how VGA signals, such as VSYNC, HSYNC, and RGB outputs, function during the scanning and display process. Additionally, the experiment introduced the concepts of retrace and cycle stealing, explaining how to access memory during the blanking intervals to avoid conflicts between image reading and display, ensuring the datapath operates smoothly within the limited bandwidth.
<br>
<br>
Adding firework special effects was another key requirement of this lab. I had to find a firework GIF online, convert it to PPM format, and use the provided script to generate 24-bit RGB data. During the design phase, I had to carefully manage the rendering order of the background, moon, and fireworks layers to ensure the correct foreground and background effects.
<br>
<br>
Given the limited BRAM resources on the ZedBoard, I adjusted the resolution and frame rate of the firework animation. This lab did not utilize an FSM; since it was necessary to retrieve pixel data from multiple layers simultaneously within a single cycle, I allocated a separate SRAM for each of the three layers to facilitate parallel data reading. Seeing the moon and fireworks successfully animated on the screen was incredibly rewarding, marking a perfect conclusion to the final lab of DLab.

<p align="center"><img src="/images/vga_fireworks.png" alt="vga vireworks" width="600" /></p>
