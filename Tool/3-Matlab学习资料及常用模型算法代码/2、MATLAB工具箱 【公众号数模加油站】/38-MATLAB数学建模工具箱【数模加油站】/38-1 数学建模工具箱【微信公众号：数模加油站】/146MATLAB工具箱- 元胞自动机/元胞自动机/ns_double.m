
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

n=4;
m=60;
a=ones(n,m);
imh=image(cat(3,a,a,a));
grid on;
% red 1 0 0 ;  black 0 0 0 ; white 1 1 1; blue 0 0 1;
% gray 0.5 0.5 0.5
axis equal;
axis tight;
grid on;
set(gca,'XTick',0.5:m+0.5,'YTick',0.5:n+6.5);
set(gca,'GridLineStyle','-','LineWidth',1,'FontSize',1);

a1=a; a2=a;a3=a;
%gray line
GrayLine=[1 4];
a1(GrayLine,:)=0.5;
a2(GrayLine,:)=0.5;
a3(GrayLine,:)=0.5;

set(imh,'cdata', cat(3,a1,a2,a3) )
drawnow;

%Main event loop
stop= 0; %wait for a quit button push
run = 0; %wait for a draw
freeze = 0; %wait for a freeze

%stop=1;
cars=zeros(2,m);
v=zeros(2,m);
colors=zeros(2,m);
vmax=3;
p=0.3;
p_c=0.9;
q1=0.9;
q2=0.1;

cars_out=0;
cars_in=0;
cars_on=0;

while (stop==0)
    if (run==1)
        temp_cars=cars;
        temp_v=v;
        temp_colors=colors;
        cars=zeros(2,m);
        v=zeros(2,m);
        colors=zeros(2,m);
        cars_out=cars_out+sum(temp_cars(:,m));
                         % alway out when car in in the last cell
        for ii=m-1:-1:1  % update from back to front
            
             % lane 2
            if temp_cars(2,ii)==1 % car in current position ii lane 2 
                
                d=0;  %  lane 2, space before
                if cars(2,ii+1:m)==0
                    d=vmax;
                else
                    for jj=ii+1:m
                        if cars(2,jj)==0
                            d=d+1;
                        else
                            break;
                        end
                    end
                end
                
                l=min(temp_v(2,ii)+1,vmax);
                d_o=0; % lane 1, space before
                d_b=0; % lane 1, space back
                if d<l 
                    if cars(1,ii+1:m)==0
                        d_o=vmax;
                    else
                        for jj=ii+1:m
                            if cars(1,jj)==0
                                d_o=d_o+1;
                            else
                                break;
                            end
                        end
                    end
                    
                    if ii<=vmax
                        d_b=0; 
                    else
                        for jj=ii:-1:1
                            if cars(1,jj)==0;
                                d_b=d_b+1;
                            else
                                break
                            end
                        end
                    end  
                end
  
                if d<l && d_o>d && d_b>=vmax && rand(1)<p_c
                    %change to lane 1
                    temp_vv=min([temp_v(2,ii)+1,vmax,d_o]);
                    if ii+temp_vv<=m
                        cars(1,ii+temp_vv)=1;
                        v(1,ii+temp_vv)=temp_vv;
                        colors(1,ii+temp_vv)=temp_colors(2,ii);
                    else
                        cars_out=cars_out+1;
                    end                 
                else
                    % still in lane 2
                    temp_vv=min([temp_v(2,ii)+1,vmax,d]);
                    if rand<p 
                        temp_vv=max(temp_vv-1,0);
                    end
                    if ii+temp_vv<=m
                        cars(2,ii+temp_vv)=1;
                        v(2,ii+temp_vv)=temp_vv;
                        colors(2,ii+temp_vv)=temp_colors(2,ii);
                    else
                        cars_out=cars_out+1;
                    end
                    
                end
            end

            % lane 1
            if temp_cars(1,ii)==1 % car in current position ii lane 1 
                d=0;
                if cars(1,ii+1:m)==0
                    d=vmax;
                else
                    for jj=ii+1:m                       
                        if cars(1,jj)==0
                            d=d+1;
                        else
                            break;
                        end
                    end
                end
                
                l=min(temp_v(1,ii)+1,vmax);  
                d_o=0; %for lane 2
                d_b=0;
                if d<l
                    if cars(2,ii+1:m)==0
                        d_o=vmax;
                    else
                        for jj=ii+1:m
                            if cars(2,jj)==0
                                d_o=d_o+1;
                            else
                                break
                            end
                        end
                    end
                   
                    if ii<=vmax
                        d_b=0;
                    else
                        for jj=ii:-1:1
                            if cars(2,jj)==0
                                d_b=d_b+1;
                            else
                                break
                            end
                        end
                    end
                end
                
                if d<l && d_o>d && d_b>=vmax && rand(1)<p_c
                    %change to lane 2
                    temp_vv=min([temp_v(1,ii)+1,vmax,d_o]);
                    if ii+temp_vv<=m
                        cars(2,ii+temp_vv)=1;
                        v(2,ii+temp_vv)=temp_vv;
                        colors(2,ii+temp_vv)=temp_colors(1,ii);
                    else
                        cars_out=cars_out+1;
                    end
                else
                    %still in lane 1
                    temp_vv=min([temp_v(1,ii)+1,vmax,d]);
                    if rand(1)<p
                        temp_vv=max(temp_vv-1,0);
                    end
                    if ii+temp_vv<=m
                        cars(1,ii+temp_vv)=1;
                        v(1,ii+temp_vv)=temp_vv;
                        colors(1,ii+temp_vv)=temp_colors(1,ii);
                    else
                        cars_out=cars_out+1;
                    end
                end
            end
        end
        
        if rand(1)<q1 % new car coming for line 1
            if cars(1,1)==0
                cars(1, 1)=1;
                v(1,1)=randi(vmax,1);
                colors(1,1)=randi(70,1)/100;
                cars_in=cars_in+1;
            end
        end
        if rand(1)<q2 % new car coming for line 2
            if cars(2,1)==0
                cars(2, 1)=1;
                v(2,1)=randi(vmax,1);
                colors(2,1)=randi(60,1)/100+1.4; % 1
                cars_in=cars_in+1;
            end
        end
        cars_on=sum(cars(:));
        %update the color data
        a1([2 3],:)=1; a2([2 3],:)=1; a3([2 3],:)=1;
        for ii=1:m
            if cars(1,ii)==1
                if colors(1,ii)<1
                    a1(2,ii)=colors(1,ii); a2(2,ii)=colors(1,ii);
                else
                    a1(2,ii)=colors(1,ii)-1; a2(2,ii)=0;  a3(2,ii)=0;
                end
            end
             if cars(2,ii)==1
                 if colors(2,ii)<1
                     a1(3,ii)=colors(2,ii); a2(3,ii)=colors(2,ii);
                 else
                     a1(3,ii)=colors(2,ii)-1; a2(3,ii)=0;  a3(3,ii)=0;
                 end
            end
        end
        
        set(imh, 'cdata', cat(3,a1,a2,a3));
        %update the step number diaplay
        stepnumber = 1 + str2double(get(number,'string'));
        set(number,'string',num2str(stepnumber));
        pause(0.5);
    end
        if (freeze==1)
            run = 0;
            freeze = 0;
        end
        drawnow; %need this in the loop for controls to work   
 end

