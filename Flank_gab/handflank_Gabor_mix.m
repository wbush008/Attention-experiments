%----------------------------------------------------------------
%  Will Bush
%  Flanker Task - 50/50 Validity, 2 Locations
%
%  Fall 2012
%
%  Contains all conditions and bocks
%----------------------------------------------------------------

% Make sure the script is running on Psychtoolbox3:
AssertOpenGL;

%These commands clear the cache of garbage left from previous experimental
%runs
clc; %clear monitor
clear all % clear memory

%cd /Users/grad_user/Dropbox/Will_Experiments/FlankGabor

expType = 'e';
StimType = 2;
RecordData = 0;

if or(expType == 'e',expType == 'd')
    RecordData = 1;
    ID = input('Enter Subject Number: ','s');

    %set default values for input arguments
    if ~exist('ID','var')
        ID=66;
    end

    %warn if duplicate sub ID
    FileName =  strcat(ID, '_HandFlank_gabmix.csv'); 
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

if mod(str2num(ID),4)<2
    HandSide=1;
else 
    HandSide=2;
end

KBoards = GetKeyboardIndices;

KbCheck;
GetSecs; 


%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------
F_Size = 300;
F_Ecc = 200;
T_Size = 300;


LeftLoc   = [CX-(F_Ecc + F_Size) CY-(F_Size/2) CX-F_Ecc             CY+(F_Size/2)];
RightLoc  = [CX+F_Ecc            CY-(F_Size/2) CX+(F_Ecc + F_Size)  CY+(F_Size/2)];
CenterLoc = [CX-(T_Size/2)       CY-(T_Size/2) CX+(T_Size/2)        CY+(T_Size/2)];

%-----------------------------------------------------------------
% Set Gabor Variables
%-----------------------------------------------------------------


F_Spread = 50; 
T_Spread = 50; 

G_Median = .5;
G_Contrast = .5;

G_TarF = 9;
G_DisF = [6 6 6 6];     % 2 CPD, 4CPD   

OrientSet = [45 -45];
OrientSetN = [0 90];

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =30; % # of blocks
TotalHandSide = 2; %1=left; 2=right
TarType = 2; %1=tilt 45; 2= tilt -45
DisCong = 2; %1=response congruent; 2=response incongruent
DisType = 4; %1=HF; 2=LF
NeuType = 2;
DistSide = 2; % 1=left;2=right
RepetitionInBlock = 1; 
HandSwitchTrials = 32;


BlockTrial = TarType*DisCong*DisType*NeuType*DistSide*RepetitionInBlock; % Total Trials = 128*RepetitionInBlock
PracTrial = 32;


%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------


BlockCount = zeros(1,BlockTrial);%creates vector of size TotalTrial
TrHandSide = zeros(1,BlockTrial);
TrTarType = zeros(1,BlockTrial);
TrDisCong = zeros(1,BlockTrial);
TrDisType = zeros(1,BlockTrial);
TrNeuType = zeros(1,BlockTrial);
TrDistSide = zeros(1,BlockTrial);
RT = zeros(1,BlockTrial);
Response = zeros(1,BlockTrial);
Accuracy = zeros(1,BlockTrial);
Order = zeros(2,BlockTrial/2);
TrialCount = zeros(1,BlockTrial);
CongAveRT = zeros(1);
InCongAveRT = zeros(1);


for i=0 : BlockTrial-1
    
    TrDisType(i+1) = mod(i/16, DisType);
	TrDisType(i+1) = floor(TrDisType(i+1))+1; 
    
    TrDisCong(i+1) = mod(i/8, DisCong);
	TrDisCong(i+1) = floor(TrDisCong(i+1))+1;

    TrNeuType(i+1) = mod(i/4, NeuType);
	TrNeuType(i+1) = floor(TrNeuType(i+1))+1; 
    
    TrTarType(i+1) = mod(i/2, TarType);
	TrTarType(i+1) = floor(TrTarType(i+1))+1; 
    
	TrDistSide(i+1) = mod(i, DistSide);
	TrDistSide(i+1) = floor(TrDistSide(i+1))+1;

end
    
for i=0 : TotalBlock-1
    
	TrHandSide(i+1) = mod(i, HandSide);
	TrHandSide(i+1) = floor(TrHandSide(i+1))+1;

end
    

%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

% This is our intro text. The '\n' sequence creates a line-feed (like hitting 'enter' in word processor):

Screen('PutImage', window, imread('WelcomeScreen.png'), WholeScreen);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

Target      = gabor([T_Size T_Size], 6,  OrientSet(1),   rand, T_Spread, G_Median+.085, G_Contrast)*256;
Neutral     = gabor([F_Size F_Size], 6,  OrientSetN(1),  rand, F_Spread, G_Median+.085, G_Contrast)*256;
Distractor  = gabor([F_Size F_Size], 6,  OrientSet(2),   rand, F_Spread, G_Median+.085, G_Contrast)*256;


Screen('PutImage', window, imread('FlankDisplay.png'), WholeScreen);
Screen('PutImage', window, Target, CenterLoc);
Screen('PutImage', window, Distractor, LeftLoc);
Screen('PutImage', window, Neutral, RightLoc);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

Screen('PutImage', window, imread('FlankTask.png'), WholeScreen);
Target      = gabor([T_Size-100 T_Size-100], 6,  OrientSet(1),   rand, T_Spread-20, G_Median+.085, G_Contrast)*256;
Screen('PutImage', window, Target, CenterLoc - [-50 80 50 180]);
Target      = gabor([T_Size-100 T_Size-100], 6,  OrientSet(2),   rand, T_Spread-20, G_Median+.085, G_Contrast)*256;
Screen('PutImage', window, Target, CenterLoc + [50 220 -50 120]);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

