function AnalysisData=splitds(data,varargin)

% Sort and split EEMs into customised subsets on the basis of metadata
% categories or sample order, then optionally combine these splits in 
% user-defined ways. For example, split a dataset into quarters
% then pair them in six different ways with each new split
% containing half the dataset in preparation for performing three
% split-half comparisons.
%
%USEAGE: AnalysisData=splitds(data,bysort,numsplit,stype,scomb,protected)
%INPUT:
%   data: The original dataset contained in a dataset structure
%
%   bysort: (optional) metadata for use in sorting and/or splitting
%         Assume there are metadata in: data.cruise, data.site, data.loc,
%         and loc is nested in site which is nested in cruise.
%                 'cruise' : sort by cruise.
%        'cruise.site.loc' : sort by cruise, then site, then loc.
%                        []: no sorting (default).
%
%   numsplit: (optional) integer number of splits.
%          n: create n splits of the original dataset
%         []: by default, 4 splits will be created with the following
%             two exceptions: 
%            (1) if stype is 'none', then no new splits will be made.
%            (2) if stype is 'exact', then numsplit will 
%             equal the number of unique groups in bysort. 
%
%  stype: (optional) style of custom split, either
%            []: default split style ('alternating' as defined below)
% 'alternating': every nth sample is assigned to split number n, where n is
%                defined in numsplit (or takes the default value of n).
%      'random': samples assigned randomly among n splits.
%  'contiguous': samples assigned to splits in n contigous (consecutive)  
%                blocks of similar length e.g. 1:30,31:60,61:90,...
%                extra samples in data.X not exactly divisible by the number  
%                of splits are assigned to the final split.
%       'exact': samples split into the unique groups identified in bysort.
%     'combine': no new splits are made but existing splits may be combined 
%                as specified in scomb.  
%        'none': dataset is sorted only. Note this operation does not
%                sort PARAFAC models that have already been created.
%
%  scomb: (optional) splits to be combined, listed as {comb1,...,combn}.
%          This step is implemented after first sorting and splitting
%          samples according to other specified input criteria. The splits
%          present prior to generating combinations are deleted.
%           e.g. [] - no splits will be combined (default).
%           eg. {[1 2],[1 2 3],[3],[1 3]} produces 4 new splits
%                made from different combinations of splits 1,2 and 3.
%           eg. {[1 2],[3 4]} produces a dataset having 2 splits that
%                combined prior splits 1&2 and splits 3&4, respectively.
%
%protected: (optional) fields to be preserved if combining splits. 
%           The defaults include Ex, Em and data backups. 
%           For example {'Abs_wavelengths','mysettings'} ensures that when
%           combining splits, the contents of these fields are not duplicated.
%
%OUTPUT
%        newdata: new dataset with splits in newdata.Split(1:n)
%
%EXAMPLES
%
%	newdata=splitds(data)  %dataset is split 4 ways (default)
%
%	newdata=splitds(data,'cruise')   %sort by cruise first
%
%	newdata=splitds(data,'cruise',1)   %sort by cruise and put in one split
%
%	newdata=splitds(data,'cruise',1)   %sort by cruise but dont split
%
%	newdata=splitds(data,'cruise.site.rep',3,'contiguous')
%      %sort by cruise/site/rep then split into 3 contiguous groups
%
%	newdata=splitds(data,'cruise',[],'exact',{[1 2],[3 4]})
%      %create individual cruise splits then combine into two new splits
%
%	newdata=splitds(data,[],4,'alternating',{[1 2],[3 4],[1 3],[2 4]})
%      %produces 4 splits each with half the dataset. This is 
%      %equivalent to AnalysisData=SplitData(data) in DOMFluor
%
%	newdata=splitds(data,[],[],'combine',{[1 2],[3 4],[1 3],[2 4],[1 4],[2 3]})
%      %replace the four or more existing splits in data with six new
%      %splits each made from combining two of the existing splits and
%      %containing approximately half of the dataset.
%
%   scomb={[1:4:71 2:4:71],[3:4:71 4:4:71],[1:4:71 3:4:71],[2:4:71 4:4:71],[1:4:71 4:4:71],[2:4:71 3:4:71]}
%	newdata=splitds(data,'cruise.site',71,'exact',scomb)
%      %create 71 exact splits (containing unique combinations of cruise 
%      %and site) then replace them with six new splits each having approx
%      %half the dataset.
%
%   newdata=splitds(data,[],[],'combine',{[1 2],[3 4],[1 3],[2 4],[1 4],[2 3]})
%      %replace the existing splits in data with six combined splits
%
%   newdata=splitds(data,[],[],'combine',{[1 2],[3 4],[1 3],[2 4],[1 4],[2 3]},{'A_wave'})
%      %prevent duplication of the contents of data.A_wave
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% splitds: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

