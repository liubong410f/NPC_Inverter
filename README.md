# NPC_Inverter
Three-Level Neutral-Point Clamped (NPC) Multilevel Inverter

## Overview

This repository contains a complete Simulink design for a **Three-Level Neutral-Point Clamped (NPC) Multilevel Inverter**. The NPC inverter is a widely-used power electronics topology for medium-voltage applications, offering superior output voltage quality compared to conventional two-level inverters.

## Features

- ✅ Three-level voltage output: +Vdc/2, 0, -Vdc/2
- ✅ Level-shifted carrier-based PWM control
- ✅ Reduced harmonic distortion
- ✅ Lower voltage stress on switching devices
- ✅ Configurable parameters for different applications
- ✅ Comprehensive documentation and building guide

## Repository Contents

### MATLAB Scripts
- **`NPC_Parameters.m`** - Main parameter configuration file (run this first)
- **`NPC_PWM_Controller.m`** - PWM generation functions for gate signals
- **`NPC_Inverter_Model.m`** - Script to create Simulink model programmatically

### Documentation
- **`Design_Documentation.md`** - Detailed technical documentation
- **`Simulink_Build_Guide.md`** - Step-by-step guide to build the model
- **`Circuit_Diagram.md`** - Circuit topology and connections

### Simulink Model
- **`NPC_Inverter_3Level.slx`** - Main Simulink model (generated)

## Quick Start

### Prerequisites
- MATLAB R2018a or later
- Simulink
- Simscape Electrical (formerly SimPowerSystems) toolbox

### Running the Simulation

1. **Load Parameters:**
   ```matlab
   >> NPC_Parameters
   ```

2. **Option A - Build Model Programmatically:**
   ```matlab
   >> NPC_Inverter_Model
   ```

3. **Option B - Build Model Manually:**
   - Follow the instructions in `Simulink_Build_Guide.md`

4. **Run Simulation:**
   ```matlab
   >> sim('NPC_Inverter_3Level')
   ```
   Or click the **Run** button in Simulink

### Testing PWM Controller

To test the PWM generation:
```matlab
>> test_PWM_controller  % Function in NPC_PWM_Controller.m
```

## Key Parameters

| Parameter | Default Value | Description |
|-----------|--------------|-------------|
| Vdc | 600 V | DC bus voltage |
| fs | 5 kHz | Switching frequency |
| f_output | 50 Hz | Output frequency |
| ma | 0.8 | Modulation index |
| R_load | 10 Ω | Load resistance |
| L_load | 10 mH | Load inductance |

Parameters can be modified in `NPC_Parameters.m`

## NPC Inverter Topology

### Single Phase Leg Configuration
```
    +Vdc/2
      |
     S1  ← Upper Outer Switch
      |
    D1-+-D2  ← Clamping Diodes (to Neutral)
      |
     S2  ← Upper Inner Switch
      |
    Output ← Phase Output (A, B, or C)
      |
     S3  ← Lower Inner Switch
      |
    D3-+-D4  ← Clamping Diodes (to Neutral)
      |
     S4  ← Lower Outer Switch
      |
    -Vdc/2
```

### Switching States

| Output | S1 | S2 | S3 | S4 | Description |
|--------|----|----|----|----|-------------|
| +Vdc/2 | ON | ON | OFF| OFF| P state |
| 0      | OFF| ON | ON | OFF| O state |
| -Vdc/2 | OFF| OFF| ON | ON | N state |

## Applications

- Medium-voltage motor drives
- Grid-connected inverters for renewable energy
- FACTS devices
- Active power filters
- UPS systems

## Advantages

1. Reduced voltage stress on switches (Vdc/2 per device)
2. Lower total harmonic distortion (THD)
3. Better output voltage quality
4. Reduced EMI
5. Suitable for medium-voltage applications

## Documentation

For detailed information, see:
- [Design Documentation](Design_Documentation.md) - Complete technical details
- [Simulink Build Guide](Simulink_Build_Guide.md) - Step-by-step construction
- [Circuit Diagram](Circuit_Diagram.md) - Topology and connections

## Expected Results

After simulation, you should observe:
- **Phase Voltage:** Three-level stepped waveform
- **Voltage Levels:** +300V, 0V, -300V (for Vdc=600V)
- **Load Current:** Sinusoidal at 50 Hz fundamental
- **THD:** Significantly lower than two-level inverter

## References

1. Nabae, A., Takahashi, I., & Akagi, H. (1981). "A new neutral-point-clamped PWM inverter." *IEEE Transactions on Industry Applications*.
2. Rodriguez, J., et al. (2002). "Multilevel inverters: a survey of topologies, controls, and applications." *IEEE Transactions on Industrial Electronics*.

## License

This project is provided for educational and research purposes.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For questions or issues, please open an issue on GitHub.

---

**Version:** 1.0  
**Last Updated:** January 2026
