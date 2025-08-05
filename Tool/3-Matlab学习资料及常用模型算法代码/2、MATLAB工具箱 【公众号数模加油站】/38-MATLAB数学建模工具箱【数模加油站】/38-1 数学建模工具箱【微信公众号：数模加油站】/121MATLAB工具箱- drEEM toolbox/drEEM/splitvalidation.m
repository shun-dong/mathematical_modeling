function data=splitvalidation(data,fac,varargin)

%Compare the excitation and emission spectra from PARAFAC models of 
%various splits of a dataset. If splits contain independent datasets and
%components are congruent among the various splits, the model is validated.
%Congruency is calculated according to the Tucker Coefficient described in
%Lorenzo-Seva, U., Berge, J.M.F.T., 2006. Methodology, 2 (2), 57–64.
%
% USEAGE: newdata=splitvalidation(data,f,comparisons,splitnames,overallmodel)
%
% INPUT:
%         data: a data structure with two or more models in data.Split
%
%          fac: the number of components in the model to be examined.
%
%  comparisons: (optional)
%              identify which splits to compare. The default is to
%              test all possible combinations of splits, however,
%              depending on how samples were assigned among splits, 
%              some such comparisons may be invalid (i.e. comparisons  
%              between splits having overlapping samples in them). 
%              Separate the comparison pairs with a colon:
%              e.g. [1 2; 3 4] which produces two independent comparisons
%              of split 1 vs 2 and split 3 vs 4.
%
%   splitnames: (optional)
%              assign splits different names (one name per split)
%              []: splits will be named using the contents of
%              data.Split_Combinations if present, or 1:n if not (default)
%
% overallmodel: (optional) 
%              If the overall model corresponding to the split model being
%              validated is specified, then in the case that the model 
%              validates, plots will be produced of (a) all the splits 
%              against the overall model spectra, and (b) contour plots of 
%              the validated model.
%
% OUTPUT: A new data structure with the same content as data, plus the
%          additional fields listed below:
%            R: a cell structure with the matched components tabulated
%               in R{1} (1st comparison),  R{2} (2nd comparison), etc.
%      summary: text summary of validation results
%         ExCC: Tucker congruency coefficients for Ex spectra for the nth
%               comparison is in ExCC{n}
%         EmCC: Tucker congruency coefficients for Em spectra for the nth
%               comparison is in EmCC{n}
%    note that if all splits validate and an overall model is specified
%         then R, ExCC and EmCC will  have an extra row representing the
%         comparison of each split individually against the overall model. 
%             
% EXAMPLES:
%   splitvalidation(data,4)
%   val=splitvalidation(splitmodels,4,[1 2;3 4],[],overallmodel); %S4C4T2 validation
%   val=splitvalidation(splitmodels,5,[1 2;3 4;5 6],{'AB','CD','AC','BD','AD','BC'},LSmodel5); %S4C6T3 validation
%   val=splitvalidation(splitmodels,6,[],{'Cruise1','Cruise2','Cruise3','Cruise4'},LSmodel6) %S4T6 validation
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% splitvalidation: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(2,5)
customsplitnames=false;
overallmodel=[];
sn=[];
p=0.95; % p criterion for spectral match

if ~isfield(data,'Split')
    error('Input data does not have a field called ''Split''')
