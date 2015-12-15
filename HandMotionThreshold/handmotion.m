%----------------------------------------------------------------
%  Will Bush
%  Flanker Task - 50/50 Validity, 2 Locations
%
%  Spring 2013
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

cd /Users/grad_user/Dropbox/Will_Experiments/GaborOfReach_move_ed

%  disp('e: experiment, d: demo');
%  expType=input('Enter imstruction type: ','s');
expType='d';
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
FileName =  strcat(ID, '_Hand_Motion_t.csv'); 
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
%[window,rect] = Screen('OpenWindow', screen, [0 0 0], [0 0 1024 768]);
screenInfo = openExperiment(324, 585, 0);
window = screenInfo.curWindow;
rect = screenInfo.screenRect;
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

%KbWait; %KbWait - readies MATLAB for a keypress
KbCheck; %kbcheck - detects keypress
GetSecs; %Marks keypress with timestamp for calculating RT


%I call these ahead of time so when they are first callled in the actual
%experiment they are ready to go and don't lag

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------

LeftLoc = [-380 0 200];
RightLoc = [380 0 200];
CenterLoc = [0 0 50];
WholeScreen = [CX-512 CY-384 CX+512 CY+384];

LeftHandLoc = [CX-205 CY-5 CX-195 CY+5];
RightHandLoc = [CX+195 CY-5 CX+205 CY+5];
FixationLoc = [CX-3 CY-3 CX+3 CY+3];

%ContrastList = [.1 .2 .3 .4 .5 .6 .7 .8 .9];
StartingContrast = .8;
StepSize = .08;

ContrastList = [.8 .8 .8 .8 .8 .8 .8 .8];
AccuracyList = [1 1 1 1 1 1 1 1];
StepList = [.08 .08 .08 .08 .08 .08 .08 .08];
StandGab = 0;

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =16; % # of blocks
HandSide = 2; %1=left;2=right; 3=none
StandSide = 2; %1=left;2=right
StandOrient = 2; %1=left;2=right
%CompContrast = 9; %1=small; 2=medium; 3=large
RepetitionInBlock = 10; 
%HandSwitchTrials = 32;

BlockTrial = StandSide*StandOrient*RepetitionInBlock; % #=36*reps
PracTrial = 30;

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
        
    TrStandOrient(i+1) = mod(i/2, StandOrient);
	TrStandOrient(i+1) = floor(TrStandOrient(i+1))+1; 
    
	TrStandSide(i+1) = mod(i, StandSide);
	TrStandSide(i+1) = floor(TrStandSide(i+1))+1;
    
end
    
%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

  
% We choose a text size of 24 pixels
Screen('TextSize', window, 20);

% % This is our intro text. 


Screen('PutImage', window, imread('WelcomeScreen.png'), WholeScreen);
Screen('Flip', window);
WaitSecs(1);
KbWait(-1);

