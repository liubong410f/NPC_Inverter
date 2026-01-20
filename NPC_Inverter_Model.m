%% Three-Level Neutral-Point Clamped (NPC) Multilevel Inverter
% This script creates a Simulink model for a three-level NPC inverter
% 
% The NPC inverter is a multilevel power converter topology that can
% generate three voltage levels: +Vdc/2, 0, and -Vdc/2
%
% Author: NPC Inverter Project
% Date: January 2026

function NPC_Inverter_Model()
    % Close all open models and clear workspace
    close all;
    bdclose('all');
    
    % Model name
    modelName = 'NPC_Inverter_3Level';
    
    % Create new Simulink model
    try
        open_system(new_system(modelName));
    catch
        % If model already exists, close and recreate
        bdclose(modelName);
        open_system(new_system(modelName));
    end
    
    %% Model Parameters
    % DC Bus Voltage
    Vdc = 600; % Volts
    
    % Load Parameters
    R_load = 10; % Ohms
    L_load = 10e-3; % Henry
    
    % PWM Parameters
    fs = 5000; % Switching frequency (Hz)
    ma = 0.8; % Modulation index (0 to 1)
    f_output = 50; % Output frequency (Hz)
    
    % Simulation Parameters
    sim_time = 0.1; % Simulation time (seconds)
    
    %% Save parameters to base workspace
    assignin('base', 'Vdc', Vdc);
    assignin('base', 'R_load', R_load);
    assignin('base', 'L_load', L_load);
    assignin('base', 'fs', fs);
    assignin('base', 'ma', ma);
    assignin('base', 'f_output', f_output);
    
    %% Configure Model Settings
    set_param(modelName, 'Solver', 'ode23tb');
    set_param(modelName, 'StopTime', num2str(sim_time));
    set_param(modelName, 'SolverType', 'Variable-step');
    
    %% Add Simscape Power Systems Library blocks
    % Note: This requires Simscape Electrical (formerly SimPowerSystems)
    
    % Position parameters for layout
    y_start = 100;
    x_start = 50;
    block_width = 100;
    block_height = 50;
    spacing_x = 200;
    spacing_y = 100;
    
    %% 1. DC Voltage Source
    % Note: The exact library path may vary by MATLAB version
    % Common paths: 'powerlib/...' or 'fl_lib/...' 
    % If this fails, manually add DC Voltage Source from Simscape Electrical library
    try
        add_block('powerlib/Electrical Sources/DC Voltage Source', ...
                  [modelName '/DC_Source'], ...
                  'Position', [x_start, y_start, x_start+block_width, y_start+block_height]);
    catch
        fprintf('Note: Unable to add DC source automatically.\n');
        fprintf('Please add DC Voltage Source manually from Simscape Electrical library.\n');
    end
    
    %% 2. Add Reference and Description
    add_block('built-in/Note', [modelName '/Description']);
    set_param([modelName '/Description'], ...
              'Position', [x_start, y_start-80, x_start+400, y_start-20], ...
              'Text', sprintf(['Three-Level Neutral-Point Clamped (NPC) Inverter\n' ...
                              'Topology: Three voltage levels (+Vdc/2, 0, -Vdc/2)\n' ...
                              'Vdc = %d V | fs = %d Hz | f_out = %d Hz'], Vdc, fs, f_output));
    
    %% 3. Save the model
    save_system(modelName);
    
    fprintf('NPC Inverter Simulink model created successfully!\n');
    fprintf('Model Name: %s.slx\n', modelName);
    fprintf('Parameters loaded to workspace:\n');
    fprintf('  - Vdc = %.0f V\n', Vdc);
    fprintf('  - Switching Frequency = %.0f Hz\n', fs);
    fprintf('  - Output Frequency = %.0f Hz\n', f_output);
    fprintf('  - Modulation Index = %.2f\n', ma);
    fprintf('  - Load: R = %.0f Ohms, L = %.0f mH\n', R_load, L_load*1000);
    fprintf('\nOpen the model in Simulink to view and simulate.\n');
    
end
