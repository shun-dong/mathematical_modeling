
%clc;
clear;

hf=figure('Position',[100,300,1200,170],'Resize','off','menubar','none', ...
    'Name','Cellular Automaton model for 2014 CUMCM Problem A', ...
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

n=5;
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
GrayLine=[1 5];
a1(GrayLine,:)=0.5;
a2(GrayLine,:)=0.5;
a3(GrayLine,:)=0.5;
a1(5,16:40)=0.3;a2(5,16:40)=0.3;a3(5,16:40)=0.3;

a1(2,[39 40 41 42])=0.2;a2(2,[39 40 41 42])=0.2;a3(2,[39 40 41 42])=0.2;
a1(3,[40 41])=0.2;a2(3,[40 41])=0.2;a3(3,[40 41])=0.2;

set(imh,'cdata', cat(3,a1,a2,a3) )
drawnow;

%Main event loop
stop= 0; %wait for a quit button push
run = 0; %wait for a draw
freeze = 0; %wait for a freeze
EXIT=0;

%stop=1; % for test
% run =1;   % for test
 
cars=zeros(3,m);
v=zeros(3,m);
colors=zeros(3,m);
vmax_m=4*ones(1,m);
vmax_m(39-8:39-3)=2;
vmax_m(39-3:42+2)=1;

p=0.1;
p_l=0.5; % slow speed up
p_c=0.9;
q1=0.3;
q2=0.37;
q3=0.18;

cars_out=0;
cars_in=0;
cars_on=0;

while (stop==0)
    if (run==1)
        temp_cars=cars;
        temp_v=v;
        temp_colors=colors;
        cars=zeros(3,m);
        v=zeros(3,m);
        colors=zeros(3,m);
        cars_out=cars_out+sum(temp_cars(:,m));
                         % alway out when car in in the last cell
        cars(1,39:41)=1; cars(2,40)=1; % assume that there exists some cars in the jam area               
        for ii=m-1:-1:1  % update from back to front
            vmax=vmax_m(ii);
            %% update lane 3
            if temp_cars(3,ii)==1 % car in current position ii lane 3
                if temp_v(3,ii)==0 && rand(1)<p_l
                    %do not move
                    temp_vv=0;
                    cars(3,ii+temp_vv)=1;
                    v(3,ii+temp_vv)=temp_vv;
                    colors(3,ii+temp_vv)=temp_colors(3,ii);
                else
                    d=0;  %  lane 3, space before
                    if cars(3,ii+1:m)==0
                        d=vmax;
                    else
                        for jj=ii+1:m
                            if cars(3,jj)==0
                                d=d+1;
                            else
                                break;
                            end
                        end
                    end
                    
                    l=min(temp_v(3,ii)+1,vmax);
                    d_o=0; % lane 2, space before
                    d_b=0; % lane 2, space back
                    if d<l
                        if cars(2,ii+1:m)==0
                            d_o=vmax;
                        else
                            for jj=ii+1:m
                                if cars(2,jj)==0
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
                                if cars(2,jj)==0;
                                    d_b=d_b+1;
                                else
                                    break
                                end
                            end
                        end
                    end
                    
                    if d<l && d_o>d && d_b>=vmax && rand(1)<p_c
                        % change to lane 2
                        temp_vv=min([temp_v(3,ii)+1,vmax,d_o]);
                        if ii+temp_vv<=m
                            cars(2,ii+temp_vv)=1;
                            v(2,ii+temp_vv)=temp_vv;
                            colors(2,ii+temp_vv)=temp_colors(3,ii);
                        else
                            cars_out=cars_out+1;
                        end
                    else
                        temp_vv=min([temp_v(3,ii)+1,vmax,d]);
                        if rand<p
                            temp_vv=max(temp_vv-1,0);
                        end
                        if ii+temp_vv<=m
                            cars(3,ii+temp_vv)=1;
                            v(3,ii+temp_vv)=temp_vv;
                            colors(3,ii+temp_vv)=temp_colors(3,ii);
                        else
                            cars_out=cars_out+1;
                        end
                    end
                end
            end
            
             %% update lane 2
            if temp_cars(2,ii)==1 && ii~=40% car in current position ii lane 2 
                if temp_v(2,ii)==0 && rand(1)<p_l
                    %do not move
                    temp_vv=0;
                    cars(2,ii+temp_vv)=1;
                    v(2,ii+temp_vv)=temp_vv;
                    colors(2,ii+temp_vv)=temp_colors(2,ii);
                else
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
                    
                    d_r=0; % lane 3, space before
                    d_r_b=0; % lane 3, space back
                    
                    if cars(3,ii+1:m)==0
                        d_r=vmax;
                    else
                        for jj=ii+1:m
                            if cars(3,jj)==0
                                d_r=d_r+1;
                            else
                                break
                            end
                        end
                    end
                    
                    if ii<=vmax
                        d_r_b=0;
                    else
                        for jj=ii:-1:1
                            if cars(3,jj)==0
                                d_r_b=d_r_b+1;
                            else
                                break
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
                    
                    if  d_r>d && d_r_b>=vmax && rand(1)<p_c %&& 0
                        %change to lane 3
                        temp_vv=min([temp_v(2,ii)+1,vmax,d_r]);
                        if ii+temp_vv<=m
                            cars(3,ii+temp_vv)=1;
                            v(3,ii+temp_vv)=temp_vv;
                            colors(3,ii+temp_vv)=temp_colors(2,ii);
                        else
                            cars_out=cars_out+1;
                        end
                        
                    elseif d<l && d_o>=l && d_b>=vmax && rand(1)<p_c
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
            end

            %% updata lane 1
            if temp_cars(1,ii)==1 && ~ismember(ii,39:41) % car in current position ii lane 1
                if temp_v(1,ii)==0 && rand(1)<p_l
                    %do not move
                    temp_vv=0;
                    cars(1,ii+temp_vv)=1;
                    v(1,ii+temp_vv)=temp_vv;
                    colors(1,ii+temp_vv)=temp_colors(1,ii);
                else
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
                    
                    d_r=0; %for lane 2
                    d_r_b=0;
                    if cars(2,ii+1:m)==0
                        d_r=vmax;
                    else
                        for jj=ii+1:m
                            if cars(2,jj)==0
                                d_r=d_r+1;
                            else
                                break
                            end
                        end
                    end
                    
                    if ii<=vmax
                        d_r_b=0;
                    else
                        for jj=ii:-1:1
                            if cars(2,jj)==0
                                d_r_b=d_r_b+1;
                            else
                                break
                            end
                        end
                    end
                    
                    if d_r>d && d_r_b>vmax && rand(1)<p_c
                        %change to lane 2
                        temp_vv=min([temp_v(1,ii)+1,vmax,d_r]);
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
        end
        cars(1,39:41)=0; cars(2,40)=0; % cancel the cars in the jam area 
        %% new car coming
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
        if rand(1)<q3 % new car coming for line 3
            if cars(3,1)==0
                cars(3, 1)=1;
                v(3,1)=randi(vmax,1);
                colors(3,1)=randi(60,1)/100+2.2; % 1
                cars_in=cars_in+1;
            end
        end
        
        cars_on=sum(cars(:));
        if cars_on>75
            freeze=1;
            disp(stepnumber);
            EXIT=1;
        end
        %update the color data
        a1([2 3 4],:)=1; a2([2 3 4],:)=1; a3([2 3 4],:)=1;
        a1(2,[39 40 41 42])=0.2;a2(2,[39 40 41 42])=0.2;a3(2,[39 40 41 42])=0.2;
        a1(3,[40 41])=0.2;a2(3,[40 41])=0.2;a3(3,[40 41])=0.2;
        for ii=1:m
            for kk=1:3
                if cars(kk,ii)==1
                    if colors(kk,ii)<=1
                        a1(kk+1,ii)=colors(kk,ii); a2(kk+1,ii)=colors(kk,ii);
                    elseif colors(kk,ii)<=2
                        a1(kk+1,ii)=colors(kk,ii)-1; a2(kk+1,ii)=0;  a3(kk+1,ii)=0;
                    else
                        a1(kk+1,ii)=0;  a3(kk+1,ii)=0;  a2(kk+1,ii)=colors(kk,ii)-2;
                    end
                end
            end
        end
        
        set(imh, 'cdata', cat(3,a1,a2,a3));
        %update the step number diaplay
        stepnumber = 1 + str2double(get(number,'string'));
        set(number,'string',num2str(stepnumber));
        pause(0.1);
    end
    if EXIT==1
        %stop=1;
        freeze=1;
        %close;
    end
    if (freeze==1)
        run = 0;
        freeze = 0;
    end
    drawnow; %need this in the loop for controls to work
 end

