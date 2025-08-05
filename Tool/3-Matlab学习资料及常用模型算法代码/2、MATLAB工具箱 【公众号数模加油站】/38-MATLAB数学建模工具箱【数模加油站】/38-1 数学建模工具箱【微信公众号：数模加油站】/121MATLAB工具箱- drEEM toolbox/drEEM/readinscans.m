function [S,W,wave,filelist]=readinscans(type,format,XLrange,display,outdat,pattern)

% Read files of specified format (csv, txt, dat, xls, xlsx) in the current directory
% and convert to a single 2D matrix of scans. Remove unwanted files of the same format
% from the current directory before running this program.
% The files will be loaded in alphabetical order (see output: filelist).
% All scans must be of the same size, type and format
%
% USEAGE:
%           [S,W,wave,filelist]=readinscans(type,format,XLrange,display,outdat,pattern)
% INPUTS:
%       type: Up to 10 characters describing the type of data scans, used to name the output file. For example: 
%            'Absorbance':  Absorbance scans
%            'UV350':  UV scans at 350 nm excitation
%
%     format: 'csv','xls','xlsx','txt','dat' or the special formats that are the same
%             as these but end in numbers e.g. 'dat_1_10', csv_2_5. See note 3 below.
%             Note 1. If importing from .txt or .dat files, first open them with Excel to determine
%                     what range of cells (XLrange) are appropriate.
%             Note 2. For xls or xls formats, data will be imported from the first worksheet of the excel file
%             Note 3. If the files have >2 columns and you wish to import
%                     only some colums, representing [wavelengths, data] then
%                     specify the indices of columns at the end of the
%                     format. Subtract columns that were excluded from the XLrange.
%                     e.g. 'dat_1_10': wavelengths from col. 1 and data from col. 10.
%                     e.g. 'csv_2_5': wavelengths from col. 2 and data from col. 5.
%
%    XLrange: Range of cells in the raw EEMs that contain numbers (see Note 1 above for 'txt' formats).
%             e.g. range ='A3..B500' or range ='A2..BB3' (or range = [] for .txt files only)
%
%    display: length of time to show plots of scans on screen (e.g. 1 = display for 1 second)
%             if display=0, no plots will be created.
%
%     outdat: 1 to write S, W, filelist and wave to an Excel file in the current directory; 0 otherwise.
%             Data are saved in "OutData_xx.xls": where xx is the contents of 'type' above.
%
%    pattern: a text string in the file name. E.g. 'QS*' means only filenames beginning with 'QS' will be read in.
%             If no pattern is specified the default will be to read in all files of the specified extension,
%             i.e. the same as reading in e.g. '*.csv' or '*.txt'.
%
% OUTPUTS:
%          S: A 2D matrix of scans
%          W: A 2D matrix of wavelengths corresponding with individual scans
%       wave: if all the rows of W are equal within 0.5 nm, wave is a single row of wavelengths rounded to 0.5nm
%   filelist: the list of filenames in the order they appear in S, W and wave.
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

%% Initialize
narginchk(5,6)
nargoutchk(4,4)

%If files are in Excel format, delete old version of OutData.xls to avoid conflict.
if strcmp(format,'xls')==1;
    FN=['OutData_' type '.xls'];
    fprintf(['Any existing files of name ' FN ' in the current directory will be replaced. Press any key to continue...\n'])
    pause;
    eval(['delete ' FN])
end

%Check whether to reduce matrices to two columns
SubByCol=false;
if nargin>=5
    prescols = regexp(format,'_', 'once');
    if ~isempty(prescols)
        SubByCol=true;
        [format,col1,col2]=numext(format);
    end
    if nargin == 5
        direc = dir(['*.' format]);
    elseif nargin == 6
        direc = dir([pattern '.' format]);
    end
end

%initialise S and W from RangeIn
W=[];S=[];
filelist=[];frows=[];

