# Circuit Diagram and Topology

## Three-Level NPC Inverter Circuit

### Complete Single-Phase Topology

```
                         DC Bus Capacitors
                    +------------------------+
                    |                        |
                   C1 (2200µF)              |||
                    |                        ||| DC Source
                    |                        ||| (Vdc = 600V)
    +Vdc/2 (300V) --+-- Neutral Point (0V)   |||
                    |                        |||
                   C2 (2200µF)               |
                    |                        |
                    +------------------------+
                    |
               -Vdc/2 (-300V)


    Phase Leg A:                  Gate Signals:
    
    +Vdc/2                        G1 ─→ S1
      |                           G2 ─→ S2
    +-+-+                         G3 ─→ S3
    |   |                         G4 ─→ S4
   [S1] |← Upper Outer IGBT
    |   |
    +-+-+
      |
    +-+-+--------+
    |            |
  [D1]         [D2] ← Clamping Diodes
    |            |
    +------+-----+
           |
        Neutral Point (0V)
           |
    +------+-----+
    |            |
  [D3]         [D4] ← Clamping Diodes
    |            |
    +-+-+--------+
      |
    +-+-+
    |   |
   [S2] |← Upper Inner IGBT
    |   |
    +-+-+
      |
      +-------------- Output A (Phase Voltage)
      |
    +-+-+
    |   |
   [S3] |← Lower Inner IGBT
    |   |
    +-+-+
      |
    +-+-+--------+
    |            |
  [D5]         [D6] ← Clamping Diodes
    |            |
    +------+-----+
           |
        Neutral Point (0V)
           |
    +------+-----+
    |            |
  [D7]         [D8] ← Clamping Diodes
    |            |
    +-+-+--------+
      |
    +-+-+
    |   |
   [S4] |← Lower Outer IGBT
    |   |
    +-+-+
      |
    -Vdc/2


Legend:
  [S1-S4] = IGBT switches with anti-parallel diodes
  [D1-D8] = Clamping diodes
  ─→ = Gate signal connection
  +Vdc/2 = Positive DC rail (+300V)
  0V = Neutral point
  -Vdc/2 = Negative DC rail (-300V)
```

### Simplified Phase Leg (Clearer View)

```
        +300V (P bus)
          ║
          ║
        ┌─╨─┐
        │S1 │ ◄── G1 (Gate 1)
        └─┬─┘
          │
      ┌───┼───┐
      │   │   │
     ╱│   │   │╲
    ──┤D1     D2├──  0V (Neutral)
     ╲│       │╱
      └───────┘
          │
        ┌─╨─┐
        │S2 │ ◄── G2 (Gate 2)
        └─┬─┘
          │
          ├─────── Output A
          │
        ┌─╨─┐
        │S3 │ ◄── G3 (Gate 3)
        └─┬─┘
          │
      ┌───┼───┐
      │   │   │
     ╱│   │   │╲
    ──┤D3     D4├──  0V (Neutral)
     ╲│       │╱
      └───────┘
          │
        ┌─╨─┐
        │S4 │ ◄── G4 (Gate 4)
        └─┬─┘
          ║
          ║
       -300V (N bus)
```

## Three-Phase NPC Inverter

### Complete System Block Diagram

```
                    DC Source (600V)
                         |
                    +----+----+
                    |         |
                   C1        C2  (DC Capacitors)
                    |         |
                    +----+----+
                         |
         +---------------+---------------+
         |               |               |
    Phase Leg A     Phase Leg B     Phase Leg C
    (0° ref)        (-120° ref)     (-240° ref)
         |               |               |
         +-------+-------+-------+-------+
                 |       |       |
              Output  Output  Output
               A        B        C
                 |       |       |
              +--+-------+-------+--+
              |                     |
              |    3-Phase Load     |
              |    (Star or Delta)  |
              |                     |
              +---------------------+
                        |
                     Neutral/Ground
```

### Load Connections

#### Star (Y) Connection
```
    Phase A ──┐
               ├──── Load A ────┐
    Phase B ──┼──── Load B ────┼─── Neutral (N)
               │                 │
    Phase C ──┘──── Load C ────┘

    Line Voltage = √3 × Phase Voltage
```

#### Delta (Δ) Connection
```
    Phase A ──── Load AB ──── Phase B
         │                        │
         │                        │
    Load CA                  Load BC
         │                        │
         │                        │
    Phase C ──────────────────────┘

    Line Current = √3 × Phase Current
```

## PWM Control System

### Control Block Diagram

```
┌─────────────────────────────────────────────────────┐
│                PWM Controller                        │
│                                                      │
│  Reference        ┌──────────────┐   Gate Signals   │
│  Generator   ───→ │ Carrier-Based│ ───→ G1, G2     │
│  (50 Hz sine)     │ Comparators  │      G3, G4     │
│                   └──────────────┘       ↓          │
│                          ↑               To IGBTs   │
│  Carrier          ┌──────┴──────┐                   │
│  Generators       │  Upper (P)  │                   │
│  (5 kHz tri)      │  Lower (N)  │                   │
│                   └─────────────┘                   │
└─────────────────────────────────────────────────────┘
```

