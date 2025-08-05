
%
clc;%clf;
clear;

hf=figure('Position',[350,100,600,400],'Resize','off','menubar','none', ...
    'Name','Life: Conway''s Game of Life: 3 cells', ...
    'NumberTitle','off');

ha=axes('Position',[0.1,0.07,0.8,0.8],'Box','on');
hw=365;
plotbutton=uicontrol('style','pushbutton',...
    'string','Run', ...
    'fontsize',12, ...
    'position',[300,hw,50,20], ...
    'callback', 'run=1;');

%define the stop button
erasebutton=uicontrol('style','pushbutton',...
    'string','Stop', ...
    'fontsize',12, ...
    'position',[400,hw,50,20], ...
    'callback','freeze=1;');

%define the Quit button
quitbutton=uicontrol('style','pushbutton',...
    'string','Quit', ...
    'fontsize',12, ...
    'position',[500,hw,50,20], ...
    'callback','stop=1;close;');

steps = uicontrol('style','text', ...
    'string','Steps:', ...
    'fontsize',12, ...
    'position',[60,hw,50,20]);

number = uicontrol('style','text', ...
    'string','1', ...
    'fontsize',12, ...
    'position',[120,hw,50,20]);

n=23;
m=38;
a=ones(n,m);
imh=image(cat(3,a,a,a));
grid on;
% red 1 0 0 ;  black 0 0 0 ; white 1 1 1; blue 0 0 1
axis equal;
axis tight;
grid on;
set(gca,'XTick',0.5:m+0.5,'YTick',0.5:n+6.5);
%set(gca,'XTick',0:m,'YTick',0:n);
%set(gca,'GridLineStyle','-','LineWidth',1,'FontSize',1,'Position',[0 0 1 1]);
set(gca,'GridLineStyle','-','LineWidth',1,'FontSize',1);

% initial 
cells=zeros(n,m);

cells(2,2)=1; cells(3,2)=1;cells(4,3)=1;

cells(7,3)=1; cells(8,[2 4])=1;

cells(11,4)=1; cells(12,3)=1; cells(13,2)=1;

cells(16,[2 3])=1; cells(17,2)=1;

cells(21,[2 3 4])=1;

set(imh,'cdata', cell2im(cells));
drawnow; 

%Main event loop
stop= 0; %wait for a quit button push
run = 0; %wait for a draw
freeze = 0; %wait for a freeze

while (stop==0)
 
    if (run==1)
        cells=nextstep(cells);
        set(imh, 'cdata', cell2im(cells))
        %update the step number diaplay
        stepnumber = 1 + str2num(get(number,'string'));
        set(number,'string',num2str(stepnumber));
        freeze=1;
    end
    
    if (freeze==1)
        run = 0;
        freeze = 0;
    end
    drawnow; %need this in the loop for controls to work
    pause(0.1);
end


