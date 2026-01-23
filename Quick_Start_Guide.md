# Quick Start Guide - NPC Inverter Simulink Model

## For Users WITH MATLAB/Simulink Access

### Option 1: Quick Visualization (No Simulink Required)

If you just want to see how the PWM works:

```matlab
>> PWM_Visualization
```

This will generate:
- PWM gate signal waveforms
- Three-level output voltage
- FFT harmonic analysis

### Option 2: Load Parameters and Create Model

```matlab
>> NPC_Parameters           % Load all parameters
>> NPC_Inverter_Model       % Create basic Simulink model
```

Then manually complete the model following `Simulink_Build_Guide.md`

### Option 3: Build Complete Model Manually

1. Open MATLAB and Simulink
2. Run: `>> NPC_Parameters` to load all parameters
3. Follow step-by-step instructions in `Simulink_Build_Guide.md`
4. Build the complete three-phase NPC inverter

## For Users WITHOUT MATLAB/Simulink Access

You can still:
1. Review all documentation to understand the NPC inverter theory
2. Study the circuit diagrams in `Circuit_Diagram.md`
3. Examine the MATLAB code to understand the PWM algorithm
4. Use this as a reference for implementing in other tools:
   - PSIM
   - PLECS
   - LTspice (limited)
   - Python-based simulators

## Implementation Checklist

### Phase 1: Basic Single-Phase Model
- [ ] Set up DC bus (600V with two capacitors)
- [ ] Build one phase leg (4 IGBTs + 4 diodes)
- [ ] Add simple RL load
- [ ] Implement basic PWM controller
- [ ] Verify three voltage levels

### Phase 2: Control System
- [ ] Add reference signal generator (50 Hz)
- [ ] Add carrier generators (5 kHz)
- [ ] Implement level-shifted PWM logic
- [ ] Test gate signals with scopes
- [ ] Verify switching rules

### Phase 3: Measurements
- [ ] Add voltage measurements
- [ ] Add current measurements
- [ ] Add power calculations
- [ ] Configure scopes properly
- [ ] Add FFT analysis (using Powergui)

### Phase 4: Three-Phase Extension
- [ ] Duplicate to three phases
- [ ] Add phase shifts (0°, -120°, -240°)
- [ ] Connect three-phase load (star or delta)
- [ ] Verify balanced operation

### Phase 5: Advanced Features (Optional)
- [ ] Add closed-loop control
- [ ] Implement neutral point balancing
- [ ] Add over-current protection
- [ ] Optimize switching strategy
- [ ] Motor load model (induction/PMSM)

## Troubleshooting Guide

### Problem: Model won't simulate

**Check:**
1. Is Powergui block present?
2. Are all grounds connected?
3. Is Solver Configuration block added?
4. Did you run `NPC_Parameters` first?

**Solution:**
```matlab
>> NPC_Parameters  % Reload parameters
```

### Problem: Incorrect voltage levels

**Check:**
1. DC voltage value (should be 600V)
2. Gate signal logic
3. Switch connections
4. Capacitor mid-point connection

**Debug:**
- Add displays to show S1, S2, S3, S4 states
- Verify: P state (S1=1,S2=1), O state (S2=1,S3=1), N state (S3=1,S4=1)

### Problem: Simulation too slow

**Solutions:**
1. Reduce simulation time (try 0.02s instead of 0.1s)
2. Use ode23tb solver
3. Set Max step size to auto
4. Simplify load model

### Problem: Algebraic loop error

**Solutions:**
1. Add small series resistance (1e-3 Ω) to switches
2. Check for circular connections
3. Use Simulink.ResolveDependencies

## Expected Performance Metrics

After successful implementation:

| Metric | Expected Value | Verification Method |
|--------|---------------|---------------------|
| Output voltage levels | ±300V, 0V | Scope on phase output |
| Fundamental frequency | 50 Hz | FFT analysis |
| Switching frequency | 5 kHz | Gate signal scope |
| THD | < 40% | Powergui FFT tool |
| Efficiency | > 95% | Power measurement |

## File Dependencies

