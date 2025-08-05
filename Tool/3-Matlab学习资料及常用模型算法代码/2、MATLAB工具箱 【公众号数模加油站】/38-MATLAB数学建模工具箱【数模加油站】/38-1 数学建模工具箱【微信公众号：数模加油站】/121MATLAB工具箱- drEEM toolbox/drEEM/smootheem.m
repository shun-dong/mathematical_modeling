function Xs=smootheem(Xin,varargin)

% Excise EEM scatter and (optionally) interpolate between missing values.
% Primary and secondary Rayleigh and Raman are removed and smoothed if 
% requested, or left as NaNs. Zeros may be placed at a specified
% distance below the line Em=Ex. Optional plots can be shown that compare 
% the EEMs before and after excising/smoothing.
%
% USEAGE:
% Xs=smootheem(Xin,Ray1,Ram1,Ray2,Ram2,NaNfilter,d2zero,freq,plotview)
%
% INPUT:
%   Xin: either a structure array or a dataset object containing at minimum
%       the EEMs, Ex and Em.
%       i.e.
%         Xin.X = X; % The EEMs
%         Xin.Em = Em; % The emission wavelengths (nm)
%         Xin.Ex = Ex; % The excitation wavelengths (nm)
%
%   Ray1: extent of 1st order Rayleigh scatter above and below the peak (nm)
%         []: no 1st order scatter, this is faster than using [0 0]
%         [0 20] - 0 nm above, 20 nm below
%         default value is [] indicating no scatter
%
%   Ram1: above and below extent of 1st order Raman scatter, in nm
%         example as for Ray1
%
%   Ray2: above and below extent of 2nd order Rayleigh scatter, in nm
%         example as for Ray1
%
%   Ram2: above and below extent of 2nd order Raman scatter, in nm
%         example as for Ray1
%
%   NaNfilter: Turn interpolation on/off for [Ray1 Ram1 Ray2 Ram2],
%         by using 1=on, 0=off
%         []: interpolation of all peaks (default)
%         [1 1 0 0]: interpolation for primary, NaNs for secondary
%                    scatter peaks
%         [1 1 1 0]: interpolation except for Ram2
%
%   d2zero: distance below Ray1 before zeros are placed. Between Ray1
%          and zeros are NaNs. If zerowidth=[], no zeros or NaNs 
%          are placed. The default value is zerowidth=40 nm.
%            
%   freq: frequency (cm-1) of energy loss due to non-elastic Raman scatter.
%         For water, the Raman peak appears at a wavenumber ~3400-3600 cm–1
%         lower than the incident wavenumber. Default value is 3382.
%
%   plotview: length of time (in seconds) to show EEMs on screen 
%          if display=0, no plots will be created.
%          if display=1, plots are displayed for 1 second then closed
%          if display='pause', each plot will be displayed until the 
%          user presses a key in order to progress to the next EEM in 
%          the series. There is no default value; plotview must always
%          be specified as the final input variable. 
%
% OUTPUT:
%
%   EEMcor: A data structure with the smoothed EEM in EEMcor.X and the 
%           excised EEM (with NaNs, no smoothing) in EEMcor.Xf
%
% EXAMPLES:    
%
%  EEMcor=smootheem(Xa,[15 15],'pause'); %1st order scatter, manually cycle through plots
%  EEMcor=smootheem(Xa,[10 10],[],[10 10],[],30,0); %no Raman scatter,no plots, 
%  EEMcor=smootheem(Xa,[10 10],[20 20],[10 10],0.5); %Rayleigh, 1st order Raman,0.5s plot display
%  EEMcor=smootheem(Xa,[10 10],[20 20],[10 10],[1 1 0 0],0.5); %smooth only primary peaks 
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% smootheem: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

%% Check optional input variables and set defaults
narginchk(2,9)
Ray1=[];Ray2=[];Ram1=[];Ram2=[];NaNfilter=[];d2zero=40;freq=3382;
warning('OFF', 'MATLAB:interp1:NaNstrip'); %ignore columns of missing data
if nargin>=2
    plotview=varargin{nargin-1};
    if isnumeric(plotview)
        if or(isempty(plotview),max(size(plotview))>1)
            error('The final input variable must specify a valid plot display option')
        elseif plotview>0
            fprintf(['plots will be displayed for ' num2str(plotview) ' seconds. \n'])
        end
    end
    if nargin>=3
        Ray1=varargin{1};
        if  nargin>=4
            Ram1=varargin{2};
            if  nargin>=5
                Ray2=varargin{3};
                if  nargin>=6
                    Ram2=varargin{4};
                    if  nargin>=7
                        NaNfilter=varargin{5};
                        if  nargin>=8
                            d2zero=varargin{6};
                            if  nargin>=9
                                freq=varargin{7};
                                if or(max(size(freq))>1,isempty(freq))
                                    error('invalid value for wave number')
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
%Ray1,Ray2,Ram1,Ram2,NaNfilter,d2zero,freq,pause

%% Obtain X, Ex and Em from input data structure / dataset
if isstruct(Xin)
    Em=Xin.Em';
    Ex=Xin.Ex';
    X=Xin.X;
    Xm=X;
    Xs=Xin;
else
    try
        Em=Xin.axisscale{2};
        Ex=Xin.axisscale{3};
        X=Xin.data;
        Xm=X;
        Xs.Em=Em'; Xs.Ex=Ex';Xs.nSample=size(Xm,1);
        Xs.nEx=length(Ex); Xs.nEm=length(Em);
    catch ME1
        fprintf('\n');
        error('X must be either a MATLAB data structure or a PLStoolbox dataset structure.')
    end
