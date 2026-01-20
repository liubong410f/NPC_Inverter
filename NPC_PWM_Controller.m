function [S1, S2, S3, S4] = NPC_PWM_Controller(Vref, t, Vdc, fs, phase_offset)
% NPC_PWM_Controller - Generates gate signals for NPC inverter switches
%
% This function implements Level-Shifted Carrier-Based PWM for a three-level
% NPC inverter. It generates switching signals for the four switches in one
% phase leg.
%
% Inputs:
%   Vref         - Reference voltage signal (normalized, -1 to +1)
%   t            - Current time (seconds)
%   Vdc          - DC bus voltage (Volts)
%   fs           - Switching frequency (Hz)
%   phase_offset - Phase offset in degrees (0, 120, or 240 for three-phase)
%
% Outputs:
%   S1 - Gate signal for upper outer switch
%   S2 - Gate signal for upper inner switch
%   S3 - Gate signal for lower inner switch
%   S4 - Gate signal for lower outer switch
%
% Switching States:
%   P state (Vout = +Vdc/2): S1=1, S2=1, S3=0, S4=0
%   O state (Vout = 0):      S1=0, S2=1, S3=1, S4=0
%   N state (Vout = -Vdc/2): S1=0, S2=0, S3=1, S4=1

    % Apply phase offset to reference
    Vref_shifted = Vref * cosd(phase_offset) - sind(phase_offset);
    
    % Generate two carrier signals (triangular waves)
    % Level-shifted carrier approach
    carrier_period = 1/fs;
    t_normalized = mod(t, carrier_period) / carrier_period;
    
    % Triangular wave generation
    if t_normalized < 0.5
        carrier = 4 * t_normalized - 1; % Rising edge: -1 to +1
    else
        carrier = 3 - 4 * t_normalized; % Falling edge: +1 to -1
    end
    
    % Upper carrier (for comparison with positive half)
    carrier_upper = carrier * 0.5 + 0.5; % Scale to 0 to 1
    
    % Lower carrier (for comparison with negative half)
    carrier_lower = carrier * 0.5 - 0.5; % Scale to -1 to 0
    
    % Normalize reference to -1 to +1 range
    Vref_norm = Vref_shifted;
    
    % Generate switching signals using comparators
    % Upper half comparison (for S1 and S2)
    if Vref_norm > 0
        if Vref_norm > carrier_upper
            % P state
            S1 = 1;
            S2 = 1;
            S3 = 0;
            S4 = 0;
        else
            % O state
            S1 = 0;
            S2 = 1;
            S3 = 1;
            S4 = 0;
        end
    else
        % Lower half comparison (for S3 and S4)
        if Vref_norm < carrier_lower
            % N state
            S1 = 0;
            S2 = 0;
            S3 = 1;
            S4 = 1;
        else
            % O state
            S1 = 0;
            S2 = 1;
            S3 = 1;
            S4 = 0;
        end
    end
    
end

%% Alternative PWM Generation Function
% This can be used in Simulink with MATLAB Function block

function gate_signals = Generate_NPC_Gates(Vref, fs, f0, ma, t)
% Generate_NPC_Gates - Complete PWM gate signal generation
%
% Inputs:
%   Vref - Reference signal amplitude
%   fs   - Switching frequency (Hz)
%   f0   - Output fundamental frequency (Hz)
%   ma   - Modulation index (0 to 1)
%   t    - Time vector
%
% Output:
%   gate_signals - Matrix of gate signals [S1; S2; S3; S4]

    % Generate reference sinusoidal signal
    v_ref = ma * sin(2 * pi * f0 * t);
    
    % Generate carrier signals
    carrier_period = 1/fs;
    t_carr = mod(t, carrier_period) / carrier_period;
    
    % Triangular carrier
    carrier = zeros(size(t));
    for i = 1:length(t)
        if t_carr(i) < 0.5
            carrier(i) = 4 * t_carr(i) - 1;
        else
            carrier(i) = 3 - 4 * t_carr(i);
        end
    end
    
    % Initialize gate signals
    S1 = zeros(size(t));
    S2 = zeros(size(t));
    S3 = zeros(size(t));
    S4 = zeros(size(t));
    
    % Generate switching signals
    for i = 1:length(t)
        carrier_upper = carrier(i) * 0.5 + 0.5;
        carrier_lower = carrier(i) * 0.5 - 0.5;
        
        if v_ref(i) > 0
            if v_ref(i) > carrier_upper
                % P state
                S1(i) = 1; S2(i) = 1; S3(i) = 0; S4(i) = 0;
            else
                % O state
                S1(i) = 0; S2(i) = 1; S3(i) = 1; S4(i) = 0;
            end
        else
            if v_ref(i) < carrier_lower
                % N state
                S1(i) = 0; S2(i) = 0; S3(i) = 1; S4(i) = 1;
            else
                % O state
                S1(i) = 0; S2(i) = 1; S3(i) = 1; S4(i) = 0;
            end
        end
    end
    
    gate_signals = [S1; S2; S3; S4];
end

%% Test Function
function test_PWM_controller()
% test_PWM_controller - Test the PWM generation functions
    
    % Parameters
    fs = 5000;      % 5 kHz switching frequency
    f0 = 50;        % 50 Hz fundamental
    ma = 0.8;       % Modulation index
    Vdc = 600;      % DC voltage
    
    % Time vector
    t = 0:1e-6:0.04; % 40 ms, two cycles at 50 Hz
    
    % Generate reference
    v_ref = ma * sin(2*pi*f0*t);
    
    % Generate gates
    S1 = zeros(size(t));
    S2 = zeros(size(t));
    S3 = zeros(size(t));
    S4 = zeros(size(t));
    
    for i = 1:length(t)
        [S1(i), S2(i), S3(i), S4(i)] = NPC_PWM_Controller(v_ref(i), t(i), Vdc, fs, 0);
    end
    
    % Calculate output voltage
    V_out = zeros(size(t));
    for i = 1:length(t)
        if S1(i) && S2(i)
            V_out(i) = Vdc/2;
        elseif S3(i) && S4(i)
            V_out(i) = -Vdc/2;
        else
            V_out(i) = 0;
        end
    end
    
    % Plot results
    figure('Name', 'NPC Inverter PWM Signals');
    
    subplot(5,1,1);
    plot(t*1000, v_ref);
    title('Reference Signal');
    ylabel('Amplitude');
    grid on;
    
    subplot(5,1,2);
    plot(t*1000, S1);
    title('S1 (Upper Outer Switch)');
    ylabel('State');
    ylim([-0.2 1.2]);
    grid on;
    
    subplot(5,1,3);
    plot(t*1000, S2);
    title('S2 (Upper Inner Switch)');
    ylabel('State');
    ylim([-0.2 1.2]);
    grid on;
    
    subplot(5,1,4);
    plot(t*1000, S3);
    title('S3 (Lower Inner Switch)');
    ylabel('State');
    ylim([-0.2 1.2]);
    grid on;
    
    subplot(5,1,5);
    plot(t*1000, V_out);
    title('Output Voltage (Three Levels)');
    xlabel('Time (ms)');
    ylabel('Voltage (V)');
    grid on;
    
    fprintf('PWM Controller Test Completed\n');
    fprintf('Expected levels: +%.0f V, 0 V, -%.0f V\n', Vdc/2, Vdc/2);
end
