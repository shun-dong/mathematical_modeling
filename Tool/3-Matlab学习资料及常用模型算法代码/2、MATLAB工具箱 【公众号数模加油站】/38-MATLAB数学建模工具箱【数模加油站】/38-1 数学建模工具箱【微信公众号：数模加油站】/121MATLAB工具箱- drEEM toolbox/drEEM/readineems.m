function [X,Emmat,Exmat,filelist,outdata]=readineems(type,format,range,headers,display,outdat)
% Read in files of specified format (xls,xlsx,dat,txt or csv) in the current directory
% and convert to a 3D matrix of EEMs. Remove non-EEM files of specified format
% from the current directory before running.
% The files will be loaded in alphabetical order (see outputed file list).
% Input EEMs must be of the same size, type and format with same Ex and Em.
%
% USEAGE:
%    [X,Emmat,Exmat,filelist,outdata]=readineems(type,format,range,headers,display,outdat)
%
% INPUTS:
%	   type: 1 or 2, defined as below
%            1:  Ex in columns and Em in rows (usual output from Fluoromax, Hitachi etc.)
%            2:  Ex in columns and Em in rows, with Em headers displayed in every second column (Varian)
%
%	 format: 'csv', 'xls', 'xlsx','dat', 'txt'
%             * by default, 'xls' and 'xlsx' data will be imported from the 
%               first sheet in each excel workbook
%             * csv data exported from a Varian fluorometer contain 2 rows of text headers. 
%               The Ex wavelengths will be automatically extracted from the first row
%               of the data file (do not include text rows in the range, see below).
%
% 	  range: Specify the range of cells in the raw EEMs that contain numbers (NOT TEXT).
%            For many EEM files, there are no text rows that need be excluded e.g. range ='A1..AA500'
%            For Varian files, exclude the first two rows plus any rows of text below the EEMs, e.g. range ='A3..CD113'
%            The chosen range affects the designation of headers, see below.
%
%	headers: indicate presence/absence for Ex and Em, reflecting data excluded from the range
%           [1 1]:  present for Ex and Em  - this is usual if numerical Ex and Em headers are present and were not excluded from the range
%           [0 1]:  present for Em but not Ex   - this is usual for Varian files once text are excluded from range
%           [1 0]:  present for Ex but not Em
%           [0 0]:  absent for Ex and Em
%
%	display: length of time (in seconds) to show plots of scans on screen (e.g. 1 = display for 1 second)
%             if display=0, no plots will be created.
%
%	  outdat: Specify whether or not to save the data in the current directory
%				1: save data, or 0 otherwise               
%                  Saved data are:
%                 (a) outdata: intensities at common wavelength pairs (A, C, M,T,B) 
%                     written to an excel workbook (OutData_FDOM.xls)
%                 (b) X,Emmat,Exmat,filelist and outdata saved to a matlab file (RawData_FDOM.mat)
%
% OUTPUTS:
%   		X: 3D matrix of EEMs
%   	Emmat: matrix of Em corresponding with individual EEMs
%   	Exmat: matrix of Ex corresponding with individual EEMs (text data excluded and replaced with 1:N)
%    filelist: list of filenames
%     outdata: data that were saved to file, or [] otherwise
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% readinscans: Copyright (C) 2013 Kathleen R. Murphy
% $ Version 0.1.0 $ September 2013 $ First Release
% $ Updated from FDOMcorr toolbox ver. 1.8
%
% Copyright (C) 2013 KR Murphy,
% Water Research Centre
% The University of New South Wales
% Department of Civil and Environmental Engineering
% Sydney 2052, Australia
% krm@unsw.edu.au
%%%%%%%%%%%%%%%%

%% INITIALISE
direc = dir(['*.' format]);
filelist=[]; X=[];Emmat=[];Exmat=[]; x=[]; outdata=[];
EmDummy=0;ExDummy=0;

