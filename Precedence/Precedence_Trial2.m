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
expType = 'e';

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
fprintf(FID, 'Block, Trial, Order, TrLeadLatency, Response, RT\n'); %\n=enter - moves to next row

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
Reps = 2;

BlockTrial = LeadLatency*Reps; % Total Trials = 128*RepetitionInBlock
PracTrial = 32;

SoundFiles = cellstr(['RightTest_01ms.wav'; 'RightTest_02ms.wav'; 'RightTest_03ms.wav'; 'RightTest_04ms.wav'; 'RightTest_05ms.wav';...
              'RightTest_06ms.wav'; 'RightTest_07ms.wav'; 'RightTest_08ms.wav'; 'RightTest_09ms.wav'; 'RightTest_10ms.wav';...
              'RightTest_11ms.wav'; 'RightTest_12ms.wav'; 'RightTest_13ms.wav'; 'RightTest_14ms.wav'; 'RightTest_15ms.wav';...
              'RightTest_16ms.wav'; 'RightTest_17ms.wav'; 'RightTest_18ms.wav'; 'RightTest_19ms.wav']);

%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------


TrLeadSound = zeros(1,BlockTrial);
TrLeadLatency = zeros(1,BlockTrial);


for i=0 : BlockTrial-1
    
    TrLeadLatency(i+1) = mod(i, LeadLatency);
	TrLeadLatency(i+1) = floor(TrLeadLatency(i+1))+1;

end

 

for Block = 0:TotalBlock  

 Order = randperm(BlockTrial);

 Screen(window, 'FillRect', grey); %clears the text off of the presentation window by filling it with background color (black)
    
 
 % We choose a text size of 24 pixels
Screen('TextSize', window, 24);

% This is our intro text. The '\n' sequence creates a line-feed (like hitting 'enter' in word processor):
if Block ==0
    BlockText = 'PracticeTrials';
else
    BlockText = 'Blocl end';
end

DrawFormattedText(window, BlockText, 'center', 'center', [0 0 0]);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1); %pauses presentation of previous test until a key is pressed
Screen(window, 'FillRect', grey); %clears the text off of the presentation window by filling it with background color (black)
    
for Trial = 1 : BlockTrial 
 
    WaitSecs(1);
    
[s,fs] =wavread(SoundFiles{TrLeadLatency(Order(Trial))});
sound(s,fs);

Begin_Time = GetSecs;    

while 1
    [keyIsDown, End_Time, keyCode]=KbCheck(-1);

    if keyIsDown 
        break
    elseif GetSecs - Begin_Time > 5
        Response(Trial) = 0;
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
elseif strcmp(KbName(keyCode),'n') %P,R
	Response(Trial) = 2;
end


   %-----------------------------------------------------------------------
   % Feedback Beep
   %-----------------------------------------------------------------------   


%---------------------------------------------------
% Saving the file
%---------------------------------------------------
if RecordData == 1
    if (BlockTrial>=1) %starts saving data if subject has completed at least 1 trial
       if (Block<1)
        Save = [0; Trial; Order(Trial); TrLeadLatency(Order(Trial)); Response(Trial); RTTrial];

        fprintf(FID, ' %7d, %7d, %7d, %7d, %7d, %3.4f\n', Save);
    else
       
        Save = [Block; Trial; Order(Trial); TrLeadLatency(Order(Trial)); Response(Trial); RTTrial];

        fprintf(FID, ' %7d, %7d, %7d, %7d, %7d, %3.4f\n', Save);
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