%% Load Files
for i=1:size(direc,1)
    
    fprintf([direc(i).name '\n'])
    filelist=char(filelist,direc(i).name); %file list

    % LOAD FILES, excluding cells that contain text
    if strcmp(format,'csv')==1;
        x = dlmread(direc(i).name,',',XLrange);
    elseif strcmp(format,'txt')==1;
        x = dlmread(direc(i).name,'\t',XLrange);
    elseif strcmp(format,'xls')==1;
        x = xlsread(direc(i).name,1,XLrange);
    elseif strcmp(format,'xlsx')==1;
        x = xlsread(direc(i).name,1,XLrange);
    elseif strcmp(format,'dat')==1;
        x = dlmread(direc(i).name,'\t',XLrange);
    end
    
    if SubByCol
         x = x(:,[col1 col2]);
    end

    % convert to row vectors
    xsize=size(x);
    sizeerror=false;
    if min(xsize)==1 % single data pair
        if and(xsize(1)==1,xsize(2)==2); %x=[wave data]
            x=x';
        else
            sizeerror=true;
        end
    elseif min(xsize)==2 %data are in rows or in columns
        if xsize(1)>2; %data are in columns
            x=x';
        elseif xsize(1)==xsize(2); %data in rows or in columns
            if isempty(frows);
                fprintf('input data are 2 rows x 2 colums, more information needed... \n')
                while isempty(frows)
                    frows=input('type 1 if wavelengths are in rows, or 2 if wavelengths are in columns: ');
                    if ismember(frows,[1;2])==true
                    else frows=[];
                    end
                end
            end
            if frows==2;
              x=x';              
            end
        end
    elseif min(xsize)>2
        sizeerror=true;
    end
    if sizeerror==true;
        fprintf(['size of input data is ' num2str(xsize(1)) ' rows and ' num2str(xsize(2))  ' columns \n'])
        error(['Inappropriate data range. Scans must consist of a row or column ' ...
            'of wavelengths followed by 1 row or column of data']);
    end
    x=(sortrows(x',1))';    
    xsize=size(x);
    
    %check that x has no more than two rows (or columns)
    if i==1;
        xsize1=xsize;
    else
        %check that the size of x is consistent with the first scan
        if size(x)~=xsize1
            fprintf('The size of the input scans has changed!\n')
            fprintf(['size of first scan was ' num2str(xsize(1)) 'rows and ' num2str(xsize(2))  ' columns'])
            fprintf(['size of current scan is ' num2str(size(x,1)) 'rows and ' num2str(size(x,2))  ' columns'])
            error('Check raw data file and resize as necessary.')
        end
    end
    
    %% Assemble matrices
    %size(x),pause
    W(i,:)=x(1,:); %#ok<AGROW>
    x=x(2,:);
    S(i,:)=x; %#ok<AGROW>
    
    %% DISPLAY a plot of each scan as it is loaded
    if display>0;
        plot(W(i,:),S(i,:),'ko'),
        title(direc(i).name,'interpreter','none')
        if i>1
            hold on
            plot(W(1:i,:)',S(1:i,:)','c-'),
            legend('current scan','prior scans')
            hold off
        end
       pause(display),
       if i<size(direc,1)
       close
       end
    end
end
%remove leading row of blank filenames
filelist=filelist(2:end,:); 

%Check for consistency among wavelengths
wave=NaN*ones(1,size(S,2));
rndW=round(W*2)/2;
rndW1=repmat(rndW(1,:),[size(rndW,1) 1]);
Wdiff=rndW-rndW1;
if max(max(Wdiff))==0;
    wave=rndW(1,:);
else
    fprintf('\n')
    fprintf('Warning: not all input wavelengths were the same! \n')
    fprintf('Check the rows of output variable W for non-standard wavelengths.\n')
    fprintf('The output variable "wave" is a vector of NaNs.\n')
end

%% EXPORT DATA 
% Export scans to an excel spreadsheet
if outdat==1;
    FN=['OutData_' type '.xls'];
    if size(wave,2)>255 %maximum number of columns allowed by Excel = 256
        wave_LowRes=wave(1:2:end);
        S_LowRes=S(:,1:2:end); 
        W_LowRes=W(:,1:2:end);
        while size(wave_LowRes,2)>255
            wave_LowRes=wave_LowRes(1:2:end);
            S_LowRes=S_LowRes(:,1:2:end);
            W_LowRes=W_LowRes(:,1:2:end);
        end
        xlswrite(FN,wave_LowRes,type,'A1')
        xlswrite(FN,S_LowRes,type,'A2')
        xlswrite(FN,W_LowRes,'Wavelengths')
        msg1='These worksheets contain data at lower wavelength resolution than the raw data files';
        msg2='Full-resolution data are retained in MATLAB';
        xlswrite(FN,cellstr(msg1),'Messages','A1')
        xlswrite(FN,cellstr(msg2),'Messages','A2')
    else
        xlswrite(FN,wave,type,'A1')
        xlswrite(FN,S,type,'A2')
        xlswrite(FN,W,'Wavelengths')
    end
    xlswrite(FN,cellstr(filelist),'Filenames','A2')
    fprintf([FN ' has been written to your current directory...\n'])
end

end

function varargout=numext(str)
%extract the column numbers from the text string
t=str;
i1 = regexp(str,'_');
i2 = regexp(str,'[0-9]');
if ~isempty(i1)
    t=t(1:i1-1);
    varargout{2}=str2double(str(i2(i2<i1(2))));
    varargout{3}=str2double(str(i2(i2>i1(2))));
elseif length(i1)>2
    error('NUMEXT:String','incompatible string format')
end
varargout{1}=t;
end