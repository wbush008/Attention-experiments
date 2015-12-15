%----------------------------------------------------------------
%  Will Bush
%  
%  CDA experiment: 1v2 colors cued
%
%  Spring 2014
%
%----------------------------------------------------------------

AssertOpenGL;

%Clear all the things

clear all 
close all 
Screen('CloseAll') 
clc; 

%-----------------------------------------------------------------
%	Set up subject number, tell MATLAB what to name data file
%-----------------------------------------------------------------

ID = input('Enter Subject Number: ','s');

%set default values for input arguments
if ~exist('ID','var')
        ID=66;
end

%warn if duplicate sub ID
FileName =  strcat(ID, '_DuoChrome2.csv'); 
if exist(FileName,'file')
    resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type y for overwrite]'], 's');

    if ~strcmp(resp,'y') %abort experiment if overwriting was not confirmed
        disp('experiment aborted')
        return
    end
end

serialattached = 1;

FID = fopen(FileName, 'w');
fprintf(FID, 'Block, RunOrder, Run, Trial, MbCueColor, TrCueSide, TrCueColorNum, TrTwoColorChooseTarg, TrTargetType, TrTargetLoc, Response, Accuracy, RT, CueTime, TargetTime\n'); %\n=enter - moves to next row
      
%-----------------------------------------------------------------
%	Setting up random seed, screen, and colors
%-----------------------------------------------------------------

rand('twister', sum(100*clock)); %generates new random order of trial presentation each time program starts
HideCursor; %hides cursor so subjects can't see it

screen = 0; %opens the main presentation window with below parameters
[window,WholeScreen] = Screen('OpenWindow', 0, [0 0 0], [0 0 1024 768]);
CX=512;		
CY=384;
Framerate = Screen('FrameRate', screen);
colordepth = 32;
Beep=sin(1:0.5:500);

black = [0 0 0];
white = [255 255 255];
grey = [100 100 100];
red = [200 0 0];
green = [24 200 0];
blue = [0 0 200];
cyan = [0 198 200];
orange = [200 99 0];
purple = [200 0 198];
yellow = [200 193 0];
BCKColor = black;

%KbWait; %KbWait - readies MATLAB for a keypress
KbCheck; %kbcheck - detects keypress
GetSecs; %Marks keypress with timestamp for calculating RT

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------


timeout = 2;
C_ISI = 200;
V_ISI = 500;

%Search array params

CA_Number = 10;
SearchItemSize = 60;
LineWidth = 12;
CA_Radius = 300;

%Cue array params
CueSize = 40;
CueEcc_Y = 30;
CueEcc_X = 60;

CueBL_Loc =  [CX-(CueEcc_X+CueSize)           CY-(CueEcc_Y+CueSize)           CX-(CueEcc_X)               CY-(CueEcc_Y)];
CueUL_Loc =  [CX-(CueEcc_X+CueSize)           CY+(CueEcc_Y)                   CX-(CueEcc_X)               CY+(CueEcc_Y+CueSize)];
CueBR_Loc =  [CX+(CueEcc_X)                   CY-(CueEcc_Y+CueSize)           CX+(CueEcc_X+CueSize)       CY-(CueEcc_Y)];
CueUR_Loc =  [CX+(CueEcc_X)                   CY+(CueEcc_Y)                   CX+(CueEcc_X+CueSize)       CY+(CueEcc_Y+CueSize)];

BBBL_Loc = CueBL_Loc + [8 8 -8 -8];
BBUL_Loc = CueUL_Loc + [8 8 -8 -8];
BBBR_Loc = CueBR_Loc + [8 8 -8 -8];
BBUR_Loc = CueUR_Loc + [8  8 -8 -8];

BBB_Loc = [10 10 30 30];


CentLocArray = zeros(CA_Number, 4);

for i=1:CA_Number
Temp_X_Loc = CA_Radius*cos(2*pi*(i/CA_Number))+CX;
Temp_Y_Loc = CA_Radius*sin(2*pi*(i/CA_Number))+CY;
CentLocArray(i, :) = round([Temp_X_Loc-(SearchItemSize/2) Temp_Y_Loc-(SearchItemSize/2) Temp_X_Loc+(SearchItemSize/2) Temp_Y_Loc+(SearchItemSize/2)]);
end

GapSquare = [0 (SearchItemSize)/2-LineWidth LineWidth*2 (SearchItemSize)/2+LineWidth];