end
Xs.X=NaN*ones(size(Xm));
[N, EmLen, ExLen]=size(Xm);

fprintf('Applying excise/smooth procedures. Please wait...\n\n')
RamScat=zeros([1 ExLen]);
for i=1:ExLen;
    RamScat(i)=1/(1/Ex(i) - freq/10^7); 
    if ~isempty(Ray1),
        j1=and(Em>Ex(i)-Ray1(2),Em<Ex(i)+Ray1(1));
        Xm(:,j1,i)=NaN;
    end
    if ~isempty(Ram1),
        j2=and(Em>RamScat(i)-Ram1(2),Em<RamScat(i)+Ram1(1));
        Xm(:,j2,i)=NaN;
    end
    if ~isempty(Ray2),
        j3=and(Em>(2*Ex(i)-Ray2(2)),Em<2*Ex(i)+Ray2(1));
        Xm(:,j3,i)=NaN;
    end
    if ~isempty(Ram2),
        j4=and(Em>2*RamScat(i)-Ram2(2),Em<2*RamScat(i)+Ram2(1));
        Xm(:,j4,i)=NaN;
    end
end
Xf=Xm;

%% Interpolation
i_data3=~isnan(Xm);
for j=1:N;
    i_ex=squeeze(i_data3(j,EmLen,:));
    EmVecNonNAN=squeeze(Xm(j,end,i_ex));
    ExNonNAN=Ex(i_ex);
    endvec=interp1(ExNonNAN,EmVecNonNAN,Ex,'cubic','extrap');
    endvec(endvec<0)=0;
    Xm(j,EmLen,:)=endvec;
    
    i_data2=~isnan(squeeze(Xm(j,:,:)));
    for i=1:ExLen;
        i_em=squeeze(i_data2(:,i));
        ExVecNonNAN=squeeze(Xm(j,i_em,i));
        EmNonNAN=Em(i_em);
        if i_em(1)==1
            ExVec=interp1(EmNonNAN,ExVecNonNAN,Em,'cubic');
        elseif i_em(1)==0
            ExVec=interp1([Ex(1),EmNonNAN],[0,ExVecNonNAN],Em,'cubic');
        end
        Xm(j,:,i)=ExVec;
        if ~isnan(d2zero)
            k1 = Em<Ex(i);
            Xm(:,k1,i)=NaN;
            k2 = Em<Ex(i)-Ray1(2)-d2zero;
            Xm(:,k2,i)=0;
        end
    end
end
Xm(Xm<0)=0;

%Apply optional NaN filter
if ~isempty(NaNfilter)
    for i=1:ExLen;
        RamScat(i)=1/(1/Ex(i) - freq/10^7);
        if and(NaNfilter(1)==0,~isempty(Ray1))
            j1=and(Em>Ex(i)-Ray1(2),Em<Ex(i)+Ray1(1));
            Xm(:,j1,i)=NaN;
        end
        if and(NaNfilter(2)==0,~isempty(Ram1))
            j2=and(Em>RamScat(i)-Ram1(2),Em<RamScat(i)+Ram1(1));
            Xm(:,j2,i)=NaN;
        end
        if and(NaNfilter(3)==0,~isempty(Ray2))
            j3=and(Em>(2*Ex(i)-Ray2(2)),Em<2*Ex(i)+Ray2(1));
            Xm(:,j3,i)=NaN;
        end
        if and(NaNfilter(4)==0,~isempty(Ram2))
            j4=and(Em>2*RamScat(i)-Ram2(2),Em<2*RamScat(i)+Ram2(1));
            Xm(:,j4,i)=NaN;
        end
    end
end
Xs.X=Xm;
Xs.Xf=Xf;
Xs.Smooth=[num2str(Ray1),',' num2str(Ram1) ',' num2str(Ray2) ',' num2str(Ram2),',' num2str(NaNfilter) ',' num2str(d2zero),',' num2str(freq)];
fprintf('..finished!\n\n');

%% Optional Plotting
if ~plotview==0;
    fprintf('Plotting results one sample at a time.\n')
    fprintf('Press Cntrl+C to cancel.\n')
    fig=figure;
    h1=subplot(2,2,1); colorbar,pos1=get(h1,'position');
    h2=subplot(2,2,2); colorbar,pos2=get(h2,'position');
    h3=subplot(2,1,2); colorbar,pos3=get(h3,'position');
    %h4=subplot(2,2,4); colorbar,pos4=get(h4,'position');
    for iSample=1:size(X,1)
        subplot(h2)
        contourf(Ex,Em,squeeze(Xs.Xf(iSample,:,:))), colorbar
        set(h2,'position',pos2)
        title('Cut')
        xlabel('Ex. (nm)')
        clim=get(h2,'CLim');
        
        subplot(h1)
        contourf(Ex,Em,squeeze(X(iSample,:,:))), colorbar
        set(h1,'position',pos1)
        title(['Sample # ' num2str(iSample)]),
        xlabel('Ex. (nm)')
        ylabel('Em. (nm)')
        set(h1,'CLim',clim)
        
        subplot(h3)
        contourf(Ex,Em,squeeze(Xs.X(iSample,:,:))), colorbar
        set(h3,'position',pos3)
        set(h3,'CLim',clim)
        title('Smoothed '),
        xlabel('Ex. (nm)')
        ylabel('Em. (nm)')
        axis('tight')
        if and(isnumeric(plotview),plotview>0);
            pause(plotview)
        else
            pause;
        end
        figure(fig)
    end
end
