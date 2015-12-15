%----------------------------------------------------------------
%  Will Bush
%  Auditory attention task
%
%  Spring 2014
%
%  Contains all conditions and bocks
%----------------------------------------------------------------



% Make sure the script is running on Psychtoolbox3:
AssertOpenGL;

%These commands clear the cache of garbage left from previous experimetnal
%runs

clear all % clear memory
close all %just to be sure
Screen('CloseAll') %just to be sure
clc; %clear monitor


%addpath(genpath('C:/Users/Will/Desktop/HandTrast/HillyardTask'));

%-----------------------------------------------------------------
%	Set up subject number, tell MATLAB what to name data file
%-----------------------------------------------------------------
% input subject id

% cd /Users/Will/Desktop/HandTrast/HillyardTask

% disp('e: experiment, d: demo');
% expType=input('Enter imstruction type: ','s');

ID = input('Enter Subject Number: ','s');

%set default values for input arguments
if ~exist('ID','var')
        ID=66;
end


% warn if duplicate sub ID
FileName =  strcat(ID, '_Hillyard_aud.csv'); 
if exist(FileName,'file')
    resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type y for overwrite]'], 's');

    if ~strcmp(resp,'y') %abort experiment if overwriting was not confirmed
        disp('experiment aborted')
        return
    end
end


        FID = fopen(FileName, 'w');
        fprintf(FID, 'Block, BlockOrder, AttendSide, Trial, TrialOrder, TrStimType, TrStimSide, Response, Accuracy, RT, T1, T2\n'); %\n=enter - moves to next row
    
        
%-----------------------------------------------------------------
%	Setting up random seed, screen, and colors
%-----------------------------------------------------------------

rand('twister', sum(100*clock)); %generates new random order of trial presentation each time program starts
HideCursor; %hides cursor so subjects can't see it

screen = 0; %opens the main presentation window with below parameters
[window,rect] = Screen('OpenWindow', 0, [0 0 0], [0 0 800 600]);
CX=400;		
CY=300;
Framerate = Screen('FrameRate', screen);
WholeScreen = [CX-400 CY-300 CX+400 CY+300];
colordepth = 32;

black = [0 0 0];
white = [255 255 255];
grey = [128 128 128];
BCKColor = grey;
StandLBeep = sin(1:1:999);
DevLBeep = sin(1:1.1:1100);
StandRBeep = sin(1:0.5:500);
DevRBeep = sin(1:0.55:550);
T1Timestamp=0;
T2Timestamp=0;
T3Timestamp=0;
T4Timestamp=0;

serialattached = 0;

C_ISI = 500;
V_ISI = 400;

%KbWait; %KbWait - readies MATLAB for a keypress
KbCheck; %kbcheck - detects keypress
GetSecs; %Marks keypress with timestamp for calculating RT


%I call these ahead of time so when they are first callled in the actual
%experiment they are ready to go and don't lag
 
%         KBoards = GetKeyboardIndices;

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------

FixationLoc = [CX-5 CY-5 CX+5 CY+5];

LeftStand = [StandLBeep; zeros(size(StandLBeep))];
LeftDev = [DevLBeep; zeros(size(DevLBeep))];

RightStand = [zeros(size(StandRBeep)); StandRBeep];
RightDev = [zeros(size(DevRBeep)); DevRBeep];

%-----------------------------------------------------------------
% Read Images - use imread to read in all image files
%-----------------------------------------------------------------

CueL= imread('CueLeft.png');
CueR = imread('CueRight.png');
Fix = imread('Fixation.png');
FixPlace = imread('FixationPlaceholders.png');

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =16; % # of blocks
AttendSide = 2; %1=Left;2=Right
StimSide = 2; %1=Left;2=Right
StimType = 2; %1=Standard;2=Target
RepetitionInBlock = 10; %multiple of 5 to maintain stand/tar balance

BlockTrial = StimSide*StimType*RepetitionInBlock; % Total Trials = 20
PracTrial = 20;

%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------

BlockCount = zeros(1,BlockTrial);%creates vector of size TotalTrial
TrialCount = zeros(1,BlockTrial);
TrStimSide = zeros(1,BlockTrial);
TrStimType = zeros(1,BlockTrial);
TrTrialVar = zeros(1,BlockTrial);
RT = zeros(1,BlockTrial);
Response = zeros(1,BlockTrial);
Accuracy = zeros(1,BlockTrial);
Order = zeros(2,BlockTrial/2);
BlAttendSide = zeros(1,TotalBlock);

