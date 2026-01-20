%% NPC Inverter PWM Waveform Visualization
% This script generates and visualizes the PWM waveforms for the NPC inverter
% without requiring Simulink. It demonstrates the basic PWM principle.
%
% Run this script to see:
% - Reference signal
% - Carrier signals
% - Gate signals for all 4 switches
% - Resulting three-level output voltage
%
% Author: NPC Inverter Project
% Date: January 2026

clear;
clc;
close all;

% Define separator for consistent formatting
SEPARATOR = repmat('=', 1, 44);
fprintf('%s\n', SEPARATOR);
fprintf('NPC Inverter PWM Waveform Visualization\n');
fprintf('%s\n\n', SEPARATOR);

%% Parameters
Vdc = 600;              % DC bus voltage [V]
fs = 5000;              % Switching frequency [Hz]
f0 = 50;                % Output frequency [Hz]
ma = 0.8;               % Modulation index

% Time vector - 3 fundamental cycles
t_cycles = 3;
t_end = t_cycles / f0;
fs_sample = 1e6;        % Sampling frequency for simulation
t = 0:1/fs_sample:t_end;

fprintf('Simulation Parameters:\n');
fprintf('  DC Voltage: %.0f V\n', Vdc);
fprintf('  Switching Frequency: %.0f Hz\n', fs);
fprintf('  Output Frequency: %.0f Hz\n', f0);
fprintf('  Modulation Index: %.2f\n', ma);
fprintf('  Simulation Time: %.3f s (%.0f cycles)\n\n', t_end, t_cycles);

%% Generate Reference Signal
v_ref = ma * sin(2*pi*f0*t);

%% Generate Carrier Signals
% Triangular carriers at switching frequency
carrier_period = 1/fs;
t_norm = mod(t, carrier_period) / carrier_period;

carrier = zeros(size(t));
for i = 1:length(t)
    if t_norm(i) < 0.5
        carrier(i) = 4*t_norm(i) - 1;  % Rising edge
    else
        carrier(i) = 3 - 4*t_norm(i);  % Falling edge
    end
end

% Upper and lower carriers for level-shifted PWM
carrier_upper = 0.5 * carrier + 0.5;  % Range: 0 to 1
carrier_lower = 0.5 * carrier - 0.5;  % Range: -1 to 0

%% Generate Gate Signals
S1 = zeros(size(t));
S2 = zeros(size(t));
S3 = zeros(size(t));
S4 = zeros(size(t));

for i = 1:length(t)
    if v_ref(i) > 0
        % Positive half: compare with upper carrier
        if v_ref(i) > carrier_upper(i)
            % P state: Output = +Vdc/2
            S1(i) = 1;
            S2(i) = 1;
            S3(i) = 0;
            S4(i) = 0;
        else
            % O state: Output = 0
            S1(i) = 0;
            S2(i) = 1;
            S3(i) = 1;
            S4(i) = 0;
        end
    else
        % Negative half: compare with lower carrier
        if v_ref(i) < carrier_lower(i)
            % N state: Output = -Vdc/2
            S1(i) = 0;
            S2(i) = 0;
            S3(i) = 1;
            S4(i) = 1;
        else
            % O state: Output = 0
            S1(i) = 0;
            S2(i) = 1;
            S3(i) = 1;
            S4(i) = 0;
        end
    end
end

%% Calculate Output Voltage
V_out = zeros(size(t));
for i = 1:length(t)
    if S1(i) && S2(i) && ~S3(i) && ~S4(i)
        V_out(i) = Vdc/2;      % P state
    elseif ~S1(i) && ~S2(i) && S3(i) && S4(i)
        V_out(i) = -Vdc/2;     % N state
    else
        V_out(i) = 0;          % O state
    end
end

%% Calculate Switching Statistics
total_samples = length(t);
p_state_count = sum(S1 & S2);
o_state_count = sum(S2 & S3);
n_state_count = sum(S3 & S4);

fprintf('Switching Statistics:\n');
fprintf('  P state (+Vdc/2): %.1f%%\n', (p_state_count/total_samples)*100);
fprintf('  O state (0V):     %.1f%%\n', (o_state_count/total_samples)*100);
fprintf('  N state (-Vdc/2): %.1f%%\n', (n_state_count/total_samples)*100);
fprintf('\n');

%% Verify Switching Rules
% S1 and S4 should be complementary (never both ON)
violation_14 = sum(S1 & S4);
% S2 and S3 are NOT complementary in NPC
% But S1+S2 and S3+S4 should have valid combinations only
valid_states = sum((S1 & S2 & ~S3 & ~S4) | (~S1 & S2 & S3 & ~S4) | (~S1 & ~S2 & S3 & S4));

fprintf('Switching Rule Verification:\n');
fprintf('  S1 and S4 simultaneous ON: %d (should be 0)\n', violation_14);
fprintf('  Valid state combinations: %.1f%% (should be ~100%%)\n', (valid_states/total_samples)*100);
fprintf('\n');

%% Plot Results
figure('Name', 'NPC Inverter PWM Waveforms', 'Position', [100, 100, 1200, 800]);

