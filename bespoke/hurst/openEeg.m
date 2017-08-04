
function eeg = openEeg(filename)
    oldFolder = '/Users/Geoff/Documents/MATLAB/EEG/Coe Collection/Robi/';
    newFolder = '/home/data/EEG/data/ROBI/';
    filename1=strrep(filename, oldFolder,newFolder);


    fileInfo = dir(filename1);
    fileLength = fileInfo.bytes / 8;
    fileId = fopen(filename1);
    data = fread(fileId, fileLength, 'float64');
    fclose(fileId);
    newSize = [int64(34), int64(fileLength)/34];
    while(newSize(1)*newSize(2) > length(data))
        newSize(2) = newSize(2) - 1;
    end
    data = data(1:newSize(1)*newSize(2));    
    eeg = reshape(data,newSize)';
    eSize = size(eeg);
    eSize(2) = eSize(2)-2;
    eeg = eeg(1:eSize(1), 1:eSize(2));
end