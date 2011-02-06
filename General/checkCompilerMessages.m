function [err, errMsg, badNewsText] = checkCompilerMessages(fileName, displayFlag)
%function [err, errMsg] = checkCompilerMessages(fileName[, displayFlag])
%Tests for errors or warnings in the compiler generated progress output file
%named 'diary.txt'. the diary file is generated by matlld_make.m
%if no input argument, function assumes filename diary.txt
%displayFlag[optional]: if not present or 0, all messages displayed
%   1: only display bad news; this keeps screen uncluttered when this procedure
%      is called as an intermediate step.
%created by M. Herrmann, Dec. 11, 2002
%
%VSS revision   $Revision: 11 $
%Last checkin   $Date: 1/23/07 2:07p $
%Last modify    $Modtime: 1/23/07 2:07p $
%Last changed by$ M. Herrmann $
%  $NoKeywords: $

if nargin < 1
  fileName = '';
end
if nargin < 2
  displayFlag = 0;
end
if length(fileName) < 1
  fileName = ('diary.txt');%default file name.
end
%what to search for.
%more key words can be added as necessary.
badNews = {'warning', 'error'};%search routine changes case to lower.
badNewsCountLimit = 10; %only display these many badNews occurences.  If more, continue to note them, just don't clutter the screen.
badNewsCount = 0;
badNewsText = {};

err = 0;
errMsg = '';
if ~findstrchr('off', lower(get(0,'diary')));
  diaryWasOn = 1;
  diary off;
else
  diaryWasOn = 0;
end

fid = fopen(fileName, 'r');
eofCount = 0
if (fid <0)
  err = 1;
  errMsg = sprintf('Unable to open file "%s" : file might be open/in use', fileName);
  return;
else %if (fid <0)
  %read the diary and search for error and warning messages(work in progress).
  progress('listboxMsg_Callback', 'Checking diary for compiler errors & warnings.');
  Ln = 1;
  foundBadNews = 0;
  while 1
    diaryText = fgetl(fid);
    if ~ischar(diaryText), break, end
    for itemp=1:length(badNews)
      lower_diaryText = lower(diaryText);
      if findstr(char(badNews(itemp)), lower_diaryText)
        %if the message is a warning about a cosmetic problem, or
        
        %if it is the name of a module being examined by "depfun"
        %  ignore it
        foundBadNews =1;
        % if warning & page width, not a problem
        if (findstrchr('warning:', lower_diaryText) & ...
            findstrchr('violating the maximum page width', lower_diaryText) )
          foundBadNews = 0;
        end
        % if examining a file, an output from "depfun", not a problem
        if (1 == findstrchr('Examining file',diaryText) & length(diaryText) > length('Examining file'))
          foundBadNews = 0;
        end
        %OK message from obfuscator?
        if (findstrchr('warning: the source file', lower_diaryText) & ...
            findstrchr('is overwritten.', lower_diaryText) )
          foundBadNews = 0;
        end
        if foundBadNews
          badNewsCount = badNewsCount + 1;
          badNewsText(badNewsCount) = {diaryText};
          if badNewsCount <= badNewsCountLimit
            disp(diaryText);
          end
          break;
        end
      end %if findstr(char(badNews(itemp)), lower_diaryText)
    end %for itemp=1:length(badNews)
    Ln = Ln + 1;
  end %while 1
  if feof(fid)
    if eofCount
      fprintf('\n End-Of-File found.');
      break
    end
    eofCount = eofCount + 1 ;
  end
end %if (fid <0) else
if badNewsCount > badNewsCountLimit
  fprintf('\n %i addition issues found & returned but not displayed.', (badNewsCount - badNewsCountLimit));
end

err = foundBadNews;
if ~foundBadNews & ~displayFlag
  % dump the good news so the user can scan it
  %reposition the read to the file beginning
  fseek(fid, 0, 'bof');
  printingOn = 0;
  while 1
    diaryText = fgetl(fid);
    if ~ischar(diaryText)
      break
    end
    if printingOn
      if findstrchr(diaryText, 'End of actions messages');
        fprintf('\n  ******** End of action messages *******\n');
        break;
      end
      a = 1;
      if 1 == findstrchr(diaryText, 'Examining file ')
        a = 0;
      else
        if 1 == findstrchr(diaryText, 'Working on ')
          if ~findstrchr(diaryText, 'New number of lines')
            a = 0;
          end
        end
      end %if 1 == findstrchr(diaryText, 'Examining file ') else
      if a
        fprintf('\n%s', diaryText);
      end
    end
    if ~printingOn
      if findstrchr(diaryText, 'Start of actions messages');
        fprintf('\n  ******** Start of action messages *******');
        printingOn = 1 ;
      end
    end
  end
  
  progress('listboxMsg_Callback', 'compile complete, no errors or warnings');
  msg = sprintf('%s', '\n\npre-compile action messages reprinted above.');
  disp(msg);
end

fcloseIfOpen(fid);

if diaryWasOn
  fprintf('\n***** Diary was on when this module was called & was turned off by this module.  Restoring to "on".')
  diary on
end
