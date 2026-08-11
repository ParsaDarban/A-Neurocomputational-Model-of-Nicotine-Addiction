clear; clc; close all; 

[addiction_established, trial_count, delta_history, ...
 final_Wr_pm, final_Wc_pm, final_Wv] = runNicotineAddictionModel();

figure;
if addiction_established
    plot(1:length(delta_history), delta_history, 'b');
    title('Reinforcement error signal when addiction IS set up');
    xlabel('Trial');
    ylabel('\delta(k)');
    grid on;
else
    plot(1:length(delta_history), delta_history, 'r');
    title('Reinforcement error signal when addiction is NOT set up');
    xlabel('Trial');
    ylabel('\delta(k)');
    grid on;
end
%%

function [addiction_established, trial_count, delta_history, ...
          final_Wr_pm, final_Wc_pm, final_Wv] = runNicotineAddictionModel()

LAMBDA = 0.5;
BETA = 0.03;
A_TANH = 3; % Parameter 'a' for tanh function in f()
MU_DA = 0.1; % Learning rate in DA subsystem
ETA_C = 0.1; % Learning rate for Wc_pm
ETA_V = 0.1; % Learning rate for Wv
ETA_R = 0.1; % Learning rate for Wr_pm
BASE_VALUE = 0.2; % Term 'base' for V(k)

THETA_DA = 0.01; % Threshold for tonic DA
THETA_UDA = 0.1 * THETA_DA;
THETA_PM = 0; % Threshold for p_m

% Appendix 1 Parameters
THETA_N = 0.6;
THETA_S = 0.7;
THETA_C = 0.7;
BETA_S = 0.4;
BETA_C = 0.4;
MU_NSC = 0.1; 
TAU_N = 0.25;
TAU_S = 1.0;
TAU_C = 2.0;

SUCCESSIVE_SMOKING_THRESHOLD = 20;
MAX_TRIALS = 1000;

% Weights
current_n = 0.1;
current_s = 0.1;
current_c = 0.1;

current_u_da = 0;

p_pm_current = rand(2,1) * 0.01;
m_pm_current = rand(2,1) * 0.01;
r_pm_current = rand(2,1) * 0.01;
n_pm_current = rand(2,1) * 0.01;
d_pm_current = rand(2,1) * 0.01;

p_m_current = rand(2,1) * 0.01;
m_m_current = rand(2,1) * 0.01;
r_m_current = rand(2,1) * 0.01;
n_m_current = rand(2,1) * 0.01;
l_m_current = rand(2,1) * 0.01;


current_Wc_pm = rand(2, 2) * 0.1;
current_Wv = rand(1, 2) * 0.1;

current_Wr_pm = [1.0; 1.0];

Wd_pm = [0.5, 0.5; 0.5, 0.5]; 
Wd_m = [0.5, 0.5; 0.5, 0.5]; 
Wrm = [0.5, 0.5; 0.5, 0.5];

NOISE_SCALE = 1e-4;

ACTION_SMOKE = [1; 0];
ACTION_NOT_SMOKE = [0; 1];
ACTION_INDECISIVE = [1; 1];

delta_history = []; 
smoking_decision_count = 0;
addiction_established = false;
trial_count = 0; 
ri = 0.01; 

current_I = ACTION_NOT_SMOKE;

prev_V = (current_Wv + BASE_VALUE) * current_I;

persistent u_da_history;
if isempty(u_da_history)
    u_da_history = [];
end

