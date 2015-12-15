function status = sndcmd(pport,cmd)
%SENDCODE Sends an event code to HERPES 64_bit
%
%   sendcode(PPORT,CODE,LENCODE);
%    
%   PPORT is the handle for the parallel port
%   CMD is the command to send
%
%   Commands:
%       startSession (11)
%       trialCodes   (12)
%       startEpoch   (13)
%       respCodes    (14)
%       endSession   (15)

status = 0;

if strcmp(cmd,'startSession')
    io64(pport,888,11); WaitSecs(0.01);
    io64(pport,888,0); WaitSecs(0.01);

elseif strcmp(cmd,'trialCodes')
    io64(pport,888,12); WaitSecs(0.01);
    io64(pport,888,0); WaitSecs(0.01);    
    
elseif strcmp(cmd,'startEpoch')
    io64(pport,888,13); WaitSecs(0.01);
    io64(pport,888,0); WaitSecs(0.01);
    
elseif strcmp(cmd,'respCodes')
    io64(pport,888,14); WaitSecs(0.01);
    io64(pport,888,0); WaitSecs(0.01);        
    
elseif strcmp(cmd,'endSession')
    io64(pport,888,15); WaitSecs(0.01);
    io64(pport,888,0); WaitSecs(0.01);
    
else
    status = 1;
    
end;
