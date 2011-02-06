function [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatusReport(fid, msgFname, receivedFlag, pathDirs, printMsg, printer, outpost, h_field);

%used for the 03-30-10 & later version
%  for earlier PACF ver, "doc9HospitalStatus" is used

% !PACF! origMsg#_O/R_Doc9Full_fac name
% # FORM DOC-9 HOSPITAL-STATUS REPORT 
% # Js-ver. 3.4, 03-30-10
% # FORMFILENAME: doc9.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% A.: [senderMsg#]
% MsgNo: [origMsg#]
% C.: [recvrMsg#]
% D.: [OTHER]
% E.: [ROUTINE]
% F.: [Yes]
% replyby: [reply by]
% facnam: [fac name]
% date: [04/15/2010]
% time: [2051]
% contact: [con name]
% phone: [phone num]
% fax: [fax num]
% other: [other phone fax cell radio (below 2== partially functional)]
% stat: [2]
% 

% % % following lines replaced by a new function, follows
% % [err, errMsg, modName] = initErrModName(mfilename) ;
% % [form, printedName, printedNamePath] = clearFormInfo;
% % if nargin < 7
% %   h_field = 0;
% % end
% % [err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printMsg, '-hospitalStatusReport', msgFname);
% % if err
% %   printEnable = 0;
% %   errMsg = strcat(modName, errMsg);
% %   fprintf('\n%s', errMsg);
% % end
% % fieldsFound = 0;
% % 
% % % skip through the comment/heading
% % textLine = '#' ;
% % while (1==findstrchr('#', textLine) & ~feof(fid))
% %   textLine = fgetl(fid);
% % end

[err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printMsg, '-hospitalStatusReport', msgFname, fid);

while 1 % read & detect the field for each line of the entire message
  % clear the print line so the line will not be altered unless the field
  %   has an entry. 
  printLine = 0;
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  textLine = readPACFLine(textLine, fid);
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  % Decode the information for the Packet Log:
  %ID/names as contained within the Outpost form of the message
  fT = strtrim(fieldText);
  switch fieldID
  case 'facnam' %
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case 'date' %
    form.date = fT;
    fieldsFound = fieldsFound + 1;
  case 'time' %
    form.time = fT;
    fieldsFound = fieldsFound + 1;
  case 'stat' %
    switch fT
    case '1'
      form.comment = 'Not Functional';
    case '2'
      form.comment = 'Partially Functional';
    case '3'
      form.comment = 'Fully Functional';
    otherwise
      form.comment = sprintf('status "%s" unrecognized', fT);
    end
    fieldsFound = fieldsFound + 1;
  case 'A.'
    form.senderMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'MsgNo'
    form.MsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'C.'
    form.receiverMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'D.'
    form.sitSevere = fT ;
    fieldsFound = fieldsFound + 1;
  case 'E.'
    form.handleOrder = fT ;
    fieldsFound = fieldsFound + 1;
  case 'F.'
    form.replyReq = fT; 
    fieldsFound = fieldsFound + 1;
  case 'replyby'
    form.replyWhen = fT ;
    fieldsFound = fieldsFound + 1;
  case 'contact' %
    %only for printing - don't count
    originator = fT;
  otherwise
  end
  if printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  else % if printMsg 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if (fieldsFound > 10)
      break
    end
  end % if printMsg else
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);
addressee = 'Planning';
if (~err & printEnable)
  [err, errMsg, printedNamePath, printedName] = ...
    formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, msgFname, originator, addressee, textToPrint, outpost, receivedFlag);
end % if (~err & printEnable)
