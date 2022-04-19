function [] = SoA_task()
%Function for my matlab TEWA 2 experiment to investigate sense of agency in
%a dexterity task with and without interference. Input participant ID to
%name the output file. Training = 'y' starts a trial run for the
%participant to get used to the task and will not be saved to a file.
%You need to restart the function to start the real trial. 
%Also make sure to have the files RatingScale.m and SoA_training.m in your directory.
%All sizes of objects and locations are in relation to the screen rect. So
%it should work fine on full screen and different screen sizes.
%Allowed input is 'k' for the task and 'esc' to stop the task prematurely. 

%clear workspace and close any open windows
sca; 
clear;

%inputs
Participant = input('Enter Participant ID: ', 's');
Training = input('Training run? y/n: ','s');

%if training run was selected the function SoA_training runs (and not the
%actual SoA_task!)
if Training == 'y'
    SoA_training()
    return
end

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
rect_width = rect_rect(3) - rect_rect(1);

%speed of rect
vel = 10;

%delay until ball stops after button press
delay = 10;

%"timer" for the ball turning green
turn_green = [200, 300, 350, 250];
loop_counter = 0;
stop_counter = 0;

%starting reward
Reward = 0;

%condition counter
cond_1 = 0;     %no help win
cond_2 = 0;     %no help loss
cond_3 = 0;     %help win
cond_4 = 0;     %help loss
conditions = [cond_1 cond_2 cond_3 cond_4];

%output arrays
Q1_ans = [];
Q2_ans = [];
Q3_ans = [];
Interf = [];
Results = [];

%while loop that runs until all conditions appeared 30 times.
while any(conditions < 30)
    
    endLoop = 0;
    keyIsDown = 0;
    while ~endLoop
        
        %keyboardcheck
        [keyIsDown, ~, keyCode, ~] = KbCheck();
        %starting loop counter
        loop_counter = loop_counter + 1;
        %interference 
        interf = randi([0 1]);

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
        
        %press 'esc' to end task prematurely
        if find(keyCode) == 27
            return
        end
        
        %here it tells the ball when to turn green after the preset loop interval
        if turn_green(randi(4)) < loop_counter
            stop_counter = stop_counter + 1;
            rect_color = [0 255 0];

            %if a key was pressed in time it checks whether it was inside of
            %bounds or not & checks if pressed key is 'k'
            if keyIsDown && find(keyCode) == 75

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

                        
                    %interference condition, e.g. moves rect out of bounds
                    if interf == 1 && (rect_rect(1) - g_lower) < (g_upper - rect_rect(3))
                        %if closer to left side then moves out of left
                        %bound
                        rect_rect(1) = g_lower - rect_width;
                        rect_rect(3) = g_lower;
                        Screen('FillRect', w, rect_color, rect_rect);
                        Screen('FillRect', w, bar_color, bar_rects);
                        Screen('Flip',w);
                        %lose
                        Reward = Reward - 1;
                        cond_4 = cond_4 + 1;
                        reward_color = [255 0 0];
                        Result = 0;
                        WaitSecs(0.5);
                        endLoop = 1;
                    
                    %interference condition to the other side
                    elseif interf == 1 && (rect_rect(1) - g_lower) > (g_upper - rect_rect(3))
                        %if closer to right side then moves right out of
                        %bounds
                        rect_rect(1) = g_upper;
                        rect_rect(3) = g_upper + rect_width;
                        Screen('FillRect', w, rect_color, rect_rect);
                        Screen('FillRect', w, bar_color, bar_rects);
                        Screen('Flip',w);
                        %lose
                        Reward = Reward - 1;
                        cond_4 = cond_4 + 1;
                        reward_color = [255 0 0];
                        Result = 0;
                        WaitSecs(0.5);
                        endLoop = 1;
                    
                    else
                        %win
                        Reward = Reward + 1;
                        reward_color = [0 255 0];
                        Result = 1;
                        cond_1 = cond_1 + 1;
                        WaitSecs(0.5);
                        endLoop = 1;
                    end
                    
                %if out of bounds
                else
                    %help condition acts here and checks if rect is left or
                    %right of green target location
                    
                    %help condition if out of left bound
                    if interf == 1 && rect_rect(1) < g_lower
                        rect_rect(1) = g_lower; 
                        rect_rect(3) = g_lower + rect_width;
                        Screen('FillRect', w, rect_color, rect_rect);
                        Screen('FillRect', w, bar_color, bar_rects);
                        Screen('Flip',w);
                        %win
                        Reward = Reward + 1;
                        cond_3 = cond_3 + 1;
                        reward_color = [0 255 0];
                        Result = 1;
                        WaitSecs(0.5);
                        endLoop = 1;
                        
                    %help condition if out of right bound
                    elseif interf == 1 && rect_rect(3) > g_upper
                        rect_rect(1) = g_upper - rect_width;
                        rect_rect(3) = g_upper;
                        Screen('FillRect', w, rect_color, rect_rect);
                        Screen('FillRect', w, bar_color, bar_rects);
                        Screen('Flip',w);
                        %win
                        Reward = Reward + 1;
                        cond_3 = cond_3 + 1;
                        reward_color = [0 255 0];
                        Result = 1;
                        WaitSecs(0.5);
                        endLoop = 1;
                        
                    else
                        %lose
                        Reward = Reward - 1;
                        reward_color = [255 0 0];
                        Result = 0;
                        cond_2 = cond_2 + 1;
                        WaitSecs(0.5);
                        endLoop = 1;
                    end
       
                end

            %if participant was too slow Result is noted as -1, which is
            %a non-valid result
            elseif stop_counter > 50

                Reward = Reward - 1;
                Result = -1;
                reward_color = [255 0 0];
                Screen('TextFont',w,'Helvetica');
                Screen('TextSize',w,50);
                DrawFormattedText(w,'Too slow!','center','center',[255 0 0]);
                Screen('Flip',w);
                WaitSecs(0.5);
                endLoop = 1;
            end
        end
    end


    %displays the current reward value to the participant. Color is red when
    %reward value went down and green when a unit was gained. Reward cannot
    %go below 0
    if Reward < 0
        Reward = 0;
    end
    disp_reward = strcat('$: ',num2str(Reward));
    Screen('TextFont',w,'Helvetica');
    Screen('TextSize',w,38);
    DrawFormattedText(w,disp_reward,'center',(rect(2)+(1/5)*rect(4)),reward_color);
    Screen('Flip',w);
    WaitSecs(1);

    %Questionnaire starts here
    Answer = RatingScale(w,rect,'I felt in control.');
    Q1 = str2num(Answer);
    WaitSecs(0.5);
    Answer = RatingScale(w,rect,'I feel stressed.');
    Q2 = str2num(Answer);
    WaitSecs(0.5);
    Answer = RatingScale(w,rect,'This game feels fair.');
    Q3 = str2num(Answer);
    WaitSecs(0.5);

    
    %resetting loop counters and rect color for next trial
    stop_counter = 0;
    loop_counter = 0;
    rect_color = [255 0 0];
    
    %outputs
    Q1_ans = [Q1_ans; Q1];
    Q2_ans = [Q2_ans; Q2];
    Q3_ans = [Q3_ans; Q3];
    Interf = [Interf; interf];
    Results = [Results; Result];
    conditions = [cond_1 cond_2 cond_3 cond_4];
    
end


%saving variables to file 
filename = append(Participant,'.mat');
save(filename, 'Interf', 'Results', 'Q1_ans', 'Q2_ans', 'Q3_ans');

%Closing the screen when the task is finished.
sca;