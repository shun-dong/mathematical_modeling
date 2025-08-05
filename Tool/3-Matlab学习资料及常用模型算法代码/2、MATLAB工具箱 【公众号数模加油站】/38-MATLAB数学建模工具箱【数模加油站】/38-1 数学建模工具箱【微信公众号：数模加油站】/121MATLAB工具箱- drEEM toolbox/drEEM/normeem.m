function Xnew=normeem(data,varargin)

% Normalise EEMs to reduce concentration effects, or reverse a normalisation 
% that was applied previously.
%
%USEAGE  Xnew=normeem(data,options,f,specs)
%INPUTS
%        data:
%     options: (optional)
%              'reverse'- reverse normalisation if applied previously
%           f: (optional) number of components in model that is to be 
%              unscaled in reverse case.
%       specs: (optional) {convgcrit, constraint}
%              constraints and convergence criteria applied during
%              modelling. If not specified, this will be taken from data
%              in {data.Val_ConvgCrit, data.Val_Constraints}, or else
%              {data.Modelfconvgcrit, data.Modelfconstraints}, or else
%              {data.OutlierTest_convgcrit, data.OutlierTest_constraints}
%
%
%OUTPUTS
%       Xnew, which is the same as data except that 
%       if options =[], 
%             Xnew.X now contains the normalised dataset;
%             Xnew.Xnotscaled now contains the original dataset;
%       if options ='reverse', Xnew.Modelf contains the f-component model
%          with the true (unscaled) scores.
%             Xnew.X now contains the unscaled dataset;
%             Xnew.Xnorm now contains the normalised dataset;
%             Xnew.Xnotscaled has been removed;
%
%EXAMPLES
%
%       Xnew=normeem(data)   %normalise samples in data.X
%       Xnew=normeem(val6,'reverse',6) %reverse normalisation of 6 comp model
%       Xnew=normeem(data,'reverse',6,{1e-6,'nonnegativity})
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% normeem: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(1,4)
Xnew=data;
cc=[];const=[];f=[];
    
if nargin==1
    ncase='apply';
end
if nargin>1
    isfield(data,'Xnotscaled')
    isfield(Xnew,'Xnotscaled')
    ncase=varargin{1};
    if ~strcmp(ncase,'reverse')
        error('wrong number of inputs for reverse case')
    end
    if nargin==2
        error('number of factors must be specified in the reverse case')
    end
    if nargin>2
        f=varargin{2};
        if isempty(f)
            error('Number of factors in model must be specified')
        end
        if nargin>3
            specs=varargin{3};
            if ~iscell(specs)
                error('Specify convergence criteria and constraints in curly brackets {}')
            end
            cc=specs{1};const=specs{2};
        end
    end
end

switch ncase
    case 'apply'
        Xnew.Xnotscaled=data.X;
        Xnew.X=nprocess(data.X,[0 0 0],[1 0 0]);
        Xnew.Preprocess='Normalised to unit variance in sample mode';
    case 'reverse'
        if ~isfield(data,'Xnotscaled')
            error('data.Xnotscaled does not contain the unscaled X data')
        else
            if ~isequal(size(data.X),size(data.Xnotscaled))
                error('data.X and data.Xnotscaled must be of equal size')
            end
        end
        Db=size(data.Xnotscaled);
        for i=f;
            if or(isempty(cc),isempty(const))
                if isfield(data,{'Val_ConvgCrit','Val_Constraints'})
                    cc=data.Val_ConvgCrit;
                    const=data.Val_Constraints;
                elseif isfield(data,{['Model' int2str(i) 'convgcrit'],['Model' int2str(i) 'constraints']})
                    cc=data.(['Model' int2str(i) 'convgcrit']);
                    const=data.(['Model' int2str(i) 'constraints']);
                elseif isfield(data,{'OutlierTest_convgcrit','OutlierTest_constraints'})
                    cc=data.OutlierTest_convgcrit;
                    const=data.OutlierTest_constraints;
                else
                    error('Specify convergence criteria and constraints in ''specs''')
                end
            end
            modeln=data.(['Model' int2str(i)]);
            [~,B,C]=fac2let(modeln);
            forced=nwayparafac(data.Xnotscaled,i,cc,const,{rand(Db(1),i);B;C},[0 1 1]);
            [Anew,B,C]=fac2let(forced);
            Xnew.(['Model' int2str(i)])={Anew;B;C};
            Xnew.(['Model' int2str(i) 'preprocess'])='Reversed normalisation to recover true scores';
        end
        Xnew.Xnorm=data.X;
        Xnew.X=data.Xnotscaled;
        Xnew=rmfield(Xnew,'Xnotscaled');
end

