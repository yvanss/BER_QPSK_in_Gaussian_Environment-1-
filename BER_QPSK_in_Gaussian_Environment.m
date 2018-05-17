% Clear all the previously used variables and close all figures
clear all;
close all;

format long;

% Frame Length
bit_count = 10000;

% Range of SNR over which to simulate 
Eb_No = -3: 1: 7;

% Convert Eb/No values to channel SNR
% Consult BERNARD SKLAR'S book 'Digital Communications'
SNR = Eb_No + 10*log10(2);

% Start the main calculation loop
for aa = 1: 1: length(SNR)
    
    % Initiate variables
    T_Errors = 0;
    T_bits = 0;
    
    % Keep going until you get 100 errors
    while T_Errors < 100
    
        % Generate some information bits
        uncoded_bits  = round(rand(1,bit_count));
        
        % Split the stream into two streams, for Quadrature Carriers
        B1 = uncoded_bits(1:2:end);
        B2 = uncoded_bits(2:2:end);
        
        % QPSK modulator set to pi/4 radians constellation
        % If you want to change the constellation angles
        % just change the angles.
        qpsk_sig = ((B1==0).*(B2==0)*(exp(i*pi/4))+(B1==0).*(B2==1)...
            *(exp(3*i*pi/4))+(B1==1).*(B2==1)*(exp(5*i*pi/4))...
            +(B1==1).*(B2==0)*(exp(7*i*pi/4))); 
        
        % Noise variance
        N0 = 1/10^(SNR(aa)/10);
        
        % Send over Gaussian Link to the receiver
        rx = qpsk_sig + sqrt(N0/2)*(randn(1,length(qpsk_sig))+i*randn(1,length(qpsk_sig)));
%---------------------------------------------------------------
        
        % QPSK demodulator at the Receiver
        B4 = (real(rx)<0);
        B3 = (imag(rx)<0);
        
        uncoded_bits_rx = zeros(1,2*length(rx));
        uncoded_bits_rx(1:2:end) = B3;
        uncoded_bits_rx(2:2:end) = B4;

    
        % Calculate Bit Errors
        diff = uncoded_bits - uncoded_bits_rx;
        T_Errors = T_Errors + sum(abs(diff));
        T_bits = T_bits + length(uncoded_bits);
        
    end
    % Received data constellation
    figure; clf;
    plot(real(rx),imag(rx),'o');  % Scatter Plot
    title(['constellation of received symbols for SNR = ', num2str(SNR(aa))]); 
    xlabel('Inphase Component'); ylabel('Quadrature Component');

    % Calculate Bit Error Rate
    BER(aa) = T_Errors / T_bits;
    disp(sprintf('bit error probability = %f',BER(aa)));

end
  
%------------------------------------------------------------

% Finally plot the BER Vs. SNR(dB) Curve on logarithmic scale 
% BER through Simulation
figure(1);
semilogy(SNR,BER,'or');
hold on;
xlabel('SNR (dB)');
ylabel('BER');
title('SNR Vs BER plot for QPSK Modualtion in Gaussian Environment');


% Theoretical BER
figure(1);
theoryBer = 0.5*erfc(sqrt(10.^(Eb_No/10)));
semilogy(SNR,theoryBer);
grid on;
legend('Simulated', 'Theoretical');

%------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is used to calculate the Bit Error Rate (BER) of QPSK in an 
% Additive White Gaussian Noise (AWGN) channel. The modulation and
% demodulation is done at baseband. Complex numbers are used to model the 
% in-phase and quadrature components of a QPSK signal. The length of the 
% symbol sequence and range of EbNo can be varied. 
%
% By Yasir Ahmed
% www.raymaps.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;                                            %Clear all variables
close all;                                            %Close all figures

l=1e6;
EbNodB=0:2:10;
EbNo=10.^(EbNodB/10);

for n=1:length(EbNodB)
    si=2*(round(rand(1,l))-0.5);                      %In-phase symbol generation
    sq=2*(round(rand(1,l))-0.5);                      %Quadrature symbol generation                
    s=si+j*sq;                                        %Adding the two parallel symbol streams
    w=(1/sqrt(2*EbNo(n)))*(randn(1,l)+j*randn(1,l));  %Random noise generation
    r=s+w;                                            %Received signal
    si_=sign(real(r));                                %In-phase demodulation
    sq_=sign(imag(r));                                %Quadrature demodulation
    ber1=(l-sum(si==si_))/l;                          %In-phase BER calculation
    ber2=(l-sum(sq==sq_))/l;                          %Quadrature BER calculation
    ber(n)=mean([ber1 ber2]);                         %Overall BER
end

semilogy(EbNodB, ber,'o-')                                 %Plot the BER
xlabel('EbNo(dB)')                                    %Label for x-axis
ylabel('BER')                                         %Label for y-axis
grid on                                               %Turning the grid on 
