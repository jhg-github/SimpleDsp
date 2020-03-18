% close all
clear

%-- common --
fs = 48000;         % Sampling frequency                    
Ts = 1/fs;          % Sampling period
fnyq = fs / 2;      % Nyquist frequency
L = 48000;          % Length of signal
t = (0:L-1)*Ts;     % Time vector
% atten_db = 60;      % Attenuation [db]. Aprox. 10 bits [ENOB], atten = 10 * 6.02 + 1.76 

% hlow_fpass = 600;
% hlow_fstop = 800;
% hband_fstop1 = 600;
% hband_fpass1 = 800;
% hband_fpass2 = 1400;
% hband_fstop2 = 6600;
% hhigh_fstop = 1400;
% hhigh_fpass = 1600;
% nfir = 100;

%-- signal --
f1 = 200;           % Signal frequency components
f2 = 400;           %
f3 = 1000;          %
f4 = 1200;          %
f5 = 1800;          %
f6 = 2000;          %
xn = sin(2*pi*f1*t) + sin(2*pi*f2*t) + sin(2*pi*f3*t) + sin(2*pi*f4*t) + sin(2*pi*f5*t) + sin(2*pi*f6*t);   %Signal

%-- signal fft --
f = fs*(0:(L/2))/L;             % Freq. vector
xn_win = xn'.*hanning(L);       % Windowing signal
Xm = fft(xn_win);               % FFT
P2 = abs(Xm/L);                 %
P1 = P2(1:L/2+1);               % Single sided FFT
P1(2:end-1) = 2*P1(2:end-1);    %
P1_db = 20*log10(P1);           %

%-- decimation filter --
decimation = 8;                     % Decimation factor. 48000Hz -> 6000Hz
B = 2200;                           % Pass band for decimate filter
fs_dec = fs / decimation;           % Sampling frequency after decimation
fstop = fs_dec - B;                 % At fstop the attenuation must be aprox 60dB (10 ENOB) to avoid aliasing
n_hdec = 50;                        % Decimation filter order
hdec_k = fir1(n_hdec,(B/fnyq));     % Decimation filter coeficients

%-- decimation filter fft --
Hdecm = fft( [hdec_k zeros(1, L - length(hdec_k))] ); % Single sided FFT
Hdecm_P2 = abs(Hdecm/1);                % Don't divide because filter coefficients are already scaled
Hdecm_P1 = Hdecm_P2(1:L/2+1);           % 
Hdecm_P1(2:end-1) = Hdecm_P1(2:end-1);  %
Hdecm_P1_db = 20*log10(Hdecm_P1);       %

%-- decimate signal --
xn_dec = filter(hdec_k,1,xn);               % Filter signal
xn_dec = downsample(xn_dec, decimation);    % Downlsample signal
t_dec = downsample(t, decimation);          % Decimate time vector

%-- decimate signal fft --
L_dec = length(xn_dec);                 % Lenght of decimated signal
f_dec = fs_dec*(0:(L_dec/2))/L_dec;     % Decimated frequency vector
xn_dec_win = xn_dec'.*hanning(L_dec);   % Windowing
Xm_dec = fft(xn_dec_win);               % Single sided FFT
P2_dec = abs(Xm_dec/L_dec);             %
P1_dec = P2_dec(1:L_dec/2+1);           %
P1_dec(2:end-1) = 2*P1_dec(2:end-1);    %
P1_dec_db = 20*log10(P1_dec);           %

% % %-- lowpass filter --
% % hl_f =   [0 (hlow_fpass/Fs) (hlow_fstop/Fs) 1];
% % hl_mag = [1 1               0               0];
% % hl_k = fir2(nfir,hl_f,hl_mag);
% % 
% % %-- lowpass filter fft --
% % Hlm = fft( [hl_k zeros(1, L - length(hl_k))] );
% % Hlm_P2 = abs(Hlm/1);    % don't divide because filter coefficients are already scaled ???
% % Hlm_P1 = Hlm_P2(1:L/2+1);
% % Hlm_P1(2:end-1) = Hlm_P1(2:end-1);


%-- plots --
%figure
subplot(5,2,1)
plot(t, xn)
grid on
title('Signal')
xlabel('t (s)')
ylabel('x(n)')

subplot(5,2,2)
plot(f,P1_db) 
% plot(f,P1) 
grid on
title('Single-Sided Spectrum of Signal')
xlabel('f (Hz)')
ylabel('P1(f) dB')

subplot(5,2,3)
stem((0:n_hdec), hdec_k)
grid on
title('Decimation filter coefficients')
xlabel('k')
ylabel('hdec(k)')

subplot(5,2,4)
plot(f,Hdecm_P1_db) 
grid on
title('Single-Sided Amplitude Spectrum of Hdec(m)')
xlabel('f (Hz)')
ylabel('Hdecm_P1(db)')

subplot(5,2,5)
plot(t_dec, xn_dec)
grid on
title('Signal decimated')
xlabel('t_dec(s)')
ylabel('xdec(n)')

subplot(5,2,6)
% plot(f_dec,P1_dec) 
plot(f_dec,P1_dec_db) 
grid on
title('Single-Sided Spectrum of Decimated Signal')
xlabel('f (Hz)')
ylabel('P1_dec(f) dB')

% % subplot(5,2,3)
% % stem((0:nfir), hl_k)
% % grid on
% % title('Lowpass filter coefficients')
% % xlabel('k')
% % ylabel('hl(k)')
% % 
% % subplot(5,2,4)
% % plot(f,Hlm_P1) 
% % grid on
% % title('Single-Sided Amplitude Spectrum of Hl(m)')
% % xlabel('f (Hz)')
% % ylabel('|Hlm_P1(f)|')
