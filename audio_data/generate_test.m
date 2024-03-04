eggert_folder = "C:\Users\tim\Documents\MATLAB\ECE113\ece113dw_project\audio_data\eggert\";
not_eggert_folder = "C:\Users\tim\Documents\MATLAB\ECE113\ece113dw_project\audio_data\not_eggert\noise\";

not_eggert_vol = 0.8;

egg_files = dir(eggert_folder);
egg_filenames = { egg_files(~[egg_files.isdir]).name };

negg_files = dir(not_eggert_folder);
negg_filenames = { negg_files(~[negg_files.isdir]).name };

vals = randi([1 size(negg_filenames, 2)],1,size(egg_filenames, 2));

for i = 1:size(egg_filenames, 2)
    file = strcat(eggert_folder, egg_filenames{i});
    disp(file);
    [eggert, Fs] = audioread(file);

    negg_file = strcat(not_eggert_folder, negg_filenames{vals(i)});
    disp(negg_file);
    [neggert, Fs] = audioread(negg_file);

    newOut = eggert + (not_eggert_vol .* neggert);


    newFilename = erase(file, ".wav");
    newFilename = strcat(newFilename, "_extranoise.wav");
    
    disp(newFilename);
    audiowrite(newFilename, newOut, Fs);
end