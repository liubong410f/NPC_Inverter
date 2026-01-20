# Verification and Expected Results

## Purpose

This document describes the expected behavior and results when the NPC Inverter model is correctly implemented and simulated.

## Pre-Simulation Verification

### 1. Parameter Loading Check

After running `NPC_Parameters.m`, verify these variables exist in workspace:

```matlab
>> whos
```

Expected variables:
| Variable | Value | Units | Description |
|----------|-------|-------|-------------|
| Vdc | 600 | V | DC bus voltage |
| C1, C2 | 2200e-6 | F | DC capacitors |
| fs | 5000 | Hz | Switching frequency |
| f_output | 50 | Hz | Output frequency |
| ma | 0.8 | - | Modulation index |
| R_load | 10 | Ω | Load resistance |
| L_load | 10e-3 | H | Load inductance |

### 2. PWM Logic Verification

Run the visualization script:
```matlab
>> PWM_Visualization
```

**Expected Console Output:**
```
============================================
NPC Inverter PWM Waveform Visualization
============================================

Simulation Parameters:
  DC Voltage: 600 V
  Switching Frequency: 5000 Hz
  Output Frequency: 50 Hz
  Modulation Index: 0.80
  Simulation Time: 0.060 s (3 cycles)

Switching Statistics:
  P state (+Vdc/2): XX.X%
  O state (0V):     XX.X%
  N state (-Vdc/2): XX.X%

Switching Rule Verification:
  S1 and S4 simultaneous ON: 0 (should be 0)
  Valid state combinations: ~100% (should be ~100%)

FFT Analysis:
  Fundamental frequency: 50.0 Hz
  Fundamental amplitude: XXX.X V
  THD (up to 1 kHz): XX.XX%
```

**Expected Figures:**
1. **Figure 1: PWM Waveforms**
   - 6 subplots showing reference, gate signals, and output
   - Three-level output clearly visible
   
2. **Figure 2: FFT Analysis**
   - Dominant peak at 50 Hz (fundamental)
   - Harmonics around switching frequency (5 kHz)

## Simulation Results

### Expected Waveforms

#### 1. DC Bus Voltage
```
Vdc = 600V (constant)
     ════════════════════════════
         Time →
```

**Verification Points:**
- ✓ Should be constant at 600V
- ✓ Minimal ripple (< 5%)
- ✓ No significant voltage drop

#### 2. Phase Output Voltage (Three-Level)
```
Voltage
+300V  ╗══╗═╗══╗═╗══╗═╗══╗═╗══╗
    0V ║══╚═╚══╚═╚══╚═╚══╚═╚══║
-300V  ╚══════════════════════╚
       Time (50 Hz period) →
```

**Verification Points:**
- ✓ Three distinct levels: +300V, 0V, -300V
- ✓ Fundamental frequency = 50 Hz
- ✓ Stepped waveform approximates sine wave
- ✓ No voltage spikes or glitches

#### 3. Load Current (Sinusoidal)
```
Current
        ╱───╲
   ────╱     ╲────
       0     ╲───╱ 
             Time →
```

**Verification Points:**
- ✓ Sinusoidal shape
- ✓ Frequency = 50 Hz
- ✓ Peak current ≈ 21 A (for given parameters)
- ✓ Smooth waveform (filtering by load inductance)

#### 4. Gate Signals

**S1 (Upper Outer Switch):**
```
ON   ╗═╗═╗═╗═╗═╗═╗═╗═╗═╗═╗═
OFF  ╚═╚═╚═╚═╚═╚═╚═╚═╚═╚═╚═
     Switching at 5 kHz
```

**S2 (Upper Inner Switch):**
```
ON   ═════════════╗════════╗══
OFF              ╚════════╚
     Mostly ON, some OFF periods
```

**S3 (Lower Inner Switch):**
```
ON   ════╗════════╚════════╚══
OFF      ╚═════════════════
     Complementary to S2 pattern
```

**S4 (Lower Outer Switch):**
```
OFF  ═╗═╚═╗═╚═╗═╚═╗═╚═╗═╚═╗═
ON   ╚═╗═╚═╗═╚═╗═╚═╗═╚═╗═╚═
     Complementary to S1
```

### Numerical Results

#### Single-Phase System (ma = 0.8, Vdc = 600V)

| Parameter | Calculated | Simulation | Unit | Tolerance |
|-----------|-----------|------------|------|-----------|
| Peak output voltage | 240 | ~240 | V | ±5% |
| RMS output voltage | 170 | ~170 | V | ±5% |
| Peak load current | 21.2 | ~21 | A | ±10% |
| RMS load current | 15.0 | ~15 | A | ±10% |
| Output power | 2550 | ~2500 | W | ±10% |
| THD | 25-35 | ~30 | % | ±5% |

#### Three-Phase System (if implemented)

| Parameter | Value | Unit |
|-----------|-------|------|
| Line-to-line voltage (RMS) | ~294 | V |
| Phase voltage (RMS) | ~170 | V |
| Line current (RMS) | ~15 | A |
| Total output power | ~7650 | W |

### FFT Analysis Results

**Expected Harmonic Spectrum:**

| Harmonic | Frequency | Magnitude | Notes |
|----------|-----------|-----------|-------|
| Fundamental | 50 Hz | ~240 V | Dominant |
| 3rd | 150 Hz | < 10% | Low (due to 3-level) |
| 5th | 250 Hz | < 8% | Low |
| 7th | 350 Hz | < 5% | Low |
| Switching (carrier) | ~5 kHz | 15-25% | Expected |
| Sideband | 4.95, 5.05 kHz | 10-20% | Expected |

