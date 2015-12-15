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
FileName =  strcat(ID, '_DuoChrome_tvt3.csv'); 
if exist(FileName,'file')
    resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type y for overwrite]'], 's');

    if ~strcmp(resp,'y') %abort experiment if overwriting was not confirmed
        disp('experiment aborted')
        return
    end
end

serialattached = 0;

FID = fopen(FileName, 'w');
fprintf(FID, 'Block, Order, Trial, TrCueColor, TrCueSide, TrCueOrient, BlCueType, TrTargetType, TrTargetLoc, Response, Accuracy, RT, CueTime, TargetTime\n'); %\n=enter - moves to next row
      
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

%KbWait; %KbWait - readies MATLAB for a keypress
KbCheck; %kbcheck - detects keypress
GetSecs; %Marks keypress with timestamp for calculating RT

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations
%-----------------------------------------------------------------


timeout = 1.5;
C_ISI = 1200;
V_ISI = 500;

%Search array params

CA_Number = 10;
SearchItemSize = 60;
LineWidth = 10;
CA_Radius = 300;

%Cue array params
CueSize  = 60;
CueEcc_Y = 30;
CueEcc_X = 45;

CueBL_Loc =  [CX-(CueEcc_X+CueSize)           CY-(CueEcc_Y+CueSize)           CX-(CueEcc_X)               CY-(CueEcc_Y)];
CueUL_Loc =  [CX-(CueEcc_X+CueSize)           CY+(CueEcc_Y)                   CX-(CueEcc_X)               CY+(CueEcc_Y+CueSize)];
CueBR_Loc =  [CX+(CueEcc_X)                   CY-(CueEcc_Y+CueSize)           CX+(CueEcc_X+CueSize)       CY-(CueEcc_Y)];
CueUR_Loc =  [CX+(CueEcc_X)                   CY+(CueEcc_Y)                   CX+(CueEcc_X+CueSize)       CY+(CueEcc_Y+CueSize)];

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
   
% ColorArray = [240 170 0; 235 235 0; 60 200 90; 60 150 110; ...
%   0 165 235; 110 60 200; 180 50 180; 245 10 100];

   ColorArray = [245 10 100; 255 100 60; 235 235 0; 120 190 60;  ...
      60 200 90; 0 190 140; 0 165 235;  180 50 180];

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

TotalBlock =0; % # of blocks
TarType = 2;
CueSide = 2; % 1=left; 2=right
CueType = 2; % 1=color; 2=orientation
CueColor = 8; % 8 colors 
CueOrient = 8; % 8 orientations
TargetSide = 2; %1=target in left array; 2=target in right array
Reps = 2;
trialcode = 1;


TotalTrial = CueColor*CueOrient*CueSide*TarType; % 32*reps
PracTrial = 20;

%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------

SearchPos = zeros(1,9);

BlockOrder = zeros(1,TotalBlock);
BlCueType = zeros(1,TotalBlock);

TrialOrder = zeros(1,TotalTrial);
TrTarType = zeros(1,TotalTrial);
TrCueColor = zeros(1,TotalTrial);
TrCueOrient = zeros(1,TotalTrial);
TrCueSide = zeros(1,TotalTrial);

for i=0 : TotalTrial-1
    TrialOrder(i+1) = i+1;
    TrCueSide(i+1) = mod(i,CueSide)+1;
    TrCueColor(i+1) = floor(mod(i/2,CueColor))+1;
    TrCueOrient(i+1) = floor(mod(i/16,CueOrient))+1;
    TrTarType(i+1) = floor(mod(i/128,TarType))+1;
end

for i=0 : TotalBlock-1
    BlockOrder(i+1) = i+1;
    BlCueType(i+1) = floor(mod(i,CueType))+1;
end


%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------

Screen('TextSize', window, 24);
Screen(window, 'FillRect', black); 

%add some actual intro text later

BlockText = ['Welcome to the experiment.\n' ...
              'Please wait while the experimenter sets up.' ];
          
DrawFormattedText(window, BlockText, 'center', 'center', [200 200 200]);
Screen('Flip', window);
WaitSecs(1);
pause

