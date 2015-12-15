
% Make sure the script is running on Psychtoolbox3:
AssertOpenGL;

%These commands clear the cache of garbage left from previous experimetnal
%runs

clear all % clear memory
close all % just to be sure
Screen('CloseAll') % just to be sure
clc; % clear monitor

CA_Radius = 200;
SearchItemSize = 40;
CA_Number = 9;
Screen('Preference', 'SkipSyncTests', 1);


screen = 0; %opens the main presentation window with below parameters
[window,WholeScreen] = Screen('OpenWindow', 0, [0 0 0], [0 0 800 600]);
CX=400;		
CY=300;
Framerate = Screen('FrameRate', screen);
colordepth = 32;

  

for i=1:CA_Number
Temp_X_Loc = CA_Radius*cos(2*pi*(mod((i-4),CA_Number)/CA_Number))+CX;
Temp_Y_Loc = CA_Radius*sin(2*pi*(mod((i-4),CA_Number)/CA_Number))+CY;
CentLocArray(i, :) = round([Temp_X_Loc-(SearchItemSize/2) Temp_Y_Loc-(SearchItemSize/2) Temp_X_Loc+(SearchItemSize/2) Temp_Y_Loc+(SearchItemSize/2)]);
end

 
  ColorArray = [240 170 0; 235 235 0; 60 200 90; 60 150 110; ...
      0 165 235; 110 60 200; 180 50 180; 245 10 100; ...
      255 100 60];
 
 Screen(window, 'FillRect', [0 0 0]); 
 
for ItemPos = 1:CA_Number
    ItemLoc = CentLocArray(ItemPos, :);
   Screen('FillRect', window, ColorArray(ItemPos,:), ItemLoc);
end

Screen('Flip', window);

A=Screen('GetImage', window);
imwrite(A,' ColorWheel.png');
 

WaitSecs(1);
pause
   