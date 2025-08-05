function ocov=conn_convertl12l1covariate(option,varargin)
% CONN_CONVERTL12L1COVARIATE
%  misc. transformations of first-level covariates
%
%  conn_convertl12l1covariate('FD_jenkinson' [,R,xc,opt,icov,ocov])
%    Computes Framewise Displacement, Jenkinson definition ("RMS deviation" measure in Jenkinson et al. 1999; FSL implementation)
%    Creates 'QC_FDjenkinson' covariate from 'realignment' covariate (note: assumes input 'realignment' covariate follows SPM-convention, 3 translation (mm) + 3 rotation (radians) parameters)
%    Parameters:
%           R:   sphere radius (in mm) [80]
%           xc:  sphere center coordinates (in mm) [0;0;0]
%           opt: 'rel'|'abs' relative/absolute deviation measures ['rel']
%                   rel: RMS deviation between each pair of two consecutive scans  
%                   abs: RMS deviation between each scan and first-scan in same run/session
%
%  conn_convertl12l1covariate('FD_power' [,R,opt,icov,ocov])
%    Computes Framewise Displacement, Power definition (Power et al. 2012; C-PAC implementation)
%    Creates 'QC_FDpower' covariate from 'realignment' covariate (note: assumes input 'realignment' covariate follows SPM-convention, 3 translation (mm) + 3 rotation (radians) parameters)
%    Parameters:
%           R:   sphere radius (in mm) [50]
%           opt: 'rel'|'abs' relative/absolute deviation measures ['rel']
%                   rel: difference between each pair of two consecutive scans  
%                   abs: difference between each scan and first-scan in same run/session
%
%  conn_convertl12l1covariate('FD_conn' [,bb,opt,icov,ocov])
%    Computes Framewise Displacement, ART/CONN definition (maximum displacement across 6 control points placed at center of each face of brain bounding box; ART/CONN implementation)
%    Creates 'QC_FDconn' covariate from 'realignment' covariate (note: assumes input 'realignment' covariate follows SPM-convention, 3 translation (mm) + 3 rotation (radians) parameters)
%    Parameters:
%           bb:   bounding box (in mm) [-70,-110,-45;70,70,75]
%           opt: 'rel'|'abs' relative/absolute deviation measures ['rel']
%                   rel: difference between each pair of two consecutive scans  
%                   abs: difference between each scan and first-scan in same run/session
%
%  conn_convertl12l1covariate('scrubbing' [,thr,ext,icov,ocov])
%    Creates 'scrubbing' covariate from 'QC_timeseries' covariate (note: assumes input 'QC_timeseries' covariate contains scan-to-scan BOLD-signal change timeseries and scan-to-scan Framewise Displacement change timeseries)
%    Parameters:
%           icov:  name of original (unthresholded) covariate ['QC_timeseries']
%           thr:   thresholds [5 0.9] (e.g. when using ART QC_timeseries input covariate: conservative=[3 0.5]; intermediate=[5 0.9]; liberal=[9 2])
%           ext:   label a total of 2*ext outliers around each identified scan-to-scan suprathreshold value [1]
%

ocov='';
if ~nargin
    opts={'Compute ''FD_conn'': Framewise Displacement (ART/CONN definition)','Compute ''FD_jenkinson'': Framewise Displacement (FSL definition)','Compute ''FD_power'': Framewise Displacement (Power 2012 definition)','Compute ''scrubbing'': thresholded list-of-outliers covariate'};
    answ=conn_questdlg('','Available first-level covariate transformations:',opts{[1:numel(opts),1]});
    if isempty(answ), return; end
    switch(answ)
        case opts{1}, % FD_conn 
            fields={'Bounding box (mm)','compare to previous- (rel) or first- (abs) scan','Name of input first-level covariate','Name of output first-level covariate'};
            values={'[-70,-110,-45; 70,70,75]','rel','realignment','QC_FDconn'};
            answ=inputdlg(fields,'FD_conn options',1,values,struct('Resize','on'));
            if numel(answ)~=numel(fields)||isempty(answ{1}),return; end
            answ(1)=cellfun(@str2num,answ(1),'uni',0);
            ocov=conn_convertl12l1covariate('FD_conn',answ{:});
        case opts{2}, % FD_jenkinson
            fields={'Sphere radius (mm)','Sphere center (mm)','compare to previous- (rel) or first- (abs) scan','Name of input first-level covariate','Name of output first-level covariate'};
            values={'80','0;0;0','rel','realignment','QC_FDjenkinson'};
            answ=inputdlg(fields,'FD_jenkinson options',1,values,struct('Resize','on'));
            if numel(answ)~=numel(fields)||isempty(answ{1}),return; end
            answ(1:2)=cellfun(@str2num,answ(1:2),'uni',0);
            ocov=conn_convertl12l1covariate('FD_jenkinson',answ{:});
        case opts{3}, % FD_power
            fields={'Sphere radius (mm)','compare to previous- (rel) or first- (abs) scan','Name of input first-level covariate','Name of output first-level covariate'};
            values={'50','rel','realignment','QC_FDpower'};
            answ=inputdlg(fields,'FD_power options',1,values,struct('Resize','on'));
            if numel(answ)~=numel(fields)||isempty(answ{1}),return; end
            answ(1)=cellfun(@str2num,answ(1),'uni',0);
            ocov=conn_convertl12l1covariate('FD_power',answ{:});
        case opts{4}, % scrubbing
            fields={'Threshold values for each input covariate timeseries (e.g. [5 0.9] intermediate; [3 0.5] conservative)','Window-size around each supra-threshold value (scans)','Name of input first-level covariate(s)','Name of output first-level covariate'};
            values={'[5 0.9]','1','QC_timeseries','scrubbing'};
            answ=inputdlg(fields,'scrubbing options',1,values,struct('Resize','on'));
            if numel(answ)~=numel(fields)||isempty(answ{1}),return; end
            answ(1:2)=cellfun(@str2num,answ(1:2),'uni',0);
            ocov=conn_convertl12l1covariate('scrubbing',answ{:});
    end
    return