### Level-Shifted PWM Timing

```
Amplitude
    1 ┐     Upper Carrier (Triangular, 5 kHz)
      │    /\      /\      /\      /\
    0 ┼───┼──┼────┼──┼────┼──┼────┼──┼──  Reference (Sine, 50 Hz)
      │  \/  \/  \/  \/  \/  \/  \/  \/
   -1 ┘     Lower Carrier (Triangular, 5 kHz)

        Time ────────────────────────────→

Gate Signals:
S1 ═══╗___╗═══╗___╗═══╗___╗═══╗___╗
      
S2 ═══╗═══════╗═══════╗═══════╗═══

S3 ___╚═══════╚═══════╚═══════╚___

S4 ___╚═══╚___╚═══╚___╚═══╚___╚___

Output:
Vout:
+Vdc/2 ╗═══╗___╗═══╗___╗═══╗___╗═══
    0  ║___║═══║___║═══║___║═══║___
-Vdc/2 ╚___╚___╚___╚___╚___╚___╚___
```

## Component Specifications

### Power Switches (IGBTs)

```
IGBT Module (per device):
┌─────────────────┐
│      ┌──┐       │
│ Coll │  │ Emit  │
│   ───┤▶ ├───    │
│      └──┘       │
│       ║         │
│ Gate ═╝         │
│                 │
│ Anti-parallel   │
│ Diode included  │
└─────────────────┘

Ratings:
- Voltage: ≥ 450V (1.5× Vdc/2)
- Current: ≥ 50A (application dependent)
- Switching: 5 kHz capable
```

### Clamping Diodes

```
Diode:
   Anode  Cathode
     │      │
     ├──▶|──┤
     │      │

Ratings:
- Voltage: ≥ 450V
- Current: ≥ 50A
- Fast recovery type
```

### DC Bus Capacitors

```
Capacitor Bank:
    +Vdc
      │
    ──┤├── C1 (2200µF, 400V)
      │
     0V (Neutral)
      │
    ──┤├── C2 (2200µF, 400V)
      │
    -Vdc

Purpose:
- Energy storage
- Voltage stabilization
- Neutral point creation
```

## Measurement Points

### Voltage Measurements

1. **V_dc**: DC bus voltage (total)
2. **V_p**: Positive rail voltage (+Vdc/2)
3. **V_n**: Negative rail voltage (-Vdc/2)
4. **V_out_A, B, C**: Phase output voltages
5. **V_AB, V_BC, V_CA**: Line-to-line voltages

### Current Measurements

1. **I_dc**: DC source current
2. **I_out_A, B, C**: Phase output currents
3. **I_load**: Load current

### Recommended Scope Connections

```
Channel 1: Reference signal (Vref)
Channel 2: Phase voltage (V_out_A)
Channel 3: Load current (I_out_A)
Channel 4: Gate signal S1 or S2
```

## Switching Sequence Example

### One Complete PWM Cycle

| Time | Vref | S1 | S2 | S3 | S4 | Vout | State |
|------|------|----|----|----|----|------|-------|
| t0   | +0.6 | 1  | 1  | 0  | 0  | +Vdc/2| P     |
| t1   | +0.3 | 0  | 1  | 1  | 0  | 0     | O     |
| t2   | -0.2 | 0  | 1  | 1  | 0  | 0     | O     |
| t3   | -0.7 | 0  | 0  | 1  | 1  | -Vdc/2| N     |
| t4   | -0.4 | 0  | 1  | 1  | 0  | 0     | O     |
| t5   | +0.1 | 0  | 1  | 1  | 0  | 0     | O     |

## Safety Considerations

### Dead-Time Requirements

```
S1 ═╗_________
     ↕ td
S2 _____╗═════

Where td = dead-time (typically 1-5 µs)
```

Dead-time prevents shoot-through (both upper and lower switches ON simultaneously).

### Protection Features

1. **Over-current protection** - Limit IGBT current
2. **Over-voltage protection** - Protect against DC bus overvoltage
3. **Under-voltage lockout** - Prevent operation at low DC voltage
4. **Thermal protection** - Temperature monitoring
5. **Gate driver isolation** - Optical or magnetic isolation

## Typical Waveforms

### Expected Simulation Results

```
DC Voltage (600V):
Vdc ══════════════════════════════

Phase Voltage (3-level):
       +300V ╗═══╗═╗═══╗═╗═══╗═╗══
          0V ║═══║═╚═══╚═╚═══╚═║══
      -300V  ╚═══╚═════════════╚══

Load Current (sinusoidal):
         ╱────╲
    ────╱      ╲────╱
               ╲────╲

Gate Signal S1 (PWM):
═╗_╗_╗═╗_╗_╗═╗_╗_╗═╗_╗_╗═
```

---

**Note:** This circuit diagram documentation provides the theoretical foundation for building the Simulink model. Refer to `Simulink_Build_Guide.md` for practical implementation steps.
