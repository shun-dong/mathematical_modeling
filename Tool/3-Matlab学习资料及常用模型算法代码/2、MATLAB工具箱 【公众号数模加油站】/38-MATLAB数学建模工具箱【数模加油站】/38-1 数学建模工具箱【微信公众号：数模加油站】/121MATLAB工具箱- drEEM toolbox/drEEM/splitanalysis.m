function newdata=splitanalysis(data,f,varargin)

%Generate PARAFAC models nested in dataset splits. Specify non-negativity
%constraint if it is desired (default is to produce unconstrained models).
%Models may be intialised by random vectors or SVD vectors. If not
%otherwise specified, the default convergence criterion used is 1e-6.
%
% USEAGE:    newdata=splitanalysis(data,f,constraints,runs,cc,SaveDataAs)
%
% INPUT:   
%        data: data structure containing one or more smaller data structures
%              in data.Split(f)
%
%           f: Number of components in the PARAFAC model(s)
%              e.g. 6 - fits a 6 component PARAFAC model
%              e.g. 3:5- fits 3, 4 and 5 component models
%
% constraints: (optional) 
%              'no constraints' - unconstrained model (default)
%              'nonnegativity' - positive solutions on all modes
%
%        runs: (optional) Number of runs (iterations) for each model.
%                       []: run the model once for each value of f 
%                           using SVD vectors for initialization.
%              [n1,n2,...]: run the model in split(i) ni times using 
%                           random vectors to initialise and keeping
%                           only the model with the best fit
%                           (the least squares solution).
%
%          cc: (optional) convergence criterion for each PARAFAC model
%                       []: default value used (1e-6) for each model
%              [n1,n2,...]: apply the i'th value of cc to model in split(i)
%
%  SaveDataAs: (optional) save data to file
%             Specify file name where new data will be saved
%             Models are saved after fitting so that the
%             can be stopped prematurely without losing previous models.
%
% OUTPUT:   
%    newdata: data structure containing PARAFAC models nested in splits
%             e.g. data.Split(1).Model4  (4 comp. model nested in Split 1)
%
% EXAMPLE
% AnalysisData=splitanalysis(data,5)
% AnalysisData=splitanalysis(data,2:6,'nonnegativity')
% AnalysisData=splitanalysis(data,2:6,'no constraints',[],[],'models2to6')
% AnalysisData=splitanalysis(data,6,'nonnegativity',[5 10 5 5 5 5])
% AnalysisData=splitanalysis(data,6,'nonnegativity',5,1e-8)
% AnalysisData=splitanalysis(data,6,'nonnegativity',[5 10 5 5 5 5],[1e-6 1e-6 1e-8 1e-8 1e-6 1e-6])
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% splitanalysis: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

%%
%Set up defaults and options - Do not edit below this line.
narginchk(2,6);
convgcrit=1e-6;
opts=[0 0 0 0 0 0];
SaveDataAs=[];
initstyle='SVD';

if  ~isfield(data,'Split')
    disp(data)
    error('Input dataset structure is lacking a field named ''Split''')
else
    nsplit=size(data.Split,2);
    runs=ones(1,nsplit);
end
crit=convgcrit*ones(1,nsplit);

constr=[0 0 0];
if nargin>2
    constraints=varargin{1};
    switch constraints
        case{'nonnegativity','Nonnegativity'}
            constr=[2 2 2];
        case{'no constraint','no constraints','noconstraint','noconstraints'}
            constr=[0 0 0];
        otherwise
            error('Unrecognised input for variable: constraints')
    end
    if nargin>3
        runs=varargin{2};
        if isempty(runs)
            runs=ones(1,nsplit);
        elseif ~isnumeric(runs)
            error('Error in the input variable ''runs''.')
        else
            if fix(runs)==runs
                opts(2)=2;
                initstyle='Random';
                if length(runs)==1;
                    runs=runs*ones(1,nsplit);
                elseif length(runs)==nsplit;
                else
                    error('size of vector ''runs'' is not compatible with the number of splits')
                end
            else
                error('Error in the input variable ''runs''.')
            end
        end
        if nargin>4
            convgcrit=varargin{3};
            if ~isnumeric(convgcrit)
                error('Unrecognised input for convergence criterion')
            else
                if isempty(convgcrit)
                    crit=1e-6*ones(1,nsplit);
                elseif length(convgcrit)==1
                    crit=convgcrit*ones(1,nsplit);
                elseif length(convgcrit)==nsplit
                    crit=convgcrit;
                else
                    error('Specify a single convergence criterion or else one for each split')
                end
            end
            if max(crit)>0.01;
                warning(['Unexpected convergence criterion: ' num2str(max(crit)) '. Press any key to continue or ^C to cancel']);
                pause;
            end
            if nargin>5
                SaveDataAs=varargin{4};
                if ~ischar(SaveDataAs)
                    error('Unrecognised input for variable: SaveDataAs')
                end
            end
        end
    end
end

newdata=data;

for NumFac=f
    Ffield=['Model' int2str(NumFac)];
    Ifield=['Model' int2str(NumFac) '_it'];
    Efield=['Model' int2str(NumFac) '_err'];
    Ifieldi=['Model' int2str(NumFac) '_ByRuns_it'];
    Efieldi=['Model' int2str(NumFac) '_ByRuns_err'];
    for j=1:nsplit
        clear Fac It Err 
        riIt =NaN*ones(1,runs(j)); riErr=NaN*ones(1,runs(j)); 
        riErr(1)=10e15;
        opts(1)=crit(j);
        fprintf('\n\n')
        S = getfield(data,{1,1},'Split',{j});
        disp('************************************************************')
        disp(['Factors = ' int2str(NumFac) ', Split = ' int2str(j) '/', int2str(nsplit) ' sample size = ' int2str(S.nSample)])
        for k=1:runs(j);
            fprintf('\n\n')
            disp('***    ***    ***    ***    ***    ***    ***    ')
            disp(['Run no. ' int2str(k) ' of ' int2str(runs(j)) ' in Split ' int2str(j) '.'])
            [Fac,It,Err]=nwayparafac(S.X,NumFac,opts,constr);
            if Err<min(riErr)
                iFac=Fac;
                iIt=It;
                iErr=Err;
            end
            riIt(k)=It;
            riErr(k)=Err;
        end
        newdata = setfield(newdata,{1,1},'Split',{j},Ffield,iFac);
        newdata = setfield(newdata,{1,1},'Split',{j},Ifield,iIt);
        newdata = setfield(newdata,{1,1},'Split',{j},Efield,iErr);
        newdata = setfield(newdata,{1,1},'Split',{j},Ifieldi,riIt);
        newdata = setfield(newdata,{1,1},'Split',{j},Efieldi,riErr);
        if ~isempty(SaveDataAs)
            save(SaveDataAs,'newdata')
        end
    end
end
newdata.Split_AnalRuns=runs;
newdata.Split_PARAFAC_Initialise=initstyle;
newdata.Split_PARAFAC_options=opts;
newdata.Split_PARAFAC_constraints=constr;
newdata.Split_PARAFAC_convgcrit=crit;
end