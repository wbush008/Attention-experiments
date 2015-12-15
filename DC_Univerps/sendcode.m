function status = sendcode(pport,code,lencode)
%SENDCODE Sends an event code to HERPES 64_bit
%
%   sendcode(PPORT,CODE,LENCODE);
%    
%   PPORT is the handle for the parallel port
%   CODE is the code to send
%   LENCODE is the length of the code

status = 0;

% send 1-digit code
if lencode == 1
    if code == '0'
        io64(pport,888,10); WaitSecs(0.01);
    else
        io64(pport,888,code); WaitSecs(0.01);
    end;
    io64(pport,888,0); WaitSecs(0.01);

% send 2-digit code
elseif lencode == 2
    codestr = num2str(code);
    if code<10
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        if codestr == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr); WaitSecs(0.01);
        end;
    else
        if codestr(1) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(1)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(2) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(2)); WaitSecs(0.01);
        end;
    end;
    io64(pport,888,0); WaitSecs(0.01);
    
% send 4-digit code
elseif lencode == 4
    codestr = num2str(code);
    if code<10
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        if codestr == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
    elseif code<100
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(1) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(1)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(2) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(2)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
    elseif code<1000
        io64(pport,888,10); WaitSecs(0.01);
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(1) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(1)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(2) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(2)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(3) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(3)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);        
    else
        if codestr(1) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(1)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(2) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(2)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(3) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(3)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
        if codestr(4) == '0'
            io64(pport,888,10); WaitSecs(0.01);
        else
            io64(pport,888,codestr(4)); WaitSecs(0.01);
        end;
        io64(pport,888,0); WaitSecs(0.01);
    end;  
    
else
    status = 1;
    
end;
