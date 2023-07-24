function hrir= get_hrir(hrtf, n_shift, alt_shift)
%GET_HRIR Get Head Related Impulse Response from a Head Related Transfer
%    Function

if nargin < 2
    n_shift = 128;
end
if nargin < 3
    alt_shift = false;
end

% Reshape input to column vectors if not already in that form:
if size(hrtf, 1) == 1
    hrtf = hrtf.';
end

% Create mirrored-conjugate spectrum of freq component and append to 
% HRTF so that the future IFFT result has no complex part. Pivot around 
% the last entry in the hrtf, so don't include that in the mirrored 
% spectrum. Flip along the frequency dimension.
mirrored_conj = flip(conj(hrtf(1:end-1)));
hrtf = cat(1, hrtf, mirrored_conj);
% Prepend with zero to represent component for "zero frequency"
hrtf = cat(1, 0, hrtf);

% make sure the component at len/2+1 is real
len = length(hrtf);
hrtf(len / 2 + 1) = abs(hrtf(len / 2 + 1)); 

% Take the IFFT
hrir_j = ifft(hrtf);

% Because we mirrored the frequencies with complex conjugates, we expect to
% have the imaginary components all be zero (or as close as machine
% precision allows). So just take the real components now.
small_number = 1.0e-13;
if max(abs(imag(hrir_j))) > small_number, warning('something is wrong -- non-zero imaginary component after IFFT -- this should not happen'); end;
hrir_w = real(hrir_j);

% The HRIR comes out inverted in time and centered at time sample 0 w.r.t. the center of the head -- let us fix that
% Shift by the number of samples it will take for the active part of the 
% HRIR to be contiguous and then invert in time.
if alt_shift
    hrir = [hrir_w(n_shift:-1:1) hrir_w(end:-1:n_shift+1)];
else
    hrir = circshift(hrir_w, n_shift);
    hrir = flip(hrir, 1);
end