%initialise and set defaults
narginchk(1,6)

numsplit=[];
bysort=[];
scomb=[];
protected=[];
stype='alternating';
styles={char('alternating','random', 'contiguous', 'exact','combine','none')};

if nargin>1
    bysort=varargin{1};
    if nargin>2
        numsplit=varargin{2};
        if nargin>3
            stype=varargin{3};
            if ~isempty(stype)
                if ~ismember(stype,styles)
                    error('split type not recognised')
                elseif strcmp(stype,'exact')
                    if isempty(bysort)
                        error('Exact mode splitting not possible for bysort =[];')
                    end
                end
            else
                stype='alternating';
            end
            if nargin>4
                scomb=varargin{4};
                if nargin>5
                    protected=varargin{5};
                    if ~iscell(protected)
                        error('Protected fields must be contained in a cell structure (inside curly brackets)')
                    end
                end
            end
        end
    end
end

% Track splitting and combining operations
if  strcmp(stype,'combine') %Combine existing splits
    if or(~isempty(bysort),~isempty(numsplit))
        error('No splitting or sorting is performed when variable stype is ''combine''.')
    end
    if isfield(data,'Split_Style')
        sinfo=data.Split_Style;
    else
        sinfo='';
    end
    if strfind(sinfo,'combine')
        error('More than one combining operation on the same dataset is not allowed')
    else
        if isempty(sinfo)
            data.Split_Style='unknown';
        else
            data.Split_Style=sinfo;
        end
        if isfield(data,'Split_nSample')
            data=rmfield(data,'Split_nSample');
        end
    end
else %Fresh splitting operation
    data.Split_Style=stype;
    if ~isempty(bysort);
        data.Split_BySort=bysort;
    end
    rmfieldlist=char('Split','Split_NumBeforeCombine','Split_NumAfterCombine','Split_Combinations','Split_nSample','Split_BySort');
    for k=1:size(rmfieldlist,1)
        rm=deblank(rmfieldlist(k,:));
        if isfield(data,rm)
            data=rmfield(data,rm);
        end
    end
end

AnalysisData=data;

