# Three-Level Neutral-Point Clamped (NPC) Multilevel Inverter - Design Documentation

## Overview

This document provides detailed information about the Three-Level Neutral-Point Clamped (NPC) Multilevel Inverter Simulink design.

## NPC Inverter Topology

### What is an NPC Inverter?

The Neutral-Point Clamped (NPC) inverter is a multilevel power converter topology that can generate three voltage levels at the output:
- **+Vdc/2** (positive DC bus voltage)
- **0** (neutral point)
- **-Vdc/2** (negative DC bus voltage)

This topology offers several advantages over conventional two-level inverters:
- Reduced voltage stress on switching devices (each switch handles Vdc/2 instead of Vdc)
- Lower harmonic distortion in output voltage
- Reduced dv/dt stress on motor windings (if used for motor drives)
- Better output voltage waveform quality

### Circuit Configuration (Per Phase)

Each phase leg of a three-level NPC inverter consists of:

```
        +Vdc/2
          |
         S1  (Upper outer switch)
          |
    D1 ---|--- D2  (Clamping diodes)
          |
         S2  (Upper inner switch)
          |--------- Output (Phase A, B, or C)
         S3  (Lower inner switch)
          |
    D3 ---|--- D4  (Clamping diodes)
          |
         S4  (Lower outer switch)
          |
        -Vdc/2
```

**Key Components:**
- **4 Power Switches (S1-S4):** Typically IGBTs with anti-parallel diodes
- **4 Clamping Diodes (D1-D4):** Connect the neutral point to the switching nodes
- **2 DC Bus Capacitors:** Split the DC voltage to create the neutral point

### Switching States

For a single phase leg, there are three valid switching states:

| State | S1 | S2 | S3 | S4 | Output Voltage |
|-------|----|----|----|----|----------------|
| P     | ON | ON | OFF| OFF| +Vdc/2        |
| O     | OFF| ON | ON | OFF| 0 (Neutral)   |
| N     | OFF| OFF| ON | ON | -Vdc/2        |

**Switching Rules:**
- S1 and S2 cannot be OFF while S3 and S4 are ON (and vice versa) - only valid transitions
- S1 and S4 are always in opposite states
- S2 and S3 are always in opposite states

## PWM Control Strategies

### 1. Carrier-Based PWM (Level-Shifted or Phase-Shifted)

**Level-Shifted PWM:**
- Uses two carrier signals (triangular waves) at different voltage levels
- The reference sine wave is compared with both carriers
- Most common approach for NPC inverters

**Implementation:**
- Carrier 1: High-level carrier (0 to 1)
- Carrier 2: Low-level carrier (-1 to 0)
- Reference: Sinusoidal modulating signal

### 2. Space Vector PWM (SVPWM)

- More complex but offers better DC bus utilization
- Reduces harmonic distortion
- Provides optimal switching patterns

## Design Parameters

### Electrical Parameters

| Parameter | Symbol | Typical Value | Description |
|-----------|--------|---------------|-------------|
| DC Bus Voltage | Vdc | 600 V | Total DC link voltage |
| Switching Frequency | fs | 5 kHz | IGBT switching frequency |
| Output Frequency | f0 | 50/60 Hz | Fundamental output frequency |
| Modulation Index | ma | 0.8 | Ratio of reference to carrier amplitude |

### Component Ratings

**Power Switches (IGBTs):**
- Voltage Rating: ≥ Vdc/2 × 1.5 (safety margin)
- Current Rating: Based on load current × 1.5

**Clamping Diodes:**
- Voltage Rating: ≥ Vdc/2 × 1.5
- Current Rating: Based on load current

**DC Bus Capacitors:**
- Voltage Rating: ≥ Vdc/2 × 1.2
- Capacitance: Large enough to maintain stable DC voltage

## Simulink Model Structure

### Main Blocks Required

1. **Power Circuit:**
   - DC Voltage Source (or two series capacitors)
   - IGBT/Diode blocks for switches S1-S4 (per phase)
   - Clamping Diodes D1-D4 (per phase)
   - Three-phase RL load or motor

2. **Control System:**
   - Reference signal generator (sine wave)
   - Carrier signal generator (triangular waves)
   - Comparators for PWM generation
   - Gate driver signals

3. **Measurement and Display:**
   - Voltage measurements (DC bus, phase voltages, line voltages)
   - Current measurements (load currents)
   - Scopes for waveform visualization
   - THD analysis blocks (optional)

### Signal Flow

```
Reference Signal (50 Hz sine) ──┐
                                 ├──> Comparators ──> Gate Signals ──> IGBTs
Carrier Signals (5 kHz tri) ────┘
```

## Expected Output Characteristics

### Voltage Waveform

The output voltage will show a three-level stepped waveform:
- Levels: +Vdc/2, 0, -Vdc/2
- Fundamental frequency: 50 Hz (or specified f0)
- The stepped waveform approximates a sine wave

### Harmonic Analysis

- **THD (Total Harmonic Distortion):** Typically 20-40% lower than two-level inverters
- **Dominant Harmonics:** Around switching frequency and its multiples
- **Low-order Harmonics:** Significantly reduced compared to two-level topology

## Applications

1. **Medium-voltage motor drives** (industrial applications)
2. **Grid-connected inverters** (renewable energy systems)
3. **FACTS devices** (Flexible AC Transmission Systems)
4. **Active power filters**
5. **UPS systems** (Uninterruptible Power Supplies)

## Advantages of NPC Topology

1. ✓ Reduced switch voltage stress (Vdc/2 per switch)
2. ✓ Better output voltage quality
3. ✓ Lower EMI and harmonic distortion
4. ✓ Suitable for medium voltage applications
5. ✓ No transformer needed for some applications

## Limitations

1. ✗ Neutral point voltage balancing can be challenging
2. ✗ More components than two-level inverters
3. ✗ Unequal loss distribution among switches
4. ✗ More complex control system

## Simulation Guidelines

### Step-by-Step Simulation Process

1. **Set Up Parameters:**
   - Define Vdc, fs, f0, ma, load parameters
   - Run `NPC_Inverter_Model.m` to load parameters

2. **Build the Model:**
   - Open Simulink
   - Add required blocks from Simscape Electrical library
   - Connect components according to topology

3. **Configure Solver:**
   - Use variable-step solver (ode23tb or ode15s)
   - Set appropriate step size for switching frequency

4. **Run Simulation:**
   - Start with short simulation time (0.1s)
   - Observe waveforms
   - Analyze results

5. **Verify Results:**
   - Check voltage levels (+Vdc/2, 0, -Vdc/2)
   - Verify fundamental frequency
   - Analyze harmonic content

## Model Files

- `NPC_Inverter_Model.m` - MATLAB script to create and configure the model
- `NPC_Inverter_3Level.slx` - Simulink model file (generated by the script)
- `NPC_PWM_Controller.m` - PWM control logic (if created separately)
- `Design_Documentation.md` - This file

## References

1. Nabae, A., Takahashi, I., & Akagi, H. (1981). "A new neutral-point-clamped PWM inverter." IEEE Transactions on Industry Applications.
2. Rodriguez, J., Lai, J. S., & Peng, F. Z. (2002). "Multilevel inverters: a survey of topologies, controls, and applications." IEEE Transactions on Industrial Electronics.
3. Franquelo, L. G., et al. (2008). "The age of multilevel converters arrives." IEEE Industrial Electronics Magazine.

## Support and Contact

For questions or issues with this design, please refer to the GitHub repository or contact the project maintainers.

---

**Version:** 1.0  
**Last Updated:** January 2026  
**License:** MIT (or as specified in repository)