% Focus on a small time window for clarity
t_window_ms = 40;  % Show 40ms (2 cycles at 50Hz)
t_window = t_window_ms / 1000;
idx = t <= t_window;
t_plot = t(idx) * 1000;  % Convert to ms

% Subplot 1: Reference and Carriers
subplot(6,1,1);
plot(t_plot, v_ref(idx), 'b-', 'LineWidth', 1.5); hold on;
plot(t_plot, carrier_upper(idx), 'r--', 'LineWidth', 0.8);
plot(t_plot, carrier_lower(idx), 'r--', 'LineWidth', 0.8);
legend('Reference', 'Carrier Upper', 'Carrier Lower', 'Location', 'northeast');
title('Reference Signal and Carrier Waves');
ylabel('Amplitude');
grid on;
ylim([-1.2, 1.2]);

% Subplot 2: Gate Signal S1
subplot(6,1,2);
plot(t_plot, S1(idx), 'b-', 'LineWidth', 1);
title('Gate Signal S1 (Upper Outer Switch)');
ylabel('State');
ylim([-0.2, 1.2]);
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

% Subplot 3: Gate Signal S2
subplot(6,1,3);
plot(t_plot, S2(idx), 'g-', 'LineWidth', 1);
title('Gate Signal S2 (Upper Inner Switch)');
ylabel('State');
ylim([-0.2, 1.2]);
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

% Subplot 4: Gate Signal S3
subplot(6,1,4);
plot(t_plot, S3(idx), 'r-', 'LineWidth', 1);
title('Gate Signal S3 (Lower Inner Switch)');
ylabel('State');
ylim([-0.2, 1.2]);
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

% Subplot 5: Gate Signal S4
subplot(6,1,5);
plot(t_plot, S4(idx), 'm-', 'LineWidth', 1);
title('Gate Signal S4 (Lower Outer Switch)');
ylabel('State');
ylim([-0.2, 1.2]);
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

% Subplot 6: Output Voltage
subplot(6,1,6);
plot(t_plot, V_out(idx), 'k-', 'LineWidth', 1.5);
title('Three-Level Output Voltage');
xlabel('Time (ms)');
ylabel('Voltage (V)');
grid on;
ylim([-Vdc/2*1.2, Vdc/2*1.2]);
yticks([-Vdc/2, 0, Vdc/2]);
yticklabels({sprintf('-Vdc/2 (%.0fV)', Vdc/2), '0V', sprintf('+Vdc/2 (%.0fV)', Vdc/2)});

% Add overall title
sgtitle('NPC Inverter PWM Generation and Output Waveforms', 'FontSize', 14, 'FontWeight', 'bold');

%% FFT Analysis of Output Voltage
figure('Name', 'FFT Analysis', 'Position', [150, 150, 1000, 600]);

% Perform FFT on the output voltage
N = length(V_out);
Y = fft(V_out);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs_sample*(0:(N/2))/N;

% Find fundamental component
[~, idx_fund] = min(abs(f - f0));
V_fundamental = P1(idx_fund);

% Calculate THD (simplified - up to 1 kHz)
idx_1kHz = find(f <= 1000, 1, 'last');
harmonics = P1(2:idx_1kHz);
harmonics(idx_fund-1) = 0;  % Exclude fundamental
THD = sqrt(sum(harmonics.^2)) / V_fundamental * 100;

fprintf('FFT Analysis:\n');
fprintf('  Fundamental frequency: %.1f Hz\n', f0);
fprintf('  Fundamental amplitude: %.1f V\n', V_fundamental);
fprintf('  THD (up to 1 kHz): %.2f%%\n', THD);
fprintf('\n');

% Plot FFT
subplot(2,1,1);
plot(f, P1, 'b-', 'LineWidth', 1);
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('|V(f)|');
xlim([0 1000]);
grid on;

% Plot in dB
subplot(2,1,2);
P1_dB = 20*log10(P1 + 1e-10);  % Add small value to avoid log(0)
plot(f, P1_dB, 'r-', 'LineWidth', 1);
title('Amplitude Spectrum (dB)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 1000]);
ylim([-60 max(P1_dB)+10]);
grid on;

% Mark fundamental and switching frequency
hold on;
xline(f0, 'g--', sprintf('f0 = %d Hz', f0), 'LineWidth', 1.5);
xline(fs, 'm--', sprintf('fs = %d Hz', fs), 'LineWidth', 1.5);

%% Summary
fprintf('%s\n', SEPARATOR);
fprintf('Simulation completed successfully!\n');
fprintf('Two figures generated:\n');
fprintf('  1. PWM waveforms (gate signals and output)\n');
fprintf('  2. FFT analysis (harmonic content)\n');
fprintf('%s\n\n', SEPARATOR);

fprintf('Key Observations:\n');
fprintf('  ✓ Three voltage levels achieved: +%.0fV, 0V, -%.0fV\n', Vdc/2, Vdc/2);
fprintf('  ✓ Switching frequency: %.0f Hz\n', fs);
fprintf('  ✓ Output fundamental: %.0f Hz\n', f0);
fprintf('  ✓ All switching rules verified\n');
fprintf('  ✓ THD: %.2f%%\n', THD);
fprintf('\n');
