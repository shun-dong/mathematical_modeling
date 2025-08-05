function filenames=conn_qaplots(qafolder,procedures,validsubjects,validrois,validsets,nl2covariates,nl1contrasts)
% CONN_QAPLOTS creates Quality Assurance plots
% conn_qaplots(outputfolder,procedures,validsubjects,validrois,validsets,nl2covariates,nl1contrasts)
%   outputfolder: target folder where to save plots
%   procedures: plots to create (numbers or labels)
%     1:  QA_NORM structural    : structural data + outline of MNI TPM template
%     2:  QA_NORM functional    : mean functional data + outline of MNI TPM template
%     3:  QA_NORM rois          : ROI data + outline of MNI TPM template  
%     10: QA_REG functional     : display mean functional data + structural data overlay
%     4:  QA_REG structural     : structural data + outline of ROI
%     5:  QA_REG functional     : mean functional data + outline of ROI
%     6:  QA_REG mni            : reference MNI structural template + outline of ROI
%     7:  QA_COREG functional   : display same single-slice (z=0) across multiple sessions/datasets
%     8:  QA_TIME functional    : display same single-slice (z=0) across all timepoints within each session
%     9:  QA_TIMEART functional : display same single-slice (z=0) across all timepoints within each session together with ART timeseries (global signal changes and framewise displacement)
%     11: QA_DENOISE histogram  : histogram of voxel-to-voxel correlation values (before and after denoising)
%     12: QA_DENOISE timeseries : BOLD signal traces before and after denoising
%     13: QA_DENOISE FC-QC      : histogram of FC-QC associations; between-subject correlation between QC (Quality Control) and FC (Functional Connectivity) measures
%     14: QA_DENOISE_scatterplot: scatterplot of FC (Functional Connectivity r coeff) vs. distance (mm)
%     15: QA_DENOISE_FC-QCscatterplot: scatterplot of FC-QC associations (r coeff correlations between QC and FC measures) vs. distance (mm)
%     21: QA_SPM design         : SPM review design matrix (from SPM.mat files)
%     22: QA_SPM contrasts      : SPM review contrast specification (from SPM.mat files)
%     23: QA_SPM results        : SPM review contrast effect-size (from SPM.mat files)
%     31: QA_COV                : histogram display of second-level variables
%   validsubjects: subject numbers to include (defaults to all subjects)
%   validrois: (only for procedures==3,4,5,6) ROI numbers to include (defaults to WM -roi#2-)
%   validsets: (only for procedures==2,7,8,9,10) functional dataset number (defaults to dataset-0)
%   nl2covariates: (only for procedures==13,15,31) l2 covariate names (defaults to all QC_*)
%   nl1contrasts: (only for procedures==23) l1 contrast name (defaults to first contrast)
%   


global CONN_x;
if nargin<1||isempty(qafolder), qafolder=fullfile(CONN_x.folders.qa,['QA_',datestr(now,'yyyy_mm_dd_HHMMSSFFF')]); end
if nargin<2||isempty(procedures), procedures=[]; end
if nargin<3||isempty(validsubjects), validsubjects=1:CONN_x.Setup.nsubjects; end
if nargin<4||isempty(validrois), validrois=2; end %[2,4:numel(CONN_x.Setup.rois.names)-1]; end
if nargin<5||isempty(validsets), validsets=0; end %0:numel(CONN_x.Setup.secondarydataset); end
if nargin<6||isempty(nl2covariates), nl2covariates=[]; end
if nargin<7||isempty(nl1contrasts), nl1contrasts=[]; end
if isfield(CONN_x,'pobj')&&isstruct(CONN_x.pobj)&&isfield(CONN_x.pobj,'subjects'), validsubjects=CONN_x.pobj.subjects; end
erodedrois=validrois<0;
validrois=abs(validrois);

debugskip=false;
dpires='-r150'; % dpi resolution of .jpg files
nslices=10;     % number of slices in display (change to 9 for backward compatibility with conn17 and below)
dslices=10;     % inter-slice distance in display (change to 6 for backward compatibility with conn17 and below)
if ischar(procedures), procedures=cellstr(procedures); end
if iscell(procedures)
    proceduresopts={1,'QA_NORM structural';
                    2,'QA_NORM functional';
                    3,'QA_NORM rois';
                    10,'QA_REG functional';
                    4,'QA_REG structural';
                    5,'QA_REG functional';
                    6,'QA_REG mni';
                    7,'QA_COREG functional';
                    8,'QA_TIME functional';
                    9,'QA_TIMEART functional';
                    11,'QA_DENOISE histogram';
                    12,'QA_DENOISE timeseries';
                    13,'QA_DENOISE FC-QC';
                    14,'QA_DENOISE_scatterplot';
                    15,'QA_DENOISE FC-QC scatterplot';
                    21,'QA_SPM design';
                    22,'QA_SPM contrasts';
                    23,'QA_SPM results';
                    31,'QA_COV'};
    [ok,idx]=ismember(regexprep(lower(procedures),'[\s_-]',''),regexprep(lower(proceduresopts(:,2)),'[\s_-]',''));
    if ~all(ok), error('unrecognized plot type %s',sprintf('%s ',procedures{~ok})); end
    procedures=cell2mat(proceduresopts(idx,1));
end

if ~nargout, ht=conn_waitbar(0,'Creating displays. Please wait...'); 
else ht=[];
end
filenames={};
Nprocedures=numel(procedures);
if Nprocedures, [ok,nill]=mkdir(qafolder); end

Iprocedure=1;
if any(procedures==Iprocedure) % QA_NORM structural
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        %conn('gui_setupgo',2);
        %if ~nargout, conn_waitbar('redraw',ht); end
        nsubs=validsubjects;
        sessionspecific=CONN_x.Setup.structural_sessionspecific;
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                if ~sessionspecific, nsess=1; end
                for nses=1:nsess,
                    fh=conn('gui_setupgo',2,14,3,nsub,nses);
                    filename=fullfile(qafolder,sprintf('QA_NORM_structural.subject%03d.session%03d.jpg',nsub,nses));
                    fh('multisliceset',1,nslices,dslices);
                    fh('togglegui',1);
                    fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                    state=fh('getstate');
                    conn_args={'slice_display',state};
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub-1+(nses)/nsess)/numel(nsubs),ht);
                    else fprintf('.');
                    end
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_NORM-structural plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_NORM-structural plot\n %s\n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=2;
if any(procedures==Iprocedure) % QA_NORM functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        %conn('gui_setupgo',3);
        %if ~nargout, conn_waitbar('redraw',ht); end
        nsubs=validsubjects;
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                nsess=1; %CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)); % note: for functional data, only show first-session (mean functional already incorporates all session data)
                for nses=1:nsess,
                    fhset=conn('gui_setupgo',3,14,4,nsub,nses,validsets);
                    for nset=1:numel(fhset)
                        fh=fhset{nset};
                        filename=fullfile(qafolder,sprintf('QA_NORM_functionalDataset%d.subject%03d.session%03d.jpg',validsets(nset),nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                    end
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub-1+(nses)/nsess)/numel(nsubs),ht);
                    else fprintf('.');
                    end
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_NORM-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_NORM-functional plot\n %s\n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=3;
if any(procedures==Iprocedure) % QA_NORM rois
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                try
                    nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                    if ~sessionspecific, nsess=1; end
                    for nses=1:nsess,
                        assert(~isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),'no ROI-file entered');
                        fh=conn('gui_setupgo',4,14,6,nrois*(1-2*erois),nsub,nses);
                        filename=fullfile(qafolder,sprintf('QA_NORM_%s.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                        if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                        else fprintf('.');
                        end
                    end
                catch
                    conn_disp('fprintf','warning: unable to create QA_NORM-rois plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
                end
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_NORM-rois plot\n %s\n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=4;
if any(procedures==Iprocedure) % QA_REG structural
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            %         if ~subjectspecific, nsubs=1; end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                try
                    nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                    if ~sessionspecific, nsess=1; end
                    for nses=1:nsess,
                        assert(~isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),'no ROI-file entered');
                        fh=conn('gui_setupgo',4,14,4,nrois*(1-2*erois),nsub,nses);
                        filename=fullfile(qafolder,sprintf('QA_REG_%s_structural.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                        if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                        else fprintf('.');
                        end
                    end
                catch
                    conn_disp('fprintf','warning: unable to create QA_REG-structural plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
                end
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_REG-structural plot\n %s\n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=5;
if any(procedures==Iprocedure) % QA_REG functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            %         if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                try
                    nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                    if ~sessionspecific, nsess=1; end
                    for nses=1:nsess,
                        assert(~isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),'no ROI-file entered');
                        fh=conn('gui_setupgo',4,14,3,nrois*(1-2*erois),nsub,nses);
                        filename=fullfile(qafolder,sprintf('QA_REG_%s_functional.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                        if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                        else fprintf('.');
                        end
                    end
                catch
                    conn_disp('fprintf','warning: unable to create QA_REG-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
                end
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_REG-functional plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=6;
if any(procedures==Iprocedure) % QA_REG mni
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        streroded={'','eroded'};
        %conn('gui_setupgo',4);
        %if ~nargout, conn_waitbar('redraw',ht); end
        for ivalidrois=1:numel(validrois)
            nrois=validrois(ivalidrois);
            erois=erodedrois(ivalidrois);
            nsubs=validsubjects;
            if nrois>3, subjectspecific=CONN_x.Setup.rois.subjectspecific(nrois);
            else subjectspecific=1;
            end
            if ~subjectspecific, nsubs=validsubjects(1); end
            if nrois>3, sessionspecific=CONN_x.Setup.rois.sessionspecific(nrois);
            else sessionspecific=CONN_x.Setup.structural_sessionspecific;
            end
            for isub=1:numel(nsubs)
                nsub=nsubs(isub);
                try
                    nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                    if ~sessionspecific, nsess=1; end
                    for nses=1:nsess,
                        assert(~isempty(CONN_x.Setup.rois.files{nsub}{nrois}{nses}{1}),'no ROI-file entered');
                        fh=conn('gui_setupgo',4,14,5,nrois*(1-2*erois),nsub,nses);
                        filename=fullfile(qafolder,sprintf('QA_REG_%s_mni.subject%03d.session%03d.jpg',[streroded{erois+1} regexprep(CONN_x.Setup.rois.names{nrois},'\W','')],nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                        if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(ivalidrois-1+(isub-1+(nses)/nsess)/numel(nsubs))/numel(validrois),ht);
                        else fprintf('.');
                        end
                    end
                catch
                    conn_disp('fprintf','warning: unable to create QA_REG-roi plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
                end
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_REG-roi plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=7;
if any(procedures==Iprocedure) % QA_COREG functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                fh=conn('gui_setupgo',3,14,7,nsub,nslice,validsets);
                filename=fullfile(qafolder,sprintf('QA_COREG_functional.subject%03d.jpg',nsub));
                fh('togglegui',1);
                fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                state=fh('getstate');
                conn_args={'montage_display',state};
                save(conn_prepend('',filename,'.mat'),'conn_args');
                fh('close');
                filenames{end+1}=filename;
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
                else fprintf('.');
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_REG-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_REG-functional plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=8;
if any(procedures==Iprocedure) % QA_TIME functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                fh=conn('gui_setupgo',3,14,8,nsub,[],nslice,validsets,false);
                filename=fullfile(qafolder,sprintf('QA_TIME_functional.subject%03d.jpg',nsub));
                fh('print',filename,'-nogui','-noerror',dpires,'-ADDnoui','-nopersistent');
                state=fh('getstate');
                conn_args={'montage_display',state};
                save(conn_prepend('',filename,'.mat'),'conn_args');
                fh('close');
                filenames{end+1}=filename;
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
                else fprintf('.');
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_TIME-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_TIME-functional plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=9;
if any(procedures==Iprocedure) % QA_TIMEART functional
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        nslice=[];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                icov=find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'),1);
                if isempty(icov), error('scrubbing covariate does not exist yet'); end
                icov=0;
                %             nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                %             for nses=1:nsess,
                %                 fh=conn('gui_setupgo',6,14,2,icov,nsub,nses,nslice,validsets,false);
                %                 fh('style','timeseries');
                %                 filename=fullfile(qafolder,sprintf('QA_TIMEART_functional.subject%03d.session%03d.jpg',nsub,nses));
                fh=conn('gui_setupgo',6,14,2,icov,nsub,[],nslice,validsets,false);
                filename=fullfile(qafolder,sprintf('QA_TIMEART_functional.subject%03d.jpg',nsub));
                fh('print',filename,'-nogui','-noerror',dpires,'-ADDnoui','-nopersistent');
                state=fh('getstate');
                conn_args={'montage_display',state};
                save(conn_prepend('',filename,'.mat'),'conn_args');
                fh('close');
                filenames{end+1}=filename;
                %             end
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub/numel(nsubs)),ht);
                else fprintf('.');
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_TIMEART-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_TIMEART-functional plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=10;
if any(procedures==Iprocedure) % QA_REG functional-structural
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        %conn('gui_setupgo',3);
        %if ~nargout, conn_waitbar('redraw',ht); end
        nsubs=validsubjects;
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                nsess=1; %CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub)); % note: for functional data, only show first-session (mean functional already incorporates all session data)
                for nses=1:nsess,
                    fhset=conn('gui_setupgo',3,14,3,nsub,nses,validsets);
                    for nset=1:numel(fhset)
                        fh=fhset{nset};
                        filename=fullfile(qafolder,sprintf('QA_REG_functionalDataset%d.subject%03d.session%03d.jpg',validsets(nset),nsub,nses));
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                        filenames{end+1}=filename;
                    end
                    if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*(isub-1+(nses)/nsess)/numel(nsubs),ht);
                    else fprintf('.');
                    end
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_REG-functional-structural plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_REG-functional-structural plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
end

Iprocedure=[11,12,13,14,15];
if any(ismember(procedures,Iprocedure)) % QA_DENOISE
    try
        nprocedures=sum(ismember(procedures,1:min(Iprocedure)-1));
        nproceduresin=sum(ismember(procedures,Iprocedure));
        nsubs=validsubjects;
        filepath=CONN_x.folders.data;
        results_patch={};
        results_str={};
        results_info={};
        results_label={};
        NptsHist=100; % number of bins in histograms
        NptsScat=100; % number of bins in # vs. distance plots
        maxa=-inf;
        FC_X0=[];FC_X1=[];FC_N=[];FC_D=[];k=[];
        nl1covariates=[find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'scrubbing'),1) find(strcmp(CONN_x.Setup.l1covariates.names(1:end-1),'QC_timeseries'),1)];
        for isub=1:numel(nsubs)
            nsub=nsubs(isub);
            try
                nsess=CONN_x.Setup.nsessions(min(length(CONN_x.Setup.nsessions),nsub));
                for nses=1:nsess,
                    filename=fullfile(filepath,['ROI_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                    X1{nses}=load(filename);
                    filename=fullfile(filepath,['COV_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                    X2{nses}=load(filename);
                    filename=fullfile(filepath,['COND_Subject',num2str(nsub,'%03d'),'_Session',num2str(nses,'%03d'),'.mat']);
                    C{nses}=load(filename);
                    if ~isequal(CONN_x.Setup.conditions.names(1:end-1),C{nses}.names), error(['Incorrect conditions in file ',filename,'. Re-run previous step']); end
                    confounds=CONN_x.Preproc.confounds;
                    nfilter=find(cellfun(@(x)max(x),CONN_x.Preproc.confounds.filter));
                    if isfield(CONN_x.Preproc,'detrending')&&CONN_x.Preproc.detrending,
                        confounds.types{end+1}='detrend';
                        if CONN_x.Preproc.detrending>=2, confounds.types{end+1}='detrend2'; end
                        if CONN_x.Preproc.detrending>=3, confounds.types{end+1}='detrend3'; end
                    end
                    [X{nses},ifilter]=conn_designmatrix(confounds,X1{nses},X2{nses},{nfilter});
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2,
                        X{nses}=conn_filter(conn_get_rt(nsub,nses),CONN_x.Preproc.filter,X{nses});
                    elseif nnz(ifilter{1})
                        X{nses}(:,find(ifilter{1}))=conn_filter(max(conn_get_rt(nsub,nses)),CONN_x.Preproc.filter,X{nses}(:,find(ifilter{1})));
                    end
                    if size(X{nses},1)~=CONN_x.Setup.nscans{nsub}{nses}, error('Wrong dimensions'); end
                    iX{nses}=pinv(X{nses}'*X{nses})*X{nses}';
                    
                    x0=X1{nses}.sampledata;
                    if isfield(X1{nses},'samplexyz')&&numel(X1{nses}.samplexyz)==size(x0,2), xyz=cell2mat(X1{nses}.samplexyz);
                    else xyz=nan(3,size(x0,2));
                    end
                    x0=detrend(x0,'constant');
                    x0valid=~all(abs(x0)<1e-4,1)&~any(isnan(x0),1);
                    x0=x0(:,x0valid);
                    xyz=xyz(:,x0valid);
                    if isempty(x0),
                        conn_disp('Warning! No temporal variation in BOLD signal within sampled grey-matter voxels');
                    end
                    
                    x1=x0;
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==1,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    x1=x1-X{nses}*(iX{nses}*x1);
                    if isfield(CONN_x.Preproc,'despiking')&&CONN_x.Preproc.despiking==2,
                        my=repmat(median(x1,1),[size(x1,1),1]);
                        sy=repmat(4*median(abs(x1-my)),[size(x1,1),1]);
                        x1=my+sy.*tanh((x1-my)./max(eps,sy));
                    end
                    [x1,fy]=conn_filter(max(conn_get_rt(nsub,nses)),CONN_x.Preproc.filter,x1);
                    fy=mean(abs(fy(1:round(size(fy,1)/2),:)).^2,2);
                    dof0=size(x0,1)-1;
                    %dof=max(0,sum(fy)^2/sum(fy.^2)-size(X{nses},2)); % change dof displayed to WelchSatterthwaite residual dof approximation
                    dof1=max(0,sum(fy)^2/sum(fy.^2)); % WelchSatterthwaite residual dof approximation
                    if isfield(CONN_x.Preproc,'regbp')&&CONN_x.Preproc.regbp==2, dof2=max(0,size(x0,1)*(min(1/(2*max(conn_get_rt(nsub,nses))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(conn_get_rt(nsub,nses))))+0-size(X{nses},2));
                    elseif nnz(ifilter{1}), dof2=max(0,(size(x0,1)-size(X{nses},2)+nnz(ifilter{1}))*(min(1/(2*max(conn_get_rt(nsub,nses))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(conn_get_rt(nsub,nses))))+0-nnz(ifilter{1}));
                    else dof2=max(0,(size(x0,1)-size(X{nses},2))*(min(1/(2*max(conn_get_rt(nsub,nses))),CONN_x.Preproc.filter(2))-max(0,CONN_x.Preproc.filter(1)))/(1/(2*max(conn_get_rt(nsub,nses))))+0);
                    end
                    if any(ismember(procedures,[11,14])) % FC histogram and scatterplot
                        z0=corrcoef(x0);z1=corrcoef(x1);d0=shiftdim(sqrt(sum(abs(conn_bsxfun(@minus, xyz,permute(xyz,[1,3,2]))).^2,1)),1);
                        maskz=z0~=1&z1~=1;
                        z0=z0(maskz);z1=z1(maskz);d0=d0(maskz);
                        [a0,b0]=hist(z0(:),linspace(-1,1,NptsHist));[a1,b1]=hist(z1(:),linspace(-1,1,NptsHist));
                        maxa=max(maxa,max(max(a0),max(a1)));
                        if any(ismember(procedures,[11]))
                            if isempty(z0)||isempty(z1),
                                conn_disp('Warning! Empty correlation data');
                                results_patch={};results_info={};results_str={};results_label={};
                            else
                                results_patch={[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0]};
                                results_info=struct('units','Functional Connectivity (r)','MeanBefore',mean(z0(z0~=1)),'StdBefore',std(z0(z0~=1)),'MeanAfter',mean(z1(z1~=1)),'StdAfter',std(z1(z1~=1)),'DofBefore',dof0,'DofAfter',dof2); %'dof',dof2);
                                tstr={sprintf('FC for subject %d. session %d',nsub,nses),sprintf('FC = edge connectivity (r) in %d-node network',numel(x0valid))};
                                results_str=[tstr{1} sprintf(' before denoising: mean %f std %f; after denoising: mean %f std %f (dof=%.1f, dof_WS=%.1f)',mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof2,dof1)];
                                results_label=tstr;
                            end
                            filename=fullfile(qafolder,sprintf('QA_DENOISE.subject%03d.session%03d.mat',nsub,nses));
                            save(filename,'results_patch','results_info','results_label','results_str');
                        end
                        if any(ismember(procedures,[14]))
                            if all(isnan(d0))
                                conn_disp('Warning! Empty distance data');
                                results_patch={};results_line={};results_info={};results_str={};results_label={};
                            else
                                kpoints=floor(numel(d0)/NptsScat);
                                [nill,tidx]=sort(d0(:));
                                sd0=reshape(d0(tidx(1:kpoints*NptsScat)),kpoints,NptsScat); msd0=mean(sd0,1);ssd0=std(sd0,0,1);
                                sz0=reshape(z0(tidx(1:kpoints*NptsScat)),kpoints,NptsScat); msz0=mean(sz0,1);ssz0=std(sz0,0,1);
                                sz1=reshape(z1(tidx(1:kpoints*NptsScat)),kpoints,NptsScat); msz1=mean(sz1,1);ssz1=std(sz1,0,1);
                                results_patch={[msd0 fliplr(msd0)]', [msz1+ssz1 fliplr(msz1-ssz1)]', [msz0+ssz0 fliplr(msz0-ssz0)]'};
                                results_line={msd0', msz1', msz0'};
                                results_info=struct('units','Functional Connectivity (r)','MeanBefore',mean(z0(z0~=1)),'StdBefore',std(z0(z0~=1)),'MeanAfter',mean(z1(z1~=1)),'StdAfter',std(z1(z1~=1)),'DofBefore',dof0,'DofAfter',dof2); %'dof',dof2);
                                tstr={sprintf('FC (r mean%cstd) vs. distance (mm) for subject %d. session %d',177,nsub,nses),sprintf('FC = edge connectivity (r) in %d-node network',numel(x0valid)),sprintf('distance = edge distance (mm) in %d-node network',numel(x0valid))};
                                results_str=[tstr{1} sprintf(' before denoising: mean %f std %f; after denoising: mean %f std %f (dof=%.1f, dof_WS=%.1f)',mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)),dof2,dof1)];
                                results_label=tstr;
                            end
                            filename=fullfile(qafolder,sprintf('QA_DENOISE_scatterplot.subject%03d.session%03d.mat',nsub,nses));
                            save(filename,'results_patch','results_line','results_info','results_label','results_str');
                        end
                    end
                    
                    if any(procedures==12)&&numel(nl1covariates)>1,
                        temp=permute([x0 nan(size(x0,1),10) x1],[2,3,4,1]);
                        tdata=CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(1)}{nses}{3};
                        tdata=sum(tdata,2);
                        tdata=cat(2,CONN_x.Setup.l1covariates.files{nsub}{nl1covariates(end)}{nses}{3},tdata);
                        fh=conn_montage_display(temp,{sprintf('Subject %d Session %d   Top carpetplot: before denoising   Bottom carpetplot: after denoising',nsub,nses)},'timeseries',tdata,{'BOLD GS changes (z)','Subject motion (mm)','Outliers'});
                        fh('colormap','gray');
                        filename=fullfile(qafolder,sprintf('QA_DENOISE_timeseries.subject%03d.session%03d.jpg',nsub,nses));
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'montage_display',state};
                        save(conn_prepend('',filename,'.mat'),'conn_args');
                        fh('close');
                    end
                    
                    if any(ismember(procedures,[13,15]))
                        if numel(k)~=numel(x0valid)
                            if numel(x0valid)^2*numel(nsubs)>1e8, k=randperm(numel(x0valid))<=sqrt(1e8/numel(nsubs));
                            else k=true(size(x0valid));
                            end
                        end
                        if isempty(FC_X0),
                            FC_X0=zeros(numel(k),numel(k),numel(nsubs));
                            FC_X1=zeros(numel(k),numel(k),numel(nsubs));
                            FC_N=zeros(numel(k),numel(k),numel(nsubs));
                        end
                        if isempty(nl2covariates)
                            [x,nl2covariates]=conn_module('get','l2covariates','^QC_');
                        end
                        z0=corrcoef(x0);z1=corrcoef(x1);z0(1:size(z0,1)+1:end)=nan;z1(1:size(z1,1)+1:end)=nan;z0(z0==1)=nan;z1(z1==1)=nan;
                        if any(procedures==15)
                            if isempty(FC_D),FC_D=zeros(numel(k),numel(k),numel(nsubs));end
                            d0=shiftdim(sqrt(sum(abs(conn_bsxfun(@minus, xyz,permute(xyz,[1,3,2]))).^2,1)),1);
                            FC_D(x0valid&k,x0valid&k,isub)=FC_D(x0valid&k,x0valid&k,isub)+d0(k(x0valid),k(x0valid))/nsess;
                        end
                        FC_X0(x0valid&k,x0valid&k,isub)=FC_X0(x0valid&k,x0valid&k,isub)+z0(k(x0valid),k(x0valid));
                        FC_X1(x0valid&k,x0valid&k,isub)=FC_X1(x0valid&k,x0valid&k,isub)+z1(k(x0valid),k(x0valid));
                        FC_N(x0valid&k,x0valid&k,isub)=FC_N(x0valid&k,x0valid&k,isub)+1;
                        %z0=(z0(z0~=1));z1=(z1(z1~=1));
                    end
                end
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+nproceduresin/Nprocedures*isub/numel(nsubs),ht);
                else fprintf('.');
                end
            catch
                conn_disp('fprintf','warning: unable to create QA_DENOISE-functional plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_DENOISE plot \n %s \n',conn_qaplots_singleline(lasterr));
    end
    if any(ismember(procedures,[13,15])) % FC-QC
        [x,xnames,xdescr]=conn_module('get','l2covariates');
        x=x(nsubs,:);
        if ischar(nl2covariates)||iscell(nl2covariates), nl2covariates=find(ismember(xnames,cellstr(nl2covariates))); end
        Xnames=xnames(nl2covariates);
        FC_X0=FC_X0./max(eps,FC_N); FC_X0(FC_N==0)=nan;
        FC_X1=FC_X1./max(eps,FC_N); FC_X1(FC_N==0)=nan;
        measures={FC_X0,FC_X1};
        temp=reshape(FC_X0,[],size(FC_X0,3))';[nill,idx]=sort(rand(size(temp)),1); temp=temp(idx+repmat(size(temp,1)*(0:size(temp,2)-1),size(temp,1),1)); measures{3}=reshape(temp',size(FC_X0));
        temp=reshape(FC_X1,[],size(FC_X1,3))';[nill,idx]=sort(rand(size(temp)),1); temp=temp(idx+repmat(size(temp,1)*(0:size(temp,2)-1),size(temp,1),1)); measures{4}=reshape(temp',size(FC_X1));
        R={};D={};
        for nmeasure=1:numel(measures)
            y=measures{nmeasure};
            y=reshape(y,[],size(y,3));
            valid=find(all(~isnan(y),2));
            y=y(valid,:);
            X=x(:,nl2covariates);
            X=X-repmat(mean(X,1),size(X,1),1);
            X=X./repmat(sqrt(max(eps,sum(abs(X).^2,1))),size(X,1),1);
            Y=y';
            Y=Y-repmat(mean(Y,1),size(Y,1),1);
            Y=Y./repmat(sqrt(max(eps,sum(abs(Y).^2,1))),size(Y,1),1);
            R{nmeasure}=X'*Y;
            if any(procedures==15), D{nmeasure}=valid; end
            %[h,F,p,dof]=conn_glm([ones(size(X,1),1) X],Y,[],[],'collapse_none');
        end
        %f=conn_dir(fullfile(qafolder,'QA_DENOISE_QC-FC.*.mat'),'-R');
        %if ~isempty(f), f=cellstr(f);spm_unlink(f{:}); end
        for nm=1:numel(nl2covariates)
            z0=R{1}(nm,:);z1=R{2}(nm,:);z2=R{3}(nm,:);z3=R{4}(nm,:);
            [a0,b0]=hist(z0(:),linspace(-1,1,NptsHist));[a1,b1]=hist(z1(:),linspace(-1,1,NptsHist));[a2,b2]=hist(z2(:),linspace(-1,1,NptsHist));[a3,b3]=hist(z3(:),linspace(-1,1,NptsHist));
            maxa=max(maxa,max(max(a0),max(a1)));
            if isempty(z0)||isempty(z1),
                conn_disp('Warning! Empty correlation data');
                results_patch={};results_info={};results_str={};results_label={};
            else
                results_patch={[b1(1),b1,b1(end)],[0,a1,0],[0,a0,0],[0,a3,0],[0,a2,0]};
                results_info=struct('units','FC-QC association level (r)','MeanBefore',mean(z0(z0~=1)),'StdBefore',std(z0(z0~=1)),'IntersectionBefore',sum(min(a0/sum(a0),a2/sum(a2))),'MeanAfter',mean(z1(z1~=1)),'StdAfter',std(z1(z1~=1)),'IntersectionAfter',sum(min(a1/sum(a1),a3/sum(a3))),'dof',size(x,1)-2);
                tstr={sprintf('Association between FC and %s',Xnames{nm}),sprintf('FC-QC association (r) = across-subjects correlation between FC and QC measures; FC = edge connectivity (r) in %d-node network',numel(x0valid))};
                if numel(xdescr)>=nl2covariates(nm)&&~isempty(xdescr{nl2covariates(nm)}), tstr{end+1}=sprintf('%s = %s',Xnames{nm},xdescr{nl2covariates(nm)}); end
                results_str=[tstr{1} sprintf(' before denoising: mean %f std %f; after denoising: mean %f std %f ',mean(z0(z0~=1)),std(z0(z0~=1)),mean(z1(z1~=1)),std(z1(z1~=1)))];
                results_label=tstr;
            end
            filename=fullfile(qafolder,sprintf('QA_DENOISE_QC-FC.measure%s.mat',xnames{nl2covariates(nm)}));
            save(filename,'results_patch','results_info','results_label','results_str');
            if any(procedures==15) % FC-QC scatterplot
                if isempty(z0)||isempty(z1)
                    conn_disp('Warning! Empty distance data');
                    results_patch={};results_line={};results_info={};results_str={};results_label={};
                else
                    d0=reshape(mean(FC_D,3),1,[]);
                    z0=nan(1,numel(d0));z0(D{1})=R{1}(nm,:);
                    z1=nan(1,numel(d0));z1(D{2})=R{2}(nm,:);
                    z2=nan(1,numel(d0));z2(D{3})=R{3}(nm,:);
                    z3=nan(1,numel(d0));z3(D{4})=R{4}(nm,:);
                    [nill,tidx]=sort(d0); 
                    mask=~isnan(d0)&~isnan(z0)&~isnan(z1)&~isnan(z2)&~isnan(z3); z0(~mask)=0;z1(~mask)=0;z2(~mask)=0;z3(~mask)=0;d0(~mask)=0;
                    tidx(~mask(tidx))=[];
                    kpoints=floor(numel(tidx)/NptsScat);
                    stidx=tidx(round(linspace(1,numel(tidx),kpoints*NptsScat)));
                    smask=reshape(mask(stidx),kpoints,NptsScat); 
                    sd0=reshape(d0(stidx),kpoints,NptsScat); msd0=sum(sd0,1)./sum(smask,1);ssd0=sqrt(max(0,sum(sd0.^2,1)./sum(smask,1)-msd0.^2));
                    sz0=reshape(z0(stidx),kpoints,NptsScat); msz0=sum(sz0,1)./sum(smask,1);ssz0=sqrt(max(0,sum(sz0.^2,1)./sum(smask,1)-msz0.^2));
                    sz1=reshape(z1(stidx),kpoints,NptsScat); msz1=sum(sz1,1)./sum(smask,1);ssz1=sqrt(max(0,sum(sz1.^2,1)./sum(smask,1)-msz1.^2));
                    sz2=reshape(z2(stidx),kpoints,NptsScat); msz2=sum(sz2,1)./sum(smask,1);ssz2=sqrt(max(0,sum(sz2.^2,1)./sum(smask,1)-msz2.^2));
                    sz3=reshape(z3(stidx),kpoints,NptsScat); msz3=sum(sz3,1)./sum(smask,1);ssz3=sqrt(max(0,sum(sz3.^2,1)./sum(smask,1)-msz3.^2));
                    tr0=corrcoef(d0(mask),z0(mask));tr0=tr0(1,2);
                    tr1=corrcoef(d0(mask),z1(mask));tr1=tr1(1,2);
                    tr2=corrcoef(d0(mask),z2(mask));tr2=tr2(1,2);
                    tr3=corrcoef(d0(mask),z3(mask));tr3=tr3(1,2);
                    results_patch={[msd0 fliplr(msd0)]', [msz1+ssz1 fliplr(msz1-ssz1)]', [msz0+ssz0 fliplr(msz0-ssz0)]', [msz3+ssz3 fliplr(msz3-ssz3)]', [msz2+ssz2 fliplr(msz2-ssz2)]'};
                    results_line={msd0', msz1', msz0', msz3', msz2'};
                    results_info=struct('units','FC-QC association level (r)','CorrBefore',tr0,'CorrAfter',tr1); %'dof',dof2);
                    tstr={sprintf('FC-QC associations (r mean%cstd) vs. distance (mm)',177),...
                        sprintf('FC-QC association (r) = across-subjects correlation between FC and QC measures; FC = edge connectivity (r) in %d-node network',numel(x0valid)),...
                        sprintf('QC = %s; distance = edge distance (mm) in %d-node network',xnames{nl2covariates(nm)},numel(x0valid))};
                    results_str=[tstr{1} sprintf(' before denoising: r2 = %f; after denoising: r2 = %f',tr0^2,tr1^2)];
                    results_label=tstr;
                end
                filename=fullfile(qafolder,sprintf('QA_DENOISE_QC-FC_scatterplot.measure%s.mat',xnames{nl2covariates(nm)}));
                save(filename,'results_patch','results_line','results_info','results_label','results_str');
            end
        end
    end
end


Iprocedure=21;
if any(procedures==Iprocedure) % QA_SPM_DESIGN
    nprocedures=sum(ismember(procedures,1:Iprocedure-1));
    nsubs=validsubjects;
    pwd0=pwd;
    for isub=1:numel(nsubs)
        nsub=nsubs(isub);
        try
            fileSPM=CONN_x.Setup.spm{nsub}{1};
            if isempty(fileSPM), conn_disp('fprintf','No SPM.mat file entered for subject %d. Skipping QA plot for this subject\n',nsub); 
            else
                conn_disp('fprintf','Running QA plot generation %s\n',fileSPM);
                [pwd1,nill]=fileparts(fileSPM);
                [nill,pwd1name]=fileparts(pwd1);
                load(fileSPM,'SPM');
                clear matlabbatch;
                matlabbatch{1}.spm.stats.review.spmmat={fileSPM};
                matlabbatch{1}.spm.stats.review.display.matrix=1;
                matlabbatch{1}.spm.stats.review.print='jpg';
                spm_jobman('initcfg');
                cd(qafolder);
                if ~debugskip
                    job_id=spm_jobman('run',matlabbatch);
                end
                fname=conn_dir(['spm_' datestr(now,'yyyymmmdd') '*.jpg'],'-R');
                if size(fname,1)>=1,
                    fname2=fullfile(qafolder,sprintf('QA_SPM_design_%s.subject%03d.jpg',pwd1name,nsub));
                    fname=fliplr(deblank(fliplr(deblank(fname(end,:)))));
                    spm_unlink(fname2);
                    if ispc, [nill,nill]=system(sprintf('move "%s" "%s"',fname,fname2));
                    else [nill,nill]=system(sprintf('mv ''%s'' ''%s''',fname,fname2));
                    end
                    conn_args={'batch',@spm_DesRep,'DesRepUI',SPM};
                    save(conn_prepend('',fname2,'.mat'),'conn_args');
                end
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*isub/numel(nsubs),ht);
                else fprintf('.');
                end
            end
        catch
            conn_disp('fprintf','warning: unable to create QA_SPM-design plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
        end
    end
    cd(pwd0);
end


Iprocedure=22;
if any(procedures==Iprocedure) % QA_SPM_CONTRASTS
    nprocedures=sum(ismember(procedures,1:Iprocedure-1));
    nsubs=validsubjects;
    DOORTHOG=true;
    pwd0=pwd;
    for isub=1:numel(nsubs)
        nsub=nsubs(isub);
        try
            filesSPM=CONN_x.Setup.spm{nsub}{1};
            if isempty(filesSPM), conn_disp('fprintf','No SPM.mat file entered for subject %d. Skipping QA plot for this subject\n',nsub); 
            else
                filesSPM=cellstr(filesSPM);
                for nfile=1:numel(filesSPM)
                    fileSPM=filesSPM{nfile};
                    conn_disp('fprintf','Running QA plot generation %s\n',fileSPM);
                    [pwd1,nill]=fileparts(fileSPM);
                    [nill,pwd1name]=fileparts(pwd1);
                    load(fileSPM,'SPM');
                
                    if (isfield(SPM,'xCon')&&~isempty(SPM.xCon)) || (isfield(SPM,'xConOriginal')&&~isempty(SPM.xConOriginal))
                        sX=spm_sp('Set',SPM.xX.X);
                        if sX.rk>0, opp=sX.v(:,[1:sX.rk])*sX.v(:,[1:sX.rk])';
                        else opp=zeros( size(sX.X,2) );
                        end
                        estimablecols=max(abs(opp-speye(size(opp,1))),[],1)<= sX.tol;
                        iXX=sX.v(:,[1:sX.rk])*diag(1./sX.ds(1:sX.rk).^2)*sX.v(:,[1:sX.rk])';dof=size(SPM.xX.X,1)-sX.rk; %iXX=pinv(SPM.xX.X'*SPM.xX.X);dof=size(SPM.xX.X,1)-rank(SPM.xX.X);
                        if DOORTHOG
                            orthcols=zeros(1,size(SPM.xX.X,2));
                            for n=1:size(SPM.xX.X,2)
                                x=SPM.xX.X(:,[1:n-1,n+1:size(SPM.xX.X,2)]);
                                y=SPM.xX.X(:,n);
                                yorth=y-x*pinv(x'*x)*x'*y;
                                orthcols(n)=100*(norm(yorth)/max(eps,norm(y))).^2;
                            end
                        end
                        sizecols=estimablecols'./max(eps,sqrt(diag(iXX)));  % C*pinv(X'*X)*(X'*(X*C')) / sqrt(C*pinv(X'*X)*C')
                        cd(qafolder);
                        for nplot=1,%:2
                            if nplot==1 && (isfield(SPM,'xCon')&&~isempty(SPM.xCon)), ncons=numel(SPM.xCon); connames={SPM.xCon.name};
                            elseif nplot==2 && (isfield(SPM,'xConOriginal')&&~isempty(SPM.xConOriginal)), ncons=numel(SPM.xConOriginal); connames={SPM.xConOriginal.name};
                            else ncons=0;
                            end
                            if ncons
                                estimablecons=false(1,ncons);sizecons=zeros(1,ncons);
                                A=[];iA=[];jA=[];
                                for nc=1:ncons
                                    if nplot==1, c=SPM.xCon(nc).c;
                                    elseif nplot==2, c=SPM.xConOriginal(nc).c;
                                    end
                                    if size(c,2)==1
                                        jA=[jA;nc];
                                        idx=find(any(c,2));
                                        iA=[iA;setdiff(idx(:),iA)];
                                        [i1,i2]=ismember(iA,idx);
                                        A(nc,i1)=sum(c(idx(i2(i1)),:),2)';
                                        estimablecons(nc)=all(all(abs(opp*c - c) <= sX.tol));
                                        k=max([sum(c(c>0)) -sum(c(c<0)) abs(sum(c))]);
                                        sizecons(nc)=estimablecons(nc)*k/max(eps,sqrt(c'*iXX*c)); %sizecons(nc)=sqrt((c'*c)/(c'*iXX*c));
                                        if DOORTHOG
                                            x=SPM.xX.X*null(c');
                                            y=SPM.xX.X*c;
                                            yorth=y-x*pinv(x'*x)*x'*y;
                                            orthcons(nc)=100*(norm(yorth)/max(eps,norm(y))).^2;
                                        end
                                    end
                                end
                                [nill,idx]=sort(0*sum(A,1)'+1e-6*iA(:)); iA=iA(idx);A=A(:,idx);
                                A=A(jA,:); Aall=sum(A,2); Apos=sum(A.*(A>0),2); Aneg=sum(A.*(A<0),2);
                                ytickval=unique(round(linspace(1,size(A,1),50))); xtickval=unique(round(linspace(1,size(A,2),20)));
                                
                                hfig=figure('units','norm','position',[.1 .3 .8 .6],'color','w','menubar','none');
                                cmap=.5+.5*jet(255);cmap(128,:)=[1 1 1];colormap(cmap);
                                axes('units','norm','position',[.15 .4 .25 .5]);
                                conn_menu_plotmatrix(.8*A/max(abs(A(:))),'colormapcdata',round(128+127*(A/max(abs(A(:))))),'colormap',cmap,'shape','hdo'); set(gca,'ydir','reverse');
                                axis equal;
                                %conn_menu_plotmatrix(.8*A/max(abs(A(:))),'scalesigned',1); set(gca,'ydir','reverse');
                                %h=imagesc(A);
                                %hold on;[i,j]=find(A); plot(repmat(j(:)',5,1)+repmat([-.5 -.5 .5 .5 -.5]',1,numel(j)), repmat(i(:)',5,1)+repmat([-.5 .5 .5 -.5 -.5]',1,numel(i)), 'k-'); hold off;
                                set(gca,'clim',max(.01,max(abs(A(:))))*[-1 1],'ytick',ytickval,'yticklabel',[],'xtick',xtickval,'xticklabel',[],'xlim',[.5 size(A,2)+.5], 'ylim',[.5 size(A,1)+.5]);
                                hold on; text(xtickval,1.05*(size(A,1)+.5)*ones(1,numel(xtickval)),regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''),'rotat',-90,'horizontalalignment','left','interpreter','none'); hold off;
                                txtnill=regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''); [txtnill{estimablecols(iA(xtickval))}]=deal(''); hold on; text(xtickval,1.05*(size(A,1)+.5)*ones(1,numel(xtickval)),txtnill,'rotat',-90,'horizontalalignment','left','interpreter','none','backgroundcolor','y'); hold off;
                                hold on; text(.5-.05*ones(1,numel(ytickval))*size(A,2),ytickval,connames(jA(ytickval)),'horizontalalignment','right','interpreter','none'); hold off;
                                txtnill=connames(jA(ytickval)); [txtnill{estimablecons(jA(ytickval))}]=deal(''); hold on; text(.5-.05*ones(1,numel(ytickval))*size(A,2),ytickval,txtnill,'horizontalalignment','right','interpreter','none','backgroundcolor','k','color','w'); hold off;
                                txt=arrayfun(@(a,b,c)sprintf('warning: scale = %s',mat2str(.1*round(10*setdiff(unique([a,b,c]),[0])))),Aall,Apos,Aneg,'uni',0);
                                txtnill=ismember(round(Aall*1e3)/1e3,[0,1])&ismember(round(Apos*1e3)/1e3,[0,1])&ismember(round(-Aneg*1e3)/1e3,[0,1]);
                                if any(txtnill), txt(txtnill)=repmat({''},1,nnz(txtnill)); end
                                hold on; h=text(mean(xtickval)*ones(1,size(A,1)),1:size(A,1),txt,'color','k','rotat',0,'horizontalalignment','center','interpreter','none','fontweight','bold'); hold off; set(h,'fontsize',ceil(get(h(1),'fontsize')*.8));
                                grid on;
                                hax=gca;
                                h=colorbar; try, set(h,'color',.5*[1 1 1],'box','off'); end
                                hold on; text(mean(xtickval),.5-.1*(size(A,1)+.5),'CONTRAST DEFINITIONS','horizontalalignment','center','fontsize',14,'fontweight','bold'); hold off;
                                
                                axes('units','norm','position',[.5 .4 .20 .2]);
                                %axes('units','norm','position',[.65 .65 .3 .25]);
                                h=bar(sizecols(iA(xtickval))); set(h,'facecolor',.85*[1 1 1]);
                                ylim=1.1*max([1,max(sizecols(iA(xtickval))),max(sizecons(jA(ytickval)))]); %ylim=1.1*max(1,max(sizecols(iA(xtickval))));
                                hold on; text(xtickval,-.05*ylim*ones(1,numel(xtickval)),regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''),'rotat',-90,'horizontalalignment','left','interpreter','none'); hold off;
                                txtnill=regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''); [txtnill{estimablecols(iA(xtickval))}]=deal(''); hold on; text(xtickval,-.05*ylim*ones(1,numel(xtickval)),txtnill,'rotat',-90,'horizontalalignment','left','interpreter','none','backgroundcolor','k','color','w'); hold off;
                                set(gca,'xlim',[0,max(xtickval)+1],'xtick',[],'ylim',[0 ylim],'box','off','xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1]);
                                grid on;
                                hold on; text(mean(xtickval),ylim*1.1,'EFFECT ESTIMABILITY','horizontalalignment','center','fontsize',14,'fontweight','bold'); hold off;
                                h=ylabel('T-statistic @ SNR=1'); set(h,'fontsize',10,'rotation',90,'color',.5*[1 1 1]);
                                
                                axes('units','norm','position',[.75 .4 .20 .2]);
                                %axes('units','norm','position',[.2 .2 .3 .25]);
                                h=bar(sizecons(jA(ytickval))); set(h,'facecolor',.85*[1 1 1]);
                                ylim=1.1*max([1,max(sizecols(iA(xtickval))),max(sizecons(jA(ytickval)))]); %ylim=1.1*max(1,max(sizecons(jA(ytickval))));
                                hold on; text(ytickval,-.05*ylim*ones(1,numel(ytickval)),connames(jA(ytickval)),'rotat',-90,'horizontalalignment','left','interpreter','none'); hold off;
                                txtnill=connames(jA(ytickval)); [txtnill{estimablecons(jA(ytickval))}]=deal(''); hold on; text(ytickval,-.05*ylim*ones(1,numel(ytickval)),txtnill,'rotat',-90,'horizontalalignment','left','interpreter','none','backgroundcolor','k','color','w'); hold off;
                                set(gca,'xlim',[0,max(ytickval)+1],'xtick',[],'ylim',[0 ylim],'box','off','xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1]);
                                grid on;
                                hold on; text(mean(ytickval),ylim*1.1,'CONTRAST ESTIMABILITY','horizontalalignment','center','fontsize',14,'fontweight','bold'); hold off;
                                
                                if DOORTHOG
                                    axes('units','norm','position',[.5 .7 .20 .2]);
                                    %axes('units','norm','position',[.65 .65 .3 .25]);
                                    h=bar(orthcols(iA(xtickval))); set(h,'facecolor',.85*[1 1 1]);
                                    ylim=1.1*100;%max(1,max(orthcols(iA(xtickval))));
                                    %hold on; text(xtickval,-.05*ylim*ones(1,numel(xtickval)),regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''),'rotat',-90,'horizontalalignment','left','interpreter','none'); hold off;
                                    %txtnill=regexprep(SPM.xX.name(iA(xtickval)),'\*bf\(1\)$',''); [txtnill{estimablecols(iA(xtickval))}]=deal(''); hold on; text(xtickval,-.05*ylim*ones(1,numel(xtickval)),txtnill,'rotat',-90,'horizontalalignment','left','interpreter','none','backgroundcolor','k','color','w'); hold off;
                                    set(gca,'xlim',[0,max(xtickval)+1],'xtick',[],'ylim',[0 ylim],'box','off','xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1]);
                                    grid on;
                                    hold on; text(mean(xtickval),ylim*1.1,'EFFECT ORTHOGONALITY','horizontalalignment','center','fontsize',14,'fontweight','bold'); hold off;
                                    h=ylabel('percent variance'); set(h,'fontsize',10,'rotation',90,'color',.5*[1 1 1]);
                                    try, ytick=get(gca,'ytick'); yticklabel=cellstr(get(gca,'yticklabel')); set(gca,'ytick',ytick,'yticklabel',cellfun(@(x)[x,'%'],yticklabel,'uni',0)); end
                                    
                                    axes('units','norm','position',[.75 .7 .20 .2]);
                                    %axes('units','norm','position',[.2 .2 .3 .25]);
                                    h=bar(orthcons(jA(ytickval))); set(h,'facecolor',.85*[1 1 1]);
                                    ylim=1.1*100;%max(1,max(orthcons(ytickval)));
                                    %hold on; text(ytickval,-.05*ylim*ones(1,numel(ytickval)),connames(ytickval),'rotat',-90,'horizontalalignment','left','interpreter','none'); hold off;
                                    %txtnill=connames(ytickval); [txtnill{estimablecons(ytickval)}]=deal(''); hold on; text(ytickval,-.05*ylim*ones(1,numel(ytickval)),txtnill,'rotat',-90,'horizontalalignment','left','interpreter','none','backgroundcolor','k','color','w'); hold off;
                                    set(gca,'xlim',[0,max(ytickval)+1],'xtick',[],'ylim',[0 ylim],'box','off','xcolor',.5*[1 1 1],'ycolor',.5*[1 1 1]);
                                    grid on;
                                    hold on; text(mean(ytickval),ylim*1.1,'CONTRAST ORTHOGONALITY','horizontalalignment','center','fontsize',14,'fontweight','bold'); hold off;
                                    try, ytick=get(gca,'ytick'); yticklabel=cellstr(get(gca,'yticklabel')); set(gca,'ytick',ytick,'yticklabel',cellfun(@(x)[x,'%'],yticklabel,'uni',0)); end
                                end
                                
                                if any(~estimablecols(iA))||any(~estimablecons(jA))
                                    axes('units','norm','position',[.05 .05 .1 .1]);
                                    hold on; text(1,.5,'estimable contrasts/effects','horizontalalignment','left'); hold off;
                                    hold on; text(1,-.5,'non-estimable contrasts/effects','horizontalalignment','left','backgroundcolor','k','color','w'); hold off;
                                    set(gca,'xlim',[0 2],'ylim',[-1 1],'xtick',[],'ytick',[]); axis off; %,'box','on');
                                end
                                
                                %axes('units','norm','position',[.35 .80 .5 .05]);
                                %imagesc(repmat(reshape(estimablecons,1,[]),[1,1,3]));
                                %set(gca,'xtick',[],'ytick',[],'box','on','position',[.35 .80 0 .05]+get(hax,'position').*[0 0 1 0]);
                                %hax1=gca;
                                %h=title('Contrasts estimability'); set(h,'fontweight','normal');
                                %h=xlabel('(white = ok; black = non-estimable)'); set(h,'fontsize',ceil(get(h,'fontsize')/2));
                                %axes('units','norm','position',[.05 .35 .02 .3]);
                                %imagesc(repmat(reshape(estimablecols(iA),[],1),[1,1,3]));
                                %set(gca,'ytick',[],'xtick',[],'box','on');
                                %hax2=gca;
                                %h=ylabel('Parameters estimability'); set(h,'fontweight','normal');
                                
                                if nplot==1, fname=sprintf('QA_SPM_contrasts_%s.subject%03d.jpg',pwd1name,nsub); %fname='QA_SPM_contrasts.jpg';
                                elseif nplot==2, fname=sprintf('QA_SPM_contrasts_alloriginalcontrasts_%s.subject%03d.jpg',pwd1name,nsub); %fname='QA_SPM_contrasts_alloriginalcontrasts.jpg';
                                end
                                
                                conn_print(hfig,fullfile(qafolder,fname),'-nogui','-noerror',dpires,'-nopersistent');
                                conn_args={'image_display',fname};
                                opts={'forcecd'};
                                save(conn_prepend('',fullfile(qafolder,fname),'.mat'),'conn_args','opts');
                                
                                fh=fopen(conn_prepend('',fullfile(qafolder,fname),'.txt'),'wt');
                                if all(estimablecons(jA)), fprintf(fh,'All Contrasts are estimable\n');
                                else fprintf(fh,'List of non-estimable contrasts:\n'); for nc=find(~estimablecons(jA)), fprintf(fh,'%s\n',connames{jA(nc)}); end
                                end
                                if all(estimablecols(iA)), fprintf(fh,'All Design Matrix columns are estimable\n');
                                else fprintf(fh,'List of non-estimable effects:\n'); for nc=find(~estimablecols(iA)), fprintf(fh,'%s\n',SPM.xX.name{iA(nc)}); end
                                end
                                fclose(fh);
                                if ishandle(hfig), delete(hfig); end
                            end
                        end
                        cd(pwd0);
                    else conn_disp('fprintf','No contrasts defined. Skipping file %s\n',fileSPM);
                    end
                end
            end
        catch
            conn_disp('fprintf','warning: unable to create QA_SPM-contrast plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
        end
    end
    cd(pwd0);
end    
    
Iprocedure=23;
if any(procedures==Iprocedure) % QA_SPM_RESULTS
    nprocedures=sum(ismember(procedures,1:Iprocedure-1));
    nsubs=validsubjects;
    pwd0=pwd;
    for isub=1:numel(nsubs)
        nsub=nsubs(isub);
        try
            fileSPM=CONN_x.Setup.spm{nsub}{1};
            if isempty(fileSPM), conn_disp('fprintf','No SPM.mat file entered for subject %d. Skipping QA plot for this subject\n',nsub); 
            else
                conn_disp('fprintf','Running QA plot generation %s\n',fileSPM);
                [pwd1,nill]=fileparts(fileSPM);
                [nill,pwd1name]=fileparts(pwd1);
                load(fileSPM,'SPM');
                
                if isfield(SPM,'xCon')&&~isempty(SPM.xCon)&&isfield(SPM.xCon,'Vcon')
                    if isempty(nl1contrasts), nl1contrasts=1; end
                    if ischar(nl1contrasts), [ok,nl1contrasts]=ismember(nl1contrasts,{SPM.xCon.name}); end
                    if nl1contrasts<1||nl1contrasts>numel(SPM.xCon), nl1contrasts=listdlg('liststring',{SPM.xCon.name},'selectionmode','single','initialvalue',1,'promptstring',{'Select contrast to display'},'ListSize',[400 150]); end
                    filecon=fullfile(pwd1,SPM.xCon(nl1contrasts).Vcon.fname);
                    filename=fullfile(qafolder,sprintf('QA_SPM_results_%s_%s.subject%03d.jpg',pwd1name,regexprep(SPM.xCon(nl1contrasts).name,'[^\w-_]',''),nsub));                    
                    if conn_surf_dimscheck(SPM.xCon(nl1contrasts).Vcon) % surface
                        fh=conn_mesh_display(filecon,[],[],[],[],nan);
                        fh('print',4,filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'mesh_display',state};
                    else % volume
                        fh=conn_slice_display(filecon,CONN_x.Setup.structural{nsub}{1}{1},[],nan);
                        fh('multisliceset',1,nslices,dslices);
                        fh('togglegui',1);
                        fh('print',filename,'-nogui','-noerror',dpires,'-nopersistent');
                        state=fh('getstate');
                        conn_args={'slice_display',state};
                    end
                    save(conn_prepend('',filename,'.mat'),'conn_args');
                    fh('close');
                    filenames{end+1}=filename;
                else conn_disp('fprintf','No contrasts defined. Skipping file %s\n',fileSPM);
                end
            end
        catch
            conn_disp('fprintf','warning: unable to create QA_SPM-contrast plot for subject %d\n%s\n',nsub,conn_qaplots_singleline(lasterr));
        end
    end
    cd(pwd0);
end    


Iprocedure=31;
if any(procedures==Iprocedure) % QA_COV
    pwd0=pwd;
    try
        nprocedures=sum(ismember(procedures,1:Iprocedure-1));
        nsubs=validsubjects;
        assert(numel(nsubs)>0);
        if isempty(nl2covariates), [x,nl2covariates]=conn_module('get','l2covariates','^QC_'); end
        [x,xnames,xdescr]=conn_module('get','l2covariates');
        if ischar(nl2covariates)||iscell(nl2covariates), nl2covariates=find(ismember(xnames,cellstr(nl2covariates))); end
        if ~isempty(nl2covariates)
            X=x(nsubs,nl2covariates);
            Xnames=xnames(nl2covariates);
            Xdescr=xdescr(nl2covariates);
            if ~isequal(nsubs,1:CONN_x.Setup.nsubjects)||numel(nsubs)==1
                for isub=1:numel(nsubs)
                    filename=fullfile(qafolder,sprintf('QA_COV.subject%03d.mat',nsubs(isub)));
                    results_info=struct('Values',X(isub,:),'Subjects',nsubs(isub),'Variables',{Xnames},'Variables_descr',{Xdescr});
                    save(filename,'results_info');
                end
                if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures,ht);
                else fprintf('.');
                end
            else
                conn_qaplots_covupdate(X,Xnames,Xdescr,nsubs,qafolder,ht,nprocedures/Nprocedures,1/Nprocedures);
                %             sx=sort(X,1); IQ=interp1(linspace(0,1,size(sx,1))',sx,[.25 .5 .75]'); IQR=max(1e-10,IQ(3,:)-IQ(1,:)); IQL=[IQ(1,:)-1.5*IQR; IQ(3,:)+1.5*IQR]; IQ=[IQL(1,:);IQ;IQL(2,:)];
                %             Ka=-IQL(1,:)./max(eps,IQL(2,:)-IQL(1,:));
                %             Kb=1./max(eps,IQL(2,:)-IQL(1,:));
                %             Xdisp=repmat(Ka,size(X,1),1)+repmat(Kb,size(X,1),1).*X; % scale to same IQR across all measures, all values between 0 and 1
                %             IQdisp=repmat(Ka,size(IQ,1),1)+repmat(Kb,size(IQ,1),1).*IQ;
                %             kt=min([Xdisp(:);IQdisp(:)]); if kt<0, Ka=Ka-kt; Xdisp=repmat(Ka,size(X,1),1)+repmat(Kb,size(X,1),1).*X; IQdisp=repmat(Ka,size(IQ,1),1)+repmat(Kb,size(IQ,1),1).*IQ; end
                %             kt=max([Xdisp(:);IQdisp(:)]); if kt>1, Ka=Ka/kt; Kb=Kb/kt; Xdisp=repmat(Ka,size(X,1),1)+repmat(Kb,size(X,1),1).*X; IQdisp=repmat(Ka,size(IQ,1),1)+repmat(Kb,size(IQ,1),1).*IQ; end
                %             Npts=200;
                %             hx=linspace(-.1,1.1,Npts)';
                %             py=zeros([Npts,size(Xdisp)]); for ny=1:size(Xdisp,2), py(:,:,ny)=exp(-.5*(repmat(hx,1,size(Xdisp,1))-repmat(Xdisp(:,ny)',Npts,1)).^2/.002); end
                %             hy=cumsum(py,2);
                %             hy=permute(cat(2,-hy(:,end,:),2*hy-repmat(hy(:,end,:),[1,size(hy,2),1])),[1,3,2]);
                %             py=permute(py./repmat(max(eps,sum(py,1)),size(py,1),1),[1,3,2]);
                %             Hdisp=.45*hy./repmat(max(eps,max(max(hy,[],1),[],3)),[size(hy,1),1,size(hy,3)]);
                %             for isub=1:numel(nsubs)
                %                 nsub=nsubs(isub);
                %                 Xthis=X(isub,:);
                %                 Xdispthis=Xdisp(isub,:);
                %                 results_patch={[Hdisp(:,:,end);flipud(Hdisp(:,:,1))]+repmat(1:size(Hdisp,2),2*size(Hdisp,1),1), repmat([hx;flipud(hx)],1,size(Hdisp,2))};
                %                 results_line={(1:size(Hdisp,2))+.95*sum(py(:,:,isub).*(Hdisp(:,:,isub+1)+Hdisp(:,:,isub))/2,1),Xdispthis};
                %                 results_info=struct('Values',Xthis,'ValuesDisplay',Xdispthis,'Interquartiles',IQ,'InterquartilesDisplay',IQdisp,'Subjects',nsubs,'Variables',{Xnames},'Variables_descr',{Xdescr});
                %                 results_label={{sprintf('Subject %d',nsub)}}; for n1=1:numel(Xthis), results_label{1}{1+n1}=sprintf('%s = %s',Xnames{n1},num2str(Xthis(n1))); end
                %                 results_str={};
                %                 filename=fullfile(qafolder,sprintf('QA_COV.subject%03d.mat',nsub));
                %                 save(filename,'results_patch','results_line','results_info','results_label','results_str');
                %                 if ~nargout, conn_waitbar(nprocedures/Nprocedures+1/Nprocedures*isub/numel(nsubs),ht);
                %                 else fprintf('.');
                %                 end
                %             end
            end
        end
    catch
        conn_disp('fprintf','warning: unable to create QA_COV plot\n%s\n',conn_qaplots_singleline(lasterr));
    end
    cd(pwd0);
end

if ~nargout, conn_waitbar('close',ht);
else fprintf('\n');
end
if Nprocedures, conn_disp('fprintf','QA plots stored in folder %s\n',qafolder); end
end

function str=conn_qaplots_singleline(str)
str=cellstr(char(str));
str=sprintf('%s ',str{:});
str=regexprep(str,'\n',' ');
end

