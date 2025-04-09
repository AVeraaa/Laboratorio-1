fc = 1000;
A = 1;
fs = 8000;
d = 0.5;
sample_rate = 100000;
t_final = 0.01;

% parámetros para cuantificación PCM
n_bits = 4;
L = 2^n_bits;

delta = 2/(L-1);
niveles = linspace(-1, 1, L);

t = 0:1/sample_rate:t_final;
m_t = A * sin(2*pi*fc*t);

Ts = 1/fs;
num_samples = floor(t_final * fs);

t_pulses = [];
instant_pulses = [];
instant_quant_pulses = [];

instant_errors = zeros(num_samples, 1);
t_samples = zeros(num_samples, 1);

for i = 1:num_samples
    t_start = (i-1)*Ts;
    t_end = t_start + d*Ts;

    if t_end > t_final
        t_end = t_final;
    end

    idx_start = find(t >= t_start, 1);
    idx_end = find(t >= t_end, 1);
    if isempty(idx_end)
        idx_end = length(t);
    end

    muestra = m_t(idx_start);
    [~, idx] = min(abs(muestra - niveles));
    muestra_cuant = niveles(idx);

    instant_errors(i) = muestra - muestra_cuant;
    t_samples(i) = t_start;

    t_pulse_inst = [t_start, t_start];
    amp_pulse_inst = [0, muestra];
    amp_pulse_quant = [0, muestra_cuant];

    t_pulses = [t_pulses; {t_pulse_inst}];
    instant_pulses = [instant_pulses; {amp_pulse_inst}];
    instant_quant_pulses = [instant_quant_pulses; {amp_pulse_quant}];
end


figure('Position', [100, 100, 1000, 400]);
plot(t, m_t, 'b-', 'LineWidth', 2, 'DisplayName', 'Señal Original');
hold on;

for i = 1:num_samples
    line(t_pulses{i}, instant_pulses{i},...
        'Color', [1 0 0], 'LineWidth', 1.2,...
        'DisplayName', 'PAM Instantáneo');
end

% señal PAM instantánea cuantificada
for i = 1:num_samples
    line(t_pulses{i}, instant_quant_pulses{i},...
        'Color', [0 0.6 0], 'LineWidth', 1.2, 'LineStyle', '--',...
        'DisplayName', 'PAM Cuantificado');
end

title('Comparación: Señal Original vs PAM Instantáneo vs PAM Cuantificado');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend({'Señal Original', 'PAM Instantáneo', 'PAM Cuantificado'}, 'Location', 'best');
grid on;
xlim([0 0.005]);
ylim([-1.2 1.2]);
hold off;

% === Figura 2: Error de Cuantificación ===
figure('Position', [100, 100, 1000, 400]);
stem(t_samples, instant_errors, 'filled', 'LineWidth', 1.5, 'MarkerSize', 5);
title('Error de Cuantificación por Muestra');
xlabel('Tiempo (s)');
ylabel('Error');
grid on;
xlim([0 0.005]);
ylim([-delta/2, delta/2]);

for i = 1:num_samples
    text(t_samples(i), instant_errors(i), ...
        sprintf('%.3f', instant_errors(i)), ...
        'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 8, 'Color', 'k');
end


disp('Errores de cuantificación por muestra:');
disp(array2table([t_samples(:), instant_errors], ...
    'VariableNames', {'Tiempo_s', 'Error'}));
