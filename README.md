# 🎵 FPGA-Digital-Audio-FIR-PWM

> Digital Audio Signal Generation, Filtering, and PWM-Based Speaker Drive Using FPGA

**By Syeda Alishba Zaidi, Huzaifa Ahmed Khan & Aamaina Mukarram**

---

## 📌 Overview

This project implements a complete **digital audio processing pipeline** on a Basys-3 FPGA. It generates sine wave tones using Direct Digital Synthesis (DDS), filters them in real time through a MATLAB-designed 51-tap FIR low-pass filter implemented in Verilog, and drives an 8-ohm speaker directly using Pulse Width Modulation (PWM) — with no DAC required.

The system demonstrates a measurable, **audible difference** between passband signals (≤ 1 kHz, clearly heard) and stopband signals (≥ 4 kHz, fully attenuated and silent).

---

## 🔧 Hardware Used

| Component | Detail |
|-----------|--------|
| FPGA Board | Digilent Basys-3 (Xilinx Artix-7) |
| Speaker | 8-ohm speaker, directly driven via PWM pin |
| EDA Tool | Xilinx Vivado |
| Design Language | Verilog HDL |
| Filter Design Tool | MATLAB |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────┐
│        SIGNAL GENERATION        │
│                                 │
│  DDS Phase Accumulator          │
│       ↓                         │
│  Sine LUT (64-point)            │
│       ↓                         │
│  Frequency Selection            │
│  (via 10-bit freq_word)         │
└──────────────┬──────────────────┘
               │ 8-bit signed @ 100 kHz
┌──────────────▼──────────────────┐
│        SIGNAL PROCESSING        │
│                                 │
│  51-tap FIR Low-Pass Filter     │
│  y[n] = Σ b[k] * x[n-k]        │
│  Hamming window, 1 kHz cutoff   │
└──────────────┬──────────────────┘
               │ 16-bit filtered output
┌──────────────▼──────────────────┐
│       OUTPUT CONVERSION         │
│                                 │
│  PWM Generator @ 100 MHz        │
│  duty cycle ∝ audio amplitude   │
└──────────────┬──────────────────┘
               │ 1-bit PWM
          [ 8-ohm Speaker ]
