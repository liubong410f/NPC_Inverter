# Simulink Model Building Guide for NPC Inverter

## Prerequisites

Before starting, ensure you have:
- MATLAB R2018a or later
- Simulink
- Simscape Electrical (formerly SimPowerSystems)

## Step-by-Step Model Construction

### Step 1: Create New Model

1. Open MATLAB
2. Type `simulink` in the command window
3. Click "Blank Model" or use: `new_system('NPC_Inverter_3Level')`
4. Save the model as `NPC_Inverter_3Level.slx`

### Step 2: Set Model Configuration

1. Go to **Simulation → Model Configuration Parameters**
2. Set the following:
   - **Solver Type:** Variable-step
   - **Solver:** ode23tb (stiff/TR-BDF2)
   - **Max step size:** auto
   - **Stop time:** 0.1 (seconds)

### Step 3: Build the DC Power Supply

1. Open Simscape Electrical library: **Simscape → Electrical → Specialized Power Systems**
2. Add the following blocks:

   **DC Source Configuration:**
   - Add `Electrical Sources/DC Voltage Source` (Vdc = 600V)
   - Add two `Elements/Capacitor` blocks in series
   - Set each capacitor: C = 2200e-6 F (2200 µF)
   - Connect capacitors to create neutral point (Vdc/2 each)

### Step 4: Build One Phase Leg

For each phase leg, you need 4 IGBTs and 4 clamping diodes.

#### 4a. Add IGBT Switches

1. From **Semiconductors & Converters/Fundamental Components**:
   - Add 4 `IGBT` blocks (S1, S2, S3, S4)
   - Configure each IGBT:
     - Internal resistance Ron = 1e-3 Ω
     - Snubber resistance Rs = 1e5 Ω
     - Snubber capacitance Cs = 1e-9 F

2. Arrange vertically in order: S1 → S2 → S3 → S4

#### 4b. Add Clamping Diodes

1. Add 4 `Diode` blocks (D1, D2, D3, D4)
2. Configure each diode:
   - Forward voltage Vf = 0.8 V
   - On resistance Ron = 1e-3 Ω
   - Snubber resistance Rs = 1e5 Ω
   - Snubber capacitance Cs = 250e-9 F

#### 4c. Connect the Phase Leg

```
    +Vdc/2
      |
     S1
      |
    +-+------+
    |        |
   D1       D2  ← Connect to Neutral Point
    |        |
    +---+----+
        |
       S2
        |
    Output A ←──── Phase Output
        |
       S3
        |
    +---+----+
    |        |
   D3       D4  ← Connect to Neutral Point
    |        |
    +-+------+
      |
     S4
      |
    -Vdc/2
```

### Step 5: Create PWM Controller

#### 5a. Reference Signal Generator

1. Add `Simulink/Sources/Sine Wave` block
   - Amplitude: 0.8 (modulation index)
   - Frequency: 2*pi*50 rad/s (50 Hz)
   - Phase: 0 degrees

#### 5b. Carrier Signal Generators

1. Add two `Signal Generator` blocks from Simulink/Sources:
   
   **Carrier 1 (Upper):**
   - Wave form: Triangle
   - Amplitude: 0.5
   - Frequency: 5000 Hz
   - Units: Hertz
   - Offset: 0.5

   **Carrier 2 (Lower):**
   - Wave form: Triangle
   - Amplitude: 0.5
   - Frequency: 5000 Hz
   - Units: Hertz
   - Offset: -0.5

#### 5c. PWM Logic

1. Add `Simulink/Logic and Bit Operations/Relational Operator` blocks
2. Create the following comparisons:

   For upper switches (S1, S2):
   ```
   If Vref > 0:
       S1_on = (Vref > Carrier_Upper)
       S2_on = 1
   Else:
       S1_on = 0
       S2_on = (Vref > Carrier_Lower)
   ```

   For lower switches (S3, S4):
   ```
   S3 = NOT S2
   S4 = NOT S1
   ```

3. Use `Simulink/Logic and Bit Operations/Logical Operator` for NOT operations

#### 5d. Alternative: Use MATLAB Function Block

1. Add `Simulink/User-Defined Functions/MATLAB Function` block
2. Copy the `NPC_PWM_Controller` function code into this block
3. Connect inputs: Vref, time, parameters
4. Connect outputs to gate terminals

### Step 6: Add Load

1. Add `Elements/Series RLC Branch`:
   - Resistance R = 10 Ω
   - Inductance L = 10e-3 H (10 mH)
   - Capacitance C = inf (no capacitor)
   - Or set Branch type: RL

2. For three-phase load:
   - Add 3 Series RLC branches
   - Configure for star or delta connection