if ~isempty(bysort)
    dots=strfind(bysort,'.');
    if isempty(dots)
        try
        t=data.(bysort);
        catch ME
            error('splitds:fieldname1','Not a valid field name for bysort')
        end
        if isnumeric(t)
            t=num2str(t);
        end
        tabl=cellstr(t);
    elseif ~isempty(dots)
        tabl=cell(size(data.X,1),length(dots));
        dots=[0 dots length(bysort)+1];
        for i=1:length(dots)-1
            b=(['' bysort(dots(i)+1:dots(i+1)-1) '']);
            try
                t=data.(b);
            catch ME
                error('splitds:fieldnameN','Not a valid field name for bysort')
            end
            if ~isnumeric(t)
                tc=char(t);%pause
                nodata=t(strcmp('',t),:);
                zees=repmat('*',[1 size(tc,2)]);
                repmat(zees,[size(nodata,1),1]);
                t(strcmp('',t),:)=cellstr(repmat(zees,[size(nodata,1),1]));%pause
                tabl(:,i)=t;
            end
        end
    end

    col=1:size(tabl,2);
    [C, iS]=sortrows(tabl,col); %sorted metadata
    newdata = sub_struct(data,iS); %sorted dataset

    %Concatenate text of different lengths (replace cell2mat)
    %aa=cellfun(@length, C)
    %sum(max(aa)) %maximum text length for nested operations
    Cstar='';
    for i=1:size(C,1)
        g=char(C(i,1)); 
        for j=2:size(C,2)
        g=[g char(C(i,j))]; %#ok<AGROW>
        end
        Cstar(i,1:size(g,2))=g;
    end
    %Cstar,pause  
    groups=cellstr(unique(Cstar,'rows')); %%%%%%%%%%%%
    NoGroups=size(groups,1);
    
    %Create exact splits
    if strcmp(stype,'exact')
        if isempty(numsplit)
            numsplit=NoGroups;
        elseif isequal(numsplit,NoGroups);
        else
            error('The number of splits specified in exact mode incompatible with no of groups')
        end
        for i=1:numsplit
            class_dat=strcmp(char(groups{i}),cellstr(Cstar));
            %class_dat=strcmp(char(groups{i}),cellstr(cell2mat(C))) %does not work if metadata varies in length
            indices=find(class_dat==1);
            AnalysisData.Split(i)= sub_struct(newdata,indices);
            AnalysisData.Split(i).nSample= length(indices);
        end
    end
else
    newdata=data;
end

if strcmp(stype,'none')
    if ~isempty(numsplit)
        error('Use numsplit=[] with stype = none for sorting without splitting')
    else
        AnalysisData=newdata;
    end
else
    if ~strcmp(stype,'combine')
        if isempty(numsplit)
            numsplit=4;
        end
        if ~strcmp(stype,'exact')
            %Create non-exact splits
            indices=(1:newdata.nSample)';
            indicesP = indices(randperm(size(indices,1)));
            NperG=floor(length(indices)/numsplit);
            for i=1:numsplit
                if strcmp(stype,'alternating')
                    class_dat=indices(i:numsplit:end);
                else %contiguous, random
                    istart=1+(i-1)*NperG;
                    if i==numsplit;
                        istop=length(indices);
                    else
                        istop=(i)*NperG;
                    end
                    if strcmp(stype,'contiguous')
                        class_dat=indices(istart:istop);
                    elseif strcmp(stype,'random')
                        class_dat=indicesP(istart:istop);
                    end
                end
                AnalysisData.Split(i)= sub_struct(newdata,class_dat);
                AnalysisData.Split(i).nSample= size(class_dat,1);
            end
            
        end
        AnalysisData.Split_NumBeforeCombine=numsplit;
    end
    
    if and(~isempty(scomb),~strcmp(stype,'none'))
        AnalysisData=CombineSplits(AnalysisData,scomb,protected);
        Split_Style=AnalysisData.Split_Style;
        AnalysisData=rmfield(AnalysisData,'Split_Style');
        AnalysisData.Split_Style=[Split_Style ' then combine'];
        splits2combine=unique(cell2mat(scomb));
        if isempty(numsplit) %combine only
            numsplit=AnalysisData.Split_NumBeforeCombine;
        end
        splitsleftout=setxor(splits2combine,1:numsplit);
        if ~isempty(splitsleftout)
            warning('splitds:Combinations2',['Splits ' num2str(splitsleftout) ' were not used in combine operation...']);
            warning('splitds:Combinations2','Some samples are not included in any splits!')
            warning('press any key to continue, or ^C to cancel');
            pause;
        end
        AnalysisData.Split_NumAfterCombine=length(scomb);
        [p{1:length(scomb)}] = deal(AnalysisData.Split.nSample);
        AnalysisData.Split_Combinations=cellfun(@num2str,scomb,'UniformOutput',false);
    else
        if strcmp(stype,'combine')
            error('Need to specify which split combinations will be created in variable ''stype''.')
        elseif strcmp(stype,'none')
        else
            [p{1:numsplit}] = deal(AnalysisData.Split.nSample);
        end
    end

    AnalysisData.Split_nSample=cell2mat(p);
