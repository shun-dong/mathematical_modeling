function varargout=fdomcorrect(X,Ex,Em,Emcor,Excor,W,varargin)
% USEAGE:
%     [XcRU Arp IFCmat BcRU XcQS QS_RU]=fdomcorrect(X,Ex,Em,Emcor,Excor,W,RamOpt,A,B,T,Q,Qw);
%
% INPUTS
%      Matrix sizes indicated by (Rows x Columns) in 2D case or (Samples x Rows x Columns) in 3D case.
%
% 	  Ex:	1D row vector of excitation wavelengths corresponding to EEMs.
% 	  Em:	1D row vector of emission wavelengths corresponding to EEMs.
%  	   X:	3D data cube (NO HEADERS, i.e. samples x Em x Ex) of fluorescence intensities in primary samples.
%  Emcor:	2D matrix (wavelength x correction factor); first column is wavelength.
%  Excor:	2D matrix (wavelength x correction factor); first column is wavelength.
% 	   W:	is either of (a) or (b):
%       	(a) a single water Raman emission scan (Ex==landa) applied to all samples; first row is wavelength;
%       	(b) 2D matrix (samples x Em) of water Raman scans (Ex==landa) for corresponding samples; 
%               first row is wavelength.
% RamOpt:	options (user-defined excitation and emission wavelengths, to nearest 0.5nm) 
%           for calculating Raman areas in the form: [landa Em1 Em2]. 
%           If RamOpt=[], the default values [350 381 426] are used.
%           RamOpt(1)= landa; excitation wavelength corresponding to the emission scan used for calculating Raman areas. 
%           RamOpt(2)= first emission wavelength in the integration range
%           RamOpt(3)= last emission wavelength in the integration range
%
% IF performing INNER FILTER CORRECTION using the Absorbance method, otherwise A=[]:
% 		A:	2D matrix (samples x wavelengths) of Absorbances (decadal form, 1 cm cell); first row is wavelength.
%
% IF performing BLANK SUBTRACTION, otherwise B=[],T=[]:
% 		B:	is either of (a) or (b):
%           (a) single blank EEM (Em x Ex) to be used for all samples;
%           (b) 3D data cube (samples x Em x Ex) of fluorescence intensities in blanks matched with samples.
% 		T: is either of (a) or (b):
%           (a) T=[] indicating that T is to be automatically extracted from B at Ex=landa;
%           (b) 2D matrix (samples x Em) of water Raman scans(Ex==landa) for blanks; first row is wavelength.
%
% IF performing QUININE SULFATE (QS) CALIBRATION, otherwise Q=[],Qw=[]:
% 		Q:	is either of (a) or (b):
%       	(a) a scalar representing the slope (uncorrected) of a linear QS dilution series 
%               at 350/450 nm applied to all samples in the dataset;
%       	(b) a vector of slopes (uncorrected) of QS dilution series corresponding with each sample.
% 		Qw:	is either of (a) or (b):
%       	(a) a water Raman emission scan (Ex==landa) collected on same day as the QS 
%				dilution series; first row is wavelength;
%       	(b) 2D matrix (samples x Em) of water Raman scans(Ex==landa) corresponding 
%               to the vector of QS blanks; in which the first row is wavelength.
%
% OUTPUTS:
% 	XcRU:	3D matrix of corrected EEMs in Raman units, including inner filter correction and blank subtraction steps, if applied.
% 	Arp:	vector of Raman Areas in arbitrary units.
% 	IFCmat:	3D matrix of inner filter correction factors.
% 	BcRU:	3D matrix of corrected blanks.
% 	XcQS:	3D matrix of corrected EEMs in QS units, including inner filter correction and blank subtraction steps, if applied.
% 	QS_RU:	vector of conversion factors between QS and RU calibrated EEMs.
%
% EXAMPLES:
% The simplest correction method requires 6 inputs and 2 outputs to produce spectrally corrected EEMs in RU units 
% There are no inner filter correction, blank subtraction or QS calibration steps:
% [Xc Arp]=fdomcorrect(X,Ex,Em,Emcor,Excor,W);   %spectral correction in RU units with landa = 350 nm
%
% if performing additional or non-default correction steps, all 12 input variables and 6 output variables must be specified 
% and irrelevant variables will be outputed as NaN. For example:
% [XcRU Arp IFCmat BcRU XcQS QS_RU]=fdomcorrect(X,Ex,Em,Emcor,Excor,W,[],A,[],[],[],[]);  %inner filter correction
% [XcRU Arp IFCmat BcRU XcQS QS_RU]=fdomcorrect(X,Ex,Em,Emcor,Excor,W,[],A,B,[],[],[]);   %inner filter correction, blank subtraction
% [XcRU Arp IFCmat BcRU XcQS QS_RU]=fdomcorrect(X,Ex,Em,Emcor,Excor,W,[],[],B,[],Q,Qw);   %blank subtraction, RU and QS normalization
% [XcRU Arp IFCmat BcRU XcQS QS_RU]=fdomcorrect(X,Ex,Em,Emcor,Excor,W,[280 300 325],[],[],[],Q,Qw);  %RU, QSE units with landa = 280 nm
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% fdomcorrect: Copyright (C) 2013 Kathleen R. Murphy
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