**THD Calculation:**
```
THD = √(V₃² + V₅² + V₇² + ... + Vₙ²) / V₁ × 100%

Expected: 25-35% for level-shifted PWM at ma=0.8
```

## Performance Metrics

### Switching Statistics

For one fundamental cycle (20ms at 50Hz):
- **Number of switching events:** ~100 per switch (at 5 kHz)
- **P state duration:** ~40% of time (positive half)
- **O state duration:** ~40% of time (transition)
- **N state duration:** ~20% of time (negative half)

### Power Quality

| Metric | Target | Acceptable Range |
|--------|--------|------------------|
| Voltage THD | < 5% | < 10% |
| Current THD | < 3% | < 5% |
| Power Factor | > 0.95 | > 0.90 |
| Neutral point balance | ±5V | ±20V |

### Efficiency Estimation

```
Switching losses per IGBT: ~5-10W
Conduction losses: ~20-30W
Total losses: ~100-150W
Output power: ~2500W
Efficiency: ~94-96%
```

## Verification Checklist

### ✓ Level 1: Basic Functionality

- [ ] Model opens without errors
- [ ] Simulation runs to completion
- [ ] No error messages in console
- [ ] Scopes show waveforms
- [ ] Three voltage levels visible

### ✓ Level 2: Correct Operation

- [ ] Output voltage levels: +300V, 0V, -300V
- [ ] Output frequency = 50 Hz ±1%
- [ ] Gate signals at 5 kHz switching frequency
- [ ] Load current is sinusoidal
- [ ] No illegal switching states

### ✓ Level 3: Performance Validation

- [ ] THD < 40%
- [ ] Fundamental frequency dominant in FFT
- [ ] Current phase lag corresponds to load impedance
- [ ] Power calculations correct
- [ ] Efficiency > 90%

### ✓ Level 4: Advanced Validation

- [ ] Neutral point voltage balanced
- [ ] Symmetrical operation in all quadrants
- [ ] Step response acceptable
- [ ] Thermal performance within limits
- [ ] EMI/harmonic standards met

## Common Issues and Solutions

### Issue 1: Voltage Levels Incorrect

**Symptom:** Output shows only two levels or wrong voltages

**Possible Causes:**
- Incorrect DC voltage setting
- Wrong gate signal logic
- Missing neutral point connection

**Solution:**
```matlab
% Verify DC voltage
>> Vdc
ans = 600  % Should be 600

% Check gate signals with scope
% Verify: S1+S2 = P state, S3+S4 = N state
```

### Issue 2: High THD

**Symptom:** THD > 50%

**Possible Causes:**
- Low switching frequency
- Incorrect modulation index
- Improper PWM implementation

**Solution:**
```matlab
% Increase switching frequency
fs = 10000;  % Try 10 kHz

% Verify modulation index
ma = 0.8;  % Should be 0.5 to 1.0
```

### Issue 3: Unstable Waveforms

**Symptom:** Oscillations or instability

**Possible Causes:**
- Solver issues
- Algebraic loops
- Too large step size

**Solution:**
```matlab
% Use stiff solver
set_param(model, 'Solver', 'ode23tb')

% Reduce max step size
set_param(model, 'MaxStep', '1e-5')
```

### Issue 4: Simulation Too Slow

**Symptom:** Simulation takes very long

**Solution:**
```matlab
% Reduce simulation time
sim_time = 0.02;  % Just one cycle

% Simplify model
% - Use ideal switches
% - Remove snubbers if not critical
% - Increase max step size slightly
```

## Automated Testing Script

```matlab
%% Automated Verification Script
% Run this to verify your implementation

function results = verify_NPC_model(modelName)
    % Load parameters
    NPC_Parameters;
    
    % Run simulation
    simOut = sim(modelName, 'StopTime', '0.04');
    
    % Get output voltage
    Vout = simOut.get('Vout');
    
    % Verify three levels
    levels = unique(round(Vout.Data));
    assert(length(levels) == 3, 'Should have 3 voltage levels');
    
    % Verify levels are correct
    expected_levels = sort([-Vdc/2, 0, Vdc/2]);
    actual_levels = sort(levels);
    assert(max(abs(actual_levels - expected_levels)) < 50, ...
           'Voltage levels incorrect');
    
    % Verify frequency
    % ... (FFT analysis code)
    
    % Print results
    fprintf('✓ All verifications passed!\n');
    results = true;
end
```

## Benchmark Results

### Reference System

Using the default parameters:
- **Simulation time (0.1s):** ~5-10 seconds on modern PC
- **Memory usage:** ~500 MB
- **Output file size:** ~10 MB

### Expected Performance

| Configuration | Sim Time (0.1s) | Memory |
|---------------|-----------------|--------|
| Single phase, simple | 3-5 s | 300 MB |
| Single phase, detailed | 8-12 s | 500 MB |
| Three phase, simple | 10-15 s | 800 MB |
| Three phase, detailed | 20-30 s | 1.5 GB |

## Conclusion

If all verification points pass:
- ✓ Model is correctly implemented
- ✓ Results match theoretical expectations
- ✓ Ready for advanced applications

**Next Steps:**
1. Experiment with different parameters
2. Add closed-loop control
3. Implement protection features
4. Test with motor load
5. Optimize for specific application

---

**Questions or Issues?**

If results don't match expected values:
1. Review parameter settings
2. Check circuit connections
3. Verify PWM logic
4. Consult troubleshooting section
5. Create GitHub issue with details
