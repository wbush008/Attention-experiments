%----------------------------------------------------------------
%  Will Bush
%  Flanker Task - 50/50 Validity, 2 Locations
%
%  Fall 2014
%
%  Contains all conditions and bocks
%----------------------------------------------------------------

% Make sure the script is running on Psychtoolbox3:
AssertOpenGL;

%These commands clear the cache of garbage left from previous experimetnal
%runs
clc; %clear monitor
clear all % clear memory

%addpath(genpath('C:/Users/Will/Desktop/FlankOfReach'));
%-----------------------------------------------------------------
%	Set up subject number, tell MATLAB what to name data file
%-----------------------------------------------------------------
% input subject id

cd /Users/grad_user/Dropbox/Will_Experiments/GaborOfReach

%  disp('e: experiment, d: demo');
%  expType=input('Enter imstruction type: ','s');
expType='e';
ID = input('Enter Subject Number: ','s');

%set default values for input arguments
if ~exist('ID','var')
        ID=66;
end

if mod(str2double(ID),2)==1
    PGroup = 1;
else
    PGroup = 2;
end

    %warn if duplicate sub ID
FileName =  strcat(ID, '_Hand_Gabor.csv'); 
if exist(FileName,'file')
    resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type y for overwrite]'], 's');

    if ~strcmp(resp,'y') %abort experiment if overwriting was not confirmed
        disp('experiment aborted')
        return
    end
end

FID = fopen(FileName, 'w');
fprintf(FID, 'Block, BlockOrder, HandSide, Trial, TrialOrder, TrStandOrient, TrCompContrast, TrStandSide, Response, Accuracy, RT, T1, T2, T3, T4\n'); %\n=enter - moves to next row

KBoards = GetKeyboardIndices;
        
%-----------------------------------------------------------------
%	Setting up random seed, screen, and colors
%-----------------------------------------------------------------

rand('twister', sum(100*clock)); %generates new random order of trial presentation each time program starts
HideCursor; %hides cursor so subjects can't see it

screen = 0; %opens the main presentation window with below parameters
[window,rect] = Screen('OpenWindow', screen, [0 0 0], [0 0 1024 768]);
CX=512;		
CY=384;
Framerate = Screen('FrameRate', screen);

black = [0 0 0];
white = [255 255 255];
grey = [128 128 128];
green = [20 150 20];
red = [150 20 20];
BCKColor = grey;
CueColor = black;
FeedBColor = green;
Beep=sin(1:0.5:500);
T1Timestamp=0;
T2Timestamp=0;
T3Timestamp=0;
T4Timestamp=0;
GabCPD = 6;

%KbWait; %KbWait - readies MATLAB for a keypress
KbCheck; %kbcheck - detects keypress
GetSecs; %Marks keypress with timestamp for calculating RT


%I call these ahead of time so when they are first callled in the actual
%experiment they are ready to go and don't lag

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------

LeftLoc = [CX-170 CY-35 CX-100 CY+35];
RightLoc = [CX+100 CY-35 CX+170 CY+35];
CenterLoc = [CX-35 CY-35 CX+35 CY+35];
WholeScreen = [CX-512 CY-384 CX+512 CY+384];

LeftHandLoc = [CX-205 CY-5 CX-195 CY+5];
RightHandLoc = [CX+195 CY-5 CX+205 CY+5];
FixationLoc = [CX-3 CY-3 CX+3 CY+3];

ContrastList = [.06 .09 .13 .17 .22 .29 .37 .54 .78];

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =21; % # of blocks
HandSide = 3; %1=left;2=right; 3=none
StandSide = 2; %1=left;2=right
StandOrient = 2; %1=left;2=right
CompContrast = 9; %1=small; 2=medium; 3=large
RepetitionInBlock = 2; 
%HandSwitchTrials = 32;

BlockTrial = StandSide*StandOrient*CompContrast*RepetitionInBlock; % #=36*reps
PracTrial = 70;

%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------

TrHandSide = zeros(1,TotalBlock);

for i=0 : TotalBlock-1
    
	TrHandSide(i+1) = mod(i, HandSide);
	TrHandSide(i+1) = floor(TrHandSide(i+1))+1;
    
end

BlockCount = zeros(1,BlockTrial);%creates vector of size TotalTrial
TrStandSide = zeros(1,BlockTrial);
TrStandOrient = zeros(1,BlockTrial);
TrCompContrast = zeros(1,BlockTrial);
RT = zeros(1,BlockTrial);
Response = zeros(1,BlockTrial);
Accuracy = zeros(1,BlockTrial);
Order = zeros(2,BlockTrial/2);
TrialCount = zeros(1,BlockTrial);