end

end

function newdata = sub_struct(data,sub_by)
%Obtain subdataset from a dataset structure
%Copyright: 2013 Kathleen R. Murphy

F=fieldnames(data);
for i=1:size(F,1)
    fldnm=char(F(i));
    if ~strcmp(fldnm,'Split_Style')
        f_i = data.(fldnm);
        dimf=size(f_i);
        if size(f_i,1)==size(data.X,1)
            if length(dimf)==1
                f_i = f_i(sub_by);
            elseif length(dimf)==2
                f_i = f_i(sub_by,:);
            elseif length(dimf)==3
                f_i = f_i(sub_by,:,:);
            elseif length(dimf)>=4
                error('Sub_struct functionality limited to data with 3 or fewer dimensions')
            end
        end
        n_i.(fldnm)=f_i;
    end
end
newdata=n_i;
end


function newdata=CombineSplits(data,splitnums,pplus)
%Combine model splits
%
%USEAGE
%      newdata=CombineSplits(data,splitnums,pplus)
%INPUT
%      data: A data structure containing splits in data.Split
% splitnums: splits to be combined, listed as {comb1,...,combn}.
%          This step is implemented after first sorting and splitting
%          samples according to other specified input criteria. The splits
%          present prior to generating combinations are deleted.
%           e.g. [] - no splits will be combined (default).
%           eg. {[1 2],[1 2 3],[3],[1 3]} produces 4 new splits
%                made from different combinations of splits 1,2 and 3.
%           eg. {[1 2],[3 4]} produces a dataset having 2 splits that
%                combined prior splits 1&2 and splits 3&4, respectively.
%     pplus: additional fields to be protected, in a cell structure
%           e.g. {'wavelength','moreinfo'}
%
% Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au

MaxComp=20; %Max No. Components in a PARAFAC model;
newdata=data;

%t=regexp(splitnums,'(\d+)','match'),t{1},pause
protected=cellstr(char('Ex','Em','nEx','nEm','backupX','backupEx','backupEm','backupXf','IntensityUnit','Smooth'));
if ~isempty(pplus)
    nprot=size(protected,1);
    for i=1:length(pplus)
        protected(nprot+i,1)=cellstr(pplus{i});
    end
end

numnewsplits=size(splitnums,2);

for i=1:numnewsplits
    %t2=str2num(char(t{i}))',pause %#ok<ST2NM>
    t2=splitnums{i};
    try
        temp=data.Split(t2);
    catch ME
        error('Attempted to access (in order to combine) a non-existent split')
    end
    names=fieldnames(temp);
    cellData=cellfun(@(f) {vertcat(temp.(f))},names); %Collect field data into a cell array
    newdata.Split(i)= cell2struct(cellData,names);  %Convert the cell array into a structure
    
    for j=1:size(protected,1)
        if isfield(temp(1),(char(protected(j,:))))
            newdata.Split(i).(char(protected(j,:)))=temp(1).(char(protected(j,:)));
        end
    end
    newdata.Split(i).nSample=sum(newdata.Split(i).nSample);
end

splitstruc=newdata.Split;
for j=1:MaxComp;
    m=['Model' num2str(j)]; e=[m '_err'];it=[m '_it'];
    if isfield(splitstruc,m)
        splitstruc=rmfield(splitstruc,m); end
    if isfield(splitstruc,e)
        splitstruc=rmfield(splitstruc,e); end
    if isfield(splitstruc,it)
        splitstruc=rmfield(splitstruc,it); end
end

newdata.Split=newdata.Split(1:numnewsplits);
end