format bank
narginchk(6, 12)

%Set up File Export preferences with ExportFiles=true or ExportFiles=false;
%If ExportFiles==true, the following data are saved to file in the current directory.
%  (a) "OutData_FDOM.xls": corrected intensities at common wavelength pairs (A,C,M,T,B) 
%  (b) "CorrData_FDOM.mat": XcRU,Arp,X,Ex,Em,Emcor,Excor are saved to a MATLAB file
ExportFiles=true; %true/false

%Default methods
IFEcorrection=false;
QScalibration=false;
BlankSubtraction=false;
method1='METHOD: Perform spectral correction';
method2='METHOD: Perform RU normalisation';

%inputs
if nargin==6;
    nargoutchk(2,2)
    method3='METHOD: No inner filter correction';
    method4='METHOD: No blank subtraction';
    method5='METHOD: No QS calibration';
    landa=350; Em1=381; Em2=426;
    IFCmat=NaN*ones(size(X));
    BcRU=NaN*ones(size(X));
    XcQS=NaN*ones(size(X));
    methodopts=char('\n',method1,'\n',method2,'\n',method3,'\n',method4,'\n',method5,'\n');
else
    if nargin<12;
        error('function requires either 6 or 12 input variables.')
    elseif  nargin==12;
        RamOpt=varargin{1};
        A=varargin{2};
        B=varargin{3};
        T=varargin{4};
        Q=varargin{5};
        Qw=varargin{6};
        nargoutchk(6,6)
    end

    if isempty(RamOpt),
        landa=350; Em1=381; Em2=426;
    else
        landa=RamOpt(1); Em1=RamOpt(2); Em2=RamOpt(3);
    end
    method3=['METHOD: Raman areas calculated for Ex = ' num2str(landa) ' nm'];
    method4=['METHOD: Raman areas to be integrated over Em = ' num2str(Em1) ' to ' num2str(Em2) ' nm'];

    if ~isempty(A);
        IFEcorrection=true;
        method5='METHOD: Perform inner filter correction';
    else
        IFEcorrection=false;
        method5='METHOD: No inner filter correction';
        IFCmat=NaN*ones(size(X));
    end
    
    if  ~isempty(B);
        BlankSubtraction=true;
        method6='METHOD: Perform blank subtraction';
    else
        BlankSubtraction=false;
        method6='METHOD: No blank subtraction';
        BcRU=NaN*ones(size(X));
    end
    
    if  and(~isempty(Q),~isempty(Qw))
        QScalibration=true;
        method7='METHOD: Perform QS calibration';
    elseif and(isempty(Q),isempty(Qw))
        QScalibration=false;
        method7='METHOD: No QS calibration';
        XcQS=NaN*ones(size(X));
    else
        error('QS calibration requires both slope and Raman inputs. Wrong number of input arguments!');
    end
    methodopts=char('\n',method1,'\n',method2,'\n',method3,'\n',method4,'\n',method5,'\n',method6,'\n',method7,'\n');
