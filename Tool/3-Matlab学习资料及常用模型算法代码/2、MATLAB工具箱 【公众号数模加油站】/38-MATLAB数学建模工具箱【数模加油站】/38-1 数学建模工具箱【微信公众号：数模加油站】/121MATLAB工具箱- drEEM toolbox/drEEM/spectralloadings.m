function spectralloadings(data,factors,varargin)

%Compare Ex and Em loadings in various models
%
%Useage:   spectralloadings(data,factors,splits,forder)
%Inputs:
%       data: data structure containing model results (e.g. data.Model4).
%    factors:  Number(s) of components in models to be compared
%                [n]: display models with n factors
%            [ni:nf]: display models with ni:nf factors
%     splits:  (optional)
%                [] : display models of full dataset (default)
%                [s]: display models in split n
%            [si:sf]: display models in splits si:sf
%     forder:  (optional)
%                 []: as it comes (1:n)
%            or specify order of plotting components for each split
%            in {model1, model2,...,modeln}
%            e.g.{[1 2 3; 2 3 1],[1 2 3 4; 2 3 4 1],[]} shows the order for
%            plotting components from models with 3-5 factors
%            where two splits are being plotted. The 5 factor model
%            components are plotted as they come (i.e. 1:5)
%
%Examples
%   spectralloadings(data,3:6)
%   spectralloadings(data,6,1:4)
%   spectralloadings(data,3:5,1:2,{[1 2 3; 2 3 1],[1 2 3 4; 2 3 4 1],[]})
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% spectralloadings: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(2,4)
nfac=length(factors);
splits=[];
color=getcolors();
forder=[];errmsg=[];

if nargin>2
    splits=varargin{1};
    nsplit=length(splits);
    if nargin>3
        forder=varargin{2};
        if ~isempty(splits)
            if ~iscell(forder)
                if or(length(factors)>1,~isequal(size(forder),[nsplit factors]));
                    errmsg=true;
                end
                forder={forder};
            else
                if ~isequal(size(forder,2),nfac)
                    errmsg=true;
                    for i=1:size(forder,2)
                        if ~isequal(size(forder{i}),[nsplit,factors(i)])
                            warning(['forder incompatible in model with ' int2str(factors(i)) ' factors'])
                            errmsg=true;
                        end
                    end
                end
            end
            matford=cell2mat(forder);
        else
            if iscell(forder)
                matford=cell2mat(forder);
            else
                matford=forder;
            end
        end
        
        if errmsg
            error('forder incompatible with specified factors')
        end;
    end
end

tit=['Spectral comparison: ' num2str(factors) ' components'];
if ~isempty(splits)
    tit=([tit ' splits ' num2str(splits)]);
end
h=figure;
set(h,'Name',tit);


if isempty(splits)
    plotfacs(data,factors,forder,[])
else
    ford4split=cell(1,nfac);
    for i=1:nsplit
        k=splits(i);
        d=getfield(data,{1,1},'Split',{k});
        if isempty(forder)
            plotfacs(d,factors,[],color(k,:))
        else
        mf=matford(i,:);
            imin=[0 factors];
            for j=1:nfac
                i1=sum(imin(1:j))+1;
                i2=i1+factors(j)-1;
                ford4split{j}=mf(i1:i2);
            end
            plotfacs(d,factors,ford4split,color(k,:))
        end
    end
    legend([repmat('split',[nsplit*2,1]) num2str(reshape([splits; splits],[nsplit*2,1])) repmat(char('Em','Ex'),[nsplit 1])]);
end
end

function plotfacs(data,factors,ford,color)
if isempty(color);color=[0 0 1];end
mfac=max(factors);
nfac=length(factors);

for j=1:nfac
    modelf=['Model' num2str(factors(j))];
    if ~isfield(data,modelf)
        disp(data)
        disp(['Can not find ' modelf])
        error('CompareComponents:fields',...
            'The dataset does not contain a model with the specified number of factors')
    end
    M = getfield(data,{1,1},modelf);
    B=M{2};C=M{3};
    
    if ~isempty(ford)
        if iscell(ford)
            fordbyn=ford{j};
        else
            fordbyn=ford;
        end
        
        if ~isempty(fordbyn)
            B=B(:,fordbyn);
            C=C(:,fordbyn);
        end
    end
    
    for i=1:size(B,2)
        subplot(nfac,mfac,mfac*(j-1)+i);
        plot(data.Em,B(:,i),'-','color',color,'LineWidth',1.5);
        if j==nfac
            xlabel('Wave. (nm)');
        end
        if i==1
            ylabel(['Loads: ' modelf]);
        end
        hold on
        plot(data.Ex,C(:,i),':','color',color,'LineWidth',1.5);
        axis tight
    end
end
end

function colororder=getcolors()
colororder = [
	0.00  0.00  1.00
	0.00  0.50  0.00
	1.00  0.00  0.00
	0.00  0.75  0.75
	0.75  0.00  0.75
	0.75  0.75  0.00
	0.25  0.25  0.25
	0.75  0.25  0.25
	0.95  0.95  0.00
	0.25  0.25  0.75
	0.75  0.75  0.75
	0.00  1.00  0.00
	0.76  0.57  0.17
	0.54  0.63  0.22
	0.34  0.57  0.92
	1.00  0.10  0.60
	0.88  0.75  0.73
	0.10  0.49  0.47
	0.66  0.34  0.65
	0.99  0.41  0.23
];
end