else
    nS=size(data.('Split'),2);
    if nargin==2
        comparisons=nchoosek(1:nS,2);
    elseif nargin>2
        c=varargin{1};
        if isempty(c)
            comparisons=nchoosek(1:nS,2);
        else
            if isnumeric(c)
                comparisons=c;
            else
                error('unrecognised input for comparisons')
            end
            if ~size(comparisons,2)==2
               error('Comparisons must be a n x 2 matrix, with n = number of comparisons')
            end
            if max(c)>size(data.Split,2)
              fprintf(['\nNumber of splits found in dataset is: ' int2str(size(data.Split,2)) '\n'])              
               error('splitvalidation:comparisons','Splits to be included in comparisons do not all exist')
            end
        end
    end
    nC=size(comparisons,1);
    splitnames=cell(nC,2);
    if nargin>3
        sn=varargin{2};
        %sn;size(sn)
        if ~isempty(sn)
            if ~isequal(size(sn,2),nS)
                fprintf(['\nNumber of splits found in dataset is: ' int2str(nS) '\n'])
                fprintf(['Number of splits named is: ' int2str(size(sn,2)) '\n'])
                if size(sn,2)<nS
                    fprintf('A name is required for all splits, whether or not it is included in validation tests\n')
                end
                error('splitvalidation:splitdim','Mismatch between splits and split names')
            else
                customsplitnames=true;
            end
        end
    end
    if isempty(sn)
        if isfield(data,'Split_Combinations')
            sn=data.Split_Combinations;
        else
            sn=cellstr(int2str((1:nS)'));
        end
    end
    if nargin>4
        overallmodel=varargin{3};
    end
end

Ffield=['Model' int2str(fac)];
R=cell(nC,1);itit=R;ExCC=R;EmCC=R;valcomp=R;
v=NaN*ones(nC,1);
Ac=R;Bc=R;Cc=R;
Av=R;Bv=R;Cv=R;
for i=1:nC
    Cal = getfield(data,{1,1},'Split',{comparisons(i,1)},Ffield);
    Val = getfield(data,{1,1},'Split',{comparisons(i,2)},Ffield);
    [A1,B1,C1]=fac2let(Cal);
    [A2,B2,C2]=fac2let(Val);
    Ac{i}=A1;Bc{i}=B1;Cc{i}=C1;
    Av{i}=A2;Bv{i}=B2;Cv{i}=C2;
    [M,CC2,CC3]=TCC3(Cal,Val,p);
    ExCC{i}=CC2; EmCC{i}=CC3;
    v(i)=sum(sum(M))==fac;
    R{i}={M};
    if customsplitnames
        splitnames{i,1}=sn{comparisons(i,1)};
        splitnames{i,2}=sn{comparisons(i,2)};
        itit{i}=['Model ' int2str(fac) ':' splitnames{i,1} ' vs ' splitnames{i,2}];
        valcomp{i}=[splitnames{i,1} ' vs ' splitnames{i,2}];
    else
        if isfield(data,'Split_Combinations')
            splitnames{i,1}=sn{comparisons(i,1)};
            splitnames{i,2}=sn{comparisons(i,2)};
            itit{i}=['Model ' int2str(fac) ':' splitnames{i,1} ' vs ' splitnames{i,2}];
            valcomp{i}=[splitnames{i,1} ' vs ' splitnames{i,2}];
        else
            itit{i}=['Model ' int2str(fac) ': Split ' int2str(comparisons(i,1)) ' vs Split ' int2str(comparisons(i,2))];
            valcomp{i}=['Split ' int2str(comparisons(i,1)) ' vs Split ' int2str(comparisons(i,2))];
        end
    end
end
summary=cell(nC,1);
if nC==sum(v)
    fprintf('Overall Result= Validated for all comparisons\n')
    summary='Overall Result= Validated for all comparisons';
    doplots=true;
else
    doplots=false;
    fprintf('\nOverall Result = Not Validated\n')
    fprintf('\nIn the following tables, rows and columns are interpreted as follows:\n')
    fprintf('      Rows: depict the 1st model in each comparison\n')
    fprintf('   Columns: depict the 2nd model in each comparison\n\n')
    fprintf('   Press any key to continue\n\n')
    pause
    for i=1:nC
        fprintf(itit{i})
        if v(i)
            summary{i}='-Validated';
            fprintf([summary{i} '\n'])
        else
            summary{i}=('-Not Validated');
            fprintf([summary{i} '\n'])
            disp(cell2mat(R{i}))
        end
    end
    summary=[char(itit) char(summary)];
end

%Plots of individual comparisons
legs=cellstr([[repmat(char('1st '),[fac 1]); repmat(char('2nd '),[fac 1])] [repmat(char('comp '),[2*fac 1])  [num2str((1:fac)'); num2str((1:fac)')]]]);
figure
set(gcf,'name',['Model ' int2str(fac) ' Cal vs Val for multiple comparisons - emission'])
for i=1:nC
    subplot(ceil(nC/2),2,i)
    plot(data.Em,Bc{i},'-','linewidth',2)
    hold on
    plot(data.Em,Bv{i},':','linewidth',2)
    axis tight
    title(itit{i})
end
legend(legs)
figure
set(gcf,'name',['Model ' int2str(fac) ' Cal vs Val for multiple comparisons - excitation'])
for i=1:nC
    subplot(ceil(nC/2),2,i)
    plot(data.Ex,Cc{i},'-','linewidth',2)
    hold on
    plot(data.Ex,Cv{i},':','linewidth',2)
    axis tight
    title(itit{i})
end
legend(legs)
compsort=sort(unique(comparisons(:)));
nCu=length(compsort); %nC or no. unique comparisons in case of overall model

%Plots of overall comparisons in the case of a validated model
while doplots==true;
    rc=      [1 1;1 2;1 3;2 2;  2 3;  2 3;  2 4;  2 4;  3 3;   2 5;     3 4;       3 4;     4 4;      4 4];
    ylabpos={{1},{1},{1},{1,3},{1,4},{1,4},{1,5},{1,5},{1,4,7},{1,4,7},{1,4,7,11},{1,4,7,11},{1,5,9,12},{1,5,9,12}};
    xlabpos={{1},{2},{2},{3:4},{3:6},{4:6},{5:8},{5:8},{7:9},  {7:10}, {9:12},    {9:12},     {12:16}, {12:16}};
    
    %Check for an overall model with fac components
    try
        Cal = overallmodel.(Ffield);
        data.(Ffield) = Cal;
    catch ME %#ok<NASGU>
        warning('splitvalidation:Plots',['Missing overall (full dataset) model for calculating final validation statistics. '...
            'No plots of Split Models vs. Overall Model will be shown. To complete the validation, specify the overall model ' ...
            'as the final input variable to splitvalidation (see randinitanal.m).']);
        break
    end
    [~,B,C]=fac2let(Cal);
    
    figure
    set(gcf,'Name',['Overlaid spectra - ' num2str(fac) ' comp. model validated with ' num2str(nC) ' split comparisons; showing ' num2str(nCu) ' unique splits vs overall model']);
    splitleg=[[repmat('Split',[nCu,1]) num2str(compsort) repmat('-em',[nCu,1])];[repmat('Split',[nCu,1]) num2str(compsort)] repmat('-ex',[nCu,1])];
    sg=char('overall-em', splitleg(1:nCu,:), 'overall-ex', splitleg(nCu+1:2*nCu,:));

    %Each split versus overall model, nCu comparisons
    BvG=cell(1,nCu);
    CvG=cell(1,nCu);
    RG=cell(1,nCu);CC2g=RG;CC3g=RG;
    err1=false;
    for j=1:nCu
        Val = getfield(data,{1,1},'Split',{compsort(j)},Ffield);
        [~,B2,C2]=fac2let(Val);
        BvG{j}=B2;CvG{j}=C2;
        [RG{j},CC2g{j},CC3g{j}]=TCC3(Cal,Val,p);
        %sum(sum(RG{j},2)),
        %sum(sum(RG{j},1))
        if ~and(sum(sum(RG{j},1))==fac,sum(sum(RG{j},2))==fac)
            warnmsg1='Overall vs Split model inconsistencies';
            warnmsg2=['Overall model does not uniquely match the split ' num2str(compsort(j)) ' model with p<'  num2str(1-p) '!'];
            disp(warnmsg2);
            disp('Match matrix')
            disp(RG{j})
            err1=true;
        end
    end
    if err1
        disp(warnmsg1);
        error('splitvalidation:InconsistentOverallModel','The split models do not match the overall model with Tucker Correlation > 0.95')
    end
    
    R{nC+1}=RG;
    EmCC{nC+1}=CC2g;
    ExCC{nC+1}=CC3g;
    
    B2i=NaN*ones(size(B2));
    C2i=NaN*ones(size(C2));
    for i=1:fac
        for j=1:nCu
            B2i(:,j)=BvG{j}(:,RG{j}(:,i)==1);
            C2i(:,j)=CvG{j}(:,RG{j}(:,i)==1);
        end
        subplot(rc(fac,1),rc(fac,2),i)
        plot(data.Em,B(:,i),'-',data.Em,B2i,'-'); axis tight, hold on
        plot(data.Ex,C(:,i),':',data.Ex,C2i,':'); axis tight, hold on
        v=axis;
        handle=title(['Comp ' int2str(i)]);
        set(handle,'Position',[v(1)+0.5*(v(2)-v(1)) v(3)+0.85*(v(4)-v(3)) 1],'FontWeight','bold'); %top inside middle

        if ismember(i,cell2mat(ylabpos{fac}))
            ylabel('loading')
        end
        if ismember(i,cell2mat(xlabpos{fac}))
            if    prod(rc(fac,:))<7
                xlabel('wavelength (nm)');
            else
                xlabel('nm');
            end
        end
    legend(sg);
    legend off 
    end
    legend(sg); %final plot only
    
    figure
    set(gcf,'Name',['Contour plot for validated overall ' num2str(fac) '-comp. model']);
    for i=1:fac
        subplot(rc(fac,1),rc(fac,2),i)
        Comp=reshape((krb(C(:,i),B(:,i))'),[1 data.nEm data.nEx]);
        contourf(data.Ex,data.Em,(squeeze(Comp(1,:,:))));
        v=axis;
        handle=title(['Comp ' int2str(i)]);
        set(handle,'Position',[0.9*v(2) 1.05*v(3) 1],'FontWeight','bold','color',[1 1 1]);
        if ismember(i,cell2mat(ylabpos{fac}))
            ylabel('Em. (nm)')
        end
        if ismember(i,cell2mat(xlabpos{fac}))
            xlabel('Ex. (nm)')
        end
    end
    doplots=false;
    if nargout>0
        fprintf('\n\n')
        disp('The final rows of ExCC, EmCC and R (i.e. R{end}, ExCC{end}, EmCC{end}')
        disp('compare each split included in the validation against the overall model. ')
        disp('Note that the order of results (left to right) for this comparison  ')
        disp('corresponds to the split order shown in Val_Splits:')
        disp((compsort)')
    end
    data.Val_ModelName=['Model' int2str(fac)];
    if isfield(overallmodel,[Ffield 'preprocess'])
        data.Val_Preprocess = overallmodel.([Ffield 'preprocess']);
    end
    try
        data.Val_Source = overallmodel.([Ffield 'source']);
        data.Val_Err = overallmodel.([Ffield 'err']);
        data.Val_It = overallmodel.([Ffield 'it']);
        data.Val_Core= overallmodel.([Ffield 'core']);
        data.Val_ConvgCrit= overallmodel.([Ffield 'convgcrit']);
        data.Val_Constraints= overallmodel.([Ffield 'constraints']);
        data.Val_Initialise= overallmodel.([Ffield 'initialise']);
        data.Val_PercentExpl= overallmodel.([Ffield 'percentexpl']);
        data.Val_CompSize= overallmodel.([Ffield 'compsize']); 
    catch ME
        disp(ME)
        warning('Could not confirm random initialisation test information for overall model (it, err, source). Model may not represent the least squares solution')
    end
end
data.Val_Result=summary;

try
    data.Val_Comparisons=(cellstr([cell2mat(valcomp) repmat(', ',[nC 1])])');
catch %#ok<CTCH>
    data.Val_Comparisons=(cellstr([cell2matpad(valcomp) repmat(', ',[nC 1])])');
end

data.Val_Comparisons_Num=comparisons;
data.Val_Matches=cellfun(@componentmatches,R,'UniformOutput',false);
data.Val_ExCC=ExCC;
data.Val_EmCC=EmCC;
if ~isempty(overallmodel)
    data.Val_Splits=sn(compsort);
    data.Val_SplitsNum=compsort';
end
end


function [Match,B_TCC,C_TCC]=TCC3(factor1,factor2,p)

%The function derives Tucker Congruence Coeficients as described in:
%Lorenzo-Seva, U., Berge, J.M.F.T., 2006. Methodology, 2 (2), 57–64.
%
% INPUT: TCC(factor1,factor2)
% factor1: the first parafac model to compare
% factor2: the second parafac model to compare
%       p: p-value for match
%Copyright 2008 Colin A Stedmon
%Modified 2013 KR Murphy

Fac= size(factor1{2},2);

%Compare Em loadings
Loadi=factor1{2};
Loadj=factor2{2};


ii=sum(Loadi.^2);
jj=sum(Loadj.^2);
ij=zeros(Fac,Fac);
B_TCC=NaN*ones(Fac,Fac);
C_TCC=NaN*ones(Fac,Fac);
for i=1:Fac,
    for j=1:Fac,
        ij(i,j)=sum((Loadi(:,(i))).*(Loadj(:,(j)))); 
        B_TCC(i,j)=(ij(i,j))./(((ii(1,(i))).*(jj(1,(j))))^0.5);
    end
end
%Compare Ex loadings
Loadi=factor1{3};
Loadj=factor2{3};

ii=sum(Loadi.^2);
jj=sum(Loadj.^2);

ij=zeros(Fac,Fac);
for i=1:Fac,
    for j=1:Fac,
        ij(i,j)=sum((Loadi(:,(i))).*(Loadj(:,(j)))); 
        C_TCC(i,j)=(ij(i,j))./(((ii(1,(i))).*(jj(1,(j))))^0.5);
    end
end

Match=zeros(Fac,Fac);
for i=1:Fac,
    for j=1:Fac,
        if B_TCC(i,j)>p && C_TCC(i,j)>p,
            Match(i,j)=1;
        end
    end
end
end

function M2comp=componentmatches(x)
% 2013 KR Murphy

M2comp=cellfun(@findmatch,x,'UniformOutput',false);
M2comp=cell2mat(M2comp)';

    function m=findmatch(y)
        m=NaN*ones(size(y,1),1);
        for i=1:size(y,2)
            [match,~]=find(y(:,i)==1);
            if ~isempty(match)
                if length(match)>1
                    warning('More than one close match found for the same component. Multiple matches reported as a single integer e.g. 34 indicates a match with both 3 and 4')
                    digs=0;
                    for k=1:length(match)
                    digs=digs+match(k)*10^(k-1);
                    end
                    m(i)=digs;
                else
                    m(i)=match;
                end
            end
        end
    end
end

function Cstar=cell2matpad(C)
Cstar='';
for i=1:size(C,1)
    g=char(C(i,1));
    for j=2:size(C,2)
        g=[g char(C(i,j))]; %#ok<AGROW>
    end
    Cstar(i,1:size(g,2))=g;
end
end
