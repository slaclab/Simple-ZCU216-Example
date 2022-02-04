addpath('../../common')

%Fadc = 614e6;  % MHz
Fadc=312.5e6;
axi_clk = 156.25e6;
Ts=1/Fadc;
taps_per_chan    = 16;
adc_lanes=16;
number_channels  = 2048;
ch_per_lane=number_channels/16;
number_subband   = number_channels/2; % really will generate 2 overlapping PFB
filt_len         = taps_per_chan*number_subband;
pass_band_weight =  1;
stop_band_weight = 2;%40


coef_bits = 16;
coef_bin_pt = 15;


pass_band_freq  = (0.6)/(number_subband); %0.6
stop_band_freq  = (1.25)/(number_subband);%1.25

filt = firpm(filt_len-1, [0,pass_band_freq,stop_band_freq,1], {'myfrf', [1 1 0 0]}, [pass_band_weight, stop_band_weight]);
% filt = ht(1:32:end)*32;
filt  = filt./max(abs(filt));%normalize coefficients to 1
filtq = round(filt * (2^coef_bin_pt-8))/2^coef_bin_pt;
taps_per_lane=number_channels/adc_lanes*taps_per_chan/2;
subband_per_lane=taps_per_lane/(taps_per_chan/2);
% filts_0 = reshape(filtq, adc_lanes, taps_per_lane);
% for i=1:adc_lanes
%     A = reshape(filts_0(i,:), subband_per_lane, taps_per_chan/2);
%     filts(i,:,:)=A;
% end

% fvtool(filt./sum(filt), 1,  filtq./sum(filtq), 1)


samples_per_channel = 256;
% generate complex chrip
t0=(0:samples_per_channel*number_channels-1)/(samples_per_channel*number_channels);
phi = cumsum(t0)/32;
chirp = exp(-j*2*pi*phi);
sine1=exp(1j*2*pi*Fadc/64/16.*(0:1:length(t0)-1)/(Fadc*16));
%sine1=zeros(1,length(t0));
num_sample=size(t0,2);
num_lane=16;
chirp_data=reshape(chirp,num_lane, num_sample/num_lane);
sindata=reshape(sine1,num_lane,num_sample/num_lane);
% testsignal=(0:16*128*16-1)*(1+1j);
% testsignal=reshape(testsignal,16,2048);
simin.signals.dimensions = 16;
simin.signals.values = chirp_data';
simin.time = [];
simin1.signals.dimensions = 16;
simin1.signals.values = sindata';
simin1.time = [];

%% combine filter into single 36 wide BRAM
filtInt = round(filtq*2^coef_bin_pt);
idx = find(filtInt < 0);
filtUint = filtInt;
filtUint(idx) = filtUint(idx) + 2^coef_bits;
A=reshape(filtUint,2048,8);
filt3D=zeros(8,16,128);
for i=1:taps_per_chan/2% i is index for taps, runs from 1 to 8
    filts3D(i,:,:) = reshape(A(:,i),16,128);
end

for i=1:taps_per_chan/2
    filts3D(i,:,1:64)=filts3D(i,:,1:64) + filts3D(i,:,65:end) * 2^coef_bits;
end
filts3D=filts3D(:,:,1:64);
%plot raw filter coeff and integer coeffs
[h,w]=freqz(filt,1,'whole',filt_len,5e9);%frequency response of digital filter
figure(2);hold on;plot((w-2.5e9)/2.5e9,log10(abs(fftshift(h)))*20);
filtInt2=round(filt*2^coef_bin_pt)/2^coef_bin_pt;
[h,w]=freqz(filtInt2,1,'whole',filt_len,5e9);%frequency response of digital filter
figure(2);hold on;plot((w-2.5e9)/2.5e9,log10(abs(fftshift(h)))*20);

FFT_L=number_channels/2;
SSR=adc_lanes;
WN_BL=16;%combine real &imag into 32bits ROM.
WNarray=exp(-1j*2*pi.*(0:1:number_channels/2-1)/number_channels);
WNA=round(WNarray*(2^(WN_BL-2)-1));
idx2 = find(real(WNA)< 0);
WNA_real = real(WNA);
WNA_real(idx2) = WNA_real(idx2) + 2^WN_BL;
WNB_real=reshape(WNA_real,num_lane,number_channels/num_lane/2);
idx3 = find(imag(WNA)< 0);
WNA_imag = imag(WNA);
WNA_imag(idx3) = WNA_imag(idx3) + 2^WN_BL;
WNB_imag=reshape(WNA_imag,num_lane,number_channels/num_lane/2);
WNB_complex=WNB_real+WNB_imag*2^WN_BL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Baseband excitation
