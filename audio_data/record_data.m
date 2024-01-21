length = 2;
filename = "noise_";
filepath = "ECE113/ece113dw_project/audio_data/";

data = zeros(1,16000);
num = 0;
while(1)
    prompt = "num=" + num + " Record more? Y/N [Y]: ";
    txt = input(prompt,"s");
    if isempty(txt)
        txt = 'Y';
    end
    if(txt == 'Y')
        num = num + 1;
        data(num, :) = recordAudio(length);
    else
        break;
    end
end

for i = 1:size(data, 1)
    fn = filename + i + ".wav";
    audiowrite(filepath + fn, data(i, :), 8000);
end


function recording = recordAudio(T) %takes in time in seconds
    Fs = 8e3;
    %if your computer has a microphone, use this block
    recObj = audiorecorder(Fs, 16, 1);
    disp('Start speaking.')
    recordblocking(recObj,T);
    disp('End of Recording.');
    recording = getaudiodata(recObj); %% variable that saves audio
end