for i=1 : BlockTrial
        
    if (mod(i,5) < 1)
        TrStimType(i) = 2;
        TrTrialVar(i) = 2;
    else 
        TrStimType(i) = 1;
        TrTrialVar(i) = 1;
    end 
    
    if (mod(i,10) < 5)
        TrStimSide(i) = 1;
    else 
        TrStimSide(i) = 2;
        TrTrialVar(i) = TrTrialVar(i)+2;
    end 
    
end
for i=1 : TotalBlock
        
    BlAttendSide(i) = mod(i, AttendSide)+1;

end


    
%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

  
% We choose a text size of 24 pixels
Screen('TextSize', window, 24);
 Screen(window, 'FillRect', grey); 
% This is our intro text. 
 
 BlockText = ['Welcome to the experiment.\n' ...
              'Make yourself comfortable while we make sure all\n' ...
              'the right wires are connected and buttons are pushed.\n' ];
 DrawFormattedText(window, BlockText, 'center', 'center', [0 0 0]);
 Screen('Flip', window);
 WaitSecs(1);
 pause

Screen(window, 'FillRect', grey); 
FlushEvents('keyDown'); 

BlockOrder = randperm(TotalBlock);%Randomizes order of presentation of each block type  

%----------------------------------------------------------------
% setup ports
%----------------------------------------------------------------
disp('Initializing Ports');

if serialattached
    sprod = serial('COM1','baudrate',9600);
    fopen(sprod);
    fwrite(sprod,'a');
    fclose(sprod);
    s = serial('COM1','baudrate',19200);
    set(s,'InputBufferSize',1);
    set(s,'ReadAsyncMode','manual');
    fopen(s);
end

pport = io64;
status = io64(pport);
io64(pport,888,0);
WaitSecs(0.01);


sendcmd(pport,'startSession');

%----------------------------------------------------------------
% Start experiment
%----------------------------------------------------------------

for Block = 1:TotalBlock  

%-----------------------------------------------------------------
%	Present Instruction/Block
%-----------------------------------------------------------------
  
Screen('TextSize', window, 24);

if (or(Block ==0,mod(Block,8) == 1))
    
    if Block ==0
    
         BlockText = ['You will now have a chance to practice the task.\n' ...
        'Press any button to start the practice trials\n' ];

    elseif Block ==1
    
        BlockText = ['You will now begin the full length blocks.\n' ...
        'You will have an opportunity to take\n' ...
        'breaks over the course of the trials.\n' ...
        'Press any button to begin\n' ];

    elseif Block > 1;
    
        BlockText = ['Time for a break.\n' ...
        'Take a minute to rest your eyes and get comfortable.\n' ...
        'Press any button to continue\n' ];

    end

    DrawFormattedText(window, BlockText, 'center', 'center', [0 0 0]);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);

 end 



if Block == 0
    if mod(ID,2)==0
    HandText = ['Monitor sounds on the LEFT side for deviants.\n' ...
    'Press a button when ready to continue\n' ];    
    else
    HandText = ['Monitor sounds on the RIGHT side for deviants.\n' ...
    'Press a button when ready to continue\n' ];
    end   
else
    if BlAttendSide(BlockOrder(Block)) == 1
    HandText = ['Monitor sounds on the LEFT side for deviants.\n' ...
    'Press a button when ready to continue\n' ];    
    else
    HandText = ['Monitor sounds on the RIGHT side for deviants.\n' ...
    'Press a button when ready to continue\n' ];
    end   
    
    
 end
    
    Screen(window, 'FillRect', grey);
    DrawFormattedText(window, HandText, 'center', 30, [0 0 0]);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait(-1);
    
    Screen(window, 'FillRect', grey); %clears screen
FlushEvents('keyDown');


Screen(window, 'FillOval', black, FixationLoc);

Screen('Flip', window);
WaitSecs(3);



%-----------------------------------------------------------------
% Randomization of Trials
%-----------------------------------------------------------------   

Order = randperm(BlockTrial);%Randomizes order of presentation of each trial type 

if Block ==0
    TotalTrial = PracTrial;
    trialcode = 2;
else
    TotalTrial = BlockTrial;
    trialcode = 1;
end
 
%-----------------------------------------------------------------
% Trials loop
%----------------------------------------------------------------- 

