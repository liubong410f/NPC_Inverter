%% NPC Inverter Simulation Parameters
% This script defines all parameters needed for the NPC inverter simulation
% Load this script before running the Simulink model
%
% Usage: Run this script in MATLAB command window before simulation
%        >> NPC_Parameters
%        >> sim('NPC_Inverter_3Level')

%% Clear workspace and command window
clear;
clc;

fprintf('========================================\n');
fprintf('NPC Inverter Simulation Parameters\n');
fprintf('========================================\n\n');

%% DC Bus Parameters
Vdc = 600;              % DC bus voltage [V]
C1 = 2200e-6;           % Upper DC capacitor [F]
C2 = 2200e-6;           % Lower DC capacitor [F]
Vdc_half = Vdc/2;       % Half DC voltage (neutral point) [V]

fprintf('DC Bus Configuration:\n');
fprintf('  Total DC Voltage (Vdc) = %.0f V\n', Vdc);
fprintf('  Capacitor C1 = %.0f uF\n', C1*1e6);
fprintf('  Capacitor C2 = %.0f uF\n', C2*1e6);
fprintf('  Neutral Point Voltage = %.0f V\n\n', Vdc_half);

%% IGBT Parameters
Ron_IGBT = 1e-3;        % IGBT on-state resistance [Ohm]
Vf_IGBT = 1.0;          % IGBT forward voltage drop [V]
Rs_IGBT = 1e5;          % IGBT snubber resistance [Ohm]
Cs_IGBT = 1e-9;         % IGBT snubber capacitance [F]

fprintf('IGBT Switch Parameters:\n');
fprintf('  On-state resistance = %.1f mOhm\n', Ron_IGBT*1e3);
fprintf('  Forward voltage drop = %.1f V\n', Vf_IGBT);
fprintf('  Snubber: Rs = %.0f kOhm, Cs = %.1f nF\n\n', Rs_IGBT/1e3, Cs_IGBT*1e9);

%% Diode Parameters (Clamping Diodes)
Ron_Diode = 1e-3;       % Diode on-state resistance [Ohm]
Vf_Diode = 0.8;         % Diode forward voltage drop [V]
Rs_Diode = 1e5;         % Diode snubber resistance [Ohm]
Cs_Diode = 250e-9;      % Diode snubber capacitance [F]

fprintf('Clamping Diode Parameters:\n');
fprintf('  On-state resistance = %.1f mOhm\n', Ron_Diode*1e3);
fprintf('  Forward voltage drop = %.1f V\n', Vf_Diode);
fprintf('  Snubber: Rs = %.0f kOhm, Cs = %.0f nF\n\n', Rs_Diode/1e3, Cs_Diode*1e9);

%% PWM Control Parameters
fs = 5000;              % Switching frequency [Hz]
Ts = 1/fs;              % Switching period [s]
ma = 0.8;               % Modulation index (0 < ma <= 1)
f_output = 50;          % Output fundamental frequency [Hz]
T_output = 1/f_output;  % Output period [s]

fprintf('PWM Control Parameters:\n');
fprintf('  Switching frequency (fs) = %.0f Hz\n', fs);
fprintf('  Switching period (Ts) = %.2f us\n', Ts*1e6);
fprintf('  Modulation index (ma) = %.2f\n', ma);
fprintf('  Output frequency (f0) = %.0f Hz\n', f_output);
fprintf('  Output period = %.0f ms\n\n', T_output*1e3);

%% Load Parameters
% Single-phase RL load
R_load = 10;            % Load resistance [Ohm]
L_load = 10e-3;         % Load inductance [H]
X_load = 2*pi*f_output*L_load;  % Inductive reactance [Ohm]
Z_load = sqrt(R_load^2 + X_load^2);  % Load impedance [Ohm]
PF_load = R_load/Z_load;  % Power factor

