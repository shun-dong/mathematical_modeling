function trimdata=subdataset(Data,OutSample,OutEm,OutEx,varargin)

%     Subset a dataset by removing samples and/or wavelengths and/or
%     convert a PLS toolbox object to a MATLAB data structure.
%     The subdataset function performs either or both of 2 functions:
%     1. Convert a PLS toolbox object to a MATLAB data structure
%     2. Additionally, or instead, remove specified samples
%        and/or wavelengths to create a smaller dataset 
%     3. If removing samples or wavelengths, create backups of the 
%        original data if requested
%     
%     The output 'trimdata' is a data structure that can be processed
%     further using the DOMFluor or DOMFluor2 toolbox
%
%USEAGE: 
%    trimdata=subdataset(data,OutSample,OutEm,OutEx,backups)
%
%INPUTS:
% data:  Input dataset, either:
%       1. A data structure containing at minimum 
%          the fields Data.X, Data.Ex, and Data.Em, or:
%       2. or PLS_toolbox dataset object containing the EEMs
%          and Ex and Em in the axisscale.
%
% OutSample: Samples to be removed. 
%        option 1: list of numbers, e.g. [1 5 9] to remove the 
%                1st, 5th & 9th samples from the data set.
%        option 2: text in curly brackets, e.g. {'site','6B','7B'} 
%                if Data.site contains sites 6B and 7B, all data 
%                corresponding to these sites will be removed.
%
% OutEm: emission wavelengths to be removed. 
%       e.g. [1 2 3]  removes the first 3 emission wavelengths.
%       e.g. Data.Em>550  removes Em wavelengths above 550nm.
%
% OutEx: excitation wavelengths to be removed
%       e.g. [1:5]  removes the first 5 excitation wavelengths.
%       e.g. Data.Ex<250  removes Ex wavelengths below 250nm.
%
% backups: (Optional) names of fields that you want to back up.
%       e.g {'date','sites',..} - note field names are case sensitive.
%        if [] or not specified, 'X','Ex','Em', and 'Xf' will be backed up
%             in Data.backupX,Data.backupEx,Data.backupEm and Data.backupXf.
%        if {'none'}, no fields will be backed up.
%        note, it is strongly recommended to backup default fields 
%
% OUTPUT: 
%       trimdata - a MATLAB data structure with specified samples
%                   and/or wavelengths removed.
%
%Examples:
%  trimdata=subdataset(Data,[8 39],data.Em>550,data.Ex<250)
%   (The trimmed data contains backups of the original X, and Xf when
%   present. If backups of these already exist, they are preserved without
%   alteration.)
%
%  trimdata=subdataset(Data,[],[],data.Ex<250,{'Class_site'})
%   (If Data is a PLS dataset object, the trimmed data contains backups of 
%    the class variable named 'site')
%   (If Data is a MATLAB data structure, the trimmed data contains backups of 
%    the field named 'Class_site')
%
%  trimdata=subdataset(Xs,{'site','','0A'},Xs.Em>540,[]);
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% subdataset: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release



%Perform checks on Input data
narginchk(4,5)

