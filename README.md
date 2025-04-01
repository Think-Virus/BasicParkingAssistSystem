# 🚗 Basic Parking Assist System (FPGA-Based)

This project implements a **Basic Parking Assist System** using Verilog HDL on a Basys3 FPGA development board. It simulates real-time distance detection and feedback using a Bluetooth module, 16x2 LCD, and buzzer. Originally designed for use with an ultrasonic sensor, the project was adapted to use Bluetooth due to voltage compatibility issues with Basys3.

## 📌 Project Overview

- **Platform**: Basys3 FPGA (Xilinx)
- **Language**: Verilog HDL
- **Tools**: Vivado 2021.1+
- **Main Features**:
  - Receive distance-related signals via Bluetooth (UART)
  - Display current distance on 16x2 LCD
  - Generate buzzer sounds with pitch/frequency based on distance
  - Visualize Bluetooth data & action codes using onboard LEDs

## 📥 How It Works

### 📶 Input: Bluetooth via UART
- `31` (hex) → Vehicle moving **away** from obstacle → action = `4'b0001`
- `32` (hex) → Vehicle moving **closer** to obstacle → action = `4'b0010`

### 🧠 Processing Logic
- Distance starts at 100 and changes by ±10 depending on received action
- Action codes are generated using `action_code.v`
- Distance adjustment is handled in `BasicParkingAssistSystem.v`

### 📺 Output Devices
- **LCD**: Displays `"Now distance: "` and numerical value
- **Buzzer**: 
  - Sounds faster and higher-pitched as distance decreases
  - Thresholds at 90, 80, 50, 20 for tone change
- **LEDs**: Debug display for action code and raw UART input

## 📁 File Structure

```
Basic_Parking_Assist_System/
├── Basic_Parking_Assist_System.xpr      # Vivado project file
└── srcs/
    ├── sources_1/new/
    │   ├── BasicParkingAssistSystem.v   # Top module
    │   ├── action_code.v                # ASCII to action code logic
    │   └── async_receiver.v             # UART receiver (Bluetooth)
    ├── sim_1/new/
    │   └── tb.v                         # Testbench
    └── constrs_1/new/
        └── Basys3-Master.xdc                # Pin constraints for Basys3 board
```

## 🛠️ Build & Run Instructions

1. **Open Project in Vivado**
   - Launch Vivado (tested with 2021.1 or later)
   - Open `Basic_Parking_Assist_System.xpr`

2. **Rebuild the Design**
   - Vivado will detect that `runs/`, `cache/`, `.bit` files are missing
   - It will automatically regenerate all outputs when you run synthesis and implementation

3. **Synthesize & Implement**
   - In the Flow Navigator, click:
     - *Run Synthesis*
     - *Run Implementation*
     - *Generate Bitstream*

4. **Program the Basys3 Board**
   - Connect your Basys3 board via USB
   - Open *Hardware Manager*
   - Click *Program Device* and select the generated `.bit` file

5. **Module Behavior**
   - Send `31` or `32` (hex) via Bluetooth to simulate distance changes
   - Watch the LCD and buzzer respond in real time

## 📦 Bill of Materials (BOM)

| Component         | Description            | Cost     |
|------------------|------------------------|----------|
| 16x2 LCD          | Display distance       | $15.99   |
| Buzzer            | Audio feedback         | $0.70    |
| Bluetooth Module  | UART input             | $10.39   |
| Basys3 Board      | FPGA Dev Board         | Provided |

## 🧠 Design Rationale

Initially, an ultrasonic sensor was intended as input, but due to the Basys3 board's 3.3V voltage restriction (vs 5.5V needed for ultrasonic), a Bluetooth module was used instead to simulate distance input. This change allowed flexible control and avoided hardware damage.

## ▶ [Watch Demo](https://1drv.ms/v/c/699aeea76de52c4e/EUM5lxRYRydAhZdwl_O2P1ABxaUy7rGKC7-Kqtawqyo1Sw?e=Qi0WzA)

## 📜 License
This project is licensed under the MIT License.  