fprintf('Load Parameters (per phase):\n');
fprintf('  Resistance (R) = %.0f Ohm\n', R_load);
fprintf('  Inductance (L) = %.0f mH\n', L_load*1e3);
fprintf('  Inductive Reactance (XL) = %.2f Ohm @ %.0f Hz\n', X_load, f_output);
fprintf('  Impedance (Z) = %.2f Ohm\n', Z_load);
fprintf('  Power Factor = %.3f lagging\n\n', PF_load);

%% Three-Phase Load Parameters (if needed)
% For three-phase configuration
R_load_3ph = R_load;    % Per-phase resistance [Ohm]
L_load_3ph = L_load;    % Per-phase inductance [H]

% Phase angles for three-phase system
phase_A = 0;            % Phase A angle [degrees]
phase_B = -120;         % Phase B angle [degrees]
phase_C = -240;         % Phase C angle [degrees] (or +120)

%% Expected Output Calculations
Vout_fund_max = ma * Vdc_half;  % Maximum fundamental output voltage [V]
Vout_fund_rms = Vout_fund_max / sqrt(2);  % RMS fundamental voltage [V]
Iout_fund_rms = Vout_fund_rms / Z_load;   % RMS fundamental current [A]
Pout_fund = Vout_fund_rms * Iout_fund_rms * PF_load;  % Fundamental output power [W]

fprintf('Expected Output (Single Phase):\n');
fprintf('  Peak fundamental voltage = %.1f V\n', Vout_fund_max);
fprintf('  RMS fundamental voltage = %.1f V\n', Vout_fund_rms);
fprintf('  RMS fundamental current = %.2f A\n', Iout_fund_rms);
fprintf('  Output power = %.1f W\n\n', Pout_fund);

%% Simulation Parameters
sim_time = 0.1;         % Simulation time [s]
sim_cycles = sim_time * f_output;  % Number of output cycles

fprintf('Simulation Settings:\n');
fprintf('  Simulation time = %.3f s\n', sim_time);
fprintf('  Number of output cycles = %.1f\n', sim_cycles);
fprintf('  Solver: Variable-step (ode23tb recommended)\n\n');

%% Carrier Signals Parameters
% For level-shifted PWM
carrier1_amp = 0.5;     % Upper carrier amplitude
carrier1_offset = 0.5;  % Upper carrier offset
carrier2_amp = 0.5;     % Lower carrier amplitude
carrier2_offset = -0.5; % Lower carrier offset

%% Save all parameters to MAT file (optional)
% You can save parameters to a file for later use
% Uncomment the following line if you want to save parameters
% Note: .gitignore allows NPC_Parameters.mat specifically
% save('NPC_Parameters.mat');

fprintf('========================================\n');
fprintf('All parameters loaded successfully!\n');
fprintf('Ready to use in Simulink model.\n');
fprintf('========================================\n\n');

%% Display voltage levels
fprintf('Output Voltage Levels:\n');
fprintf('  Level +1: +%.0f V (S1=ON, S2=ON, S3=OFF, S4=OFF)\n', Vdc_half);
fprintf('  Level  0:    0 V (S1=OFF, S2=ON, S3=ON, S4=OFF)\n');
fprintf('  Level -1: -%.0f V (S1=OFF, S2=OFF, S3=ON, S4=ON)\n\n', Vdc_half);

%% Component Ratings Recommendations
fprintf('Recommended Component Ratings:\n');
fprintf('  IGBT Voltage Rating: >= %.0f V\n', Vdc_half * 1.5);
fprintf('  IGBT Current Rating: >= %.0f A\n', Iout_fund_rms * 2);
fprintf('  Diode Voltage Rating: >= %.0f V\n', Vdc_half * 1.5);
fprintf('  Diode Current Rating: >= %.0f A\n', Iout_fund_rms * 2);
fprintf('  Capacitor Voltage Rating: >= %.0f V\n', Vdc_half * 1.2);
fprintf('========================================\n\n');

fprintf('You can now run the Simulink model:\n');
fprintf('  >> sim(''NPC_Inverter_3Level'')\n\n');
fprintf('Or open the model:\n');
fprintf('  >> open_system(''NPC_Inverter_3Level'')\n\n');
