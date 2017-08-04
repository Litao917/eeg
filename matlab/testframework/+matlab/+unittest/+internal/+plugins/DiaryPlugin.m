classdef DiaryPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
        matlab.unittest.internal.plugins.Printable
    
    properties(Access= private)
        Folder
        DiaryState
        DiaryFile
    end
    
    
    methods
        function plugin = DiaryPlugin(folder)
            plugin.Folder = folder;
            plugin.DiaryState = get(0, 'Diary');
            plugin.DiaryFile = get(0, 'DiaryFile');
        end
    end
    
    
    methods (Access=protected)
        
        
        function runTestClass(plugin, pluginData)
            % Store the global diary state that is modified
            plugin.DiaryState = get(0, 'Diary');
            plugin.DiaryFile = get(0, 'DiaryFile');
            
            diaryFile = fullfile(plugin.Folder, sprintf('%sDiary.log', pluginData.Name));
            diary(diaryFile);
            
            runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);

            diary(plugin.DiaryState);
            set(0,'DiaryFile', plugin.DiaryFile);
        end
        
    end
    
end
