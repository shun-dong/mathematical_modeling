function [LSmodel,convergence,DSit]=randinitanal(data,f,it,constraints,varargin)

%Run PARAFAC multiple times to identify the least squares solution, or plot
%models that were generated previously using randinitanal. New models are
%initialised with random values and fit with a convergence criterion of
%1e-6, unless a different convergence criterion is specified.
%
%USEAGE: 
%       results=randinitanal(data,f,it,constraints,convgcrit)
%
%INPUTS: 
%        data: data structure containing EEMs to be modelled in data.X.
%           f: Number of components in the model to be fitted.
%          it: number of times to run the model with random initial values.
% constraints: 
%       'nonnegativity': constrain spectra to positive values in all modes.
%       'unconstrained': no constraints (default).
%       'existing': do not generate new models but generate the SSE/it and
%                   core consistency plots for an existing set of models.
%   convgcrit: (optional) convergence criterion for PARAFAC model
%          []: use default value (1e-6 = 0.000001).
%           n: use specified value (warning if n>0.01).
%
%OUTPUTS:
%       LSmodel: Least squares model chosen from all model runs.
%   convergence: Summary of convergence results for each run.
%          DSit: New data structure containing iterated models. 
%
%    Additionally, a plot will be shown of the sum of squared errors and 
%    number of iterations before the model converged, for each run. 
%    The run number with the least squares solution will be identified.
%
%Examples
%   LSmodel5=randinitanal(AnalysisData,5,10,'unconstrained')
%   [LSmodel5,converg5,DSit5]=randinitanal(AnalysisData,5,10,'nonnegativity',1e-8)
%   randinitanal(DSit5,5,10,'existing')
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

%% Inputs
narginchk(4,5)
CC=1e-6;
if nargin>4
    CC=varargin{1};
    if isempty(CC)
        CC=1e-6;
    end
    if ~isnumeric(CC)
        error('Unrecognised input for convergence criterion')
    elseif CC>0.01;
        warntxt=['Unexpectedly high convergence criterion: ' num2str(CC) '. Press any key to continue or ^C to cancel'];
        warning('drEEM:CC',warntxt);
        pause;
    end
end

%% Modelling
initialisationtype=2;
errmat=NaN*ones(it,1);
itmat=NaN*ones(it,1);
for i=1:it,
    if strcmp(constraints,'existing')
        try
            errmat(i) = getfield(data,{1,1},['Model' int2str(f) 'err_run' int2str(i)]);
             itmat(i) = getfield(data,{1,1},['Model' int2str(f) 'it_run' int2str(i)]);
        catch ME
            error(['Model' int2str(f) 'err_run' int2str(i) ' was not found in input data structure'])
        end
    else
        if i==1
            fprintf (['\n\n Model ' int2str(f) ' with random initialization and convergence criterion ' num2str(CC) '\n\n '])
        end
        fprintf (['\n\n                        *** Run No. ' int2str(i) ' of ' int2str(it) ' ***\n\n '])
        
        if strcmp(constraints,'nonnegativity')
            [Model,Iter,Err,corecon]=nwayparafac(data.X,f,[CC initialisationtype],[2 2 2]);
        elseif strcmp(constraints,'unconstrained')
            [Model,Iter,Err,corecon]=nwayparafac(data.X,f,[CC initialisationtype]);
        else
            error('Accepted options are ''nonnegativity'', ''unconstrained'', and ''existing''')
        end
        data = setfield(data,{1,1},['Model' int2str(f) '_run' int2str(i)],Model);
        data = setfield(data,{1,1},['Model' int2str(f) 'err_run' int2str(i)],Err);
        data = setfield(data,{1,1},['Model' int2str(f) 'it_run' int2str(i)],Iter);
        data = setfield(data,{1,1},['Model' int2str(f) 'core_run' int2str(i)],corecon);
        errmat(i)=Err;
        itmat(i)=Iter;
    end
end
[minerr,mini]=min(errmat);

%Iterated models
DSit=data;

%Least Squares Model
LSmodel=data;
F=fieldnames(LSmodel);
runs=cellfun(@isempty,strfind(F,'run'));
LSmodel=rmfield(LSmodel,F(~runs));
LSmodel.(['Model' int2str(f)])= getfield(data,{1,1},['Model' int2str(f) '_run' int2str(mini)]);
LSmodel.(['Model' int2str(f) 'err' ])= getfield(data,{1,1},['Model' int2str(f) 'err_run' int2str(mini)]);
LSmodel.(['Model' int2str(f) 'it' ])= getfield(data,{1,1},['Model' int2str(f) 'it_run' int2str(mini)]);
LSmodel.(['Model' int2str(f) 'core' ])= getfield(data,{1,1},['Model' int2str(f) 'core_run' int2str(mini)]);
LSmodel.(['Model' int2str(f) 'source' ])= ['Model' int2str(f) 'it_' int2str(mini)];
LSmodel.(['Model' int2str(f) 'convgcrit'])= CC;
LSmodel.(['Model' int2str(f) 'constraints'])= constraints;
LSmodel.(['Model' int2str(f) 'initialise'])= 'random';
convergence=[(1:it)' errmat itmat];

%Variance Explained -total
modeln=LSmodel.(['Model' int2str(f)]);
err=LSmodel.(['Model' int2str(f) 'err' ]);
ssX = sum(data.X(~isnan(data.X)).^2);
TotPercentExplVar=100*(1-err/ssX);

%Variance Explained -by component
[A,B,C]=fac2let(modeln);
ssF=NaN*ones(1,f);sizeF=ssF;errF=ssF;
modelledF=NaN*ones([data.nSample,data.nEm,data.nEx]);
for i=1:f
    compF=B(:,i)*C(:,i)';
    for j=1:data.nSample
        modelledF(j,:,:) =A(j,i)*compF;
    end
    resF = data.X-modelledF;
    errF(i)=sum(resF(~isnan(data.X)).^2); 
    sizeF(i)=100*(1-errF(i)/ssX); 
end
LSmodel.(['Model' int2str(f) 'percentexpl'])= TotPercentExplVar;
LSmodel.(['Model' int2str(f) 'compsize'])= sizeF;

%Plotting
figure
AX=plotyy((1:it)',errmat,(1:it)',itmat);
set(AX(1),'XTick',[])
set(AX(2),'XTick',1:it)
set(AX(2),'XTickLabel',num2str((1:it)'))
hold on,
plot(mini,minerr,'bo','MarkerSize',8,'MarkerFaceColor','b')
title(['Comparisons of ' int2str(it) ' repeat runs of ' int2str(f) '-component model']),
set(get(AX(1),'Ylabel'),'String','Sum of Squared Errors') 
set(get(AX(2),'Ylabel'),'String','iterations until convergence') 
set(get(AX(2),'Xlabel'),'String','Model run number') 
legend('SSE','least squares result','iterations');
figure,corcond(data.X,modeln,[],1);