Screen(window, 'FillRect', black); 
FlushEvents('keyDown'); 

%----------------------------------------------------------------
% Start experiment
%----------------------------------------------------------------

for Block = 1:TotalBlock%TotalBlock  


    
    BlockText = ['Time for a new block.\n' ...
    'Please wait for the experimenter\n' ];

    Screen('TextSize', window, 24);
    DrawFormattedText(window, BlockText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);


    WaitSecs(1);
    pause

    Screen(window, 'FillRect', black); %clears screen
    FlushEvents('keyDown');

    Screen('Flip', window);
    WaitSecs(2);
    
    Order = randperm(TotalTrial);

 for Trial = 1 : TotalTrial %Trial loop
     if mod(Trial, 64) == 1  
         BlockText = ['Take a minute to rest your eyes and get comfortable.\n' ...
        'Press any button to continue\n' ];

        Screen('TextSize', window, 24);
        DrawFormattedText(window, BlockText, 'center', 'center', [255 255 255]);
        Screen('Flip', window);

   WaitSecs(1);
    pause

        Screen(window, 'FillRect', black); %clears screen
        FlushEvents('keyDown');

        Screen('Flip', window);
        WaitSecs(2);
     end
    
     if Trial == 10  
         BlockText = ['That is the end of the practice.\n' ...
        'Wait for the experimenter before continuing.\n' ];

        Screen('TextSize', window, 24);
        DrawFormattedText(window, BlockText, 'center', 'center', [255 255 255]);
        Screen('Flip', window);

   WaitSecs(1);
    pause

        Screen(window, 'FillRect', black); %clears screen
        FlushEvents('keyDown');

        Screen('Flip', window);
        WaitSecs(2);
     end
     
   
TBtime = GetSecs;  
TrISI = (C_ISI+(rand*V_ISI))*.001;
%-----------------------------------------------------------------
%  Choosing Stim
%-----------------------------------------------------------------

% randomly choose some trial values, may want to balance later


TrTargetLoc = randi(CA_Number,1);

Cue1_Loc = CueLoc_Array(TrCueSide(Order(Trial)),1);
Cue2_Loc = CueLoc_Array((mod(TrCueSide(Order(Trial)),2)+1),1);
Cue3_Loc = CueLoc_Array(TrCueSide(Order(Trial)),2);
Cue4_Loc = CueLoc_Array((mod(TrCueSide(Order(Trial)),2)+1),2);

%Assign search array items and locations

Cue1_Color = ColorArray((TrCueColor(Order(Trial))),:);
Cue2_Color = ColorArray((mod(TrCueColor(Order(Trial))+3,8)+1),:);

TrTargetColor = Cue1_Color;
TrWhitinDistractor = Cue2_Color;

TargetRot = TrCueOrient(Order(Trial))*.125;
FoilRot = TargetRot +.5;
    
%---------------------------------------------------
% Presenting the Cue
%---------------------------------------------------


Screen(window, 'FillRect', black); 

 if TrCueSide(Order(Trial))==1
         CueText = '<<<';
 else
         CueText = '>>>';
 end
 Screen('TextSize', window, 14);
DrawFormattedText(window, CueText, 'center', CY-(28), [125 125 125]);
DrawFormattedText(window, CueText, 'center', CY+(10), [125 125 125]);
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);

Screen('FillRect', window, Cue1_Color, Cue1_Loc{:});
Screen('FillRect', window, Cue2_Color, Cue2_Loc{:});

Screen('DrawTexture', window, OffScrWin, OffScrRect, Cue3_Loc{:}, (TargetRot*360),[],[],grey);
Screen('DrawTexture', window, OffScrWin, OffScrRect, Cue4_Loc{:}, (FoilRot*360),[],[],grey);


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

WaitSecs(.2);

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
    Item = grey;
    ItemLoc = CentLocArray(ItemPos, :);
    ItemRot = randi(8,1)*.125;
    Screen('DrawTexture', window, OffScrWin, OffScrRect, ItemLoc, (ItemRot*360),[],[],Item);
end