[OffScrWin, OffScrRect] = Screen('OpenOffscreenWindow',-1, black, [0 0 SearchItemSize SearchItemSize]);
Screen('FrameOval', OffScrWin, white, OffScrRect, LineWidth, LineWidth);
Screen('FillRect', OffScrWin, black, GapSquare);

[OffScrCue, OffScrCueRect] = Screen('OpenOffscreenWindow',-1, black, [0 0 CueSize CueSize]);
Screen('FillRect', OffScrCue, white, OffScrCueRect);
Screen('FillRect', OffScrCue, black, BBB_Loc);

[LeftCue, LeftCueRect] = Screen('OpenOffscreenWindow',-1, grey, [0 0 CueSize CueSize]);
Screen('FillRect', LeftCue, white, [0 0 CueSize/2 CueSize]);

[RightCue, RightCueRect] = Screen('OpenOffscreenWindow',-1, grey, [0 0 CueSize CueSize]);
Screen('FillRect', RightCue, white, [CueSize/2 0 CueSize CueSize]);

[Fixation, FixationRect] = Screen('OpenOffscreenWindow',-1, grey, [0 0 CueSize CueSize]);

FixationLoc = [CX-6 CY-6 CX+6 CY+6];

%-----------------------------------------------------------------
% Read Images - use imread to read in all image files
%-----------------------------------------------------------------

CueLoc_Array = {CueUL_Loc CueBL_Loc; CueUR_Loc CueBR_Loc};
   
    ColorArray = [235 235 0; 60 200 90; ...
            0 165 235; 110 60 200; 245 10 100; ...
       255 100 60];

%----------------------------------------------------------------
% setup ports
%----------------------------------------------------------------

disp('Initializing Ports');

serialattached = 1;

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

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TotalBlock =6; % # of blocks
CueSide = 2; % 1=left; 2=right
CueColorNum = 2; %1=one color; 2=two colors
CueColor = 6; % =10
TargetType = 2; %1=gap top; 2=gap bottom
TargetSide = 2; %1=target in left array; 2=target in right array
RunLength = 12; %repetitions of same cue color
RunsPerBlock = 4; %number of runs between breaks
trialcode = 1;


TotalRuns = CueColorNum*CueColor; % Variables to be randomized
PracTrial = 20;

%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------

SearchPos = zeros(1,9);
RunOrder = zeros(1,TotalRuns);
TrCueColorNum = zeros(1,TotalRuns);
TrCueColor = zeros(1,TotalRuns);

for i=0 : TotalRuns-1
    RunOrder(i+1) = i+1;
    TrCueColor(i+1) = mod(i,CueColor)+1;
    TrCueColorNum(i+1) = mod(floor(i/CueColor),CueColorNum)+1;
end

%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

Screen('TextSize', window, 24);
Screen(window, 'FillRect', black); 

%add some actual intro text later

BlockText = ['Welcome to the experiment.\n' ...
              'It is color/colourful.' ];
          
DrawFormattedText(window, BlockText, 'center', 'center', [200 200 200]);
Screen('Flip', window);
WaitSecs(1);
pause

Screen(window, 'FillRect', black); 
FlushEvents('keyDown'); 

%----------------------------------------------------------------
% Start experiment
%----------------------------------------------------------------

for Block = 1:TotalBlock  

%-----------------------------------------------------------------
% Randomize dose runs
%-----------------------------------------------------------------   

RandRunOrder = randperm(TotalRuns);

%-----------------------------------------------------------------
%Runs loop
%----------------------------------------------------------------- 
 for Run = 1 : TotalRuns
     
%-----------------------------------------------------------------
% Trials loop
%----------------------------------------------------------------- 

if TrCueColorNum(RandRunOrder(Run)) == 1
    Cue1_Color = ColorArray(TrCueColor(RandRunOrder(Run)),:);
    Cue2_Color = grey;
    Cue3_Color = ColorArray(TrCueColor(mod(RandRunOrder(Run)+2,6)+1),:);
    Cue4_Color = ColorArray(TrCueColor(mod(RandRunOrder(Run)+4,6)+1),:);
else
    Cue1_Color = ColorArray(TrCueColor(mod(RandRunOrder(Run)+2,6)+1),:);
    Cue2_Color = ColorArray(TrCueColor(mod(RandRunOrder(Run)+4,6)+1),:);
    Cue3_Color = ColorArray(TrCueColor(RandRunOrder(Run)),:);
    Cue4_Color = grey;