for Trial = 1 : TotalTrial %Trial loop

    TrISI = (C_ISI+(rand*V_ISI))*.001;
    TBtime = GetSecs;    
        


    %-----------------------------------------------------------------
    %  Choosing Stim
    %-----------------------------------------------------------------

    if TrStimType(Order(Trial)) == 1 
        if TrStimSide(Order(Trial)) == 1 
            Stim = LeftStand';
        else
            Stim = RightStand';
        end
    else
        if TrStimSide(Order(Trial)) == 1 
            Stim = LeftDev';
        else
            Stim = RightDev';
        end
    end

    while (GetSecs-TBtime) < (TrISI)
    end

    % output trial info to HERPES
    sendcmd(pport,'trialCodes');
    sendcode(pport,Block,2); % block (expects 2 digits)
    sendcode(pport,Trial,2); % trial (expects 2 digits)
    sendcode(pport,trialcode,1); % trial code prac/noprac (expects 1 digit)
    sendcode(pport,1,1); %trial event tag

    sendcmd(pport,'startEpoch'); % send start code to HERPES
    T1Timestamp = GetSecs;

    %---------------------------------------------------
    % Presenting the Stimuli
    %---------------------------------------------------



    while (GetSecs-T1Timestamp) < .195
    end



    Screen(window, 'FillRect', grey); 
    Screen(window, 'FillOval', black, FixationLoc);


    [T2Timestamp, Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
    sound(Stim);
    sendcode(pport,1,1);

    Screen(window, 'FillRect', grey); 



    Screen(window, 'FillOval', black, FixationLoc);

    [T3Timestamp]=Screen('Flip', window, (Begin_Time + .05));

    %---------------------------------------------------
    % Keyboard Response
    %---------------------------------------------------

    while 1
        [keyIsDown, End_Time, keyCode]=KbCheck;

        if keyIsDown 
            %WaitSecs (1 - (End_Time - Begin_Time))
            break
        elseif GetSecs - Begin_Time > 1.5
            break
        end
        WaitSecs(0.0001);
    end

    while GetSecs < Begin_Time + 1.5;
    end

    %---------------------------------------------------
    % Response Coding
    %---------------------------------------------------

    RTTrial = (End_Time-Begin_Time)*1000;
    RT(Trial)=RTTrial; %Determines RT using timestamps from above

    Response(Trial) = 0;
    Accuracy(Trial) = 0;

    if strcmp(KbName(keyCode),'b')
      Response(Trial) = 1;
      if TrStimType(Order(Trial)) == 1
          Accuracy(Trial) = 0;
      else
          if TrStimType(Order(Trial)) == BlAttendSide(BlockOrder(Block))
          Accuracy(Trial) = 1;
          end
      end
    else
      if TrStimType(Order(Trial)) == 1
          Accuracy(Trial) = 2;
      else
          Accuracy(Trial) = 3;
      end
    end
     sendcode(pport,5,1);
     keyCode=1;
    %---------------------------------------------------
    % Send response codes
    %---------------------------------------------------

    sendcmd(pport,'respCodes');
    sendcode(pport,keyCode,1); % response code
    sendcode(pport,1111,4); % rt
    sendcode(pport,10,1); % error code
     
    %---------------------------------------------------
    % Saving the file
    %---------------------------------------------------


        
    %RT(Trial)=RTTrial; %Determines RT using timestamps from above

    if Block == 0

        if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
           
            Save = [Block; 0; 0; Trial; Order(Trial); TrStimType(Order(Trial));TrStimSide(Order(Trial));...
            Response(Trial); Accuracy(Trial); RT(Trial); T1Timestamp; T2Timestamp; ];

            fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
        end
        
    else

        if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial

            Save = [Block; BlockOrder(Block); BlAttendSide(BlockOrder(Block)); Trial; Order(Trial); TrStimType(Order(Trial)); TrStimSide(Order(Trial)); ...
            Response(Trial); Accuracy(Trial); RT(Trial); T1Timestamp; T2Timestamp];

            fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
        end
    end
        


    while GetSecs < Begin_Time + 1 + TrISI;
    end
%-------------------End Loop-----------------------------------------    
    
end %closes trial loop
end %closes Block loop

   Screen('PutImage', window, FixPlace, WholeScreen);
    Screen('Flip', window);%flips the window from the beginning window
    WaitSecs(1);

%--------------------------------------------------------------------
%	Ending experiment
%--------------------------------------------------------------------

sendcmd(pport,'endSession');    
fclose(FID);

Screen('TextSize', window, 24);
IntroText = ['You have completed the experiment\n' ...
    'Please see the experimenter\n'];
DrawFormattedText(window, IntroText, 'center', 'center');
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);
    
pause

%fclose(s); % close serial port
%ListenChar(0); % echo keyboard characters
ShowCursor;
Screen('CloseAll');
