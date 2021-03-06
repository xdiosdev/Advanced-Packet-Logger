function [codeVersion, reply] = about_processOutpostPacketMessa()
%function [codeVersion, reply] = about_processOutpostPacketMessa()
% codeVersion: version number in floating point xx.yyy where X is major & yyy is minor
%reply: string including some text, the date & time of creation & the above version number
% Note: this function is generated by "makeabout_diag" & therefore
%this file should not be editted.

codeVersion = 0.000000;
if codeVersion
  reply = sprintf('processOutpostPacketMessages Version %.3f (Debug) created 12-Jan-2012 11:36:08.', codeVersion);
else % if codeVersion
  reply = sprintf('processOutpostPacketMessages created  (Debug)12-Jan-2012 11:36:08.');
end % if codeVersion
