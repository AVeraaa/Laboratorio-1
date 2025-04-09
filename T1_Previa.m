fc = 1000;
A = 1;
fs = 8000;
d = 0.5;
sample_rate = 100000;
t_final = 0.01;

t = 0:1/sample_rate:t_final;
m_t = A * sin(2*pi*fc*t);

Ts = 1/fs;
num_samples = floor(t_final * fs);

t_pulses = [];
natural_pulses = [];
instant_pulses = [];

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
    
    sample_value = m_t(idx_start);
    
    t_pulse_nat = [t_start, t(idx_start:idx_end-1), t_end, t_start];
    amp_pulse_nat = [0, m_t(idx_start:idx_end-1), 0, 0];
    
    t_pulse_inst = [t_start, t_start];
    amp_pulse_inst = [0, sample_value];
    
    t_pulses = [t_pulses; {t_pulse_nat, t_pulse_inst}];
    natural_pulses = [natural_pulses; {amp_pulse_nat}];
    instant_pulses = [instant_pulses; {amp_pulse_inst}];
end

figure('Position', [100, 100, 1000, 400]);
plot(t, m_t, 'b-', 'LineWidth', 2, 'DisplayName', 'Señal Original');
hold on;

for i = 1:num_samples
    fill(t_pulses{i,1}, natural_pulses{i}, [1 0.5 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'DisplayName', 'Señal PAM Natural');
end

for i = 1:num_samples
    line(t_pulses{i,2}, instant_pulses{i}, 'Color', [1 0 0], 'LineWidth', 1.2, 'DisplayName', 'Señal PAM Instantánea');
end

title('Señal Original (azul), PAM Natural (traslúcida) y PAM Instantáneo (rojo)');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('show', 'Location', 'best');
grid on;
xlim([0 0.005]);
ylim([-1.2 1.2]);
hold off;