### Step 7: Add Measurements

1. **Voltage Measurements:**
   - Add `Sensors and Transducers/Voltage Measurement` blocks
   - Measure: DC bus voltage, phase voltages, line voltages

2. **Current Measurements:**
   - Add `Sensors and Transducers/Current Measurement` blocks
   - Measure load currents for each phase

3. **Add Scopes:**
   - Add `Simulink/Sinks/Scope` blocks
   - Connect to voltage and current measurements
   - Configure for proper time scale (0 to 0.1 seconds)

### Step 8: Add Grounding

1. Add `Elements/Ground` blocks
2. Connect ground to:
   - Negative terminal of DC source
   - Reference node for measurements
   - Neutral point of load (if star-connected)

### Step 9: Add Solver Configuration Block

1. Add `Simscape/Utilities/Solver Configuration` block
2. Connect to every Simscape network
3. Settings usually auto-configured

### Step 10: Complete Three-Phase System

1. Copy the entire single-phase leg
2. Paste twice to create Phase B and Phase C
3. Adjust phase offsets in reference signals:
   - Phase A: 0°
   - Phase B: -120° (or 240°)
   - Phase C: -240° (or 120°)

### Step 11: Add Display and Analysis

1. **Add Display Blocks:**
   - `Simulink/Sinks/Display` - for RMS values
   - `Simulink/Sinks/To Workspace` - save data for post-processing

2. **Optional - FFT Analysis:**
   - Add `Powergui` block (required for Simscape Electrical)
   - Use FFT tool to analyze harmonics
   - Right-click Powergui → FFT Analysis

### Step 12: Configure Powergui

1. Add `Simscape Electrical/Specialized Power Systems/Powergui` block
2. This is ESSENTIAL for simulation
3. Set Simulation type: Continuous
4. Sample time: auto

### Step 13: Run Initial Simulation

1. Load parameters: Run `NPC_Inverter_Model.m` in MATLAB
2. Click the **Run** button in Simulink
3. Check for errors
4. Verify waveforms in scopes

### Step 14: Optimize and Fine-Tune

1. Adjust modulation index for desired output voltage
2. Tune solver settings if simulation is slow
3. Add signal processing for better visualization
4. Add THD calculation blocks if needed

## Simulink Library Blocks Summary

| Component | Library Path |
|-----------|--------------|
| DC Voltage Source | Simscape/Electrical/Specialized Power Systems/Electrical Sources |
| IGBT | Simscape/Electrical/Specialized Power Systems/Semiconductors & Converters |
| Diode | Simscape/Electrical/Specialized Power Systems/Semiconductors & Converters |
| Capacitor | Simscape/Electrical/Specialized Power Systems/Elements |
| Series RLC | Simscape/Electrical/Specialized Power Systems/Elements |
| Voltage Measurement | Simscape/Electrical/Specialized Power Systems/Sensors and Transducers |
| Current Measurement | Simscape/Electrical/Specialized Power Systems/Sensors and Transducers |
| Ground | Simscape/Electrical/Specialized Power Systems/Elements |
| Powergui | Simscape/Electrical/Specialized Power Systems |
| Scope | Simulink/Sinks |
| Sine Wave | Simulink/Sources |

## Expected Results

After successful simulation, you should observe:

1. **DC Bus Voltage:** Stable at 600V (or configured value)
2. **Phase Voltage:** Three-level waveform (-300V, 0V, +300V)
3. **Load Current:** Sinusoidal with fundamental frequency = 50 Hz
4. **THD:** Significantly lower than two-level inverter
5. **Switching Patterns:** Six switches operating at 5 kHz

## Troubleshooting

### Common Issues:

1. **Simulation won't run:**
   - Check if Powergui block is present
   - Verify all grounds are connected
   - Check solver configuration

2. **Algebraic loop error:**
   - Add small resistances in series with switches
   - Check for circular connections

3. **Unstable waveforms:**
   - Reduce max step size
   - Use stiff solver (ode23tb or ode15s)
   - Check capacitor values

4. **Incorrect voltage levels:**
   - Verify gate signals
   - Check DC bus voltage
   - Verify switching logic

## Saving and Documentation

1. Save model: `Ctrl+S` or File → Save
2. Save workspace: `save('NPC_params.mat')`
3. Export waveforms: Use To Workspace blocks
4. Generate report: Simulink → Print → Print to File

## Next Steps

1. Validate three-level output
2. Perform harmonic analysis using FFT
3. Test with different loads (motor model)
4. Implement closed-loop control
5. Add protection circuits
6. Optimize switching strategy

---

**Note:** This guide provides the structure for building the model. The actual implementation requires MATLAB/Simulink software and appropriate toolboxes.
