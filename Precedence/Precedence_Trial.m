%----------------------------------------------------------------
%  Will Bush
%  Precedence Effect
%----------------------------------------------------------------

% Make sure the script is running on Psychtoolbox3:
AssertOpenGL;

%These commands clear the cache of garbage left from previous experimental
%runs
clc; %clear monitor
clear all % clear memory

%cd /Users/grad_user/Dropbox/Will_Experiments/FlankGabor


if or(expType == 'e',expType == 'd')
    RecordData = 1;
    ID = input('Enter Subject Number: ','s');

    %set default values for input arguments
    if ~exist('ID','var')
        ID=66;
    end

    %warn if duplicate sub ID
    FileName =  strcat(ID, '_precedence.csv'); 
    if exist(FileName,'file')

            resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type y for overwrite]'], 's');

        if ~strcmp(resp,'y') %abort experiment if overwriting was not confirmed
            disp('experiment aborted')
            return
        end
    end
end

FID = fopen(FileName, 'w');
fprintf(FID, 'Block, Trial, Hand Side, Order, TrTarType, TrDisCong, TrDisType, TrNeuType, TrDistSide, Response, Accuracy, RT\n'); %\n=enter - moves to next row

%-----------------------------------------------------------------
%	Setting up random seed, screen, and colors
%-----------------------------------------------------------------

rand('twister',sum(100*clock)); 

HideCursor;

screen = 0; 
[window,rect] = Screen('OpenWindow', screen, [0 0 0], [0 0 1024 768]);
CX=512;		
CY=384;
WholeScreen = [CX-512 CY-384 CX+512 CY+384];
Framerate = Screen('FrameRate', screen);

black = [0 0 0];
white = [255 255 255];
grey = [128 128 128];

KBoards = GetKeyboardIndices;

KbCheck;
GetSecs; 


%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =10; % # of blocks
LeadSounds = 2; %1=left; 2=right
LeadLatency = 19; %1-19 ms

BlockTrial = LeadSounds*LeadLatency; % Total Trials = 128*RepetitionInBlock
PracTrial = 32;


%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------


TrLeadSound = zeros(1,BlockTrial);
TrLeadLatency = zeros(1,BlockTrial);


for i=0 : BlockTrial-1
    
    TrLeadSound(i+1) = mod(i, LeadSound);
	TrLeadSound(i+1) = floor(TrLeadSound(i+1))+1; 
    
    TrLeadLatency(i+1) = mod(i/2, LeadLatency);
	TrLeadLatency(i+1) = floor(TrLeadLatency(i+1))+1;

end

 

for Block = 0:TotalBlock  

 
for Trial = 1 : BlockTrial 
 


while 1
    [keyIsDown, End_Time, keyCode]=KbCheck(-1);

    if keyIsDown 
        break
    elseif GetSecs - Begin_Time > 5
        break
    end
    WaitSecs(0.0001);
end

%---------------------------------------------------
% Response Coding
%---------------------------------------------------

RTTrial = (End_Time-Begin_Time)*1000;

if strcmp(KbName(keyCode),'m') %X,V
    Response(Trial) = 1;
elseif strcmp(KbName(keyCode),'z') %P,R
	Response(Trial) = 2;
end

if TrTarType(Order(Trial)) == Response(Trial) %Top
    Accuracy(Trial) = 1;
else %Bottom
    Accuracy(Trial) = 0;
end

   %-----------------------------------------------------------------------
   % Feedback Beep
   %-----------------------------------------------------------------------   


%---------------------------------------------------
% Saving the file
%---------------------------------------------------
if RecordData == 1
    if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
       if (Block<1)
        Save = [0; Trial; 0; Order(Trial); TrTarType(Order(Trial)); TrDisCong(Order(Trial)); ...
            TrDisType(Order(Trial)); TrNeuType(Order(Trial));TrDistSide(Order(Trial)); Response(Trial); Accuracy(Trial); RTTrial];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f\n', Save);
    else
       
        Save = [Block; Trial; TrHandSide(BlOrder(Block)); Order(Trial); TrTarType(Order(Trial)); TrDisCong(Order(Trial)); ...
            TrDisType(Order(Trial)); TrNeuType(Order(Trial));TrDistSide(Order(Trial)); Response(Trial); Accuracy(Trial); RTTrial];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f\n', Save);
       end
    end
end

    

%-------------------End Loop-----------------------------------------    
    
end %closes the for Trial=1:TotalTrial loop
end


%--------------------------------------------------------------------
%	Ending experiment
%--------------------------------------------------------------------
if RecordData == 1
    fclose(FID);
end


Screen('TextSize', window, 24);
IntroText = ['You have completed the experiment\n' ...
    'Please see the experimenter\n'];
DrawFormattedText(window, IntroText, 'center', 'center');
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);
    
KbWait(-1);

ShowCursor;
SCREEN('CloseAll');