end
fprintf(methodopts')

%% Step 0: Pretreatment: Resize files as needed
fprintf('\n\n')
fprintf('Step 0: Checking input files...\n')
N_samples=size(X,1);  %or: N_samples=max(size(L));
N_ex=max(size(Ex));
N_em=max(size(Em));
Em=CheckMatrixDim(Em,N_em,1,[],'Em');
Ex=CheckMatrixDim(Ex,1,N_ex,[],'Ex');
X=CheckMatrixDim(X,N_samples,N_em,N_ex,'X');

% Obtain water Raman Scans for Samples
fprintf('  obtaining water Raman scans, W...\n')
if min(size(W))==2; % use a single Raman scan for all samples
   W=CheckMatrixDim(W,2,[],[],'W');
   W=[W(1,:)'  W(2,:)'*ones(1,N_samples)]';
end
W=CheckMatrixDim(W,N_samples+1,[],[],'W');

%Obtain correction files and resize as necessary
doplots=false;
fprintf('  obtaining and resizing correction files...\n')
fprintf('  matching EmcorX & Em \n');
EmcorX=MatchWave(Emcor,Em,doplots); %Resize EmcorX to match Em,
fprintf('  matching ExcorX & Ex \n');
ExcorX=MatchWave(Excor,Ex,doplots); %Resize ExcorX to match Ex,
fprintf('  matching EmcorR & W \n');
EmcorR=MatchWave(Emcor,W,doplots);  %Resize Emcor to match Raman scans for samples
EmcorX=CheckMatrixDim(EmcorX,N_em,2,[],'Emcor for EEM');
ExcorX=CheckMatrixDim(ExcorX,N_ex,2,[],'Excor for EEM');
EmcorR=CheckMatrixDim(EmcorR,size(W,2),2,[],'Emcor for Raman Scan');
Excorlanda=Excor(Excor(:,1)==landa,2);
if isempty(Excorlanda)
    error('Could not locate ex=landa in correction files');
end

if BlankSubtraction
    fprintf('  obtaining and resizing blank files, B and T...\n')
    %Check size of B and replicate single EEM if necessary
    B=squeeze(B);
    if ismatrix(B); %2D dataset
        fprintf('  replicating blank EEM .. \n');
        B=CheckMatrixDim(B,N_em,N_ex,[],'B');
        B=RepEEM(B,N_samples,0);
    end
    B=CheckMatrixDim(B,N_samples,N_em,N_ex,'B');
    
    %Check size of T and extract from B if necessary
    if isempty(T);
        fprintf('  Raman scans for Blanks will be extracted from blank matrix\n');
        T=[Em';squeeze(B(:,:,Ex==landa))];
    end
    T=CheckMatrixDim(T,N_samples+1,[],[],'T');
end

if QScalibration
    fprintf('  obtaining correction factors @ 350/450 nm \n');
    Excor350=Excor(Excor(:,1)==350,2);
    Emcor450=Emcor(Emcor(:,1)==450,2);
    cor350_450=Excor350*Emcor450;
    if isempty(cor350_450)
        error('Could not locate ex=350 and em=450 nm in correction files for QS slope calibration');
    end
    
    fprintf('  obtaining and resizing dilution series Qs...\n')
    % Q is a scalar or vector of dilution series slopes
    if max(size(Q))==1; %a scalar
        fprintf('  use same QS slope for all samples .. \n');
        Q=Q*ones(N_samples,1);
    end
    Q=CheckMatrixDim(Q,N_samples,1,[],'Q');
    
    fprintf('  obtaining and resizing water Raman Qw...\n')
    if min(size(Qw))==2; % a single Raman scan for all samples
        Qw=CheckMatrixDim(Qw,2,[],[],'W');
        Qw=[Qw(1,:)'  Qw(2,:)'*ones(1,N_samples)]';
    end
    Qw=CheckMatrixDim(Qw,N_samples+1,[],[],'Qw');
end

%% Step 1: Apply Spectral Correction files
fprintf('\nStep 1: Apply Spectral Correction \n')

%EEM correction factors
eemXcor=EmcorX(:,2)*ExcorX(:,2)'; %2D correction matrix applying to each sample
eemcormat=RepEEM(eemXcor,N_samples,0); %3D correction matrix

%correct the sample EEMs
Xc = eemcormat.*X; 
Xs=Xc; %spectrally corrected EEMs

%correct the Raman scans corresponding to the sample EEMs
%[mw, d_1]=size(W);
mw=size(W,1);
Rcormat=(Excorlanda*EmcorR(:,2)*ones(1, mw))';
Wc=Rcormat.*W;
Wc(1,:)=W(1,:); %Corrected Raman scans, first row is wavelength

if BlankSubtraction
    %Spectrally correct B and T
    Bc = eemcormat.*B; %spectrally corrected blanks
    fprintf('  matching EmcorT & T \n');
    EmcorT=MatchWave(Emcor,T,doplots);  %Resize Emcor to match Raman scans for blanks
    %[mw, d_2]=size(T);
    mw=size(T,1);
    Tcormat=(Excorlanda*EmcorT(:,2)*ones(1, mw))';
    Tc=Tcormat.*T;
    Tc(1,:)=T(1,:); %Tc=spectrally corrected Raman scans for blanks, first row is wavelength
end

if QScalibration
  % Spectrally correct the Quinine Sulfate dilution series and Raman scans 
  % Slopes:
    Sc=cor350_450*Q; %Corrected slopes of the dilution series
  % Raman scans:
    fprintf('  matching EmcorQ & Qw \n');
    EmcorQ=MatchWave(Emcor,Qw,doplots);  
    %[mw, d_3]=size(Qw);
    mw=size(Qw,1);
    Qcormat=(Excorlanda*EmcorQ(:,2)*ones(1, mw))';
    Qwc=Qcormat.*Qw;
    Qwc(1,:)=Qw(1,:); %Qwc=spectrally corrected Raman scans for QS series
end

%% Step 2: Inner Filter Correction (Parker & Barnes 1957)
%A is the absorbance in a 1 cm cell in decadal form (samples x wavelengths)
%method is accurate within 5 percent for A<1.5-2.0
%First, resize A to match wavelengths Ex and Em in EEMs

if IFEcorrection
    fprintf('Step 2: Apply Inner Filter correction \n')
    A=CheckMatrixDim(A,N_samples+1,[],[],'A');
    A=(sortrows(A',1))'; %wavelengths in descending order
    if min(A)<0
        warning('MATLAB:NegAbs1','2.1: some Absorbance measurements have negative values.');
        warning('MATLAB:NegAbs2','2.2: Negative absorbance will be set to zero.');
        A(A<0)=0;
    end
    
    %Generate a matrix of inner filter corection factors
    %according to the method of Parker & Barnes, 1957.
    pathlength = 1; %1 cm cell
    warning('MATLAB:PathLen',['2.3: Pathlength of ' num2str(pathlength) '-cm is assumed.']);
    IFCmat = IFEabs(A,N_samples,Em,Ex,pathlength);
    % % OPTIONAL: Plot the correction factors
    % for i=1:size(M,1)
    %     figure, contourf(Ex,Em,squeeze(IFCmat(i,:,:)));
    % end
    Xife =Xc.*IFCmat;
    Xc=Xife;
else fprintf('Step 2: No inner filter correction \n')
end


%% Step 3: Raman Normalisation
%Integrate scatter peaks between Em1-Em2 in a matrix of Raman scans
%Em1 and Em2 are scalars to nearest 0.5nm, e.g. 381, 426 nm
%Note that Em1 and Em2 must both be present in the Raman scan.
%If Em1 or Em2 are not found the program will increment Em1 down and Em2 up by 0.5m.
%If Em1 or Em2 are still not found following 10 increments an error will be produced
%and a new integration range must be specified manually.

fprintf('Step 3: Apply Raman normalisation \n')

%Normalise the sample EEMs to the area under the Raman scan between Em1-Em2;
fprintf('  Normalise the EEMs using Raman scans from W.  \n')
fprintf('  First, check wavelengths in W and adjust integration range if necessary.... \n')
if Em1==Em2
    Arp=Wc(2:end,Wc(1,:)==Em1);
    if max(isnan(Arp))==1 %NaN in one or more rows
        error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
    elseif isempty(Arp),  %all rows empty
        error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
    end
    method2a=['METHOD: Samples normalized to Raman height at' num2str(Em1) ' nm'];
else
    [Arp, EmAout1, EmAout2]=RamanArea(Wc,Em1,Em2);
    method2a=['METHOD: Actual Raman integration area - samples: ' num2str(EmAout1) ' to ' num2str(EmAout2) ' nm'];
end
methodopts=char(methodopts,method2a,'\n');

ArpMat=repmat(Arp,[1,N_em,N_ex]); %convert to a 3D matrix
Xc = Xc./ArpMat;  %EEMs in R.U.

if BlankSubtraction
    fprintf('  Normalise the blanks using Raman scans from T (or B)... \n')
    fprintf('  First, check wavelengths in T (or B) and adjust integration range if necessary... \n')
    %calculate Raman area/height for the blanks
    if Em1==Em2
        Brp=Tc(2:end,Tc(1,:)==Em1);
        if max(isnan(Arp))==1 %NaN in one or more rows
            error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
        elseif isempty(Arp),  %all rows empty
            error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
        end
    method2b=['METHOD: Blanks normalized to Raman height at' num2str(Em1) ' nm'];
    else
        [Brp, EmBout1, EmBout2]=RamanArea(Tc,Em1,Em2);
    method2b=['METHOD: Actual Raman integration area - blanks: ' num2str(EmBout1) ' to ' num2str(EmBout2) ' nm'];
    end
    methodopts=char(methodopts,method2b,'\n');

    BrpMat=repmat(Brp,[1,N_em,N_ex]); %convert to a 3D matrix

    %Normalise the blanks, using the Raman area/height corresponding to the blanks
    BcRU = Bc./BrpMat;  %blanks in R.U.
end

if QScalibration
    fprintf('  Normalise the QS series using Raman scans from Qw... \n')
    fprintf('  First, check wavelengths in Qw and adjust integration range if necessary... \n')
    %Normalise the QS dilution series to Raman area/height.
    if Em1==Em2
        Qr=Qwc(2:end,Qwc(1,:)==Em1);
        if max(isnan(Qr))==1 %NaN in one or more rows
            error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
        elseif isempty(Qr),  %all rows empty
            error(['Emission wavelength ' num2str(Em1) '-nm not found in one or more Raman scans.'])
        end
        method2c=['METHOD: QS series normalized to Raman height at' num2str(Em1) ' nm'];
    else
        [Qr, EmQout1, EmQout2]=RamanArea(Qwc,Em1,Em2); %Qr=Raman Area for corrected QS blanks (samples x 1)
        method2c=['METHOD: Actual Raman integration area - QS: ' num2str(EmQout1) ' to ' num2str(EmQout2) ' nm'];
    end
    RU_QS=Sc./Qr;
    QS_RU=Qr./Sc;
    QS_RUMat=repmat(QS_RU,[1,N_em,N_ex]); %convert to a 3D matrix
    methodopts=char(methodopts,method2c,'\n');
end

%% Step 4: Blank Subtraction
if BlankSubtraction
  % blank subtraction step
    fprintf('Step 4: Apply blank subtraction \n')
    Xbs = Xc - BcRU;
    Xc=Xbs;
else fprintf('Step 4: No blank subtraction \n')
end
XcRU=Xc;

%% Step 5: Quinine Sulfate Calibration
if QScalibration
   % Calibrate to corrected slope of the dilution series
    fprintf('Step 5: Apply QS calibration \n')
    XcQS=Xc.*QS_RUMat;  %EEMs in QSE units
   % Display:  Raw, Corrected, Ram Area, QS/RU
    QW350_450=[Q Sc Qr QS_RU RU_QS];
    if min(Q(1)*ones(N_samples,1)==Q)==1 %QW350_450 is identical for all samples
        QW350_450=QW350_450(1,:);
    end
    
    fprintf('\n\n Conversion between QSE and RU for each unique dilution series, using QS slope at 350/450 nm: \n')
    disp('          Raw           Corr.       RamArea        QS/RU          RU/QS')
    disp('         -----         -------      -------       -------         ------')
    disp(unique(QW350_450,'rows'));
    pause(2)
 
    fprintf('\n\n Conversion between QSE and RU applied to each sample: \n')
    disp('          Raw           Corr.       RamArea        QS/RU          RU/QS')
    disp('         -----         -------      -------       -------         ------')
    disp(QW350_450);
    
else fprintf('Step 5: No QS calibration \n')
    QS_RU=NaN;
end

%% Demonstrate results at specific wavelengths (Ex/Em=pex/pem)

%choose demonstration wavelengths similar to 350/450 nm
demopair=nearestwave([350 450],Ex,Em);
pex=demopair(1);
pem=demopair(2);

XsRA=Xs(:,(Em==pem),(Ex==pex))./Arp;

p=[X(:,(Em==pem),(Ex==pex)) ...
    Xs(:,(Em==pem),(Ex==pex)) ...
    Arp ... 
    XsRA ...
    IFCmat(:,Em==pem,Ex==pex) ... 
    BcRU(:,(Em==pem),(Ex==pex)) ... 
    XcRU(:,(Em==pem),(Ex==pex))...  
    XcQS(:,(Em==pem),(Ex==pex))];  

fprintf('\n');
fprintf(' \n *********** Demonstration of the results: ***************');
fprintf(['\n Fluorescence intensities for samples in filelist_eem at ' num2str(pex) '/' num2str(pem) 'nm: ' ...
    '\n Col 1: raw,'  ...
    '\n Col 2: corrected,'  ...
    '\n Col 3: Raman Area,'  ...
    '\n Col 4: spectrally corrected in RU units [default]'  ...
    '\n Col 5: inner filter correction factor,'  ...
    '\n Col 6: corrected blank,'  ...
    '\n Col 7: final output, RU units '  ...
    '\n Col 8: final output, QSE units\n\n'])
disp(p)

%% OUTPUT VARIABLES

%Convert irrelevant output matrices to simple NaNs
if ~IFEcorrection;IFCmat=NaN;end
if ~BlankSubtraction;BcRU=NaN;end
if ~QScalibration;XcQS=NaN;QS_RU=NaN;end

%output variables
varargout{1}=XcRU;
varargout{2}=Arp;
%if sum([IFEcorrection,BlankSubtraction,QScalibration])>0;
if  nargin==12;
    varargout{3}=IFCmat;
    varargout{4}=BcRU;
    varargout{5}=XcQS;
    varargout{6}=QS_RU;
end

%% EXPORT DATA for particular wavelength pairs to file
% If ExportFiles = 1, data are saved to the current directory:
%  (a) "OutData_FDOM.xls": corrected intensities at common wavelength pairs (A,C,M,T,B) 
%  (b) "CorrData_FDOM.mat": XcRU,Arp,X,Ex,Em,Emcor,Excor are saved to a MATLAB file

if ExportFiles;

    %Adjust or add to the following wavelength selection as required
    inpairs=[350 450; ...   %C (humic-like)
        250 450; ...         %A (humic-like)
        290 350; ...         %T (tryptophan-like)
        270 304; ...         %B (tyrosine-like)
        320 412];            %M (marine/microbial-like)
    
    %adjust the list above to correspond with Ex and Em in this dataset
    outwaves=nearestwave(inpairs,Ex,Em);
    
    %Create OutData matrix
    outdata=NaN*ones(size(XcRU,1)+2,size(outwaves,1)+2); %first two rows are headers
    outdata(1,3:end)=outwaves(:,1)';    %excitation headers
    outdata(2,3:end)=outwaves(:,2)';    %emission headers
    outdata(3:end,1)=(1:size(XcRU,1))';  %number samples
    for i=1:size(outwaves,1)
        p=XcRU(:,round(2*Em)/2==outwaves(i,2),round(2*Ex)/2==outwaves(i,1));
        if ~isempty(p)
            outdata(3:end,i+2)=p;
        end
    end
    
    %Write OutData to Excel: "OutData_FDOM.xls":
    FNout='OutData_FDOM.xls';
    fprintf('writing summary data OutData_FDOM.xls to the current directory...\n')
    mi=size(methodopts(2:2:end,:),1); %placement of a method note related to sample order
    xlswrite(FNout,cellstr(methodopts(2:2:end,:)),'Methods')
    xlswrite(FNout,cellstr('Note: the data in this workbook correspond to samples as listed in filelist_eem'),'Methods',['A' num2str(mi+3)])
    xlswrite(FNout,cellstr('type the list name (e.g. filelist_eem) in Matlab to view and copy the sample names'),'Methods',['A' num2str(mi+4)])
    xlswrite(FNout,outdata,'Corr_RU')
    xlswrite(FNout,cellstr('Ex wave'),'Corr_RU','B1')
    xlswrite(FNout,cellstr('Em wave'),'Corr_RU','B2')
  
    if QScalibration
        for i=1:size(outwaves,1)
            p=XcQS(:,round(2*Em)/2==outwaves(i,2),round(2*Ex)/2==outwaves(i,1));
            if ~isempty(p)
                outdata(3:end,i+2)=p;
            end
        end
        xlswrite(FNout,cellstr('Sample'),'QS_RU','A1')
        xlswrite(FNout,cellstr('QS/RU'),'QS_RU','B1')
        xlswrite(FNout,[(1:size(QS_RU,1))' QS_RU],'QS_RU','A2')
        xlswrite(FNout,outdata,'Corr_QS')
        xlswrite(FNout,cellstr('Ex wave'),'Corr_QS','A1')
        xlswrite(FNout,cellstr('Em wave'),'Corr_QS','A2')
    end
    fprintf('                          ......done. \n')
    
    %Write the full list of variables to "CorrData_FDOM.mat":
    fprintf('writing CorrData_FDOM.mat to the current directory...\n')
    if sum([IFEcorrection,BlankSubtraction,QScalibration])>0;
        save CorrData_FDOM.mat XcRU Arp IFCmat BcRU XcQS QS_RU X Ex Em Emcor Excor W RamOpt A B T Q Qw
    else
        save CorrData_FDOM.mat XcRU Arp X Ex Em Emcor Excor W
    end
end %Export Files
    
%% NESTED FUNCTIONS
function M=CheckMatrixDim(M,Dim1,Dim2,Dim3,Mname)
% M=CheckMatrixDim(M,Dim1,Dim2,Dim3,Mname)
% Check the dimensions of matrix M (name = 'Mname') against expected dimensions Dim1, Dim2,and Dim3
% Transpose M if necessary to achieve correct dimensions or else generate error message.
% Copyright K.R. Murphy, 
% July 2010
if isempty(Dim3); %2D data
    if size(M,1)~=Dim1;
        if and(size(M,2)==Dim1,size(M,1)==Dim2)
            M=M';
        elseif isempty(Dim2) %Number of columns is arbitrary
            if size(M,2)==Dim1
                M=M';
            else
                fprintf(['Check size of matrix ' Mname '.\n'])
                fprintf(['Expecting ' num2str(Dim1) ' rows.\n']),pause
                fprintf(['Current size is ' num2str(size(M,1)) ' rows and ' num2str(size(M,2)) ' columns.\n']),pause
                fprintf('Hit any key to continue.\n'),pause
                error('Unexpected Matrix Size')
            end
        else
            fprintf(['Check size of matrix ' Mname '.\n'])
            fprintf(['Expecting ' num2str(Dim1) ' rows and ' num2str(Dim2) ' columns.\n']),pause
            fprintf(['Current size is ' num2str(size(M,1)) ' rows and ' num2str(size(M,2)) ' columns.\n']),pause
            fprintf('Hit any key to continue.\n'),pause
            error('Unexpected Matrix Size')
        end
    end
else  %3D data
    if isequal(size(M),[Dim1 Dim2 Dim3]);
    else
        fprintf(['Check size of matrix ' Mname '.\n'])
        fprintf(['Expecting ' num2str(Dim1) ' x ' num2str(Dim2) ' x ' num2str(Dim3) '.\n']),pause
        fprintf(['Current size is ' num2str(size(M,1)) ' x ' num2str(size(M,2)) ' x ' num2str(size(M,3)) '.\n']),pause
        fprintf('Hit any key to continue.\n'),pause
        error('Unexpected Matrix Size')
    end
end

%% 
function Y=RepEEM(X,N,dochecks)
% Y=RepEEM(X,N,dochecks)
% Make an cube of identical EEMs, each consisting of the EEM X
% Size of cube specified by input N
% if dochecks = true, function displays 3 matrices which should all be identical.
% Copyright K.R. Murphy, 
% July 2010

n1=size(X,1);
n2=size(X,2);
X1 = repmat(X,N,1);
X1 = reshape(X1,[n1 N n2]);
Y = permute(X1,[2 1 3]);

if dochecks==true;
    squeeze(X(1:5,1:3))
    squeeze(Y(1,1:5,1:3))
    squeeze(Y(2,1:5,1:3))
    fprintf('check that the preceeding 3 matrices are all identical, then press any key to continue...')
    pause
end

%%
function Y=MatchWave(V1,V2,doplot)
%Y=MatchWave(V1,V2,doplot)
%Automatically match the size of two vectors, interpolating if necessary.
%Vector V1 is resized and interpolated to have the same wavelengths as V2;
%For example, V1 is a correction file (0.5nm intervals) and V2 is an Emission scan in 2 nm intervals.
%Errors are produced if 
%(1) there are wavelengths in V2 that are outside the upper or lower limit of V1.
%(2) Be aware of rounding errors. For example, 200.063 is NOT equivalent to 200 nm.
% Errors can often be resolved by restricting the wavelength range of V2
% Copyright K.R. Murphy
% July 2010

if size(V1,2)>2; V1=V1';end  %V1 should have multiple rows
if size(V2,2)>2; V2=V2';end  %V2 should have multiple rows

%Restrict the wavelength range of V1 so it is the same as V2
t=V1(find(V1(:,1)<=V2(1,1),1,'last'):find(V1(:,1)>=V2(end,1),1,'first'),:); 
if isempty(t)
    fprintf('\n')
    fprintf(['Error - Check that your VECTOR 1 (e.g. correction file) '...
        'encompasses \n the full range of wavelengths in VECTOR 2 (e.g. emission scan)\n'])
    fprintf('\n Hit any key to continue...')
    pause
    fprintf(['\n VECTOR 1 range is ' num2str(V1(1,1)) ' to ' num2str(V1(end,1)) ' in increments of ' num2str(V1(2,1)-V1(1,1)) '.']),pause
    fprintf(['\n VECTOR 2 range is ' num2str(V2(1,1)) ' to ' num2str(V2(end,1)) ' in increments of ' num2str(V2(2,1)-V2(1,1)) '.']),pause
    fprintf('\n\n This error can usually be resolved by restricting the wavelength range of VECTOR 2,');
    fprintf('\n also, be aware of rounding errors (e.g. 200.063 is NOT equivalent to 200 nm)\n');
    error('Error - abandoning calculations.');
else
    Y=[V2(:,1) interp1(t(:,1),t(:,2),V2(:,1))]; %V1 corresponding with EEM wavelengths
end

if doplot==true;    
figure, 
plot(V1(:,1),V1(:,2)), hold on, plot(Y(:,1),Y(:,2),'ro')
legend('VECTOR 1', 'VECTOR 2')
end

function M=IFEabs(A,N_samples,Em,Ex,PL)
%M = IFEabs(A,N_samples,Em,Ex,PL)
%Calculate a matrix of inner filter correction factors according to the
%absorbance method of Parker & Barnes (1957).
%Parker, C. A.; Barnes, W. J., Some experiments with spectrofluorimeters
%and filter fluorimeters. Analyst 1957, 82, 606-618.
%Inputs:
%A = 2D matrix of Absorbance scans with wavelength on the first row
%N_samples=number of samples
%Em=vector of emission wavelengths
%Ex=vector of excitation wavelengths
%PL = pathlength (1 cm cell)

N_em=length(Em);
N_ex=length(Ex);
M=NaN*ones([N_samples,N_em,N_ex]);

for k=1:N_samples;
    A254=A(2:end,round(A(1,:))==254);
    if max(A254>1.5)
        warning('MATLAB:InnerFilter',['2.4:  A254 exceeds 1.5 for one or more samples. ' ...
            'Confirm linearity between concentration and absorbance for A>1.5, or else ' ...
            'restrict the dataset to lower absorbance samples.']);
        figure,
        subplot(2,1,1),
        plot(A(1,:)',A(2:end,:))
        hold on, plot(A(1,:)',0.05*ones(size(A,2)),'k--')
        hold on, plot(A(1,:)',1.5 *ones(size(A,2)),'k--')
        hold on, plot(254*ones(11,1),0:0.1:1,'k--')
        axis tight,
        ylim([0 1])
        xlabel('wavelength (nm)'); ylabel('Absorbance');
        subplot(2,1,2),
        plot(A254,'ro')
        xlabel('sample number'); ylabel('Absorbance at 254 nm');
    end
    Atot=zeros(N_em,N_ex);
    Ak=[A(1,:);A(k+1,:)];
    
    %fprintf('matching Absorbance scans & Ex, Em \n');
    try
        Aem=MatchWave(Ak,Em,0);
    catch ME
        disp(ME)
        fprintf(['\nThe range of A is ' num2str(min(A(1,:))) '-' num2str(max(A(1,:)))]);
        fprintf(['\nThe range of Em is ' num2str(min(Em)) '-' num2str(max(Em))]);
        error('MATLAB:InnerFilter:Wavelengths','2.41:  Absorbance scans must span the full range of Em');
    end
    
    try
        Aex=MatchWave(Ak,Ex,0);
    catch ME
        disp(ME)
        fprintf(['\nThe range of A is ' num2str(min(A(1,:))) '-' num2str(max(A(1,:)))]);
        fprintf(['\nThe range of Ex is ' num2str(min(Ex)) '-' num2str(max(Ex))]);
        error('MATLAB:InnerFilter:Wavelengths','2.42:  Absorbance scans must span the full range of Ex');
    end
    
    for i=1:size(Aem,1)
        for j=1:size(Aex,1)
            Atot(i,j)=Aex(j,2)+Aem(i,2);
        end
    end
    IFC=10.^(PL/2*Atot);
    M(k,:,:)=IFC;
end

function [Y,EmMin,EmMax]=RamanArea(M,EmMin,EmMax)
% [Y,EmMin,EmMax]=RamanArea(M,EmMin,EmMax)
% Find the area under the curves in M between wavelengths EmMin and EmMax, with EmMin<EmMax
% Wavelengths must be in the first row of M. These are rounded automatically to nearest 0.5nm
% prior to matching with EmMin and EmMax.
% If EmMin or EmMax are not found the program will increment Em1 down and Em2 up by 0.5m for a maximum
% of 10 incrementation steps, after which an error will be produced. 
% Fix this error by adjusting EmMin and EmMax or by interpolating M.
% Copyright K.R. Murphy
% July 2010

wave=M(1,:); %first row is wavelength
wave=round(wave*2)/2; %round wavelengths to nearest 0.5 nm
istart=find(wave==EmMin); %index of first wavelength
istop=find(wave==EmMax);  %index of last wavelength

j=0; jmax=10;
while isempty(istart),
    j=j+1;
    fprintf(['    Wavelength ' num2str(EmMin) 'nm not found in Raman scan. Automatically adjusting integration range...\n']),
    EmMin = EmMin-0.5;
    istart=find(wave==EmMin); %index of first wavelength
    if j>jmax
        error('Can not find integration wavelengths in Raman file. Check files before continuing.')
    end
end
j=0; jmax=10;
while isempty(istop),
    j=j+1;
    fprintf(['    Wavelength ' num2str(EmMax) 'nm not found in Raman scan. Automatically adjusting integration range...\n']),
    EmMax = EmMax+0.5;
    istop=find(wave==EmMax); %index of first wavelength
    if j>jmax;
        error('Can not find integration wavelengths in Raman file. Check files before continuing.')
    end
end
fprintf(['    Actual integration range is ' num2str(EmMin) ' to ' num2str(EmMax) ' nm.\n'])
delta=round((EmMax-EmMin)/(istop-istart)*2)/2; %wavelength increment to nearest 0.5 nm
    
%Area under the curve
rr=M(2:end,istart:istop); %restrict to curve between EmMin and EmMax
rr1=rr(:,1:end-1);
rr2=rr(:,2:end);
RAsum=0.5*(sum(rr1,2)+sum(rr2,2))*delta;

%Calculate area below the baseline
y1=rr(:,1);y2=rr(:,end);  %data points at EmMin and EmMax;
BaseArea=(wave(istop)-wave(istart))*(y1+0.5*(y2-y1));

%Raman Area, Y
Y = RAsum - BaseArea;

function newpair=nearestwave(inpair,Ex,Em)
%find wavelength pairs in Ex and Em as similar 
%to those listed in inpair as possible
newpair=inpair;
for i=1:size(inpair,1);
    [i1, j1]=min(abs(Ex-inpair(i,1))); %#ok<ASGLU>
    [i2, j2]=min(abs(Em-inpair(i,2))); %#ok<ASGLU>
    newpair(i,:)=[Ex(j1) Em(j2)];
end