Screen('PutImage', window, imread('HandDesc.png'), WholeScreen);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

Screen('PutImage', window, imread('FlankPrePrac.png'), WholeScreen);
Target      = gabor([T_Size-150 T_Size-150], 6,  OrientSet(1),   rand, T_Spread-25, G_Median+.085, G_Contrast)*256;
Screen('PutImage', window, Target, CenterLoc - [-75 -55 75 95]);
Target      = gabor([T_Size-150 T_Size-150], 6,  OrientSet(2),   rand, T_Spread-25, G_Median+.085, G_Contrast)*256;
Screen('PutImage', window, Target, CenterLoc + [75 305 -75 155]);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1); 


Screen(window, 'FillRect', grey); %clears the text off of the presentation window by filling it with background color (black)
FlushEvents('keyDown'); %flushes keypress info from cache for memory purposes

BlOrder = randperm(TotalBlock);    

for Block = 0:TotalBlock  
    

%-----------------------------------------------------------------
%	Present Instruction/Block
%-----------------------------------------------------------------

  
% We choose a text size of 24 pixels
Screen('TextSize', window, 24);

% This is our intro text. The '\n' sequence creates a line-feed (like hitting 'enter' in word processor):
if Block ==0    
    BlockText = ['You will now begin the practice trials.\n' ...
    'Press a foot pad to begin\n' ];

elseif Block ==1
    BlockText = ['You will now begin the full length blocks.\n' ...
    'You will have an opportunity to take\n' ...
    'breaks over the course of the trials.\n' ...
    'Press a foot pad to begin\n' ];

else
    BlockText = ['Time for a break.\n' ...
    'Take a minute to rest your eyes and get comfortable.\n' ...
    'Press a foot pad to continue\n' ];
end

DrawFormattedText(window, BlockText, 'center', 'center', [0 0 0]);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1); %pauses presentation of previous test until a key is pressed
Screen(window, 'FillRect', grey); %clears the text off of the presentation window by filling it with background color (black)
FlushEvents('keyDown'); %flushes keypress info from cache for memory purposes

%---------------------------------------------------
% Breaks Between Trials
%---------------------------------------------------

Screen('TextSize', window, 24);

if Block == 0
    HandText = ['Raise your LEFT hand up to the side of the screen.\n' ...
    'Press a foot pad when ready to continue\n' ];
else

    if TrHandSide(BlOrder(Block)) == 1
        HandText = ['Raise your LEFT hand up to the side of the screen.\n' ...
        'Press a foot pad when ready to continue\n' ];
    else
        HandText = ['Raise your RIGHT hand up to the side of the screen.\n' ...
        'Press a foot pad when ready to continue\n' ];
    end
end

DrawFormattedText(window, HandText, 'center', 30, [0 0 0]);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1); %pauses presentation of previous test until a key is pressed
Screen(window, 'FillRect', grey); %clears the text off of the presentation window by filling it with background color (black)
FlushEvents('keyDown'); %flushes keypress info from cache for memory purposes
Screen('Flip', window);

WaitSecs(3);
%-----------------------------------------------------------------
% Randomization of Trials
%-----------------------------------------------------------------       

Order = randperm(BlockTrial);

if Block ==0
    TotalTrial = PracTrial;
else
    TotalTrial = BlockTrial;
end
 
for Trial = 1 : TotalTrial 
 
    WaitSecs(1);                    
%-----------------------------------------------------------------
%  Choosing Target Type
%-----------------------------------------------------------------

if TrDisCong(Order(Trial)) == 1
   DistractorOrient =  -1*(OrientSetN(TrNeuType(Order(Trial)))-90);
else 
   DistractorOrient =  -1*OrientSet(TrTarType(Order(Trial)));
end   

Target      = gabor([T_Size T_Size], G_DisF(TrDisType(Order(Trial))),  OrientSet(TrTarType(Order(Trial))),   rand, T_Spread, G_Median, G_Contrast)*256;
Neutral     = gabor([F_Size F_Size], G_DisF(TrDisType(Order(Trial))),  OrientSetN(TrNeuType(Order(Trial))),  rand, F_Spread, G_Median, G_Contrast)*256;
Distractor  = gabor([F_Size F_Size], G_DisF(TrDisType(Order(Trial))),  DistractorOrient,                     rand, F_Spread, G_Median, G_Contrast)*256;

%-----------------------------------------------------------------
%  Linking Stimulus Conditions to Display Types
%-----------------------------------------------------------------

if TrDistSide(Order(Trial)) == 1 
        DistLoc = LeftLoc; 
        NeutralLoc = RightLoc;            
else 
        DistLoc = RightLoc; 
        NeutralLoc = LeftLoc; 
end    
    
%---------------------------------------------------
% Presenting the Stimuli
%---------------------------------------------------


Screen('PutImage', window, Target, CenterLoc);
Screen('PutImage', window, Distractor, DistLoc);
Screen('PutImage', window, Neutral, NeutralLoc);
[VBLTimestamp Begin_Time]=Screen('Flip', window);

while 1
    [keyIsDown, End_Time, keyCode]=KbCheck(-1);

    if keyIsDown 
        break
    elseif GetSecs - Begin_Time > 5
        break
    end
    WaitSecs(0.0001);
end

%Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);%clear screen between trials
Screen(window, 'FillRect', grey);
Screen('Flip', window);
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
if Accuracy(Trial) == 0;
   Beep=sin(1:0.5:500);
   sound(Beep);
end
   


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