```
NPC_Parameters.m  ──→ Loads parameters to workspace
       ↓
NPC_Inverter_Model.m  ──→ Creates basic model structure
       ↓
Simulink_Build_Guide.md  ──→ Manual completion steps
       ↓
NPC_Inverter_3Level.slx  ──→ Final Simulink model
```

For PWM testing without Simulink:
```
PWM_Visualization.m  ──→ Standalone visualization
       ↓
   (Generates plots)
```

## Customization Guide

### Change DC Voltage

Edit in `NPC_Parameters.m`:
```matlab
Vdc = 800;  % Change from 600V to 800V
```

### Change Switching Frequency

Edit in `NPC_Parameters.m`:
```matlab
fs = 10000;  % Change from 5kHz to 10kHz
```

### Change Output Frequency

Edit in `NPC_Parameters.m`:
```matlab
f_output = 60;  % Change from 50Hz to 60Hz
```

### Change Modulation Index

Edit in `NPC_Parameters.m`:
```matlab
ma = 0.9;  % Change from 0.8 to 0.9 (max is 1.0)
```

After changes, always run:
```matlab
>> NPC_Parameters  % Reload parameters
>> sim('NPC_Inverter_3Level')  % Run simulation
```

## Testing Procedure

### Step 1: Verify Parameters
```matlab
>> NPC_Parameters
```
Check output confirms all values are loaded.

### Step 2: Test PWM Logic
```matlab
>> PWM_Visualization
```
Verify:
- Reference signal is sinusoidal
- Three voltage levels appear
- Gate signals follow switching rules

### Step 3: Run Basic Simulation
```matlab
>> sim('NPC_Inverter_3Level', 0.02)  % 20ms simulation
```

### Step 4: Check Results
- Open scopes
- Verify voltage waveforms
- Check current is sinusoidal
- Analyze harmonics with FFT

### Step 5: Extended Tests
- Vary modulation index (0.5 to 1.0)
- Test different loads
- Measure THD
- Verify neutral point balance

## Common Modifications

### Add Dead-Time

In gate signal generation, add delay:
```matlab
% Add 2 microseconds dead-time
td = 2e-6;
S1_delayed = [zeros(1, round(td*fs)), S1(1:end-round(td*fs))];
```

### Change to Space Vector PWM

Replace carrier-based PWM with SVPWM algorithm:
- Use sector identification
- Calculate duty cycles
- Generate switching sequences

(Refer to advanced SVPWM documentation)

### Add Three-Phase

For each additional phase:
1. Duplicate phase leg blocks
2. Shift reference by ±120°
3. Connect to same DC bus
4. Add to three-phase load

## Support Resources

### Within This Repository
- `Design_Documentation.md` - Theory and design details
- `Simulink_Build_Guide.md` - Building instructions
- `Circuit_Diagram.md` - Topology reference
- `README.md` - Overview and features

### External Resources
- MATLAB Documentation: [Simscape Electrical](https://www.mathworks.com/products/simscape-electrical.html)
- IEEE Papers on NPC inverters
- Power electronics textbooks (Mohan, Rashid, etc.)

## Validation Checklist

Before considering the model complete:

- [ ] All switching states verified (P, O, N)
- [ ] Three voltage levels confirmed
- [ ] Output frequency = 50 Hz ±1%
- [ ] Switching frequency = 5 kHz ±5%
- [ ] No illegal switching states
- [ ] Load current is sinusoidal
- [ ] THD < 40%
- [ ] Neutral point voltage stable
- [ ] All documentation reviewed
- [ ] Model saved and documented

## Next Steps After Basic Implementation

1. **Performance Analysis**
   - Measure switching losses
   - Calculate efficiency
   - Analyze thermal performance

2. **Advanced Control**
   - Implement PI controllers
   - Add current control loop
   - Voltage regulation

3. **Protection Circuits**
   - Over-current detection
   - Over-voltage protection
   - Thermal monitoring

4. **Real-World Application**
   - Motor drive implementation
   - Grid-tie inverter
   - Active power filter

---

**Questions?** Check the documentation files or create an issue on GitHub.

**Ready to start?** Run `NPC_Parameters` and open `Simulink_Build_Guide.md`!