end
    
TrDistractorColors = ColorArray;
RemoveTargs = [TrCueColor(RandRunOrder(Run)) TrCueColor(mod(RandRunOrder(Run)+2,6)+1) TrCueColor(mod(RandRunOrder(Run)+4,6)+1)];
TrDistractorColors(RemoveTargs,:) = [];

if mod(Run,RunsPerBlock) == 1
    BlockText = ['Take a minute to rest your eyes and get comfortable.\n' ...
    'Press any button to continue\n' ];

    DrawFormattedText(window, BlockText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);

    if serialattached
        getresponse(s,0);
    else
        WaitSecs(1);
    end

    Screen(window, 'FillRect', black); %clears screen
    FlushEvents('keyDown');

    Screen('Flip', window);
    WaitSecs(2);
end

 for Trial = 1 : RunLength %Trial loop
TBtime = GetSecs;  
TrISI = (C_ISI+(rand*V_ISI))*.001;
%-----------------------------------------------------------------
%  Choosing Stim
%-----------------------------------------------------------------

% randomly choose some trial values, may want to balance later

TrCueSide = randi(CueSide,1);
TrCueVertPos = randi(2,1);
TrTwoColorChooseTarg = randi(2,1);
TrWithinSetDistractor = randi(2,1);
TrTargetType = randi(TargetType,1); 
TrTargetLoc = randi(CA_Number,1);

Cue1_Loc = CueLoc_Array(TrCueSide,TrCueVertPos);
Cue2_Loc = CueLoc_Array(TrCueSide,(mod(TrCueVertPos,2)+1));
Cue3_Loc = CueLoc_Array((mod(TrCueSide,2)+1),TrCueVertPos);
Cue4_Loc = CueLoc_Array((mod(TrCueSide,2)+1),(mod(TrCueVertPos,2)+1));

%Assign search array items and locations

if TrCueColorNum(RandRunOrder(Run)) == 1; 
    TrTargetColor = Cue1_Color;
else
    if TrTwoColorChooseTarg == 1
        TrTargetColor = Cue1_Color;
        TrWhitinDistractor = Cue2_Color;
    else
        TrTargetColor = Cue2_Color;
        TrWhitinDistractor = Cue1_Color;
    end
end


    
%---------------------------------------------------
% Presenting the Cue
%-------------------------------------------------

Screen(window, 'FillRect', black); 

% if TrCueSide==1
%     Screen('DrawTexture', window, LeftCue, LeftCueRect, FixationLoc);
% else
%     Screen('DrawTexture', window, RightCue, RightCueRect, FixationLoc);
% end
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue1_Loc{:}, (45),[],[],grey);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue2_Loc{:}, (45),[],[],grey);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue3_Loc{:}, (0),[],[],grey);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue4_Loc{:}, (0),[],[],grey);

Screen('Flip', window);
WaitSecs(.5);

Screen(window, 'FillRect', black); 

% if TrCueSide==1
%     Screen('DrawTexture', window, LeftCue, LeftCueRect, FixationLoc);
% else
%     Screen('DrawTexture', window, RightCue, RightCueRect, FixationLoc);
% end

% Screen('FillRect', window, Cue1_Color, Cue1_Loc{:});
% Screen('FillRect', window, Cue2_Color, Cue2_Loc{:});
% Screen('FillRect', window, Cue3_Color, Cue3_Loc{:});
% Screen('FillRect', window, Cue4_Color, Cue4_Loc{:});
% 
% Screen('FillRect', window, black, BBBL_Loc);
% Screen('FillRect', window, black, BBUL_Loc);
% Screen('FillRect', window, black, BBBR_Loc);
% Screen('FillRect', window, black, BBUR_Loc);
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue1_Loc{:}, (45),[],[],Cue1_Color);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue2_Loc{:}, (45),[],[],Cue2_Color);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue3_Loc{:}, (0),[],[],Cue3_Color);
Screen('DrawTexture', window, OffScrCue, OffScrCueRect, Cue4_Loc{:}, (0),[],[],Cue4_Color);

while (GetSecs-TBtime) < (TrISI)
end

sendcmd(pport,'trialCodes');
sendcode(pport,Block,2); % block (expects 2 digits)
sendcode(pport,Trial,2); % trial (expects 2 digits)
sendcode(pport,trialcode,1); % trial code prac/noprac (expects 1 digit)
sendcode(pport,1,1); %trial event tag

