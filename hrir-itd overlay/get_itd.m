function [itd, onset1_i, onset2_i] = get_itd(hrir1, hrir2, sample_rate, method, upsamp_method, upsamp_factor, threshold)
%GET_ITD Get interaural time difference between two HRIR signals.
%
% ITD is the time difference between when a sound wave hits the first ear
% and when it hits the second. If the waves are of low wavelength 
% (~ < 1000 Hz), then they pass through the tissue of the head and will 
% have the same speed regardless of frequency.  However if they are above 
% 1000 Hz then they creep around the circumference of the head due to
% diffraction and their time reaching the second ear will depend on their
% frequency.
% 
% We compute ITD using the onsets of the two signals. We define onset as 
% the point at which a signal first crosses 15% of its peak value.
%
% Input: 
%     hrir1: Head Related Impulse Response for the first ear. The HRIR 
%         looks like a raw audio wave file with time on the x axis and db 
%         on the y axis. It is derived by the fourier transform of the 
%         HRTF.
%     hrir2: Head Related Impulse Response for the second ear.
%     sample_rate (optional): Sampling frequency. How many audio samples 
%         are taken per second. 
%         Defaults to 48,000 Hz.
%     target_freq: (optional) Return the ITD only for a specific frequency
%     band from the HRIRs.
% 
% Output: 
%     itd: ITD in seconds.
% 
% Written by Monte Hoover on 7 Oct 2022

% Default value for sample_rate
if nargin < 3
    sample_rate = 48000;
end
if nargin < 4
    method = "onset";
end
if nargin < 5
    upsamp_method = "lowpass";
end 
if nargin < 6
    upsamp_factor = 10;
end
if nargin < 7
    threshold = 0.325;
end

% Upsample the signals before searching for the correlation/onset to get a more 
% precise ITD.
if upsamp_method == "lowpass"
    hrir1_upsampled = interp(hrir1, upsamp_factor);
    hrir2_upsampled = interp(hrir2, upsamp_factor);
else
    len = length(hrir1);
    upsample_pts = 1:len*upsamp_factor;
    hrir1_upsampled = interp1(hrir1, upsample_pts, upsamp_method);
    hrir2_upsampled = interp1(hrir2, upsample_pts, upsamp_method);
end

% Return a signed difference. A positive ITD indicates the sound hit the
% ear for hrir1 first, a negative ITD indicates it hit the ear for hrir2
% first.
if method == "onset"
    % Get the onset values in amplitude.
    onset1 = threshold * max(hrir1);
    onset2 = threshold * max(hrir2);
    onset1_i = find(hrir1_upsampled >= onset1, 1, "first");
    onset2_i = find(hrir2_upsampled >= onset2, 1, "first");
    diff_in_samples = onset2_i - onset1_i;
elseif method == "xcorr"
    [coor, lag] = xcorr(hrir2_upsampled, hrir1_upsampled);
    [~, imax_corr] = max(coor);
    diff_in_samples = lag(imax_corr);
else
    warning("An unexpected value was passed in for method. Expected either 'onset' or 'xcorr'.");
end

samples_per_sec = sample_rate * upsamp_factor;
itd = diff_in_samples / samples_per_sec;

% figure; plot(hrir1_upsampled, "-o"); title('hrir 1 upsamp'); ylim([-2.25 3.25]);
% figure; plot(hrir2_upsampled, "-o"); title('hrir 2 upsamp'); ylim([-2.25 3.25]);

end