compulsary=char('Ex','Em','X');
if nargin==5;
    if ~iscell(varargin{1})
        error('List backup fields in curly brackets, or {''none''} for no backups...!')
    end
    fields4bkup=char(varargin{1}');
end

%Convert dataset objects to structures, do further checks.
if ~isstruct(Data);
    try
        try
            Em=Data.axisscale{2};
            Ex=Data.axisscale{3};
            if isempty(Em)||isempty(Ex)
                error('MATLAB:PLS_dataset',...
                    'could not retrieve Ex or Em wavelengths from dataset object');
            end
            trimdata.X=Data.data;
            trimdata.Em=Em'; trimdata.Ex=Ex';
            dim=size(Data.data);
            if isempty(Data.class)||isempty(Data.label)
                error('MATLAB:DataObjStruc',...
                    'Input data not a dataset structure or a PLS dataset object');
            end
        catch ME
            disp(ME)
        end
        try
            classnames=reshape(Data.classname,[numel(Data.classname) 1]);
            classdata=reshape(Data.class,[numel(Data.class) 1]);
            for i=1:numel(Data.class);
                %i,classnames{i},classdata{i}
                if ~isempty(classdata{i})
                    if ~isempty(classnames{i})
                        F=['Class_' classnames{i}];
                    else
                        F=['Class_' num2str(i)];
                    end
                    cdat=classdata{i};
                    dimc=size(cdat);
                    if ~isequal(dimc(1),dim(1));
                        cdat=cdat';
                    end
                    if ischar(cdat)
                        cdat=cellstr(cdat);
                    else
                        cdat=cellstr(num2str(cdat));
                    end
                    trimdata.(F)=cdat;
                end
            end
        catch ME
            disp(ME)
            error('PLS:ClassesAndLabels',...
                'Failed to Dataset Object: Classes')
        end
        try
            labelnames=reshape(Data.labelname,[numel(Data.labelname) 1]);
            labeldata=reshape(Data.label,[numel(Data.label) 1]);
            for i=1:numel(Data.label);
                %i,labelnames{i},labeldata{i}
                if ~isempty(labeldata{i})
                    if ~isempty(labelnames{i})
                        F=['Label_' labelnames{i}];
                    else
                        F=['Label_' num2str(i)];
                    end
                    cdat=labeldata{i};
                    diml=size(cdat);
                    if ~isequal(diml(1),dim(1));
                        cdat=cdat';
                    end
                    if ischar(cdat)
                        cdat=cellstr(cdat);
                    else
                        cdat=cellstr(num2str(cdat));
                    end
                    trimdata.(F)=cdat;
                end
            end
        catch ME
            disp(ME)
            error('PLS:ClassesAndLabels',...
                'Failed to Dataset Object: Labels')
        end
        trimdata.IntensityUnit='';
    catch ME
        disp(ME)
        error('MATLAB:DataStructure',...
            'Input must be a data structure containing data.X, data.Em, data.Ex,...')
    end
    FNs=fieldnames(trimdata);
else
    FNs=fieldnames(Data);
    if ismember(compulsary,FNs)
        trimdata=Data;
    else
        error('Compulsary fields Ex, Em, and/or X are missing from input data structure')
    end
    dim=size(Data.X);
end

%Create sample index
if ~isfield(Data,'i')
    trimdata.i=(1:dim(1))';
end

%Backup specified fields
if nargin<5
    fields4bkup=intersect(char('X','Xf','Ex','Em'),FNs); %default
end
backupfields=char([repmat('backup',[size(fields4bkup,1),1]) char(fields4bkup)]);
[~,~,IB]=setxor(char('X','Em','Ex','Xf','nEx','nEm','nSample'),FNs);
if ~strcmp(fields4bkup,'none')
    for i=1:size(backupfields,1)
        %i,fields4bkup(i,:),deblank(backupfields(i,:))
        if ismember(backupfields(i,:),FNs),
            trimdata.(deblank(backupfields(i,:)))=Data.(deblank(backupfields(i,:)));
        else
            if ismember(fields4bkup(i,:),FNs)
                if isstruct(Data)
                    trimdata.(deblank(backupfields(i,:)))=Data.(deblank(char(fields4bkup(i,:))));
                else
                    trimdata.(deblank(backupfields(i,:)))=trimdata.(deblank(char(fields4bkup(i,:))));
                end
            end
        end
    end
end

%Sample removal on the basis of metadata
if iscell(OutSample)
    Sremove=[];
    OS1=OutSample{1};
    if isfield(Data,OS1)
        OS1a=Data.(OS1);
        for i=2:size(OutSample,2)
            Sremove=[Sremove; find(strcmp(OS1a,OutSample{i}))]; %#ok<AGROW>
        end
    else
        error([OS1 ' is not a known field name within the dataset'])
    end
    OutSample=Sremove;
end

%Remove specified samples and/or wavelengths
trimdata.i(OutSample)=[];     %indices
trimdata.X(OutSample,:,:)=''; %samples
trimdata.X(:,OutEm,:)='';     %Em
trimdata.X(:,:,OutEx)='';     %Ex
trimdata.Ex(OutEx,:)='';      %Ex
trimdata.Em(OutEm,:)='';      %Em
if ismember('Xf',FNs),
    if length(size(Data.Xf))==3;
        trimdata.Xf(OutSample,:,:)=''; %samples
        trimdata.Xf(:,OutEm,:)='';     %Em
        trimdata.Xf(:,:,OutEx)='';     %Ex
    end
end
if ismember('Xnotscaled',FNs),
    if length(size(Data.Xnotscaled))==3;
        trimdata.Xnotscaled(OutSample,:,:)=''; %samples
        trimdata.Xnotscaled(:,OutEm,:)='';     %Em
        trimdata.Xnotscaled(:,:,OutEx)='';     %Ex
    end
end

%Remove samples from metadata
if ~isempty(IB)
    metadata=FNs(IB);
    for i=1:size(metadata,1)
        m=metadata(i);
        mdata=trimdata.(char(m));
        if and(size(mdata,1)==dim(1),length(size(mdata))<3)
            trimdata.(char(m))(OutSample,:)='';
        end
    end
end

%Update dimension fields
dimTrim=size(trimdata.X);
trimdata.nSample=dimTrim(1);
trimdata.nEm=dimTrim(2);
trimdata.nEx=dimTrim(3);