%CA Close all Screens and ports
% 
%   Closes PsychToolbox Screens, serial port, and parallel port. Handy if 
%   you need to stop in the middle of an experiment. Hit Ctrl-C a couple 
%   times to quit the experiment. Then, type 'ca' and press enter. Focus 
%   should be in the command window, so it should run this script.

Screen('closeall')
sendcmd(pport,'endSession');
fclose(s);
ListenChar(0);
ShowCursor;
