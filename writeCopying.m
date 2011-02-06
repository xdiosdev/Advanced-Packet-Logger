function [fName] = writeCopying(handles);
%Support file for 'displayCounts'
%write the "copying underway" semaphore file
% needs to be deleted after the copying is completed - fName will be null if it wasn't written:
%  if length(fName)
%    delete(fName);
%  end

%same line in "displayCounts_CloseRequestFcn"
fName = sprintf('%s%scopy.txt', handles.logPath, handles.semaphoreCoreName);
fid = fopen(fName,'w');
if (fid > 0)
  fprintf(fid,'This file indicates that "%s" is copying the Log. Will be deleted when copying is completed.', mfilename);
  %don't change this wording without updating processOutpostMessages's reading operation
  fprintf(fid,'\r\nmonitoredLog = %s', handles.logPathName);
  fclose(fid) ;
else
  fName = '';
end
