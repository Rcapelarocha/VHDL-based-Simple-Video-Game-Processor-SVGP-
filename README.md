# Simple Video Game Processor (SVGP) — COE758 Project 2

This repository contains the full VHDL implementation of a **Simple Video Game Processor (SVGP)** designed to run on the **Xilinx Spartan-3E FPGA**.  
The system generates **real-time VGA output** and implements a hardware-based Pong-style game with user-controlled paddles, a moving ball, collision logic, and goal detection.

This project was developed for **COE758 – Digital Systems Engineering** (Fall 2025) at **Toronto Metropolitan University**.

---

## 📺 Project Overview

The SVGP outputs a 640×480 @ 60 Hz VGA signal, rendering:

- A green playfield
- White borders and goal zones
- A center dashed line
- Two player-controlled paddles
- A moving ball that reacts to collisions and goals

All graphics, logic, and motion are computed entirely in hardware using VHDL, leveraging:
- VGA timing generation  
- Pixel-level rendering  
- Real-time game physics  
- On-board switch inputs  

---

## 📌 Features

### **VGA Core**
- 640×480 @ 60 Hz output  
- Pixel clock: 25 MHz (divided from 50 MHz onboard clock)  
- Horizontal timing: 800 cycles / 640 visible  
- Vertical timing: 525 lines / 480 visible  
- Generates `HSYNC`, `VSYNC`, `x`, `y`, and `video_on`

### **Game Engine**
- Paddle control via board switches:
  - SW0(HIGH): Left paddle up  
  - SW0(LOW): Left paddle down  
  - SW2(HIGH): Right paddle up  
  - SW2(LOW): Right paddle down  
- Ball movement with speed and vector control  
- Collision detection:
  - Top and bottom boundaries  
  - Left and right paddles  
  - Left and right gate openings  
- Goal detection:
  - Ball turns red momentarily  
  - Auto-reset to screen center  

### **Renderer**
- Draws all static and dynamic objects based on `(x, y)` pixel position  
- Implements:
  - Green background  
  - White top/bottom borders  
  - Side walls with gate openings  
  - Center dashed dividing line  
  - Colored paddles (blue & magenta)  
  - Yellow ball (red on scoring)  

### **ChipScope / Debugging**
- Integrated ILA/ICON cores  
- Captures:
  - Pixel coordinates  
  - Sync pulses  
  - Color data  

---

## 🧩 System Architecture

The SVGP consists of three main subsystems:

