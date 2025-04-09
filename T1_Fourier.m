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

pam_natural = zeros(size(t));
pam_instant = zeros(size(t));

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

    pam_natural(idx_start:idx_end-1) = sample_value;

    pam_instant(idx_start) = sample_value;
end

% FFT de cada señal

N = length(t);
f = (0:N-1)*(sample_rate/N);

M_f = abs(fft(m_t))/N;
PAMnat_f = abs(fft(pam_natural))/N;
PAMinst_f = abs(fft(pam_instant))/N;

% parte positiva
half = floor(N/2);

f_plot = f(1:half);
M_f_plot = M_f(1:half);
PAMnat_f_plot = PAMnat_f(1:half);
PAMinst_f_plot = PAMinst_f(1:half);


figure;
plot(f_plot, M_f_plot, 'b', 'LineWidth', 1.5); hold on;
plot(f_plot, PAMnat_f_plot, 'r', 'LineWidth', 1.5);
plot(f_plot, PAMinst_f_plot, 'g', 'LineWidth', 1.5);

xlim([0 3000]);
xlabel('Frecuencia (Hz)');
ylabel('Magnitud Normalizada');
title('Transformada de Fourier: Señal Original, PAM Natural e Instantáneo');
legend('Señal Original', 'PAM Natural', 'PAM Instantáneo');
grid on;
