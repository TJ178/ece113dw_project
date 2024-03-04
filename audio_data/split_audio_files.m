folder = "C:\Users\tim\Documents\MATLAB\ECE113\ece113dw_project\audio_data\not_eggert\";

allFiles = dir(folder);
filenames = { allFiles(~[allFiles.isdir]).name };

for i = 1:size(filenames, 2)
    file = strcat(folder, filenames{i});
    disp(file);
    [y, Fs] = audioread(file);
    y1 = y(1:8000);
    y2 = y(8001:16000);

    newFilename = erase(file, ".wav");
    newFilename1 = strcat(newFilename, "_1.wav");
    newFilename2 = strcat(newFilename, "_2.wav");
    
    disp(newFilename);
    disp(newFilename1);
    disp(newFilename2);
    audiowrite(newFilename1, y1, Fs);
    audiowrite(newFilename2, y2, Fs);
end