if expType == 'd'

    Screen('PutImage', window, imread('DotFieldDisplay.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);
    
    Screen(window, 'FillRect', grey, FixationLoc);
    Screen('Flip', window);
    WaitSecs(2);
    
    dotInfo = createMinDotInfo(1);

    dotInfo.coh = [0 800];
    dotInfo.apXYD = [LeftLoc; RightLoc];
    dotInfo.dir = [180 0];
    dotInfo.maxDotTime = [.3 .3];
    dotInfo.dotSize = 1;
    dotInfo.maxDotsPerFrame = 5000;
    screenInfo.ppd = 10;
    
        for i=1:8
            if mod(i,2)==1
                dotInfo.apXYD = [LeftLoc; RightLoc];
            else
                dotInfo.apXYD = [RightLoc; LeftLoc];
            end
            
            if mod(i,4)<2
                dotInfo.dir = [180 0];
            else
                dotInfo.dir = [0 180];
            end
            
            [frames, rseed, Begin_Time, End_Time, response_hold, response_time] = dotsX(screenInfo, dotInfo);
            Screen(window, 'FillRect', grey, FixationLoc);
            Screen('Flip', window);
            WaitSecs(2);
        end

    Screen('PutImage', window, imread('DotFieldTask.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);
        
    Screen('PutImage', window, imread('HandDesc.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

    Screen('PutImage', window, imread('DotFieldPrac.png'), WholeScreen);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);   
   
end

Screen(window, 'FillRect', black); 
FlushEvents('keyDown'); 

BlockOrder = randperm(TotalBlock);%Randomizes order of presentation of each block type  
    
for Block = 0:TotalBlock  
    

%-----------------------------------------------------------------
%	Present Instruction/Block
%-----------------------------------------------------------------
  
Screen('TextSize', window, 20);

if (or(Block ==0,mod(Block,5) == 1))
    
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

    
    Screen(window, 'FillRect', black); %clears screen
    DrawFormattedText(window, BlockText, 'center', 'center', white);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

end 

if expType == 'd'
    if Block == 0
        if PGroup == 1

        HandText = ['Raise just your LEFT hand up to the side of the screen.\n' ...
        'Press a foot pad when ready to continue\n' ];

        else

        HandText = ['Raise just your RIGHT hand up to the side of the screen.\n' ...
        'Press a foot pad when ready to continue\n' ];

        end

    else
        if TrHandSide(Block) == 1

            HandText = ['Raise just your LEFT hand up to the side of the screen.\n' ...
            'Press a foot pad when ready to continue\n' ];

        else 

            HandText = ['Raise just your RIGHT hand up to the side of the screen.\n' ...
            'Press a foot pad when ready to continue\n' ];
        end

    end


    if Block > 1
        strcat('Now you will switch hand positions.\n',HandText);
    else 
        strcat('\n',HandText);
    end

    DrawFormattedText(window, HandText, 'center', 30, white);
    Screen('Flip', window);
    WaitSecs(1);

    KbWait(-1);

    Screen(window, 'FillRect', grey, FixationLoc);
    Screen('Flip', window);
    FlushEvents('keyDown');

end
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

WaitSecs(2);                           
                           
%-----------------------------------------------------------------
%  Choosing Target Type
%-----------------------------------------------------------------

if TrStandOrient(Order(Trial))==1
    SOrient = 0;
    COrient = 180;
else
    SOrient = 180;
    COrient = 0;
end
    

if Block > 0
    CompDetermine = ((((TrHandSide(Block))-1)*4)+(((TrStandSide(Order(Trial)))-1)*2)+ TrStandOrient(Order(Trial)));
    CompGab = ContrastList(CompDetermine);
else 
  CompDetermine = 1;
  CompGab = .8;  
end

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

%-----------------------------------------------------------------
%  Create dot patterns
%-----------------------------------------------------------------

dotInfo = createMinDotInfo(1);

dotInfo.coh = [StandGab*1000 CompGab*1000];
dotInfo.apXYD = [StandLoc; CompLoc];
dotInfo.dir = [SOrient COrient];
dotInfo.maxDotTime = [.3 .3];
dotInfo.dotSize = 1;
dotInfo.maxDotsPerFrame = 5000;
screenInfo.ppd = 10;
    
%---------------------------------------------------
% Presenting the Stimuli
%---------------------------------------------------
  
[frames, rseed, Begin_Time, End_Time, response_hold, response_time] = dotsX(screenInfo, dotInfo);
Screen(window, 'FillRect', grey, FixationLoc);
Screen('Flip', window);
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
     else
         Response(Trial) = 0;
     end


    if TrStandOrient(Order(Trial)) == Response(Trial) %responded to standard
        Accuracy(Trial) = 1;
        if Block > 0
        ContrastList(CompDetermine) = ContrastList(CompDetermine)- StepList(CompDetermine);
            if ContrastList(CompDetermine)<0
              ContrastList(CompDetermine) = 0;
            end
        if Trial > 2
            if AccuracyList(CompDetermine) == 0 && StepList(CompDetermine) > .01 
                StepList(CompDetermine) = StepList(CompDetermine)/2;
            end   
        end
        end

    else 
        Accuracy(Trial) = 0;
        if Block > 0
            ContrastList(CompDetermine) = ContrastList(CompDetermine)+ (3*StepList(CompDetermine));
            if ContrastList(CompDetermine)>1
              ContrastList(CompDetermine) = 1;
            end
            if Trial > 2
                if AccuracyList(CompDetermine) == 1 && StepList(CompDetermine) > .01
                    StepList(CompDetermine) = StepList(CompDetermine)/2;
                end    
            end
        end

    end
AccuracyList(CompDetermine) = Accuracy(Trial);
 
%---------------------------------------------------
% Saving the file
%---------------------------------------------------


    
RT(1,Trial)=RTTrial; %Determines RT using timestamps from above

if Block == 0

    if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
       
        Save = [Block; 0; 0; Trial; Order(Trial); TrStandOrient(Order(Trial)); ContrastList(CompDetermine); TrStandSide(Order(Trial)); ...
        Response(Trial); Accuracy(Trial); RT(Trial); Begin_Time; End_Time; response_time; 0];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f\n', Save);
    end
    
else

    if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial

        Save = [Block; BlockOrder(Block); TrHandSide(BlockOrder(Block)); Trial; Order(Trial); TrStandOrient(Order(Trial)); ContrastList(CompDetermine); TrStandSide(Order(Trial)); ...
        Response(Trial); Accuracy(Trial); RT(Trial); Begin_Time; End_Time; response_time; 0];

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
