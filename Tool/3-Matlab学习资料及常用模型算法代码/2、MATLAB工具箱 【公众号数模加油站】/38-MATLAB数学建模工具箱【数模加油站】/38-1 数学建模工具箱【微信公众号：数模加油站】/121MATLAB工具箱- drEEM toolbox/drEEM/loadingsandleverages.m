function loadingsandleverages(data,f,varargin)
% Visualise the PARAFAC model loadings and leverages. Leverages show the
% impact of each sample and wavelength (excitation, emission) on the model.
%
% USEAGE:   
%       loadingsandleverages(data,f,it,fignames)
%
% INPUTS: 
%      data: dataset structure containing PARAFAC model results
%         f: Number of components in the model to be plotted, 
%            e.g. 6 to plot the 6-component model in data.Model6.
%       run: (optional) 
%            Run number of model to be plotted, when data contains
%            multiple runs of the same model, as from the output
%            of randinitanal.
%             []: the main model will be plotted (default)
%              n: plot run number x (the model plotted will be
%                data.Modeln_runx, e.g. data.Model6_run2)
%  fignames: (optional) 
%             []: by default the figure is called 
%               "Model f - scores, leverages and loading"
%       'mytext': prefix the figure name by the word(s) in mytext
%
% EXAMPLES:
%    loadingsandleverages(Test1,6)
%    loadingsandleverages(Test1,6,5)
%    loadingsandleverages(S.Split(1),6,5,'Split 1, Run 5')
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% loadingsandleverages: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release
%%%%%%

%Initialise
narginchk(2,4)
fignames=[];
R=[];
if length(f)>1
    error('Specify one value of ''f'' at a time');
else
    modelf=['Model' num2str(f)];
end
if nargin>2
    R=varargin{1};
    if nargin>3
        fignames=varargin{2};
    end
end

if ~isempty(R)
    if ~isnumeric(R)
        error('Input for variable ''run'' is not understood.')
    else
        modelf=[modelf '_run' int2str(R)];
    end
end

if ~isfield(data,modelf)
   disp(modelf)
   disp(data)
   error('loadingsandleverages:fields',...
       'The dataset does not contain a model with the specified number of factors') 
end
M = getfield(data,{1,1},modelf);
A=M{1};B=M{2};C=M{3};
DimX = size(data.X);

h=figure;
if isempty(fignames)
    set(h,'Name',[modelf ' - scores,leverage and loadings']);
else
    set(h,'Name',[fignames ' ' modelf ' - scores,leverage and loadings']);
end    
xaxl=char('Sample #','Em. (nm)','Ex. (nm)');
yaxl=char('Scores','Loadings','Loadings','Leverage');
taxl=char('Sample','Emission','Excitation');
for i=1:3;
    subplot(2,3,i),
    if i==1; 
        plot(A);
    elseif i==2; 
        plot(data.Em,B);
    elseif i==3; 
        plot(data.Ex,C);
    end
    axis tight
    ylabel(yaxl(i,:))
    xlabel(xaxl(i,:))
    title(taxl(i,:))
    if i==3,legend(num2str((1:size(B,2))'),'Location','Best'),end
end

factors = [M{1}(:);M{2}(:);M{3}(:)];

% PLOTS OF LEVERAGE
lidx=[3 DimX(1)*f];
lidx(1,:)=[1 DimX(1)*f];
lidx(2,:)=[lidx(1,2)+1 sum(DimX(1:2))*f];
lidx(3,:)=[lidx(2,2)+1 sum(DimX(1:3))*f];

for i=4:6
    A=reshape(factors(lidx(i-3,1):lidx(i-3,2)),DimX(i-3),f);
    lev=diag(A*pinv(A'*A)*A');
    subplot(2,3,i)
    if std(lev)>eps
        if i==4
            plot(lev+100*eps,'+'),
            for j=1:DimX(1)
                text(j,lev(j),num2str(j))
            end
        elseif i==5
            plot(data.Em,lev+100*eps,'+'), axis tight
        elseif i==6
            plot(data.Ex,lev+100*eps,'+'), axis tight
        end
        
    else
        warning('Leverage is constant')
    end
    xlabel(xaxl(i-3,:))
    ylabel(yaxl(4,:))
end




    
    