clc;
clear;

hf=figure('Position',[100,300,1200,170],'Resize','off','menubar','none', ...
    'Name','Nagel-Schreckenberg model', ...
    'NumberTitle','off');

ha=axes('Position',[0.05,0.05,0.9,0.8],'Box','on');

hw=130;
plotbutton=uicontrol('style','pushbutton',...
    'string','Run', ...
    'fontsize',12, ...
    'position',[250,hw,50,20], ...
    'callback', 'run=1;');

%define the stop button
erasebutton=uicontrol('style','pushbutton',...
    'string','Stop', ...
    'fontsize',12, ...
    'position',[350,hw,50,20], ...
    'callback','freeze=1;');

%define the Quit button
quitbutton=uicontrol('style','pushbutton',...
    'string','Quit', ...
    'fontsize',12, ...
    'position',[450,hw,50,20], ...
    'callback','stop=1;close;');

steps = uicontrol('style','text', ...
    'string','Steps:', ...
    'fontsize',12, ...
    'position',[60,hw,50,20]);

number = uicontrol('style','text', ...
    'string','1', ...
    'fontsize',12, ...
    'position',[120,hw,50,20]);

n=3;
m=60;
a=ones(n,m);
imh=image(cat(3,a,a,a));
grid on;
% red 1 0 0 ;  black 0 0 0 ; white 1 1 1; blue 0 0 1; 
%gray 0.5 0.5 0.5
axis equal;
axis tight;
grid on;
set(gca,'XTick',0.5:m+0.5,'YTick',0.5:n+6.5);
set(gca,'GridLineStyle','-','LineWidth',1,'FontSize',1);

a1=a; a2=a;a3=a;
GrayLine=[1 3];
a1(GrayLine,:)=0.5;
a2(GrayLine,:)=0.5;
a3(GrayLine,:)=0.5;

set(imh,'cdata', cat(3,a1,a2,a3) )
drawnow; 

%Main event loop
stop= 0; %wait for a quit button push
run = 0; %wait for a draw
freeze = 0; %wait for a freeze

%stop=1; % only for test
cars=zeros(1,m); % cars position
v=zeros(1,m); % velocities
colors=zeros(1,m); % different colors for cars
vmax=4; % maximal velocity
p=0.1;    %prob. of random decreasing velocity
q=0.9;    %prob. of new car coming

cars_in=0; % number of cars entering this road
cars_out=0; %  number of cars exiting this road
cars_on=0; %number of cars current in this road

while (stop==0)
    if (run==1)
        temp_cars=cars;
        temp_v=v;
        temp_colors=colors;
        cars=zeros(1,m);
        colors=zeros(1,m);
        v=zeros(1,m);
        cars_out=cars_out+sum(temp_cars(:,m));
                         % alway out when car in in the last cell
        for ii=m-1:-1:1
            if temp_cars(ii)==1
                d=0; 
                if cars(ii+1:m)==0
                    d=vmax;
                else
                    for jj=ii+1:m
                        if cars(jj)==0
                            d=d+1;
                        else
                            break;
                        end
                    end
                end
                temp_vv=min([temp_v(ii)+1,vmax,d]); % current velocity
                if rand(1)<p
                   temp_vv=max(temp_vv-1,0); 
                end
                if ii+temp_vv<=m
                    cars(ii+temp_vv)=1;
                    v(ii+temp_vv)=temp_vv;
                    colors(ii+temp_vv)=temp_colors(ii);
                else
                    cars_out=cars_out+1;
                end
            end
        end
        if rand(1)<q
            %new car coming
            if cars(1)==0 
                cars(1)=1;
                v(1)=randi(vmax-1,1)+1;
                colors(1)=randi(80,1)/100;
                cars_in=cars_in+1;
            end
        end
        cars_on=sum(cars(:));
        
        % update the colors
        a1(2,:)=1; a2(2,:)=1; a1(2,:)=1;
       for ii=1:m
           if cars(ii)==1
               a1(2,ii)=colors(ii); a2(2,ii)=colors(ii);
           end
       end
        set(imh, 'cdata', cat(3,a1,a2,a3));
        %update the step number diaplay
        stepnumber = 1 + str2double(get(number,'string'));
        set(number,'string',num2str(stepnumber));
    end
    
    if (freeze==1)
        run = 0;
        freeze = 0;
    end
    drawnow; %need this in the loop for controls to work
    pause(0.5);
end
