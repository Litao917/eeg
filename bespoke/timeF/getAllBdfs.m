function [ fileinfo ] = getAllBdfs( varargin )
%GETALLBDFS Summary of this function goes here
%   Detailed explanation goes here

fileinfo = [];

rootFolder = '/home/data/EEG/data/';
subFolders = {'Flanker1', 'Flanker2', 'Auditory1', 'Auditory2', 'PTSD'};


for i = 1:length(subFolders);
    subContents = dir(fullfile(rootFolder,subFolders{i}));
    for k = length(subContents):-1:1
        % remove folders
        if subContents(k).isdir
            subContents(k) = [ ];
            continue
        end
        % remove folders starting with .
        fname = subContents(k).name;
        if fname(1) == '.'
            subContents(k) = [ ];
        end
        % remove non-bdfs
        if(~strcmp(fname(end-3:end), '.bdf'))
            subContents(k) = [ ];
        end
        
    end
    for j = 1:length(subContents)
        path = fullfile(rootFolder, subFolders(i), subContents(j).name);
        switch i
            case 1
                fileinfo.Flanker1(j) = path;
            case 2
                fileinfo.Flanker2(j) = path;
            case 3
                fileinfo.Auditory1(j) = path;
            case 4
                fileinfo.Auditory2(j) = path;
            case 5
                fileinfo.PTSD(j) = path;
        end
    end
end





% 
% Tones = [];
% ANT = [];
% PTSD = [];
% other = [];
% path = [];
% 
% folder = '/home/data/EEG/data/';
% if(length(varargin) > 0)
%     folder = varargin(1);
% end
% 
% files = dir(folder);
% display({files.name}');
% for i = 1:length(files);
%     if(strfind(files(i).name, '.mat'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         other = [other path];
%     elseif(strfind(files(i).name, 'PM'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         PTSD = [PTSD path];
%     elseif(strfind(files(i).name, 'ANT'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         ANT = [ANT path];
%     elseif(strfind(files(i).name, 'ANT'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         ANT = [ANT path];
%     elseif(strfind(files(i).name, 'ANT'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         ANT = [ANT path];
%         path.filename = files(i).name;
%         path.folder = folder;
%         ANT = [ANT path];
%         path.filename = files(i).name;
%         path.folder = folder;
%         ANT = [ANT path];
%     elseif(strfind(files(i).name, '.bdf'))
%         path.filename = files(i).name;
%         path.folder = folder;
%         Tones = [Tones path];
%     else
%         path.filename = files(i).name;
%         path.folder = folder;
%         other = [other path];
%     end
% end

end


