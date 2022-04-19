function [RS_Answer] = RatingScale(wPtr, rect, RatingQuestion)
%function that creates a five point likert scale to survey agreement to a
%Rating Question. Inputs are the Window pointer, the window rectangle and a
%string input for the question. Output is the answer (1-5).


%locations of answers 1-5
x_loc_1 = (rect(1)+(1/6)*rect(3));
x_loc_2 = (rect(1)+(2/6)*rect(3));
x_loc_3 = (rect(1)+(3/6)*rect(3));
x_loc_4 = (rect(1)+(4/6)*rect(3));
x_loc_5 = (rect(1)+(5/6)*rect(3));
y_loc = (rect(2)+(4.5/6)*rect(4));

%list of accepted Key presses as answers
ans_list = ['1','2','3','4','5'];
loc_list = [x_loc_1, x_loc_2, x_loc_3, x_loc_4, x_loc_5];

keyIsDown = 0;
while ~keyIsDown
    
    [keyIsDown, ~, keyCode, ~] = KbCheck();
    %drawing text
    Screen('TextFont',wPtr,'Helvetica');
    Screen('TextSize',wPtr,38);
    %drawing the question and a 5 point likert scale
    DrawFormattedText(wPtr,RatingQuestion,'center',(rect(2)+(1/5)*rect(4)),[0 0 0]);
    DrawFormattedText(wPtr,'1',x_loc_1,y_loc,[0 0 0]);
    DrawFormattedText(wPtr,'2',x_loc_2,y_loc,[0 0 0]);
    DrawFormattedText(wPtr,'3',x_loc_3,y_loc,[0 0 0]);
    DrawFormattedText(wPtr,'4',x_loc_4,y_loc,[0 0 0]);
    DrawFormattedText(wPtr,'5',x_loc_5,y_loc,[0 0 0]);
    DrawFormattedText(wPtr,'Not at all',(rect(1)+(0.5/6)*rect(3)),(rect(2)+(5/6)*rect(4)),[0 0 0]);
    DrawFormattedText(wPtr,'Totally',(rect(1)+(4.7/6)*rect(3)),(rect(2)+(5/6)*rect(4)),[0 0 0]);
    Screen('Flip',wPtr);
    
    if ~ismember(KbName(keyCode),ans_list)
        keyIsDown = 0;
    end
end

RS_Button = KbName(keyCode);  %Button_1 saved as key name
RS_Answer = RS_Button(1); %for some reason KbCheck gives 2 KbName outputs here, so i'm just using the first one, which is the key pressed
Ans_index = str2num(RS_Answer);
%short visual feedback of answer given
DrawFormattedText(wPtr,RatingQuestion,'center',(rect(2)+(1/5)*rect(4)),[0 0 0]);
DrawFormattedText(wPtr,RS_Answer,loc_list(Ans_index),y_loc,[0 0 0]);
DrawFormattedText(wPtr,'Not at all',(rect(1)+(0.5/6)*rect(3)),(rect(2)+(5/6)*rect(4)),[0 0 0]);
DrawFormattedText(wPtr,'Totally',(rect(1)+(4.7/6)*rect(3)),(rect(2)+(5/6)*rect(4)),[0 0 0]);
Screen('Flip', wPtr);
% WaitSecs(0.5);

end
