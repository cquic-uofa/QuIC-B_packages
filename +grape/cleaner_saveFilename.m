function [clean_str] = cleaner_saveFilename(dirty_str)

% clean_str = strrep(strrep(strrep(strrep(dirty_str,'\',''),' ','_'),'-','m'),'=','');
clean_str = strrep(strrep(strrep(strrep(strrep(dirty_str,'.','p'),'\',''),' ','_'),'-','m'),'=','');

end