for i=0 : BlockTrial-1
        
    TrStandOrient(i+1) = mod(i/18, StandOrient);
	TrStandOrient(i+1) = floor(TrStandOrient(i+1))+1; 
    
	TrStandSide(i+1) = mod(i/9, StandSide);
	TrStandSide(i+1) = floor(TrStandSide(i+1))+1;
        
    TrCompContrast(i+1) = mod(i, CompContrast);
	TrCompContrast(i+1) = floor(TrCompContrast(i+1))+1;
    
end
    
%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

  
% We choose a text size of 24 pixels
Screen('TextSize', window, 20);

% % This is our intro text. The '\n' sequence creates a line-feed (like hitting 'enter' in word processor):


Screen('PutImage', window, imread('WelcomeScreen.png'), WholeScreen);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

if expType == 'e'

    Screen('PutImage', window, imread('GaborDisplay.png'), WholeScreen);
    Screen(window, 'FillRect', black, FixationLoc);
    StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .22)*256;
    CompGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .78)*256;
    Screen('PutImage', window, StandGab, LeftLoc);
    Screen('PutImage', window, CompGab, RightLoc);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

    Screen('PutImage', window, imread('GaborTaskTiltR.png'), WholeScreen);
    Screen(window, 'FillRect', black, FixationLoc);
    StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .78)*256;
    Screen('PutImage', window, StandGab, CenterLoc);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);
        
    Screen('PutImage', window, imread('GaborTaskTiltL.png'), WholeScreen);
    Screen(window, 'FillRect', black, FixationLoc);
    StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .78)*256;
    Screen('PutImage', window, StandGab, CenterLoc);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);
    
     PracText = ['Now you will practice responding.\n'...
           'Let the experimenter know if you have any questions about choosing a response.\n\n'...          
           'Use the footpedals to indicate the orientation of the high contrast pattern.'];
    Screen(window, 'FillRect', grey);
    
        % example 1    
        DrawFormattedText(window, PracText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .78)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen('Flip', window);
        WaitSecs(.5);
        
        while 1
            [keyIsDown, End_Time, keyCode]=KbCheck(-1);
            if keyIsDown 
                break
            end
            WaitSecs(0.0001);
        end
        
        if strcmp(KbName(keyCode),'z')
                 BlockText = ['Correct!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = green;
        else
                 BlockText = ['Incorrect!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = red;
                 
        end
        
        DrawFormattedText(window, BlockText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .78)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen(window, 'FrameOval', FeedBColor, RightLoc, 3, 3);
        Screen('Flip', window);
        WaitSecs(1);
        KbWait(-1);
          
        PracText = ['Try some more.'];
        
        % example 2
        DrawFormattedText(window, PracText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .78)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen('Flip', window);
        WaitSecs(.5);
        
        while 1
            [keyIsDown, End_Time, keyCode]=KbCheck(-1);
            if keyIsDown 
                break
            end
            WaitSecs(0.0001);
        end
        
        if strcmp(KbName(keyCode),'m')
                 BlockText = ['Correct!  The high contrast pattern is tilted right.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = green;
        else
                 BlockText = ['Incorrect!  The high contrast pattern is tilted right.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = red;
        end
        
        DrawFormattedText(window, BlockText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .78)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen(window, 'FrameOval', FeedBColor, RightLoc, 3, 3);
        Screen('Flip', window);
        WaitSecs(1);
        KbWait(-1);
       
        % example 3        
        DrawFormattedText(window, PracText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .06)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen('Flip', window);
        WaitSecs(.5);  
        
        while 1
            [keyIsDown, End_Time, keyCode]=KbCheck(-1);
            if keyIsDown 
                break
            end
            WaitSecs(0.0001);
        end
        
        if strcmp(KbName(keyCode),'m')
                 BlockText = ['Correct!  The high contrast pattern is tilted right.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = green;
        else
                 BlockText = ['Incorrect!  The high contrast pattern is tilted right.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = red;
        end
        
        DrawFormattedText(window, BlockText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .06)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen(window, 'FrameOval', FeedBColor, LeftLoc, 3, 3);
        Screen('Flip', window);
        WaitSecs(1);
        KbWait(-1);
        
        % example 4
        DrawFormattedText(window, PracText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .09)*256;
        Screen('PutImage', window, StandGab, RightLoc);
        Screen('PutImage', window, CompGab, LeftLoc);
        Screen('Flip', window);
        WaitSecs(.5);
        
        while 1
            [keyIsDown, End_Time, keyCode]=KbCheck(-1);
            if keyIsDown 
                break
            end
            WaitSecs(0.0001);
        end
        
        if strcmp(KbName(keyCode),'z')
                 BlockText = ['Correct!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = green;
        else
                 BlockText = ['Incorrect!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = red;
        end
        
        DrawFormattedText(window, BlockText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .09)*256;
        Screen('PutImage', window, StandGab, RightLoc);
        Screen('PutImage', window, CompGab, LeftLoc);
        Screen(window, 'FrameOval', FeedBColor, RightLoc, 3, 3);
        Screen('Flip', window);
        WaitSecs(1);
        KbWait(-1);
        
        % example 5
        DrawFormattedText(window, PracText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .09)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen('Flip', window);
        WaitSecs(.5);

        
        while 1
            [keyIsDown, End_Time, keyCode]=KbCheck(-1);
            if keyIsDown 
                break
            end
            WaitSecs(0.0001);
        end
        
        if strcmp(KbName(keyCode),'z')
                 BlockText = ['Correct!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = green;
        else
                 BlockText = ['Incorrect!  The high contrast pattern is tilted left.\n'...
                     'Press either footpad to continue.'];
                 FeedBColor = red;
        end
        
        DrawFormattedText(window, BlockText, 'center', 100, black);
        Screen(window, 'FillRect', black, FixationLoc);
        StandGab = gabor([70 70], GabCPD, -45, rand, 12 , 0.5, .22)*256;
        CompGab = gabor([70 70], GabCPD, 45, rand, 12 , 0.5, .09)*256;
        Screen('PutImage', window, StandGab, LeftLoc);
        Screen('PutImage', window, CompGab, RightLoc);
        Screen(window, 'FrameOval', FeedBColor, LeftLoc, 3, 3);
        Screen('Flip', window);
        WaitSecs(1);
        KbWait(-1);
     
 
    Screen('PutImage', window, imread('HandDescription.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

    Screen('PutImage', window, imread('HandDescription2.png'), WholeScreen);
    Screen(window, 'FillRect', black, FixationLoc);
    Screen(window, 'FillOval', black, LeftHandLoc);
    Screen(window, 'FillOval', black, RightHandLoc);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

    Screen('PutImage', window, imread('GaborPrac.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);    
   
end

Screen(window, 'FillRect', grey); 
FlushEvents('keyDown'); 

BlockOrder = randperm(TotalBlock);%Randomizes order of presentation of each block type  
    
for Block = 0:TotalBlock  
    

%-----------------------------------------------------------------
%	Present Instruction/Block
%-----------------------------------------------------------------
  
Screen('TextSize', window, 20);

if (or(Block ==0,mod(Block,7) == 1))
    
    if Block ==0
    
         BlockText = ['You will now begin the practice trials.\n' ...
        'Press a foot pad to begin\n' ];

    elseif Block ==1
    
        BlockText = ['You will now begin the full length blocks.\n' ...
        'You will have an opportunity to take\n' ...
        'breaks over the course of the trials.\n' ...
        'Press a foot pad to begin\n' ];

    elseif Block > 1;
    
        BlockText = ['Time for a break.\n' ...
        'Take a minute to rest your eyes and get comfortable.\n' ...
        'Press a foot pad to continue\n' ];

    end

    
    Screen(window, 'FillRect', grey); %clears screen
    DrawFormattedText(window, BlockText, 'center', 'center', black);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

end 


if Block == 0
    if PGroup == 1
        
    HandText = ['Raise just your LEFT hand up to the side of the screen.\n' ...
    'Wait for the experimenter to adjust\n' ...
    'the wooden dowels before continuing.\n\n' ...
    'Press a foot pad when ready to continue\n' ];

    else
       
    HandText = ['Raise just your RIGHT hand up to the side of the screen.\n' ...
    'Wait for the experimenter to adjust\n' ...
    'the wooden dowels before continuing.\n\n' ...
    'Press a foot pad when ready to continue\n' ];
        
    end

elseif TrHandSide(BlockOrder(Block)) == 1
        
    HandText = ['Raise just your LEFT hand up to the side of the screen.\n' ...
    'Wait for the experimenter to adjust\n' ...
    'the wooden dowels before continuing.\n\n' ...
    'Press a foot pad when ready to continue\n' ];
    
elseif TrHandSide(BlockOrder(Block)) == 2
        
    HandText = ['Raise just your RIGHT hand up to the side of the screen.\n' ...
    'Wait for the experimenter to adjust\n' ...
    'the wooden dowels before continuing.\n\n' ...
    'Press a foot pad when ready to continue\n' ];

else 
    
    HandText = ['LOWER both your hands to rest on the table away from the screen.\n' ...
    'Wait for the experimenter to adjust\n' ...
    'the wooden dowels before continuing.\n\n' ...
    'Press a foot pad when ready to continue\n' ];
    
end
    
if Block > 1
    strcat('Now you will switch hand positions.\n',HandText);
else 
    strcat('\n',HandText);
end
    
DrawFormattedText(window, HandText, 'center', 30, black);
Screen(window, 'FillRect', black, FixationLoc);
Screen(window, 'FillOval', black, LeftHandLoc);
Screen(window, 'FillOval', black, RightHandLoc);
Screen('Flip', window);
WaitSecs(1);

KbWait(-1);
Screen(window, 'FillRect', grey);
Screen(window, 'FillRect', black, FixationLoc);
Screen('Flip', window);
WaitSecs(2);
FlushEvents('keyDown');

%-----------------------------------------------------------------
% Randomization of Trials
%-----------------------------------------------------------------   

Order = randperm(BlockTrial);%Randomizes order of presentation of each trial type 

if Block ==0
    TotalTrial = PracTrial;
else
    TotalTrial = BlockTrial;
end
 
for Trial = 1 : TotalTrial %tells MATLAB to loop through the code contained 
                           %in the following loop until it reaches the last
                           %trial (TotalTrial)
                    
%-----------------------------------------------------------------
%  Choosing Target Type
%-----------------------------------------------------------------
StandPhase = rand;
CompPhase = rand;
if TrStandOrient(Order(Trial))==1
    SOrient = -45;
    COrient = 45;
else
    SOrient = 45;
    COrient = -45;
end
    

StandGab = gabor([70 70], GabCPD, SOrient, rand, 12 , 0.5, .22)*256;
CompGab = gabor([70 70], GabCPD, COrient, rand, 12 , 0.5, ContrastList(TrCompContrast(Order(Trial))))*256;

%-----------------------------------------------------------------
%  Linking Stimulus Conditions to Display Types
%-----------------------------------------------------------------

if TrStandSide(Order(Trial)) == 1  
    StandLoc = LeftLoc;
    CompLoc = RightLoc;
else 
    StandLoc = RightLoc;
    CompLoc = LeftLoc;
end    
    
%---------------------------------------------------
% Presenting the Stimuli
%---------------------------------------------------
  
Screen(window, 'FillRect', black, FixationLoc);
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(.5);

Screen(window, 'FillRect', black, FixationLoc);
Screen('PutImage', window, StandGab, StandLoc);
Screen('PutImage', window, CompGab, CompLoc);
[T1Timestamp Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
    
Screen(window, 'FillRect', grey);
Screen(window, 'FillRect', black, FixationLoc);
[T4Timestamp]=Screen('Flip', window, (Begin_Time + .04));

while 1
    [keyIsDown, End_Time, keyCode]=KbCheck(-1);

    if keyIsDown 
        break
    elseif GetSecs - Begin_Time > 10
        break
    end
    WaitSecs(0.0001);
end

%---------------------------------------------------
% Response Coding
%---------------------------------------------------

RTTrial = (End_Time-Begin_Time)*1000;

    if strcmp(KbName(keyCode),'z') %tilt left
        Response(Trial) = 1;
    elseif strcmp(KbName(keyCode),'m') %tilt right
        Response(Trial) = 2;
    end



    if TrStandOrient(Order(Trial)) == Response(Trial) %responded to standard
        Accuracy(Trial) = 1;
    else 
        Accuracy(Trial) = 0;
    end

 
%---------------------------------------------------
% Saving the file
%---------------------------------------------------


    
RT(1,Trial)=RTTrial; %Determines RT using timestamps from above

if Block == 0

    if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
       
        Save = [Block; 0; 0; Trial; Order(Trial); TrStandOrient(Order(Trial)); TrCompContrast(Order(Trial)); TrStandSide(Order(Trial)); ...
        Response(Trial); Accuracy(Trial); RT(Trial); T1Timestamp; T2Timestamp; T3Timestamp; T4Timestamp];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f\n', Save);
    end
    
else

    if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial

        Save = [Block; BlockOrder(Block); TrHandSide(BlockOrder(Block)); Trial; Order(Trial); TrStandOrient(Order(Trial)); TrCompContrast(Order(Trial)); TrStandSide(Order(Trial)); ...
        Response(Trial); Accuracy(Trial); RT(Trial); T1Timestamp; T2Timestamp; T3Timestamp; T4Timestamp];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f\n', Save);
    end
end
    

%-------------------End Loop-----------------------------------------    
    
end %closes the for Trial=1:TotalTrial loop
end

    Screen(window, 'FillRect', black, FixationLoc);
    Screen('Flip', window);%flips the window from the beginning window
    WaitSecs(1);

%--------------------------------------------------------------------
%	Ending experiment
%--------------------------------------------------------------------
    fclose(FID);

Screen('TextSize', window, 24);
IntroText = ['You have completed the experiment\n' ...
    'Please see the experimenter\n'];
DrawFormattedText(window, IntroText, 'center', 'center', black);
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);
    
KbWait(-1);

ShowCursor;
SCREEN('CloseAll');
