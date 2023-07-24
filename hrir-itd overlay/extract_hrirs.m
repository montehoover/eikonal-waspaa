% Load precomputed HRTFs for a spherical grid of source locations
struct = load("hrtfs_HUTUBS_600mm.mat");
hrtfs = struct.hrtfs;  % (n_el x n_az x n_mics x n_freqs)

% Extract HRIRs from selected directions and save files

i_el = 51;
i_az = [1, 17, 34, 51];

source_dirs = ["0_deg";
        "30_deg";
        "60_deg";
        "90_deg" ];

for i=1:length(i_az)

    hrtf_l = squeeze(hrtfs(i_el,i_az(i),1,:));
    hrtf_r = squeeze(hrtfs(i_el,i_az(i),2,:));
    hrir_l = get_hrir(hrtf_l);
    hrir_r = get_hrir(hrtf_r);
    
    % Save in Matlab format
    save("hrir_left_ear_" + source_dirs(i) + ".mat", "hrir_l");
    save("hrir_right_ear_" + source_dirs(i) + ".mat", "hrir_r");
   
    % Save in Numpy format
    f = py.open("hrir_left_ear_" + source_dirs(i) + ".bin", 'wb');
    py.numpy.array(hrir_l).tofile(f);
    f.close();
    f = py.open("hrir_right_ear_" + source_dirs(i) + ".bin", 'wb');
    py.numpy.array(hrir_r).tofile(f);
    f.close();
end
