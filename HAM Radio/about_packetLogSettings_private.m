function [codeVersion, reply] = about_packetLogSettings_private()
%function [codeVersion, reply] = about_packetLogSettings_private()
% codeVersion: version number in floating point xx.yyy where X is major & yyy is minor
%reply: string including some text, the date & time of creation & the above version number
% Note: this function is generated by "makeabout_diag" & therefore
%this file should not be editted.

codeVersion = 0.000000;
if codeVersion
  reply = sprintf('packetLogSettings Version %.3f (Debug) created 25-Jan-2012 09:41:48.', codeVersion);
else % if codeVersion
  reply = sprintf('packetLogSettings created  (Debug)25-Jan-2012 09:41:48.');
end % if codeVersion
