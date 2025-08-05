function z=zap(data,samples,EmRange,ExRange)

% Set data to missing (replace with NaNs) in selected samples and at
% specified wavelengths.
%
%USEAGE z=zap(data,samples,EmRange,ExRange)
%
%INPUTS
%       data: data structure with eems in data.X
%    samples: indices of samples to be affected.
%    EmRange: range of emission wavelengths [minEx,maxEx]
%       e.g. [450] replaces only data at Em=450 nm
%       e.g. [300 320] replaces data from Em=300-320 nm inclusive
%       e.g. [] replaces entire Em spectrum
%    ExRange: range of excitation wavelengths [minEx,maxEx]
%       e.g. [320] replaces only data at Ex=320 nm
%       e.g. [255 270] replaces data from Ex=255-270 nm inclusive
%       e.g. [] replaces entire Ex spectrum
%OUTPUTS
%     z: data with NaNs in the specified samples and wavelength ranges.
%
%EXAMPLES
%     newdata=zap(data,3,450,350)              %Ex/Em=350/450 for sample 3
%     newdata=zap(data,2:5,[298,306],[270,280])
%     newdata=zap(data,[3 5 8],430,[])
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% zap: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(4,4)
z=data;E=cell(1,2);
for i=1:2
    if i==1; 
        iR='emission';Range=EmRange; wave=data.Em;
    elseif i==2; 
        iR='excitation';Range=ExRange; wave=data.Ex;
    end
    if ~isempty(Range)
        if length(Range)==1
            E{i}=find(wave==Range);
            if isempty(E{i})
                %disp(wave)
                error([num2str(Range) 'nm is not one of the ' iR ' wavelengths.']) 
            end
        elseif length(Range)==2
            E{i}=intersect(find(wave>=Range(1)),find(wave<=Range(2)));
        else
            error('Invalid wavelength range');
        end
    else
        E{i}=1:length(wave);
    end
end
Emi=E{1};
Exi=E{2};

nanmat=data.X(samples,Emi,Exi);
z.X(samples,Emi,Exi)=NaN*ones(size(nanmat));

if isfield(data,'Zap')
    k=size(data.Zap,2)+1;
else
    k=1;
end

%Tracking Info
if and(~isempty(ExRange),~isempty(EmRange))
    z.Zap{k}=['[' num2str(samples) '],[' num2str(EmRange) '],[' num2str(ExRange) ']'];
elseif  and(isempty(EmRange),~isempty(ExRange))
    z.Zap{k}=['[' num2str(samples) '],[],[' num2str(ExRange) ']'];
elseif  and(~isempty(EmRange),isempty(ExRange))
    z.Zap{k}=['[' num2str(samples) '],[' num2str(EmRange) '],[]'];
elseif  and(isempty(EmRange),isempty(ExRange))
    z.Zap{k}=[num2str(samples) ',[],[]'];
end