for i=1:size(direc,1)
    
    fprintf([direc(i).name '\n'])
    filelist=char(filelist,direc(i).name); %file list

    %% LOAD FILES, excluding cells that contain text
    if strcmp(format,'csv')==1;
        x = dlmread(direc(i).name,',',range);
    elseif strcmp(format,'xls')==1;
        x = xlsread(direc(i).name,1,range);
    elseif strcmp(format,'xlsx')==1;
        x = xlsread(direc(i).name,1,range);
    elseif strcmp(format,'dat')==1;
        x = dlmread(direc(i).name,'\t',range);
    elseif strcmp(format,'txt')==1;
        x = dlmread(direc(i).name,'\t',range);    
    end
    
    if i==1;
        xsize=size(x);
    else
        %check that the size of x is consistent with the first EEM
        if size(x)~=xsize
            fprintf('The size of the input EEMs has changed!\n')
            error('Check raw data file and resize as necessary.')
        end
    end
    
    %% REMOVE HEADERS
    %size(x),x(1:5,1:5)
    if headers(2)==1; %remove the Em headers
        if headers(1)==0 %no Ex headers
            Emmat(:,i)=x(:,1); %#ok<*AGROW>
            if type==1;
                x=x(:,2:end); % remove Em headers from first column
                ExDummy=1;Exmat(i,:)=1:size(x,2);
            elseif type==2; %varian
                x=x(:,2:2:end); % remove Em headers from every second column of varian file
                TxtLen=6; %Assume excitation wavelengths that are 6 characters long, e.g. 250.00 
                try
                TxtEx=ExtractVarianEx(direc(i).name,TxtLen);
                %Exmat, pause
                if isempty(Exmat)
                     Exmat(i,:)=TxtEx;
                elseif isequal(length(TxtEx),size(Exmat,2))
                    Exmat(i,:)=TxtEx;
                elseif ~isequal(length(TxtEx),size(Exmat,2))
                    Exmat(i,:)=TxtEx(1:size(Exmat,2))';
                    warning('The Ex header has changed!'),pause(1)
                    %size(TxtEx),TxtEx',size(Exmat)
                    disp(Exmat(i,:))
                end
                catch %#ok<CTCH>
                    ExDummy=1;
                    Exmat(i,:)=1:(size(x,2));
                    disp(Exmat(i,:))
               end
            end
        elseif headers(1)==1 %has Ex headers
            Emmat(:,i)=x(2:end,1);
            if type==1;
                Exmat(i,:)=x(1,2:end);
                x=x(2:end,2:end); % remove Em headers from first column
            elseif type==2;
                Exmat(i,:)=x(1,2:2:end);
                x=x(2:end,2:2:end); % remove Em headers from every second column of varian file
            end
        end
    elseif headers(2)==0; % no Em headers
        if type==2
            error('type=2 (alternate columns of Em) is not compatible with "no Em headers"');
        end
        EmDummy=1;
        if headers(1)==1; %remove the Ex headers
            Exmat(i,:)=x(1,:);
            x=x(2:end,:);
        elseif headers(1)==0; %
            ExDummy=1;
            Exmat(i,:)=1:(size(x,2));
        end
        Emmat(:,i)=(1:size(x,1))';
    end
    
    X(i,:,:)=x;
    %size(Exmat),size(Emmat), size(x),x(1:5,1:5)
    
    if ~isequal(size(Emmat,1),size(x,1))
        fprintf('Em size is '), size(Emmat),
        fprintf('X size is '), size(x),
        error('Em and X matrix sizes not compatible'),
    end
    if ~isequal(size(Exmat,2),size(x,2))
        fprintf('Ex size is '), size(Exmat),
        fprintf('X size is '), size(x),
        error('Ex and X matrix sizes not compatible'),
    end
    
    %% DISPLAY a plot of each EEM as it is loaded
    if display>0;
        %size(x),size(Emmat(:,i)), size(Exmat(i,:))
        figure, contourf(Exmat(i,:),Emmat(:,i),x),
        title(direc(i).name,'interpreter','none')
        pause(display),
        close
    end
end
filelist=filelist(2:end,:); %remove first row of blanks

%Create outdata matrix (assume Em and Ex as for the first file that was read in)
if EmDummy==0
    Em=round(Emmat(:,1)*2)/2; %round to nearest 0.5 nm