```

---

## 📐 FIR Filter Specifications

| Parameter | Value |
|-----------|-------|
| Sampling Frequency | 100 kHz |
| Passband | 0 – 1 kHz |
| Transition Band | 1 kHz → 3 kHz |
| Stopband | > 3 kHz |
| Stopband Attenuation | ≈ −40 dB |
| Filter Order | 50 |
| Number of Taps | 51 |
| Window Function | Hamming |
| Coefficient Format | 8-bit signed |
| Output | `accumulator[23:8]` (24-bit sum, upper 16 bits taken) |

---

## 🧩 Verilog Modules

### `fir_filter.v` — 51-Tap FIR Low-Pass Filter
- **Inputs:** `Data_in` [7:0], `clk` (100 kHz), `reset`
- **Output:** `Data_out` [15:0]
- Delay line → 51 parallel multipliers → 24-bit accumulator → `Data_out = accumulator[23:8]`

### `dds.v` — Direct Digital Synthesiser
- **Inputs:** `clk`, `reset`, `freq_word` [9:0]
- **Output:** `sine_out` [7:0] (signed, −128 to +127)
- Phase accumulator increments by `freq_word` each clock; upper 6 bits index 64-point sine LUT
- `f_out = (freq_word / 1024) × f_clk`

| freq_word | Output Frequency |
|-----------|-----------------|
| 5 | 500 Hz |
| 10 | 1 kHz |
| 41 | ~4 kHz |
| 280 | ~10 kHz |

### `tone_rom.v` — ROM-Based Tone Generator
- `tone_select = 0` → 2 kHz (64-sample ROM) — **passes** FIR filter
- `tone_select = 1` → 6 kHz (16-sample ROM) — **blocked** by FIR filter

### `pwm_generator_high_res.v` — PWM Speaker Driver
- Runs at 100 MHz system clock
- `pwm_out = (pwm_counter < audio_input)` — larger input = wider pulse = louder

### `clock_divider.v`
- 100 MHz → 100 kHz (toggle every 500 cycles) for DDS and FIR
- PWM remains on full 100 MHz for high output resolution

### `square_wave_gen.v` — 1 kHz Square Wave
- 100 samples/cycle at 100 kHz; alternates ±127 every 50 samples

---

## 📊 Simulation Results

| Input Frequency | Band | Filter Output | PWM | Audible |
|----------------|------|--------------|-----|---------|
| 500 Hz | Passband | 121 | 255 (max) | ✅ Clear |
| 1 kHz | Passband | High | High | ✅ Clear |
| 4 kHz | Stopband | 0 | 0 | ❌ Silent |
| 10 kHz | Stopband | −1 | ~0 | ❌ Silent |

**Measured attenuation at 10 kHz:**
```
20 × log10(1 / 127) ≈ −42 dB   ✅ Meets −40 dB stopband spec
```

---

## 🔊 Hardware Speaker Test Results

| Test | Observation |
|------|-------------|
| 500 Hz unfiltered | Clearly audible |
| 1 kHz unfiltered | Clearly audible |
| 4 kHz unfiltered | Audible (bypassed FIR); silent through filter |
| 10 kHz unfiltered | Audible (bypassed FIR); silent through filter |
| 1 kHz square wave filtered | Higher harmonics removed; smoother tone audible |
| 2 kHz ROM tone | Passes FIR — audible |
| 6 kHz ROM tone | Blocked by FIR — silent |

---

## 📂 Repository Structure

```
FPGA-Digital-Audio-FIR-PWM/
├── src/
│   ├── fir_filter.v              # 51-tap FIR filter
│   ├── dds.v                     # DDS sine generator
│   ├── tone_rom.v                # ROM-based 2kHz/6kHz tones
│   ├── pwm_generator_high_res.v  # PWM speaker driver
│   ├── clock_divider.v           # 100MHz to 100kHz divider
│   ├── square_wave_gen.v         # 1kHz square wave generator
│   └── audio_system.v            # Top-level integration
├── matlab/
│   └── fir_design.m              # MATLAB FIR coefficient generation
├── constraints/
│   └── basys3.xdc                # Basys-3 pin constraints
├── sim/
│   └── tb_audio_system.v         # Simulation testbench
└── DSD_report.pdf                # Full design report
```

---

## ⚙️ How to Run

### Step 1 — Generate FIR Coefficients (MATLAB)
```matlab
Fs = 100e3;   Fc = 1e3;   order = 50;
b = fir1(order, Fc/(Fs/2), hamming(order+1));
b_quantized = round(b * 127);   % 8-bit signed
```

### Step 2 — Simulate in Vivado
1. Add all `.v` files from `src/` and `sim/` to a Vivado project (Basys-3 target: `xc7a35tcpg236-1`)
2. Set `tb_audio_system` as simulation top
3. Run Behavioral Simulation and verify waveforms match expected filter behaviour

### Step 3 — Deploy to FPGA
1. Add `basys3.xdc` constraints
2. Run Synthesis → Implementation → Generate Bitstream
3. Program the Basys-3 via Open Hardware Manager
4. Connect 8-ohm speaker to the PWM output pin
5. Toggle onboard switches to select `freq_word` and hear the filtering in action

---

## 🔑 Key Design Choices

| Decision | Reason |
|----------|--------|
| No DAC | Speaker's mechanical inertia acts as a natural low-pass integrator of the PWM signal |
| Dual clock domains | DDS/FIR at 100 kHz for correct sampling; PWM at 100 MHz for fine duty-cycle resolution |
| 8-bit coefficient quantization | Meets −40 dB spec while keeping FPGA LUT usage low |
| Hamming window | Good stopband attenuation with moderate transition band width |
| Linear-phase (symmetric) FIR | Zero phase distortion in the passband |
| ROM-based tones for testing | Deterministic signal source to verify filter before integrating DDS |


## 📄 License

Developed as a Digital System Design course project at Habib University. Implemented on Xilinx Basys-3 using Vivado.