end

switch(lower(option))
    case {'fd_conn','fdconn','fd_art','fdart'}
        if numel(varargin)<1||isempty(varargin{1}), bb=[-70,-110,-45;70,70,75]; else bb=varargin{1}; end
        if numel(varargin)<2||isempty(varargin{2}), opt='rel'; else opt=varargin{2}; end        
        if numel(varargin)<3||isempty(varargin{3}), icov='realignment'; else icov=varargin{3}; end
        if numel(varargin)<4||isempty(varargin{4}), ocov='QC_FDconn'; else ocov=varargin{4}; end

        assert(ismember(opt,{'rel','abs'}),'incorrect input %s (expected abs|rel)',opt);
        conn_disp('fprintf','compute %s\n Bounding-Box=%s\n Measure=%s\n Input=%s\n Output=%s\n',option,mat2str(bb),opt,icov,ocov);
        f=conn_module('get','l1covariates',icov);
        assert(~isempty(f),'missing first-level covariate ''%s''',icov);
        fout={};
        resneg=diag(bb(1,:));
        respos=diag(bb(2,:));
        res=[respos,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1); % 6 control points: [+x,+y,+z,-x,-y,-z];
            zeros(3,4),respos,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
            zeros(3,4),zeros(3,4),respos,zeros(3,1),eye(3),zeros(3,1);
            resneg,zeros(3,1),zeros(3,4),zeros(3,4),eye(3),zeros(3,1);
            zeros(3,4),resneg,zeros(3,1),zeros(3,4),eye(3),zeros(3,1);
            zeros(3,4),zeros(3,4),resneg,zeros(3,1),eye(3),zeros(3,1);];
        for nsub=1:numel(f)
            for nses=1:numel(f{nsub})
                filename=f{nsub}{nses};
                data=load(filename);
                if isstruct(data), tempnames=fieldnames(data); data=data.(tempnames{1}); end
                T1=reshape(reshape(spm_matrix(data(1,:)),1,[])*res',3,6);
                e=zeros(size(data,1),1);
                for n=1:size(data,1)
                    T2=reshape(reshape(spm_matrix(data(n,:)),1,[])*res',3,6);
                    e(n)=max(sqrt(sum(abs(T2-T1).^2,1)),[],2);
                    if strcmp(opt,'rel'), T1=T2; end
                end
                out=conn_prepend([ocov,'_'],filename,'.mat');
                R=e; save(out,'R');
                conn_disp('fprintf','created file %s\n',out);
                fout{nsub}{nses}=out;
            end
        end
        conn_module('set','l1covariates',fout,ocov,'add');       
        
    case {'fd_jenkinson','fdjenkinson'}
        if numel(varargin)<1||isempty(varargin{1}), Radius=80; else Radius=varargin{1}; end
        if numel(varargin)<2||isempty(varargin{2}), xc=[0;0;0]; else xc=varargin{2}; end
        if numel(varargin)<3||isempty(varargin{3}), opt='rel'; else opt=varargin{3}; end
        if numel(varargin)<4||isempty(varargin{4}), icov='realignment'; else icov=varargin{4}; end
        if numel(varargin)<5||isempty(varargin{5}), ocov='QC_FDjenkinson'; else ocov=varargin{5}; end
        
        assert(ismember(opt,{'rel','abs'}),'incorrect input %s (expected abs|rel)',opt);
        assert(numel(xc)==3,'incorrect input %s (expected 3 values)',mat2str(xc));
        conn_disp('fprintf','compute %s\n Radius=%f\n Center=%s\n Measure=%s\n Input=%s\n Output=%s\n',option,Radius,mat2str(xc),opt,icov,ocov);
        f=conn_module('get','l1covariates',icov);
        assert(~isempty(f),'missing first-level covariate ''%s''',icov);
        fout={};
        for nsub=1:numel(f)
            for nses=1:numel(f{nsub})
                filename=f{nsub}{nses};
                data=load(filename);
                if isstruct(data), tempnames=fieldnames(data); data=data.(tempnames{1}); end
                T1=spm_matrix(data(1,:));
                iT1=pinv(T1);
                e=zeros(size(data,1),1);
                for n=1:size(data,1)
                    if strcmp(opt,'rel'), iT1=pinv(T1); end
                    T2=spm_matrix(data(n,:));
                    M=T2*iT1-eye(4);
                    A=M(1:3,1:3);
                    t=M(1:3,4);
                    e(n)=sqrt(1/5*Radius^2*trace(A'*A)+(t+A*xc(:))'*(t+A*xc(:)));
                    T1=T2;
                end
                out=conn_prepend([ocov,'_'],filename,'.mat');
                R=e; save(out,'R');
                conn_disp('fprintf','created file %s\n',out);
                fout{nsub}{nses}=out;
            end
        end
        conn_module('set','l1covariates',fout,ocov,'add');
        
    case {'fd_power','fdpower'}
        if numel(varargin)<1||isempty(varargin{1}), Radius=50; else Radius=varargin{1}; end
        if numel(varargin)<2||isempty(varargin{2}), opt='rel'; else opt=varargin{2}; end
        if numel(varargin)<3||isempty(varargin{3}), icov='realignment'; else icov=varargin{3}; end
        if numel(varargin)<4||isempty(varargin{4}), ocov='QC_FDpower'; else ocov=varargin{4}; end
        
        assert(ismember(opt,{'rel','abs'}),'incorrect input %s (expected abs|rel)',opt);
        conn_disp('fprintf','compute %s\n Radius=%f\n Measure=%s\n Input=%s\n Output=%s\n',option,Radius,opt,icov,ocov);
        f=conn_module('get','l1covariates',icov);
        assert(~isempty(f),'missing first-level covariate ''%s''',icov);
        fout={};
        for nsub=1:numel(f)
            for nses=1:numel(f{nsub})
                filename=f{nsub}{nses};
                data=load(filename);
                if isstruct(data), tempnames=fieldnames(data); data=data.(tempnames{1}); end
                T1=data(1,:);
                e=zeros(size(data,1),1);
                for n=1:size(data,1)
                    T2=data(n,:);
                    D=T2-T1;
                    e(n)=sum(abs(D(1:3)))+Radius*sum(abs(D(4:6)));
                    if strcmp(opt,'rel'), T1=T2; end
                end
                out=conn_prepend([ocov,'_'],filename,'.mat');
                R=e; save(out,'R');
                conn_disp('fprintf','created file %s\n',out);
                fout{nsub}{nses}=out;
            end
        end
        conn_module('set','l1covariates',fout,ocov,'add');
        

    case {'scrubbing'}
        if numel(varargin)<1||isempty(varargin{1}), thr=[5 0.9]; else thr=varargin{1}; end
        if numel(varargin)<2||isempty(varargin{2}), ext=1; else ext=varargin{2}; end
        if numel(varargin)<3||isempty(varargin{3}), icov='QC_timeseries'; else icov=varargin{3}; end
        if numel(varargin)<4||isempty(varargin{4}), ocov='scrubbing'; else ocov=varargin{4}; end

        conn_disp('fprintf','compute %s\n thr=%s\n extension=%d\n Input=%s\n Output=%s\n',option,mat2str(thr),ext,icov,ocov);
        if ~isempty(regexp(icov,',')), 
            icov=regexp(icov,'\s*,\s*','split'); 
        else icov={icov};
        end
        for ncov=1:numel(icov)
            f{ncov}=conn_module('get','l1covariates',icov{ncov});
            assert(~isempty(f{ncov}),'missing first-level covariate ''%s''',icov{ncov});
        end
        fout={};
        for nsub=1:numel(f{1})
            for nses=1:numel(f{1}{nsub})
                data=[];
                for ncov=1:numel(icov)
                    filename=f{ncov}{nsub}{nses};
                    tdata=load(filename);
                    if isstruct(tdata), tempnames=fieldnames(tdata); tdata=tdata.(tempnames{1}); end
                    data=cat(2,data,tdata);
                end
                idx=find(any(data>repmat(thr(:)',size(data,1),1),2));
                if ext>0, idx=repmat(idx(:),1,2*ext)+repmat(-ext:ext-1,numel(idx),1); end
                idx=unique(idx(idx>0&idx<=size(data,1)));
                e=full(sparse(idx,1:numel(idx),1,size(data,1),numel(idx)));
                out=conn_prepend([ocov,'_'],filename,'.mat');
                R=e; save(out,'R');
                conn_disp('fprintf','created file %s\n',out);
                fout{nsub}{nses}=out;
            end
        end
        conn_module('set','l1covariates',fout,ocov,'add');            
end