elseif EmDummy==1
    moveon=0;
    while moveon==0;
        Em = input('Specify the emission wavelength range, e.g. 300:2:600:    ');
        if size(Em,2)==size(x,1)
            Emmat=repmat(Em',[1 size(X,1)]);
            moveon=1;
        else
            fprintf(['Size mismatch: expecting a header of size 1x' num2str(size(x,1)) '. Try again. \n']) ;
        end
    end
end
if ExDummy==0
    Ex=round(Exmat(1,:)*2)/2; %round to nearest 0.5 nm
elseif ExDummy==1
    moveon=0;
    while moveon==0;
        Ex = input('Specify the excitation wavelength range, e.g. 250:5:450:    ');
        if size(Ex,2)==size(x,2)
            Exmat=repmat(Ex,[size(X,1) 1]);
            moveon=1;
        else
            fprintf(['Size mismatch: expecting a header of size 1x' num2str(size(x,2)) '. Try again. \n']) ;
        end
    end
end

%% EXPORT DATA 
% Export EEM cube to MATLAB file "RawData_FDOM.mat"
% Export data for particular wavelength pairs to an excel spreadsheet "OutData_FDOM.xls"
% adjust or add to the following wavelength selection as required

if outdat==1;
    inpairs=[350 450; ...    %C (humic-like)
        250 450; ...         %A (humic-like)
        290 350; ...         %T (tryptophan-like)
        270 304; ...         %B (tyrosine-like)
        320 412];            %M (marine/microbial-like)
    
    %modify the list above to correspond with Ex and Em in this dataset
    outwaves=nearestwave(inpairs,Ex,Em);
    
    outdata=NaN*ones(size(X,1)+2,size(outwaves,1)+1); %first two rows are headers
    outdata(1,2:end)=outwaves(:,1)';    %excitation headers
    outdata(2,2:end)=outwaves(:,2)';    %emission headers
    outdata(3:end,1)=(1:size(X,1))';  %number samples
    for i=1:size(outwaves,1)
        p=X(:,Em==outwaves(i,2),Ex==outwaves(i,1));
        if ~isempty(p)
            outdata(3:end,i+1)=p;
        end
    end
    
    %Write outdata matrix to excel file: OutData_FDOM.xls
    fprintf('writing OutData_FDOM.xls to your current directory...\n')
    %delete 'OutData_FDOM.xls'; %Remove old versions of this spreadsheet.
    xlswrite('OutData_FDOM.xls',outdata,'Raw')
    xlswrite('OutData_FDOM.xls',cellstr('Ex wave'),'Raw','A1')
    xlswrite('OutData_FDOM.xls',cellstr('Em wave'),'Raw','A2')
    xlswrite('OutData_FDOM.xls',(1:size(X,1))','Filenames','A2')
    xlswrite('OutData_FDOM.xls',cellstr('List of Files'),'Filenames','B1')
    xlswrite('OutData_FDOM.xls',cellstr(filelist),'Filenames','B2')

    fprintf('writing RawData_FDOM.mat to your current directory...\n')
    save RawData_FDOM.mat X Emmat Exmat filelist outdata 
end

%% Extract Ex from Varian text headers
function ExTXT=ExtractVarianEx(fn,TxtLen)
% function ExTXT=ExtractVarianEx(fn,TxtLen)
% Extract wavelengths embedded in text from the first row of a Varian data file
%
% INPUTS
%  fn       = filename
%  TxtLen   = number of characters in each Ex wavelength (typically six, for example, 220.00)
%
% OUTPUTS
%  ExTXT    = Excitation wavelengths extracted from the header
%
% Copyright (C) 2011 KR Murphy,
% Water Research Centre
% The University of New South Wales
% Department of Civil and Environmental Engineering
% Sydney 2052, Australia
% krm@unsw.edu.au
%%%%%%%%%%%%%%%%

fid=fopen(fn);          % Open the file
tline = fgetl(fid);     % Header line containing excitation wavelengths
fclose(fid);            % Close the file

CommaPos=strfind(tline,',');
C=[];
for i=1:TxtLen 
C=[(CommaPos(1:2:end)-i)' C];
end
ExTXT=str2num(tline(C)); %#ok<ST2NM>
%%%%%%%%%%%%%%%%

function newpair=nearestwave(inpair,Ex,Em)
%find wavelength pairs in Ex and Em as similar 
%to those listed in inpair as possible
newpair=inpair;
for i=1:size(inpair,1);
    [~, j1]=min(abs(Ex-inpair(i,1)));
    [~, j2]=min(abs(Em-inpair(i,2)));
    newpair(i,:)=[Ex(j1) Em(j2)];
end