while ~addiction_established && trial_count < MAX_TRIALS

    trial_count = trial_count + 1;

    if trial_count < 500
        nicotine_level = 0.3;
    else
        nicotine_level = 0;
    end

    alpha_n = alpha_n_activation(nicotine_level, THETA_N);
    alpha_s = alpha_s_activation(current_n, THETA_S);
    alpha_c = alpha_c_activation(current_s, THETA_C);
    beta_n = beta_n_activation(current_c, THETA_N);

    n_next = current_n + MU_NSC * (1/TAU_N) * (-beta_n * current_c + alpha_n * (1 - current_n * current_c));
    s_next = current_s + MU_NSC * (1/TAU_S) * (-BETA_S * current_s + alpha_s * (1 - current_s));
    c_next = current_c + MU_NSC * (1/TAU_C) * (-BETA_C * current_c + alpha_c * (1 - current_c));

    current_n = n_next;
    current_s = s_next;
    current_c = c_next;

    if nicotine_level > 0
        Ni = current_n * current_s;
    else
        Ni = 0; 
    end


    s_da_val = s_DA_activation(ri, Ni, THETA_DA);
    u_da_next = current_u_da + MU_DA * (-current_u_da + s_da_val);
    current_u_da = u_da_next;


    noise_signal = rand(2,1) * NOISE_SCALE;

    p_pm_next = f_activation(LAMBDA * p_pm_current + m_pm_current + current_Wc_pm * current_I, A_TANH);
    m_pm_next = f_activation(p_pm_current - d_pm_current, A_TANH);
    r_pm_next = current_Wr_pm .* f_activation(p_pm_current, A_TANH); % Element-wise multiplication, consistent with Wr_pm being 2x1.

    n_pm_next = f_activation(p_pm_current, A_TANH);
    d_pm_next = f_activation(Wd_pm * n_pm_current - r_pm_current, A_TANH);

    p_m_next = f_activation(LAMBDA * p_m_current + m_m_current + BETA * p_pm_current + noise_signal, A_TANH);
    m_m_next = f_activation(p_m_current - l_m_current, A_TANH);
    r_m_next = Wrm * f_activation(p_m_current, A_TANH);
    n_m_next = f_activation(p_m_current, A_TANH);
    l_m_next = f_activation(Wd_m * n_m_current - r_m_current, A_TANH);

    p_pm_current = p_pm_next; m_pm_current = m_pm_next; r_pm_current = r_pm_next;
    n_pm_current = n_pm_next; d_pm_current = d_pm_next;

    p_m_current = p_m_next; m_m_current = m_m_next; r_m_current = r_m_next;
    n_m_current = n_m_next; l_m_current = l_m_next;

    [~, selected_action_idx] = max(p_m_current);
    if selected_action_idx == 1 
        current_selected_action = ACTION_SMOKE;
    else 
        current_selected_action = ACTION_NOT_SMOKE;
    end


    if isequal(current_selected_action, ACTION_SMOKE)
        ri = min(1.0, ri * 2);
        smoking_decision_count = smoking_decision_count + 1;
    else
        smoking_decision_count = 0; 
    end

    current_V = (current_Wv + BASE_VALUE) * current_I;


    delta = ri + MU_NSC * current_V - prev_V;
    prev_V = current_V; 

    delta_history = [delta_history, delta];

 
    current_Wc_pm = current_Wc_pm + ETA_C * delta * (p_m_current * current_I');
    current_Wc_pm = current_Wc_pm ./ sum(abs(current_Wc_pm), 'all');

    if ri > 0.5
        u_da_history = [u_da_history, current_u_da];
        if length(u_da_history) > 10
            u_da_history = u_da_history(end-9:end); 
        end
        u_da_bar = mean(u_da_history); 

        term1_scalar = (u_da_bar + Ni) * (current_u_da - THETA_UDA);
        term2_vector = (p_m_current - THETA_PM);

        current_Wr_pm = current_Wr_pm + ETA_R * term1_scalar .* term2_vector .* f_activation(p_m_current, A_TANH) .* r_m_current;
        current_Wr_pm = current_Wr_pm ./ sum(abs(current_Wr_pm), 'all');
    end
    current_Wv = current_Wv + ETA_V * delta * current_I';

    current_I = current_selected_action;

    if smoking_decision_count >= SUCCESSIVE_SMOKING_THRESHOLD
        addiction_established = true;
        fprintf('Addiction established! Number of trials: %d\n', trial_count);
    end

end


if ~addiction_established
    fprintf('Addiction NOT established. Max trials (%d) reached.\n', MAX_TRIALS);
end

fprintf('Simulation finished.\n');
final_Wr_pm = current_Wr_pm;
final_Wc_pm = current_Wc_pm;
final_Wv = current_Wv;

fprintf('Final Wr_pm: %s\n', mat2str(final_Wr_pm'));
fprintf('Final Wc_pm: \n'); disp(final_Wc_pm);
fprintf('Final Wv: %s\n', mat2str(final_Wv));

end 

function output = f_activation(x, a_val)
    output = 0.5 * (1 + tanh(a_val * (x - 0.45)));
end

function output = s_DA_activation(ri, Ni, theta_da_val)
    output = 0.5 * (1 + tanh(Ni * ri - theta_da_val));
end

function output = alpha_n_activation(nicotine_level, theta_n_val)
    output = 0.5 * (1 + tanh(nicotine_level - theta_n_val));
end

function output = alpha_s_activation(n_val, theta_s_val)
    output = 0.5 * (1 + tanh(n_val - theta_s_val));
end

function output = alpha_c_activation(s_val, theta_c_val)
    output = 0.5 * (1 + tanh(s_val - theta_c_val));
end

function output = beta_n_activation(c_val, theta_n_val)
    output = 0.5 * (1 + tanh(c_val - theta_n_val));
end