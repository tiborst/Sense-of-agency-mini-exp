function [] = SoA_training()
%training function of the SoA task. Only console output, nothing gets saved to
%file. Participant needs to get a score of >= 80% accuracy without
%interference. 

sca; clear;

%removing error message
Screen('Preference', 'SkipSyncTests', 1);
%defining my window
[w, rect] = Screen('OpenWindow',1, [], [800 100 1600 900]); 

% Assign top priority
Priority(MaxPriority(w));
% unify keynames for better keycode recognition across systems
KbName('UnifyKeyNames');
% Start BlendFunction
Screen('BlendFunction', w, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

%red green bar for FillRect.
%the bar_rects(1,2) and bar_rects(3,2) are the left and right bounds for the "reward
%section" of the moving rectangle. 
bar_color = [255 0 255; 0 255 0; 0 0 0];
bar_rects = [rect(3)*(1/8) rect(3)*(3.5/8) rect(3)*(4.5/8); rect(4)*(7/10) rect(4)*(7/10) rect(4)*(7/10); 
    rect(3)*(3.5/8) rect(3)*(4.5/8) rect(3)*(7/8); rect(4)*(7.5/10) rect(4)*(7.5/10) rect(4)*(7.5/10)];

%green lower and upper bound 
g_lower = bar_rects(1,2);
g_upper = bar_rects(3,2);

%moving rect color and size
rect_color = [255 0 0];
rect_rect = [rect(3)*(1/8) rect(4)*(6.3/10) rect(3)*(1.24/8) rect(4)*(6.6/10)];

%speed of ball
vel = 8;

%delay until ball stops after button press
delay = 10;

%starting Score
Score = 0;

%"timer" for the ball turning green
turn_green = [200, 300, 350, 250];

loop_counter = 0;
stop_counter = 0;

%trial number
nTrials = 5;

for t = 1:nTrials
    endLoop = 0;
    keyIsDown = 0;
    
    while ~endLoop
        %starting loop counter
        loop_counter = loop_counter + 1;
        %drawing the bar and the rectangular moving stimulus
        Screen('FillRect', w, rect_color, rect_rect);
        Screen('FillRect', w, bar_color, bar_rects);
        Screen('Flip',w);
        %moving the rect
        rect_rect(1) = rect_rect(1) + vel;
        rect_rect(3) = rect_rect(3) + vel;
        %checking for upper and lower bound and reversing direction
        if rect_rect(3) >= rect(3)*(7/8)
            vel = vel * (-1);
        elseif rect_rect(1) <= rect(3)*(1/8)
            vel = vel * (-1);
        end
        
        %keyboardcheck to break loop; press 'k' to stop ball, use 'esc' to
        %stop function
        [keyIsDown, ~, keyCode, ~] = KbCheck();
        if find(keyCode) == 27
            return
        end
        %here it tells the ball when to turn green after the preset loop interval
        if turn_green(randi(4)) < loop_counter
            stop_counter = stop_counter + 1;
            rect_color = [0 255 0];
            
            if keyIsDown && find(keyCode) == 75

                Screen('FillRect', w, rect_color, rect_rect);
                Screen('FillRect', w, bar_color, bar_rects);
                Screen('Flip',w);

                %delay loop to move the ball further after kb input
                for d = 1:delay
                    rect_rect(1) = rect_rect(1) + vel;
                    rect_rect(3) = rect_rect(3) + vel;
                    Screen('FillRect', w, rect_color, rect_rect);
                    Screen('FillRect', w, bar_color, bar_rects);
                    Screen('Flip',w);
                end
                %if in bounds
                if rect_rect(1) >= g_lower && rect_rect(3) <= g_upper
                    
                    Score = Score + 1;
                    Accuracy = Score / t;
                    Screen('TextFont',w,'Helvetica');
                    Screen('TextSize',w,50);
                    DrawFormattedText(w,'Well Done!','center','center',[0 255 0]);
                    Screen('Flip',w);
                    WaitSecs(1);
                    endLoop = 1;
                
                %if out of bounds
                else
                    
                    Accuracy = Score / t;
                    Screen('TextFont',w,'Helvetica');
                    Screen('TextSize',w,50);
                    DrawFormattedText(w,'Please be accurate!','center','center',[255 0 0]);
                    Screen('Flip',w);
                    WaitSecs(1);
                    endLoop = 1;
                end
                
            %if too slow
            elseif stop_counter > 50

                Accuracy = Score / t;
                Screen('TextFont',w,'Helvetica');
                Screen('TextSize',w,50);
                DrawFormattedText(w,'Too slow!','center','center',[255 0 0]);
                Screen('Flip',w);
                WaitSecs(0.5);
                endLoop = 1;
            end
        end
    end
    %resetting loop counters and rect color for next trial
    stop_counter = 0;
    loop_counter = 0;
    rect_color = [255 0 0];
end
          
%starts function again if accuracy is too low
if Accuracy < 0.8
    SoA_training()
else
    fprintf('Accuracy: %f %%\n',Accuracy);
end

sca;