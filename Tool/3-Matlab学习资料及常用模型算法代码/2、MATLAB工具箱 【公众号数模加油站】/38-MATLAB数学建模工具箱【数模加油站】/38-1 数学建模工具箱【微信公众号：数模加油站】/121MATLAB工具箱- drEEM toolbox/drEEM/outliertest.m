function Test=outliertest(data,varargin)

%Look for unusual samples or wavelengths in a dataset by generating PARAFAC
%models of data.X and evaluating leverages. For speed, models are fit using
%SVD vectors for initialisation with a convergence criterion of 1e-02.
%Speed up modeling further by using fewer wavelengths in the models. Note
%that the chosen model should be confirmed using all of the data with a
%stricter convergence criterion (typically 1e-06 or lower) and random
%initialisation (see randinitanal.m).
%
% USEAGE:
%    Test=outliertest(data,wavestep,myfactors,constraints,CC,Stepwise)
%
% INPUT:
%       data: data structure containing EEMs to be modelled in data.X
%
%   wavestep: (optional wavelength selection - [ExInt,EmInt])
%         wavestep=[] or [1,1]: use all the data (default)
%         wavestep=[1,2]: use every other Em wavelength 
%         wavestep=[2,2]: every other Ex and Em wavelength
%
%  myfactors: (optional, numbers of factors in models)
%                     []: construct models with 2-6 components (default)
%               e.g. 2:5: construct models with 2,3,4 and 5 factors
%
%constraints: (optional, default = 'unconstrained')
%        'nonnegativity': Apply non-negativity constraints on all modes
%        'unconstrained': No constraints
%
%         CC: (optional) convergence criterion for PARAFAC model
%                     []: default value used is 1e-2
%
%  Stepwise : (optional, default = 'stepwise')
%             In stepwise mode,  models are run one at a time 
%             and diagnostic plots  created immediately after each  model. 
%             Press enter to continue to the next PARAFAC model. 
%             'stepwise': run model in stepwise mode
%              'at once': run models at once
%
% Examples
%   Test=outliertest(Xs) %Defaults: 2-6 factors, unconstrained models,
%   Test=outliertest(Xs,[2,2],2:7)
%   Test=outliertest(Xs,[1,2],5,'nonnegativity')
%   Test=outliertest(Xs,[],4:5,'unconstrained',1e-6,'at once')
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
%Copyright (C) 2013- Kate Murphy krm@unsw.edu.au
%Copyright (C) 2008- Colin Stedmon
%
% $ Version 0.1.0 $ September 2013 $ First Release

%%
%Checks and Defaults
narginchk(1,6)
EmInt=1;ExInt=1;
myfactors=2:6;
NonNegativity=0;
Stepwise=1;
convgcrit=1e-2;
if nargin>1
    wavestep=varargin{1};
    if isempty(wavestep)
        wavestep=[1,1];
    end
    ExInt=wavestep(1);
    EmInt=wavestep(2);
    if nargin>2
        myfactors=varargin{2};
        if nargin>3
            NN=varargin{3};
            switch NN
                case{'nonnegativity','Nonnegativity'}
                    NonNegativity=1;
                case{'Unconstrained','unconstrained'}
                    NonNegativity=0;
            end
            if nargin>4
                convgcrit=varargin{4};
                if isempty(convgcrit)
                    convgcrit=1e-2;
                end
                if ~isnumeric(convgcrit)
                    error('Unrecognised input for convergence criterion')
                elseif convgcrit>0.01;
                    warning(['Unexpected convergence criterion: ' num2str(convgcrit) '. Press any key to continue or ^C to cancel']);
                    pause;
                end
                if nargin>5
                    SW=varargin{5};
                    switch SW
                        case{'stepwise','Stepwise'}
                            Stepwise=1;
                        case{'at once','At once','atonce'}
                            Stepwise=0;
                    end
                end
            end
        end
    end
end

%Reduce dataset to increase speed
Test=data;
Test.X=data.X(:,1:EmInt:end,1:ExInt:end);
if isfield(Test,'Xf')
    Test.Xf=data.Xf(:,1:EmInt:end,1:ExInt:end);
end
Test.Em=data.Em(1:EmInt:end);
Test.Ex=data.Ex(1:ExInt:end);
Test.nEm=length(Test.Em);
Test.nEx=length(Test.Ex);
Test.nSample=length(Test.X);

%preexisting fields
vars=char('Val_ModelName','Val_Source','Val_Err','Val_It','Val_Result',...
    'Val_Splits','Val_Comparisons','Val_R','Val_Matches','Val_ExCC',...
    'Val_EmCC','_it','_err');

%Modelling
for NumFac=myfactors
    if NonNegativity
        Model=nwayparafac(Test.X,NumFac,[convgcrit 1 Stepwise 1],[2 2 2]);
    else
        Model=nwayparafac(Test.X,NumFac,[convgcrit 1 Stepwise 1]);
    end
    mname=['Model',int2str(NumFac)];
    Test = setfield(Test,{1,1},mname,Model);
    if Stepwise
        pause
    end

    for i=1:size(vars,1)
        v=[mname deblank(vars(i,:))];
        if isfield(data,v)
            Test=rmfield(Test,v);
        end
    end
end
Test.OutlierTest_convgcrit=convgcrit;
Test.OutlierTest_constraints=NN;