sendcmd(pport,'startEpoch'); % send start code to HERPES

T1Timestamp = GetSecs;

while (GetSecs-T1Timestamp) < .195
end

[T2Timestamp, Cue_Time]=Screen('Flip', window);
sendcode(pport,1,1);

WaitSecs(.1);

Screen(window, 'FillRect', black); 
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);

Screen('Flip', window);

WaitSecs(.9);

%---------------------------------------------------
% Presenting the Search array
%---------------------------------------------------

Screen(window, 'FillRect', black);
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);

for ItemPos = 1:CA_Number
    Item = TrDistractorColors(randi(3,1),:);
    ItemLoc = CentLocArray(ItemPos, :);
    ItemRot = randi(4,1)*.25;
    Screen('DrawTexture', window, OffScrWin, OffScrRect, ItemLoc, (ItemRot*360),[],[],Item);
end


TargLoc = CentLocArray(TrTargetLoc, :);
Screen('DrawTexture', window, OffScrWin, OffScrRect, TargLoc, ((TrTargetType*180)-90),[],[],TrTargetColor);

[Begin_Time]= Screen('Flip', window);

%---------------------------------------------------
% Keyboard Response
%---------------------------------------------------
% 
% while 1
%     [keyIsDown, End_Time, keyCode]=KbCheck;
% 
%     if keyIsDown 
%         break
%     elseif GetSecs - Begin_Time > 2
%         break
%     end
%     WaitSecs(0.0001);
% end

if serialattached
    [keyCode, End_Time] = getresponse(s,timeout);
else
    WaitSecs(2);
    resp = 1;
    End_Time = GetSecs;
end;

while GetSecs < Begin_Time + 2;
end

Screen(window, 'FillRect', black); 
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);

Screen('Flip', window);


%---------------------------------------------------
% Response Coding
%---------------------------------------------------

RTTrial = (End_Time-Begin_Time)*1000;


  if keyCode == 1
      Response = 1;
      if TrTargetType == 1
          Accuracy = 1;
      else
          Accuracy = 0;
      end
  elseif keyCode == 2
      Response = 2;
      if TrTargetType == 2
          Accuracy = 1;
      else
          Accuracy = 0;
      end
  else 
    Response = 0;
    Accuracy = 0;
  end

if Accuracy == 1
    respmade = 9;
    resperr = 2;
else
    respmade = 5;
    resperr = 10;
   % if Block == 0
        sound(Beep);
    %end
end

 % send response-made code
 sendcode(pport,respmade,1);
 keyCode=1;

%---------------------------------------------------
% Send response codes
%---------------------------------------------------

sendcmd(pport,'respCodes');
sendcode(pport,keyCode,1); % response code
sendcode(pport,(RTTrial),4); % rt
sendcode(pport,resperr,1); % error code
  
%---------------------------------------------------
% Saving the file
%---------------------------------------------------
   
if Block == 0

    if (Trial>=1) %starts saving data if subject has completed at least 1 trial
       
        Save = [Block; 0; Run; Trial; TrCueColor(RandRunOrder(Run));TrCueSide; TrCueColorNum(RandRunOrder(Run)); ...
        TrTwoColorChooseTarg; TrTargetType; TrTargetLoc; Response; Accuracy; RTTrial; Cue_Time; Begin_Time; ];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
    end
    
else

    if (Trial>=1) %starts saving data if subject has completed at least 1 trial

        Save = [Block; RandRunOrder(Run); Run; Trial; TrCueColor(RandRunOrder(Run));TrCueSide; TrCueColorNum(RandRunOrder(Run)); ...
        TrTwoColorChooseTarg; TrTargetType; TrTargetLoc; Response; Accuracy; RTTrial; Cue_Time; Begin_Time; ];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
    end
end
    


%-------------------End Loop-----------------------------------------    
    
end %closes trial loop
end %closes runs loop
end %closes Block loop


Screen(window, 'FillRect', grey); 
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);

%--------------------------------------------------------------------
%	Ending experiment
%--------------------------------------------------------------------

sendcmd(pport,'endSession');   
fclose(FID);


Screen('TextSize', window, 24);
IntroText = ['You have completed the experiment\n' ...
    'I said good day sir!\n'];
DrawFormattedText(window, IntroText, 'center', 'center');
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);
    
pause

ListenChar(0); % echo keyboard characters
ShowCursor;
SCREEN('CloseAll');