if mod(Block+1,2)+1 == 1
    if TrTarType(Order(Trial)) == 1;
        TarRot = 1;
    else
        TarRot = randi(8,1)*.125;
    end
    
    TargLoc = CentLocArray(TrTargetLoc, :);
    Screen('DrawTexture', window, OffScrWin, OffScrRect, TargLoc, (TarRot*360),[],[],TrTargetColor);
    DistRot = randi(8,1)*.125;
    DistLoc = CentLocArray(mod(TrTargetLoc+4,CA_Number)+1, :);
    Screen('DrawTexture', window, OffScrWin, OffScrRect, DistLoc, (DistRot*360),[],[],TrWhitinDistractor);
else
    if TrTarType(Order(Trial)) == 1;
        TarRot = TargetRot;
    else
        TarRot = randi(8,1)*.125;
    end
    TargLoc = CentLocArray(TrTargetLoc, :);
    Screen('DrawTexture', window, OffScrWin, OffScrRect, TargLoc, (TarRot*360),[],[],[245 10 100]);
    DistRot = randi(8,1)*.125;
    DistLoc = CentLocArray(mod(TrTargetLoc+4,CA_Number)+1, :);
    Screen('DrawTexture', window, OffScrWin, OffScrRect, DistLoc, (DistRot*360),[],[],[60 200 90]);
   
end

[Begin_Time]= Screen('Flip', window);

%---------------------------------------------------
% Keyboard Response
%---------------------------------------------------

while 1
    [keyIsDown, End_Time, keyCode]=KbCheck(-1);

    if keyIsDown 
        break
    elseif GetSecs - Begin_Time > 1.5
        break
    end
    WaitSecs(0.0001);
end

if strcmp(KbName(keyCode),'b') %X,V
    Response = 1;
elseif strcmp(KbName(keyCode),'v') %P,R
	Response = 2;
else 
    Response = 0;
end

while GetSecs < Begin_Time + 1.5;
end

Screen(window, 'FillRect', black); 
Screen('DrawTexture', window, Fixation, FixationRect, FixationLoc);

Screen('Flip', window);


%---------------------------------------------------
% Response Coding
%---------------------------------------------------

RTTrial = (End_Time-Begin_Time)*1000;


  if Response == 1
      if TrTarType(Order(Trial)) == 1
          Accuracy = 1;
      else
          Accuracy = 0;
      end
  elseif Response == 2
      if TrTarType(Order(Trial)) == 2
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
end

 % send response-made code
 sendcode(pport,respmade,1);
 keyCode=1;

% %---------------------------------------------------
% % Send response codes
% %---------------------------------------------------

sendcmd(pport,'respCodes');
sendcode(pport,keyCode,1); % response code
sendcode(pport,(RTTrial),4); % rt
sendcode(pport,resperr,1); % error code
%   
% ---------------------------------------------------
% Saving the file
% ---------------------------------------------------

if Block == 0

    if (Trial>=1) %starts saving data if subject has completed at least 1 trial
       
        Save = [Block; Order(Trial); Trial; TrCueColor(Order(Trial));TrCueSide(Order(Trial)); TrCueOrient(Order(Trial)); ...
        BlCueType(Block); TrTarType(Order(Trial)); TrTargetLoc; Response; Accuracy; RTTrial; Cue_Time; Begin_Time ];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
    end
    
else

    if (Trial>=1) %starts saving data if subject has completed at least 1 trial

        Save = [Block; Order(Trial); Trial; TrCueColor(Order(Trial)); TrCueSide(Order(Trial)); TrCueOrient(Order(Trial)); ...
        BlCueType(Block); TrTarType(Order(Trial)); TrTargetLoc; Response; Accuracy; RTTrial; Cue_Time; Begin_Time ];

        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f\n', Save);
    end
end
    


%-------------------End Loop-----------------------------------------    
    
end %closes trial loop
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

Screen(window, 'FillRect', black); 
Screen('TextSize', window, 24);
IntroText = ['You have completed the experiment\n' ...
    'Please wait for the experimenter.\n'];
DrawFormattedText(window, IntroText, 'center', 'center');
Screen('Flip', window);%flips the window from the beginning window
WaitSecs(1);
    
pause

ListenChar(0); % echo keyboard characters
ShowCursor;
Screen('CloseAll');
