function [ID_ML,ID_AIC,ID_BIC,Family] = MvCAT_main(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MATLAB code developed by Mojtaba Sadegh (mojtabasadegh@gmail.com) and Amir AghaKouchak,
% Center for Hydrometeorology and Remote Sensing (CHRS)
% University of California, Irvine
%
% Last modified on June 12, 2018
%
% Please reference to:
% Sadegh, M., E. Ragno, and A. AghaKouchak (2017), MvDAT: Multivariate
% Dependence Analysis Toolbox, Water Resources Research, 53, doi:10.1002/2016WR020242.
% Link: http://onlinelibrary.wiley.com/doi/10.1002/2016WR020242/epdf
%
% Sadegh, M., et al. (2018) "Multi-hazard scenarios for analysis of compound extreme events." 
% Geophysical Research Letters. https://doi.org/10.1029/2018GL077317
%
% Please contact Mojtaba Sadegh (mojtabasadegh@gmail.com) with any issue.
%
% Disclaimer:
% This program (hereafter, software) is designed for instructional, educational and research use only.
% Commercial use is prohibited. The software is provided 'as is' without warranty
% of any kind, either express or implied. The software could include technical or other mistakes,
% inaccuracies or typographical errors. The use of the software is done at your own discretion and
% risk and with agreement that you will be solely responsible for any damage and that the authors
% and their affiliate institutions accept no responsibility for errors or omissions in the software
% or documentation. In no event shall the authors or their affiliate institutions be liable to you or
% any third parties for any special, indirect or consequential damages of any kind, or any damages whatsoever.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prespecify Rhat (convergence of MCMC)
Rhat = nan;


data = handles.data;
ID_CHOSEN = handles.ID_CHOSEN;
Optimization = handles.Optimization;

tic
% Remove previous Results folder, if any
% if exist('Results','file') ~= 0, rmdir('Results','s'); end
% Create a Results folder
if ispc
    mkdir([pwd,'\Results']);
    % Delete previous contents of the Results folder
    cd([pwd,'\Results']);
else
    mkdir([pwd,'/Results']);
    % Delete previous contents of the Results folder
    cd([pwd,'/Results']);
end
delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
cd ..

% Get matlab version
v = version;

if v(1) < 9 % If matlab version is older than 2016a, you need to manually open matlabpool
    % try parallel computing
    try
        matlabpool(feature('numCores'))
    catch
        % Do nothing! You don't have parallel toolbox
    end
end


% Available families of copula
Family = {'Gaussian','t','Clayton','Frank','Gumbel','Independence','AMH','Joe','FGM',...
    'Plackett','Cuadras-Auge','Raftery','Shih-Louis','Linear-Spearman','Cubic','Burr','Nelsen','Galambos','Marshal-Olkin',...
    'Fischer-Hinzmann','Roch-Alegre','Fischer-Kock','BB1','BB5','Tawn'};

% Length of data
n = length(data);

% Find data ranks
for i = 1:n
    R1(i,1) = sum(data(:,1) >= data(i,1));
    R2(i,1) = sum(data(:,2) >= data(i,2));
end

% Transform to uniform marginals
U1 = (n-R1+0.5)./n;
U2 = (n-R2+0.5)./n;

% Compute Kendal's Corelation Coefficient
TAU = corr(U1,U2,'type','kendall');

%% Compute emperical probability
EP1_emp = Calc_Emp_Prob(U1);
EP2_emp = Calc_Emp_Prob(U2);
EP_emp = [EP1_emp EP2_emp];

%% Fit distributions to marginals and compute fitted marginal probability
if ispc
    addpath([pwd,'\Data'])
else
    addpath([pwd,'/Data'])
end
% Fit a distribution to data(:,1)
[D_U1, PD_U1] = allfitdist(data(:,1));
% Fit a distribution to data(:,2)
[D_U2, PD_U2] = allfitdist(data(:,2));

% Compute fitted marginal probability
EP1 = cdf(PD_U1{1},data(:,1));
EP2 = cdf(PD_U2{2},data(:,2));

% Check if inverse is also OK
IEP1 = icdf(PD_U1{1},EP1);
IEP2 = icdf(PD_U2{1},EP2);

% If EP is inf or nan, try next distribution
counter_D_U1 = 1;
while any( isnan(EP1) | isinf(EP1) | isnan(IEP1) | isinf(IEP1) )
    counter_D_U1 = counter_D_U1 + 1;
    EP1 = cdf(PD_U1{counter_D_U1},data(:,1));
    IEP1 = icdf(PD_U1{counter_D_U1},EP1);
end
counter_D_U2 = 1;
while any( isnan(EP2) | isinf(EP2) | isnan(IEP2) | isinf(IEP2) )
    counter_D_U2 = counter_D_U2 + 1;
    EP2 = cdf(PD_U2{counter_D_U2},data(:,2));
    IEP2 = icdf(PD_U2{counter_D_U2},EP2);
end


EP = [EP1 EP2];
% Replace 0 probability with 1e-4
EP( EP == 0 ) = 1e-4;
% Update structure handles with marginal distribution info
handles.D_U1 = D_U1; handles.D_U2 = D_U2;
handles.PD_U1 = PD_U1; handles.PD_U2 = PD_U2;
handles.counter_D_U1 = counter_D_U1; handles.counter_D_U2 = counter_D_U2;

%% Evaluate dependence between the two variables and goodness of fit of the marginal distributions and write to summary report
PWD1 = pwd;
if ispc
    cd([pwd,'\Results'])
else
    cd([pwd,'/Results'])
end

fileID = fopen('SummaryReport.txt','w');
fprintf(fileID,'%80s \r\n','================================================================================');
fprintf(fileID,'%22s \r\n','MARGINAL DISTRIBUTIONS');
fprintf(fileID,'%80s \r\n','================================================================================');
fprintf(fileID,'%51s \r\n\r\n','Evaluate dependence between the two input variables');
fprintf(fileID,'%22s %30s %20s %30s\r\n','Correlation type','Correlation Coefficient','p value','Significant at 5%?');
[r_print,p_print] = corr(data(:,1),data(:,2),'type','kendall'); % compute correlation coefficient and p-value
if p_print <= 0.05; Significant = 'Yes'; else Significant = 'No'; end % evaluate if correlation is significant
fprintf(fileID,'%22s %30.4f %20.4f %30s \r\n','Kendall rank',r_print,p_print,Significant);
[r_print,p_print] = corr(data(:,1),data(:,2),'type','spearman'); % compute correlation coefficient and p-value
if p_print <= 0.05; Significant = 'Yes'; else Significant = 'No'; end % evaluate if correlation is significant
fprintf(fileID,'%22s %30.4f %20.4f %30s \r\n','Spearman''s rank-order',r_print,p_print,Significant);
[r_print,p_print] = corr(data(:,1),data(:,2),'type','pearson'); % compute correlation coefficient and p-value
if p_print <= 0.05; Significant = 'Yes'; else Significant = 'No'; end % evaluate if correlation is significant
fprintf(fileID,'%22s %30.4f %20.4f %30s \r\n','Pearson product-moment',r_print,p_print,Significant);
fprintf(fileID,'%70s \r\n\r\n','');
cd(PWD1)
%% Now plot fitted marginals versus empirical
% Get size of screen in inches
%Sets the units of your root object (screen) to inches
set(0,'units','inches');
%Obtains this inch information
Inch_SS = get(0,'screensize');
% Remove zero and find minimum size of screen dimensions
Inch_SS( Inch_SS == 0 ) = [];
% Define the figure size
h = figure('visible','off');
set(gcf,'color','w','units','inches','position',[0.5 0.5 0.8*max(Inch_SS) 0.8*min(Inch_SS)],'paperpositionmode','auto');

% First plot the results
ax1 = axes('units','normalized'); axpos1 = [0.1 0.23 0.4 0.5]; set(ax1,'position',axpos1);
[S_data,id_S_data] = sort(data(:,1));
plot(S_data,EP1(id_S_data),'r','linewidth',2); hold on; plot(data(:,1),EP1_emp,'b.','markersize',12)
legend({'Fitted','Empirical'},'Location','northwest','fontname','times','fontweight','bold','fontsize',10)
title('Marginal distribution','fontname','times','fontweight','bold','fontsize',12)
xlabel(handles.U1_name,'fontname','times','fontweight','bold','fontsize',12)
ylabel('Probability','fontname','times','fontweight','bold','fontsize',12)
box on; axis square

ax2 = axes('units','normalized'); axpos2 = [0.5 0.23 0.4 0.5]; set(ax2,'position',axpos2);
h1 = qqplot(EP1,EP1_emp);
set(h1(1),'marker','.','markersize',12);
set(h1(2),'linewidth',2);
set(h1(3),'linewidth',2);
title('QQ plot','fontname','times','fontweight','bold','fontsize',12)
xlabel('Fitted probability','fontname','times','fontweight','bold','fontsize',12)
ylabel('Empirical probability','fontname','times','fontweight','bold','fontsize',12)
box on; axis square

% Save figure
if ispc
    mkdir([pwd,'\Results\Marginal'])
    cd([pwd,'\Results\Marginal'])
else
    mkdir([pwd,'/Results/Marginal'])
    cd([pwd,'/Results/Marginal'])
end
delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
% Save the graph to folder
eval(['saveas(h,''Variable 1 marginal distribution.png'')'])
eval(['saveas(h,''Variable 1 marginal distribution.fig'')'])
cd(PWD1)
close(h)

% Define the figure size
h = figure('visible','off');
set(gcf,'color','w','units','inches','position',[0.5 0.5 0.8*max(Inch_SS) 0.8*min(Inch_SS)],'paperpositionmode','auto');

% First plot the results
ax1 = axes('units','normalized'); axpos1 = [0.1 0.23 0.4 0.5]; set(ax1,'position',axpos1);
[S_data,id_S_data] = sort(data(:,2));
plot(S_data,EP2(id_S_data),'r','linewidth',2); hold on; plot(data(:,2),EP2_emp,'b.','markersize',12)
legend({'Fitted','Empirical'},'Location','northwest','fontname','times','fontweight','bold','fontsize',10)
title('Marginal distribution','fontname','times','fontweight','bold','fontsize',12)
xlabel(handles.U2_name,'fontname','times','fontweight','bold','fontsize',12)
ylabel('Probability','fontname','times','fontweight','bold','fontsize',12)
box on; axis square

ax2 = axes('units','normalized'); axpos2 = [0.5 0.23 0.4 0.5]; set(ax2,'position',axpos2);
h1 = qqplot(EP2,EP2_emp);
set(h1(1),'marker','.','markersize',12);
set(h1(2),'linewidth',2);
set(h1(3),'linewidth',2);
title('QQ plot','fontname','times','fontweight','bold','fontsize',12)
xlabel('Fitted probability','fontname','times','fontweight','bold','fontsize',12)
ylabel('Empirical probability','fontname','times','fontweight','bold','fontsize',12)
box on; axis square
% Save figure
if ispc
    cd([pwd,'\Results\Marginal'])
else
    cd([pwd,'/Results/Marginal'])
end
% Save the graph to folder
eval(['saveas(h,''Variable 2 marginal distribution.png'')'])
eval(['saveas(h,''Variable 2 marginal distribution.fig'')'])
cd(PWD1)
close(h)

%% Now write the fit to SummaryStatistics file
fprintf(fileID,'%50s \r\n\r\n','Evaluate fit of marginal distributions to variables');
fprintf(fileID,'%10s %30s %20s %20s %20s %20s %20s %20s %20s %20s %70s\r\n','','Fitted distribution','Par 1 name','Par 1 value','Par 2 name','Par 2 value','Par 3 name','Par 3 value','Par 4 name','Par 4 value','Chi square gof test that data is drawn from dist at 5% significance');
% Evaluate with chi square goodness of fit test whether data is drawn from the fitted distribution or not
[h_D_U1] = chi2gof(data(:,1),'CDF',PD_U1{counter_D_U1}); if h_D_U1 == 0, chigof = 'Accepted'; else chigof = 'Rejected'; end
%try D_U1(counter_D_U1).ParamNames(3);catch D_U1(counter_D_U1).ParamNames(3)={'NaN'}; D_U1(counter_D_U1).Params(3) = nan;end
if length(D_U1(counter_D_U1).Params) == 1
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20s %20s %20s %15s\r\n','Variable 1',D_U1(counter_D_U1).DistName,D_U1(counter_D_U1).ParamNames{1},D_U1(counter_D_U1).Params(1),'NaN',nan,'NaN',nan,'NaN',nan,chigof);
elseif length(D_U1(counter_D_U1).Params) == 2
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20s %20s %20s %15s\r\n','Variable 1',D_U1(counter_D_U1).DistName,D_U1(counter_D_U1).ParamNames{1},D_U1(counter_D_U1).Params(1),D_U1(counter_D_U1).ParamNames{2},D_U1(counter_D_U1).Params(2),'NaN',nan,'NaN',nan,chigof);
elseif length(D_U1(counter_D_U1).Params) == 3
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20.4f %20s %20s %15s\r\n','Variable 1',D_U1(counter_D_U1).DistName,D_U1(counter_D_U1).ParamNames{1},D_U1(counter_D_U1).Params(1),D_U1(counter_D_U1).ParamNames{2},D_U1(counter_D_U1).Params(2),D_U1(counter_D_U1).ParamNames{3},D_U1(counter_D_U1).Params(3),'NaN',nan,chigof);
else
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20.4f %20s %20.4f %15s\r\n','Variable 1',D_U1(counter_D_U1).DistName,D_U1(counter_D_U1).ParamNames{1},D_U1(counter_D_U1).Params(1),D_U1(counter_D_U1).ParamNames{2},D_U1(counter_D_U1).Params(2),D_U1(counter_D_U1).ParamNames{3},D_U1(counter_D_U1).Params(3),D_U1(counter_D_U1).ParamNames{4},D_U1(counter_D_U1).Params(4),chigof);
end
% Evaluate with chi square goodness of fit test whether data is drawn from the fitted distribution or not
[h_D_U2] = chi2gof(data(:,2),'CDF',PD_U2{counter_D_U2}); if h_D_U2 == 0, chigof = 'Accepted'; else chigof = 'Rejected'; end
%try D_U2(counter_D_U2).ParamNames(3);catch D_U2(counter_D_U2).ParamNames(3)={'NaN'}; D_U2(counter_D_U2).Params(3) = nan;end
if length(D_U2(counter_D_U2).Params) == 1
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20s %20s %20s %15s\r\n','Variable 2',D_U2(counter_D_U2).DistName,D_U2(counter_D_U2).ParamNames{1},D_U2(counter_D_U2).Params(1),'NaN',nan,'NaN',nan,'NaN',nan,chigof);
elseif length(D_U2(counter_D_U2).Params) == 2
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20s %20s %20s %15s\r\n','Variable 2',D_U2(counter_D_U2).DistName,D_U2(counter_D_U2).ParamNames{1},D_U2(counter_D_U2).Params(1),D_U2(counter_D_U2).ParamNames{2},D_U2(counter_D_U2).Params(2),'NaN',nan,'NaN',nan,chigof);
elseif length(D_U2(counter_D_U2).Params) == 3
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20.4f %20s %20s %15s\r\n','Variable 2',D_U2(counter_D_U2).DistName,D_U2(counter_D_U2).ParamNames{1},D_U2(counter_D_U2).Params(1),D_U2(counter_D_U2).ParamNames{2},D_U2(counter_D_U2).Params(2),D_U2(counter_D_U2).ParamNames{3},D_U2(counter_D_U2).Params(3),'NaN',nan,chigof);
else
    fprintf(fileID,'%10s %30s %20s %20.4f %20s %20.4f %20s %20.4f %20s %20.4f %15s\r\n','Variable 2',D_U2(counter_D_U2).DistName,D_U2(counter_D_U2).ParamNames{1},D_U2(counter_D_U2).Params(1),D_U2(counter_D_U2).ParamNames{2},D_U2(counter_D_U2).Params(2),D_U2(counter_D_U2).ParamNames{3},D_U2(counter_D_U2).Params(3),D_U2(counter_D_U2).ParamNames{4},D_U2(counter_D_U2).Params(4),chigof);
end
fprintf(fileID,'%70s \r\n\r\n','');
%%

% Compute empirical bivariate probability
EBVP = Calc_Emp_BiVar_Prob([U1,U2]);

% Pre-assign TPAR
TPAR = nan(2000, 5, 25);
% 95% confidence interval of parameters
CI95 = nan(25,3,2);

% Pre define PAR
PAR.LO = nan(25,3); % LO: local optimization; 25 copulas and a maximum of 3 parameters
PAR.T = nan(25,3); % T: theoretical; 25 copulas and a maximum of 3 parameters
PAR.MC = nan(25,3); % MC: Markov Chain; Best parameter (maximum likelihood);

% Predefine Model selection criteria
MAX_L = nan(25,1); AIC = nan(25,1); BIC = nan(25,1); RMSE = nan(25,1); NSE = nan(25,1);

% Go through the loop for all built-in copulas of MATLAB
% Use matlab functions to estimate copula parameters
for jj = 1:length(ID_CHOSEN)
    % Which copulas to run?
    j = ID_CHOSEN(jj);
    
    % Skip independance copula! No parameter
    if j == 6
        % Number of parameters
        DD = 0;
        
        % Calculate joint probabilities and residuals
        [~,RES,~] = Copula_Families_CDF(EP,EBVP,Family{j},PAR.LO(j,1:DD),2);
        
        % Maximum log-likelihood
        MAX_L(j,1) = -length(RES)/2 * log( sum(RES.^2)/length(RES) );
        
        % Calculate Akaike Information Content (AIC) based on https://en.wikipedia.org/wiki/Akaike_information_criterion
        AIC(j,1) = n * log(det(RES'*RES/n)) + 2 * DD;
        
        % Calculate Bayesian information criterion. Based on https://en.wikipedia.org/wiki/Bayesian_information_criterion
        % Under Gaussian special case
        BIC(j,1) = n * log(RES'*RES/n) + DD * log(n);
        
        % Calculate root mean square error (RMSE)
        RMSE(j,1) = sqrt(mean(RES'*RES));
        
        % Calculate Nash Sutcliff Efficiency (NSE)
        NSE(j,1) = 1 - sum( RES'*RES )/sum( (EBVP - mean(EBVP)).^2 );
        continue
    end
    
    % Use try-catch to avoid failure of the entire code, if one copula fails
    try
        % Find parameters of copula based on local search methods of matlab
        [par,PAR_RANGE,fval] = LocalOptimization(EP,EBVP,Family,j);
        for i = 1:29
            [par_new,~,fval_new] = LocalOptimization(EP,EBVP,Family,j);
            if fval_new < fval
                par = par_new; fval = fval_new;
            end
        end
        % Assign parameters to PAR.LO to save them
        PAR.LO( j, 1:length(par) ) = par;
        PAR.RANGE(j) = PAR_RANGE;
        
        % Dimensionality of the copula
        DD = length(PAR_RANGE.min);
        
        % Convergence of MCMC: Rhat: not available for local optimization
        Rhat = nan;
        
        if strcmp(Optimization,'MCMC')
            % Use MCMC simulation to estimate the posterior parameter distribution
            [~, tpar, ~, ~, Rhat] = MCMC(PAR_RANGE,1000,Family,EP, EBVP, j, 0);
            % Only store last 2500 samples
            TPAR(1:2000, 1:DD+2, j) = tpar(end-1999:end, 1:DD+2) ;
            
            % Compute the 95% confidence interval
            CI95(j,1:DD,1) = prctile(TPAR(1:2000,1:DD,j),2.5);
            CI95(j,1:DD,2) = prctile(TPAR(1:2000,1:DD,j),97.5);
            
            % Find index of best sample from MCMC draws
            [~,id_tpar] = max(tpar(:,DD+2)); id_tpar = id_tpar(end);
            % Save best MCMC sample
            PAR.MC(j,1:DD) = tpar(id_tpar, 1:DD);
            
            % Maximum likelihood
            MAX_L(j,1) = tpar(id_tpar,DD+2);
            
            % Calculate residuals for the maximum likelihood parameter
            [~,RES,PSIM] = Copula_Families_CDF(EP,EBVP,Family{j},tpar(id_tpar,1:DD),2);
            
        else % Use local optimization results
            % Calculate residuals for the maximum likelihood parameter
            [~,RES,PSIM] = Copula_Families_CDF(EP,EBVP,Family{j},PAR.LO(j,1:DD),2);
            
            % Maximum likelihood
            MAX_L(j,1) = -length(RES)/2 * log( sum(RES.^2)/length(RES) );
        end
        
        % Calculate Akaike Information Content (AIC) based on https://en.wikipedia.org/wiki/Akaike_information_criterion
        AIC(j,1) = n * log(det(RES'*RES/n)) + 2 * DD;
        
        % Calculate Bayesian information criterion. Based on https://en.wikipedia.org/wiki/Bayesian_information_criterion
        % Under Gaussian special case
        BIC(j,1) = n * log(RES'*RES/n) + DD * log(n);
        
        % Calculate root mean square error (RMSE)
        RMSE(j,1) = sqrt(mean(RES'*RES));
        
        % Calculate Nash Sutcliff Efficiency (NSE)
        NSE(j,1) = 1 - sum( RES'*RES )/sum( (EBVP - mean(EBVP)).^2 );
        
        % Find theoretically derived Rho
        if j ~= 2 && j <=5
            % Calculate theoretical Rho
            PAR.T(j,1) = copulaparam(Family{j},TAU);
        elseif j == 2
            % Calculate theoretical Rho for t copula
            if ~isnan(PAR.MC(j,2))
                PAR.T(j,1) = copulaparam(Family{j},TAU,PAR.MC(j,2));
            else PAR.T(j,1) = copulaparam(Family{j},TAU,PAR.LO(j,2));
            end
        end
    catch
        % Do nothing! Go to next copula!
    end
    
    
end

% Find best copula based on maximum likelihood & AIC & BIC
[ML_VALUE,ID_ML] = sort(MAX_L,'descend'); % ID_ML(ID_ML==6) = []; % Remove independence copula
% Trick to move NANs
id_nan = isnan(ML_VALUE); ID_ML = [ID_ML(~id_nan); ID_ML(id_nan)];
[~,ID_AIC] = sort(AIC,'ascend'); % ID_AIC(ID_AIC==6) = []; % Remove independence copula
[~,ID_BIC] = sort(BIC,'ascend'); % ID_BIC(ID_BIC==6) = []; % Remove independence copula

% Run time
Run_Time = toc;


%% Plot figure:
if strcmp(Optimization,'MCMC')
    % Plot histogram
    Copula_Hist(TPAR,PAR,ID_CHOSEN,Family)
    % Plot copula-based bivariate probability contours in probability space
    MvCAT_Copula_Prob_Plot(EP,EBVP,PAR.MC,ID_CHOSEN,Family,handles)
    % Plot copula-based bivariate probability contours in original data space
    MvCAT_Copula_Plot(EP,EBVP,PAR.MC,ID_CHOSEN,Family,handles)
    % Plot copula-based bivariate exceedance probability contours in original data space
    MvCAT_Survival_Plot(EP,EBVP,PAR.MC,ID_CHOSEN,Family,handles)
    % Plot return period isolines in original data space
    MvCAT_ReturnPeriod(EBVP,PAR.MC,ID_CHOSEN,Family,handles);
else
    % Plot copula-based bivariate probability contours in probability space
    MvCAT_Copula_Prob_Plot(EP,EBVP,PAR.LO,ID_CHOSEN,Family,handles)
    % Plot copula-based bivariate probability contours in original data space
    MvCAT_Copula_Plot(EP,EBVP,PAR.LO,ID_CHOSEN,Family,handles)
    % Plot copula-based bivariate exceedance probability contours in original data space
    MvCAT_Survival_Plot(EP,EBVP,PAR.LO,ID_CHOSEN,Family,handles)
    % Plot return period isolines in original data space
    MvCAT_ReturnPeriod(EBVP,PAR.LO,ID_CHOSEN,Family,handles);
end

% Save the Workspace to folder
if ispc
    cd([pwd,'\Results'])
else
    cd([pwd,'/Results'])
end

% Clean variable handles
tokeep = {'D_U1','PD_U1','D_U2','PD_U2','data','U1_name','U2_name'};
f=fieldnames(handles);
toRemove = f(~ismember(f,tokeep));
handles = rmfield(handles,toRemove);
% Assign copula parameters/fields to a structure
Copula_Variables.TPAR = TPAR; Copula_Variables.PAR = PAR; Copula_Variables.ID_ML = ID_ML; Copula_Variables.ID_AIC = ID_AIC; Copula_Variables.ID_BIC = ID_BIC;
Copula_Variables.Run_Time = Run_Time; Copula_Variables.MAX_L = MAX_L; Copula_Variables.AIC = AIC; Copula_Variables.BIC = BIC; Copula_Variables.Family = Family;
Copula_Variables.ID_CHOSEN = ID_CHOSEN; Copula_Variables.CI95 = CI95; Copula_Variables.RMSE = RMSE; Copula_Variables.NSE = NSE; Copula_Variables.Rhat = Rhat;
% Now save variables
save MvCAT_Results Copula_Variables data EBVP U1 U2 EP EP_emp handles
cd ..

%% Write a summary text file for model selection
fprintf(fileID,'%80s \r\n','================================================================================');
fprintf(fileID,'%38s \r\n','COPULA JOINT PROBABILITY DISTRIBUTIONS');
fprintf(fileID,'%80s \r\n','================================================================================');
fprintf(fileID,'%37s \r\n\r\n','Sort copulas based on different criteria');
fprintf(fileID,'%4s %20s %20s %20s \r\n','Rank','Max-Likelihood','AIC','BIC');

for i = 1:length(ID_CHOSEN)
    fprintf(fileID,'%4d %20s %20s %20s \r\n',i,Family{ID_ML(i)},Family{ID_AIC(i)},Family{ID_BIC(i)});
end

fprintf(fileID,'\r\n \r\n%27s \r\n\r\n','Estimated copula parameters');
fprintf(fileID,'%17s %9s %9s %20s %12s %12s %20s %27s %12s %27s %12s %27s\r\n','Copula Name','RMSE','NSE','Par#1-Local','Par#2-Local','Par#3-Local','Par#1-MCMC','95%-Par#1-Unc-Range','Par#2-MCMC','95%-Par#2-Unc-Range','Par#3-MCMC','95%-Par#3-Unc-Range');
for i = 1:length(ID_CHOSEN)
    fprintf(fileID,'%17s %9.4f %9.4f %20.4f %12.4f %12.4f %20.4f %9s%8.4f%1s%8.4f%1s %12.4f %9s%8.4f%1s%8.4f%1s %12.4f %9s%8.4f%1s%8.4f%1s \r\n',Family{ID_CHOSEN(i)},RMSE(ID_CHOSEN(i),1), NSE(ID_CHOSEN(i)), PAR.LO(ID_CHOSEN(i),1),PAR.LO(ID_CHOSEN(i),2),PAR.LO(ID_CHOSEN(i),3),PAR.MC(ID_CHOSEN(i),1),'[',CI95(ID_CHOSEN(i),1,1),' ',CI95(ID_CHOSEN(i),1,2),']',PAR.MC(ID_CHOSEN(i),2),'[',CI95(ID_CHOSEN(i),2,1),' ',CI95(ID_CHOSEN(i),2,2),']',PAR.MC(ID_CHOSEN(i),3),'[',CI95(ID_CHOSEN(i),3,1),' ',CI95(ID_CHOSEN(i),3,2),']');
end

% Print out warnings
fprintf(fileID,'\r\n \r\n%10s \r\n','WARNING(s)');
% Second parameter of t copula is degree of freedom
if any(ID_CHOSEN == 2)
    fprintf(fileID,'Second parameter of t copula is degree of freedom \r\n');
    if strcmp(Optimization,'MCMC') && PAR.MC(2,2) > 25
        fprintf(fileID,'Estimated degree of freedom for t copula is >25. You may consider switching to Gaussian copula in this case. \r\n');
    elseif PAR.LO(2,2) > 25
        fprintf(fileID,'Estimated degree of freedom for t copula is >25. You may consider switching to Gaussian copula in this case. \r\n');
    end
end
%  Package only works for bivariate copulas
if size(data,2) > 2
    fprintf(fileID,'This package only analyzes bivariate copulas. The program only reads the first two columns for copula fitting. \r\n');
end
% Warning about negative correlation of data
r = corr(data,'type','spearman');
if r(1,2) < 0
    fprintf(fileID,'Your input data exhibits negative correlation. Not all copula families can be used for modeling negatively correlated variables. Please review literature (e.g., Joe 1997, Nelesen, 2006) before using the results. \r\n');
end
% Check if optimization converged to boundaries of the parameters
for i = 1:length(ID_CHOSEN)
    if ID_CHOSEN(i) == 6 % No need to check for independence copula
        continue
    end
    try
        if strcmp(Optimization,'MCMC')
            id_notnan = find(isnan(PAR.MC(ID_CHOSEN(i),:))); if isempty(id_notnan), id_notnan = 4; end
            DIFF1 = abs(PAR.MC(ID_CHOSEN(i),1:id_notnan(1)-1) - PAR.RANGE(ID_CHOSEN(i)).min);
            DIFF2 = abs(PAR.MC(ID_CHOSEN(i),1:id_notnan(1)-1) - PAR.RANGE(ID_CHOSEN(i)).max);
        else
            id_notnan = find(isnan(PAR.MC(ID_CHOSEN(i),:))); if isempty(id_notnan), id_notnan = 4; end
            DIFF1 = abs(PAR.LO(ID_CHOSEN(i),1:id_notnan(1)-1) - PAR.RANGE(ID_CHOSEN(i)).min);
            DIFF2 = abs(PAR.LO(ID_CHOSEN(i),1:id_notnan(1)-1) - PAR.RANGE(ID_CHOSEN(i)).max);
        end
    catch
        % If a copula returns nan values, don't check for parameter convergence
        DIFF1 = 2*ones(size(PAR.RANGE(ID_CHOSEN(i)).min)); DIFF2 = 2*ones(size(PAR.RANGE(ID_CHOSEN(i)).min));
    end
    % Define a threshold
    THRESHHOLD = max(0.05, abs(0.03 * (PAR.RANGE(ID_CHOSEN(i)).max - PAR.RANGE(ID_CHOSEN(i)).min)) );
    % Check if any parameter has converged to the boundary
    if any( DIFF1 < THRESHHOLD ) || any( DIFF2 < THRESHHOLD )
        fprintf(fileID,'One (of the) parameter(s) of %17s copula is converging to the parameter boundary(s). There is a chance that this is not a good fit! \r\n',Family{ID_CHOSEN(i)});
    end
    
end

if ispc
    cd([pwd,'\Results\Marginal'])
else
    cd([pwd,'/Results/Marginal'])
end
openfig('Variable 1 marginal distribution.fig','new','visible');
openfig('Variable 2 marginal distribution.fig','new','visible');
cd(PWD1)

if ispc
    cd([pwd,'\Results\Copula_Data_Space'])
else
    cd([pwd,'/Results/Copula_Data_Space'])
end
eval(['openfig(''Copula Data Space-',num2str(find(ID_CHOSEN==ID_BIC(1))),'.fig'',''new'',''visible'')']);
cd(PWD1)

if ispc
    cd([pwd,'\Results\ReturnPeriod'])
else
    cd([pwd,'/Results/ReturnPeriod'])
end
eval(['openfig(''Return Period-',num2str(find(ID_CHOSEN==ID_BIC(1))),'.fig'',''new'',''visible'')']);
cd(PWD1)

if ispc
    cd([pwd,'\Results\Survival_Copula'])
else
    cd([pwd,'/Results/Survival_Copula'])
end
eval(['openfig(''Survival_Copula Data Space-',num2str(find(ID_CHOSEN==ID_BIC(1))),'.fig'',''new'',''visible'')']);
cd(PWD1)


if ispc
    cd([pwd,'\Results'])
else
    cd([pwd,'/Results'])
end
edit SummaryReport.txt;
cd(PWD1)

% Shut down the parallel cores that were opened up previously
if v(1) < 9
    % If matlabpool is open, close it
    if matlabpool('size') ~= 0
        matlabpool close
    end
else
    if ~isempty(gcp('nocreate'))
        delete(gcp('nocreate'))
    end
end

end

% Compute empirical univariate probability distribution
function Y = Calc_Emp_Prob(D)

% Length of data
n = length(D);
% Pre-assign probability array
P = zeros(n,1);

% Loop through the data
for i = 1:n
    P(i,1) = sum( D(:,1) <= D(i,1) );
end

% Gringorten plotting position
Y = (P - 0.44) ./ (n + 0.12);
end

% Compute empirical bivariate probability distribution
function Y = Calc_Emp_BiVar_Prob(D)

% Length of data
n = length(D);
% Pre-assign bivariate probability array
BVP = zeros(n,1);

% Loop through the data
for i = 1:n
    % Pre-assign CD in each time step
    CD = zeros(n,3);
    % Find count of data points for which p(X < x)
    CD( D(:,1) <= D(i,1), 1 ) = 1;
    % Find count of data points for which p(Y < y)
    CD( D(:,2) <= D(i,2), 2 ) = 1;
    % Find count of data points for which p(X < x & Y < y)
    CD(:,3) = CD(:,1) .* CD(:,2);
    BVP(i,1) = sum( CD(:,3) );
end

% Gringorten plotting position (bivariate)
Y = (BVP - 0.44) ./ (n + 0.12);

end

function [PAR,PAR_RANGE,fval] = LocalOptimization(EP,EBVP_CDF,Family,j)
% Prespecify nan
fval = nan;

if j == 1 % Gaussian Copula
    RHO = copulafit(Family{j}, EP);
    PAR(1,1) = RHO(1,2);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = -0.9999; PAR_RANGE.max = 0.9999;
    
elseif j == 2 % t Copula
    [RHO,nu] = copulafit(Family{j}, EP);
    PAR(1,1) = RHO(1,2); PAR(1,2) = nu;
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = [-1, 0]; PAR_RANGE.max = [1, nu+4*abs(nu)];
    PAR_RANGE.min = [-0.9999, 0.0001]; PAR_RANGE.max = [0.9999, 35];
    
elseif j == 3 % Clayton copula
    PAR(1,1) = copulafit(Family{j}, EP);
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = 0;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 0.0001;  PAR_RANGE.max = 35;
    
elseif j == 4 % Frank copula
    PAR(1,1) = copulafit(Family{j}, EP);
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = PAR(1,1) - 4*abs(PAR(1,1));  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = -35;  PAR_RANGE.max = 35;
    
elseif j == 5 % Gumbel copula
    PAR(1,1) = copulafit(Family{j}, EP);
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = 1;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 1.0001;  PAR_RANGE.max = 35;
    
elseif j == 6 % Independence copula
    % No parameter
    PAR(1,1) = nan;
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = nan;  PAR_RANGE.max = nan;
    
elseif j == 7 % Ali-Mikhail-Haq copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-1,1);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = -1;  PAR_RANGE.max = 1;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 8 % Joe copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),1,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = 1;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 1;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 9 % Farlie-Gumbel-Mogenstern copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-1,1);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = -1;  PAR_RANGE.max = 1;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 10 % Placket copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),1e-4,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = 1e-4;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 1e-4;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 11 % Cuadras-Auge copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),0,1);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = 0;  PAR_RANGE.max = 1;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 12 % Raftery copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),0,0.9999);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = 0;  PAR_RANGE.max = 0.9999;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 13 % Shih-Louis copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-35,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = PAR(1,1) - 4*abs(PAR(1,1));  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = -35;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 14 %Linear-Spearman copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-1,1);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = -1;  PAR_RANGE.max = 1;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 15 % Cubic copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-1,2);
    % Define minimum and maximum ranges for parameter estimation
    PAR_RANGE.min = -1;  PAR_RANGE.max = 2;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 16 % Burr copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),1e-4,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = 1e-4;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 1e-4;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 17 % Nelsen copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),-35,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = PAR(1,1) - 4*abs(PAR(1,1));  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = -35;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 18 % Galambos copula
    % [PAR(1,1), favl] = fminbnd(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),0,35);
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = 0;  PAR_RANGE.max = PAR(1,1) + 4*abs(PAR(1,1));
    PAR_RANGE.min = 0;  PAR_RANGE.max = 35;
    % Initial point
    Init_Point = PAR_RANGE.min + rand .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
    %% fminbnd only works for 1 parmeter models; for 2+ parameter models we use fmincon
elseif j == 19 %Marshal-Olkin copula
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = [0 0];  PAR_RANGE.max = PAR(1,1:2) + 4*abs(PAR(1,1:2));
    PAR_RANGE.min = [0 0];  PAR_RANGE.max = [35 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 20 % Fischer-Hinzman copula
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = [0 PAR(1,2)-4*abs(PAR(1,2))];  PAR_RANGE.max = [1 PAR(1,2)+4*abs(PAR(1,2))];
    PAR_RANGE.min = [0 -35]; PAR_RANGE.max = [1 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 21 % Roch-Alegre copula
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = [1e-4 1];  PAR_RANGE.max = PAR(1,1:2) + 4*abs(PAR(1,1:2));
    PAR_RANGE.min = [1e-4 1];  PAR_RANGE.max = [35 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 22 % Fiischer-Kock copula
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = [1 -1];  PAR_RANGE.max = [PAR(1,1)+4*abs(PAR(1,1)) 1];
    PAR_RANGE.min = [1 -1];  PAR_RANGE.max = [35 1];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 23 % BB1 copula
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = [1e-4 1];  PAR_RANGE.max = PAR(1,1:2) + 4*abs(PAR(1,1:2));
    PAR_RANGE.min = [1e-4 1];  PAR_RANGE.max = [35 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 24 % BB5 copula
    % Define minimum and maximum ranges for parameter estimation
    %PAR_RANGE.min = [1 1e-4];  PAR_RANGE.max = PAR(1,1:2) + 4*abs(PAR(1,1:2));
    PAR_RANGE.min = [1 1e-4];  PAR_RANGE.max = [35 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,2) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:2), favl] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
elseif j == 25 % Tawn copula
    % Define minimum and maximum ranges for parameter estimation
    % PAR_RANGE.min = [0 0 1];  PAR_RANGE.max = [1 1 PAR(1,3)+4*abs(PAR(1,3))];
    PAR_RANGE.min = [0 0 1];  PAR_RANGE.max = [1 1 35];
    % Initial point
    Init_Point = PAR_RANGE.min + rand(1,3) .* ( PAR_RANGE.max - PAR_RANGE.min );
    [PAR(1,1:3), fval] = fmincon(@(PAR) Copula_Families_CDF(EP,EBVP_CDF,Family{j},PAR,2),Init_Point,[],[],[],[],PAR_RANGE.min,PAR_RANGE.max);
    
end
end

function [CH, TPAR, OLR, Z, Rhat] = MCMC(PAR_RANGE,IT,Family,EP,EBVP,j,Parallel)
% Notations
% CH: Chain
% PRP: Propsal sample
% PAR.min, PAR.max: Min & Max range of parameters
% N: Number of chains (min 5)
% D: Dimension of the problem
% IT: Number of iterations
% LHS: Latin Hypercube Samples
% LN: Number of LHS
% PDV: Probability density value
% L_PDV: Log of PDV
% MR: Mtropolis ratio
% Z: Past Samples

%% References used in this code
%[1] Haario, Heikki, Eero Saksman, and Johanna Tamminen. "Adaptive proposal distribution for random walk Metropolis algorithm." Computational Statistics 14.3 (1999): 375-396.
%[2] Roberts, Gareth O., and Jeffrey S. Rosenthal. "Examples of adaptive MCMC." Journal of Computational and Graphical Statistics 18.2 (2009): 349-367.
%[3] Gilks, Walter R., Gareth O. Roberts, and Edward I. George. "Adaptive direction sampling." The statistician (1994): 179-189.
%[4] Haario, Heikki, Eero Saksman, and Johanna Tamminen. "An adaptive Metropolis algorithm." Bernoulli (2001): 223-242.
%[5] ter Braak, Cajo JF. "A Markov Chain Monte Carlo version of the genetic algorithm Differential Evolution: easy Bayesian computing for real parameter spaces." Statistics and Computing 16.3 (2006): 239-249.
%[6] ter Braak, Cajo JF, and Jasper A. Vrugt. "Differential evolution Markov chain with snooker updater and fewer chains." Statistics and Computing 18.4 (2008): 435-446.
%[7] Roberts, Gareth O., and Sujit K. Sahu. "Updating schemes, correlation structure, blocking and parameterization for the Gibbs sampler." Journal of the Royal Statistical Society: Series B (Statistical Methodology) 59.2 (1997): 291-317.
%[8] Duan, Q. Y., Vijai K. Gupta, and Soroosh Sorooshian. "Shuffled complex evolution approach for effective and efficient global minimization." Journal of optimization theory and applications 76.3 (1993): 501-521.
%[9] Vrugt, J. A., Ter Braak, C. J. F., Diks, C. G. H., Robinson, B. A., Hyman, J. M., & Higdon, D. (2009). Accelerating Markov chain Monte Carlo simulation by differential evolution with self-adaptive randomized subspace sampling. International Journal of Nonlinear Sciences and Numerical Simulation, 10(3), 273-290.
%% end references

% Initialize Rhat (convergence statistics)
Rhat = [];

% Number of parameters (problem dimension)
D = length(PAR_RANGE.min);
% Number of chains
N = max(2*D, 5);
% Initialize Chains with NAN
CH = nan(N, D+2, IT); % rows: different chains; columns: parameter set; 3rd dim: iterations
% Assure LN is multiplicative of N and at least 20*D
LN = max([N, 30*D]);
LN = ceil(LN/N); LN = N * LN;

%% Start chains with Latin Hypercube Sampling: LN samples
LHS = repmat(PAR_RANGE.min, LN, 1) + lhsdesign(LN, D) .* repmat(PAR_RANGE.max - PAR_RANGE.min, LN, 1);
% Cohort of Past Samples
Z = LHS;
% Compute probabilty density value
LHS(:, D+1:D+2) = Calc_PDV(LHS,Family,EP,EBVP,j,Parallel);

% Total Parameter Sets
TPAR = LHS;

% Covariance of LHS
COV = cov(TPAR(:, 1:D));

%% Divide LHS into 5 random comlexes: Based on SCE of Duan et al, 1993
% Create randomly distributed numbers between 1 & LN
c_idx = randperm(LN);
% Divide indices into N complexes
c_idx = reshape(c_idx, LN/N, N);

% Select best candidate in each complex to be the starting point of each chain
for i = 1:N
    % Find indices of max likelihood in each complex
    [~,id] = max(LHS(c_idx(:,i), end));
    % Assign max likelihood samples to chains
    CH(i, 1:D+2, 1) = LHS(c_idx(id,i), :);
end

% Wait bar
eval(strcat(['h = waitbar(0,''Hybrid MCMC is estimating parameters of ',Family{j},' copula'');']));

%% Go through time: Based on ter Braak 2006, 2008
for t = 2:IT
    % Update waitbar
    waitbar(t/IT)
    
    % Initialize jumps for each chain
    dPRP = zeros(N, D);
    PRP = nan(N, D+2);
    id_CH = nan(N,3);
    
    % Use snooker update with a probability of 0.1: remark 5, page 439 of ter Braak 2008
    Snooker = rand < 0.1;
    
    % Update covariance each 20 iterations: remark 3, page 226 of Haario 2001
    if rem(t,20) == 0
        % Covariance of LHS based on the last 50% of chains
        S_T = size(TPAR, 1);
        COV = cov(TPAR(S_T/2:S_T, 1:D));
    end
    
    %% Go through the loop for different chains: "Algorithm for updating population X" page 438 of ter Braak 2008
    for i = 1:N
        % Determine indices of the chains used for DE: Eq 1 of ter Braak 2008, page 437
        id_CH(i,1:3) = randsample(1:size(Z,1) , 3, 'false');
        
        %% Parallel update
        if ~Snooker
            %% Perform Subspace Sampling %%
            % Randomly select the subspace for sampling
            SS = find( rand(1, D) <= unifrnd(0, 1) );
            % Shouldn't be empty
            if isempty(SS), SS = randsample(1:D,1); end
            % Size of the subspace
            d = length(SS);
            
            %First chain will follow adaptive metropolis %%
            if i <= 1
                %Create a proposal candidate: Eq.3, page 3 of Roberts 2009
                % Small positive constant
                Beta = unifrnd(0,0.1,1);
                dPRP(i, SS) = (1 - Beta) * mvnrnd( zeros(1, d), (2.38^2/d)*COV(SS,SS) ) + Beta * mvnrnd( zeros(1, d), (0.1^2/d)*eye(d) );
            end
            
            %% Next chains based on DE-MC %%
            if i >= 2
                % Select gamma with 10% probability of gamma = 1 or 0.98 for direct jumps: first line on the right in page 242 & first
                % paragraph on the right in page 248 of ter Braak 2006
                gamma = randsample([2.38/sqrt(2*d) 0.98], 1, 'true', [0.9 0.1]);
                
                % The difference between the two chains: Eq 2, page 241 of ter Braak 2006
                dCH = Z(id_CH(i, 1), 1:D) - Z(id_CH(i, 2), 1:D);
                
                % Select jump: adopted from Eq 2, page 241 of ter Braak 2006 and E4, page 274 of Vrugt 2009
                dPRP(i, SS) =  unifrnd(gamma-0.1,gamma+0.1) * dCH(SS) + normrnd(0, 1e-12, 1, d);
            end
            %% Snooker Update
        else
            % Find the direction of the update: "Algorithm of DE Snooker update (Fig. 3)", page 438 of ter Braak 2008
            DIR = CH(i, 1:D, t-1) - Z(id_CH(i, 1), 1:D);
            
            % Project vector a onto b (https://en.wikipedia.org/wiki/Vector_projection):
            % a.b/b.b * b
            
            % Difference between z1 and z2 and its length on DIR
            DIF = ( (Z(id_CH(i, 2), 1:D) - Z(id_CH(i, 3), 1:D)) * DIR' ) / ( DIR*DIR' ); DIF = max(DIF, 0);
            % Resize DIR
            dCH = DIR * DIF;
            
            % Select jump: page 439 of ter Braak, 2008
            dPRP(i, 1:D) = unifrnd(1.2,2.2,1) * dCH;
        end

    end
    
    %% Create a proposal candidate: Current + Jump %%
    PRP(1:N, 1:D) = CH(1:N, 1:D, t-1) + dPRP(1:N, 1:D);
    
    %% Boundary handling: fold back in if fall outside: General Knowledge %%
    PRP(1:N , 1:D) = Bound_handle(PRP(1:N, 1:D), PAR_RANGE);
    
    %% Snooker correction for the metropolis ratio: Eq 4, page 439 of ter Braak, 2008
    C_sn = ones(N,1); % No need to correct if parallel updating
    if Snooker,
        DSS = PRP(1:N , 1:D) - Z(id_CH(1:N,1), 1:D); % nominator difference of Eq 4
        DS  = CH(1:N, 1:D, t-1) - Z(id_CH(1:N,1), 1:D); % denominator difference of Eq 4
        % Dot function yields norm of each chain in matrix of all chains
        C_sn = ( dot(DSS,DSS,2) ./ dot(DS,DS,2) ).^((D-1)/2);
    end
    
    %% Calculate Likelihood %%
    PRP(1:N, D+1:D+2) = Calc_PDV(PRP(1:N, 1:D),Family,EP,EBVP,j,Parallel);
    % Compute Metropolis ratio: a/b = exp( log(a) - log(b) )
    MR = min(1, C_sn .* exp(PRP(1:N, end) - CH(1:N, end, t-1)) );
    % Accept/reject the proposal point
    id_accp = find( MR >= rand(N,1) );
    id_rjct = setdiff(1:N, id_accp);
    
    %% Accept proposal and update chain %%
    CH(id_accp, 1:D+2, t) = PRP(id_accp, 1:D+2);
    % Reject proposal and remain at the previous state
    CH(id_rjct, 1:D+2, t) = CH(id_rjct, 1:D+2, t-1);
    dPRP(id_rjct, 1:D) = 0;
    
    %% Check for outliers: remark 3, page 275 of Vrugt 2009
    OLR{t} = OUTLIER(CH, t);
    if D > 3
        [~,id_olr] = sort(CH(:,end,t-1),'descend');
        CH(OLR{t},:,t) = CH(id_olr(1:length(OLR{t})),:,t-1);
    end
    
    
    %% Total Parameter Sets
    TPAR = [TPAR; CH(1:N, 1:D+2, t)];
    
    %% Check convergence, every 10 steps
    if rem(t,10) == 0
        dummy = Convergence_GR( CH(1:N, 1:D, 1:t) );
        Rhat = [Rhat; [t dummy]];
    end
    
    %% Update Z each 10 iterations
    if rem(t,10) == 0
        Z = [Z; CH(1:N, 1:D, t)];
    end
    
end

% close wait bar
try
close(h)
catch
end

end

%% Calculate probabilty density value
% Log likelihood of residuals, e, if they are uncorrelated, homoskedastic, gaussian distributed with zero mean
% log(L) = -n/2 * log(2pi) - n/2 * log(sigma^2) - 1/(2*sigma^2) * sum(e^2)
% sigma^2 = sum(e^2)/n ==> 1/(2*sigma^2) * sum(e^2) = n/2
% ==> log(L) = -n/2 - n/2 * log(2pi) - n/2 * log(sigma^2)
% ==> log(L) = Constant              - n/2 * log(sum(e^2)/n) 
function [OUT] = Calc_PDV(X,Family,EP,EBVP,j,Parallel)
if ~Parallel
    for i = 1:size(X,1)
        % Simulate copula probabilities
        [~,RES,~] = Copula_Families_CDF(EP,EBVP,Family{j},X(i,:),2);
        % Assign RES vector to the PDV values (trick to decrease simuations later)
        PDV(i,1) = nan;
        % Compute log-likelihood
        L_PDV(i,1) = -length(RES)/2 * log( sum(RES.^2)/length(RES) );
    end
else
    parfor i = 1:size(X,1)
        % Simulate copula probabilities
        [~,RES,~] = Copula_Families_CDF(EP,EBVP,Family{j},X(i,:),2);
        % Assign RES vector to the PDV values (trick to decrease simuations later)
        PDV(i,1) = nan;
        % Compute log-likelihood
        L_PDV(i,1) = -length(RES)/2 * log( sum(RES.^2)/length(RES) );
    end
end
OUT = [PDV, L_PDV];
end


%% Boundary handling: General Knowledge
function PRP = Bound_handle(PRP, PAR_RANGE)
for i = 1:size(PRP,1)
    % Find parameter values less than minimum range
    id = find(PRP(i , :) < PAR_RANGE.min);
    % Fold them back in the range                                  make sure not to fall outside of the other limit!
    if ~isempty(id)
        PRP(i, id) = PAR_RANGE.min(id) + min( abs(PAR_RANGE.min(id) - PRP(i, id)), PAR_RANGE.max(id) - PAR_RANGE.min(id) );
    end
    
    % Find parameter values less than minimum range
    id = find(PRP(i , :) > PAR_RANGE.max);
    % Fold them back in the range                                  make sure not to fall outside of the other limit!
    if ~isempty(id)
        PRP(i, id) = PAR_RANGE.max(id) - min( abs(PAR_RANGE.max(id) - PRP(i, id)), PAR_RANGE.max(id) - PAR_RANGE.min(id) );
    end
end
end

%% Check for outliers: remark 3, page 275 of Vrugt 2009
function OLR = OUTLIER(CH, t)
% Compute mean of the loglikelihood for each chain
L = mean( CH(:, end, floor(t/2):t-1), 3);
% Compute interquartile
IQR = iqr(L);
% First Quartile
Q1 = quantile(L, 0.25);
% Find out if any chain is outlier
OLR = find( CH(:, end, t) < Q1 - 2*IQR);

end

function Rhat = Convergence_GR(CH)

% References:
% Gelman, Andrew, and Donald B. Rubin. "Inference from iterative simulation using multiple sequences." Statistical science (1992): 457-472.
% Brooks, Stephen P., and Andrew Gelman. "General methods for monitoring convergence of iterative simulations." Journal of computational and graphical statistics 7.4 (1998): 434-455.

% Determine number of iterations and take the second half of them
[~ ,~ ,n_iter] = size(CH);
CH = CH(:, :, round(n_iter/2):end);

% Update n_iter
[n_chain,n_par,n_iter] = size(CH);

% Compute mean and variances of each chain, as well variance of means
MEAN = mean(CH, 3); MEAN_VAR = var(MEAN);
VAR = var(CH, [], 3);

% Compute B (between) and W (within chain variances); following page 436 of ref 2
B = n_iter * MEAN_VAR;
W = mean(VAR);


% Compute sigma^2: first eq of page 437 of ref 2
S2 = (n_iter-1)/n_iter * W + B/n_iter;

% Compute rhat for univariate analysis
Rhat = sqrt( (n_chain+1)/n_chain * S2./W - (n_iter-1)/(n_chain*n_iter) );
end

function MvCAT_Copula_Plot(EP,EBVP,PAR,ID_CHOSEN,Family,handles)
PWD1 = pwd;
% Get size of screen in inches
%Sets the units of your root object (screen) to inches
set(0,'units','inches');
%Obtains this inch information
Inch_SS = get(0,'screensize');
% Remove zero and find minimum size of screen dimensions
Inch_SS( Inch_SS == 0 ) = [];
Inch_SS = min( Inch_SS );

%% Plot empirical and copula-based bivariate probability

hh = msgbox({'........................................',...
    '........................................',...
    'MvCAT is ploting copulas',...
    'if you run t copula, be patient!',...
    '........................................',...
    '........................................'});


for ik = 1:length(ID_CHOSEN)
    % Define the figure size
    h = figure('visible','off');
    set(gcf,'color','w','units','inches','position',[0.4 0.4 0.85*Inch_SS 0.85*Inch_SS],'paperpositionmode','auto');
    
    % First plot the results of
    ax1 = axes('units','normalized'); axpos1 = [0.45 0.45 0.45 0.45]; set(ax1,'position',axpos1);
    box on; % axis square
    
    % Sample from everywhere in the square
    x = [linspace(1e-5,.95,400) linspace(0.95+1e-5,1-1e-5,500)];
    [xx,yy] = meshgrid(x,x);
    S = [xx(:),yy(:)];
    
    try
        % Find probability of samples
        [~,~,P] = Copula_Families_CDF(S,EBVP,Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))),1);
        
        % Plot fitted copula contours
        Prob_Plot1(S,P,0,Family,ID_CHOSEN,ik,handles,PAR)
        % Plot probability points
        plot(handles.data(:,1),handles.data(:,2),'b.','markersize',15)
    catch
        % Do nothing!
    end
    grid on;
    
    % set(gca,'fontsize',14)
    
    % Plot marginal of variable 1
    ax2 = axes('units','normalized'); axpos2 = [0.45 0.1 0.45 0.25]; set(ax2,'position',axpos2);
    box on;
    [DATA_U1, ID_D_U1] = sort(handles.data(:,1));
    plot(DATA_U1, EP(ID_D_U1, 1),'linewidth',2);
    axis([min(handles.data(:,1)) 1*max(handles.data(:,1)) 0 1])
    set(gca,'ytick',0:0.25:1)
    xlabel(handles.U1_name,'fontname','times','fontweight','bold','fontsize',12)
    ylabel('Probability','fontname','times','fontweight','bold','fontsize',12)
    grid on;
    
    set(gca,'fontsize',14)
    
    % Plot marginal of variable 2
    ax3 = axes('units','normalized'); axpos3 = [0.1 0.45 0.25 0.45]; set(ax3,'position',axpos3);
    box on;
    [DATA_U2, ID_D_U2] = sort(handles.data(:,2),'descend');
    plot(-EP(ID_D_U2, 2), DATA_U2,'linewidth',2);
    axis([-1 0 min(handles.data(:,2)) 1*max(handles.data(:,2))])
    set(gca,'xtick',-1:0.25:0,'xticklabel',{'1','0.75','0.5','0.25','0'})
    ylabel(handles.U2_name,'fontname','times','fontweight','bold','fontsize',12)
    xlabel('Probability','fontname','times','fontweight','bold','fontsize',12)
    ax = gca;
    ax.XTickLabelRotation = 90;
    grid on;
    
    set(gca,'fontsize',14)
    
    % Save the graph to folder
    if ispc
        mkdir([pwd,'\Results\Copula_Data_Space'])
        cd([pwd,'\Results\Copula_Data_Space'])
    else
        mkdir([pwd,'/Results/Copula_Data_Space'])
        cd([pwd,'/Results/Copula_Data_Space'])
    end
    if ik == 1
        delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
    end
    eval(strcat('saveas(h,''Copula Data Space-',num2str(ik),'.png'')'))
    eval(strcat('saveas(h,''Copula Data Space-',num2str(ik),'.fig'')'))
    cd(PWD1)
    close(h)
    
end

try
close(hh); 
catch
end

end

% Plot joint probability contours; this is written based on observed data
% and their probabilities, but fitted copulas can readily be replaced
function Prob_Plot1(EP,EBVP,Emp,Family,ID_CHOSEN,ik,handles,PAR)
hold on;
% Sort data based on joint probability
[P_Sort, ID_Pr] = sort(EBVP);
% Associated uniform marginal probabilities
U1  = EP(ID_Pr, 1);
U2  = EP(ID_Pr, 2);

% Probability contours and their acceptable lower and upper bounds
P = 0.1:0.1:0.9;
if Emp
    P_LB = P - 0.0025*ones(1,9); P_UB = P + 0.0025*ones(1,9);
else
    P_LB = P - 0.0005*ones(1,9); P_UB = P + 0.0005*ones(1,9);
end

% Define size of text
SIZE = 14;

% Loop through probability contours
for j = 1:9
    % Find indices associated with each probability contour
    ID_Contour = find( P_Sort(:) >= P_LB(j) & P_Sort(:) <= P_UB(j) );
    
    % Sort first uniform marginal
    [UU, ID_U] = sort( U1(ID_Contour) );
    % Associated second uniform marginal
    VV = U2(ID_Contour);
    VVV = VV(ID_U);
    
    % Compute inverse of cdf for each varaible
    IUU = icdf( handles.PD_U1{handles.counter_D_U1}, UU );
    IVVV = icdf( handles.PD_U2{handles.counter_D_U2}, VVV );
    
    % Trick: remove infinity if there is any
    IDNAN = find( isinf(IUU) | isinf(IVVV) | isnan(IUU) | isnan(IVVV) );
    IUU(IDNAN) = []; IVVV(IDNAN) = [];
    
    if ~Emp
        % Calculate densities along the probability isoline
        [Dens] = Copula_Families_PDF([UU,VV(ID_U)],Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))));
        % Normalize Densities to the highest density value
        Dens = Dens / max(Dens);
        Dens(IDNAN) = [];
        
        if any(isnan(Dens)) % If analytical density doesn't exist, plot with red
            % Now plot
            plot(IUU, IVVV, 'r-', 'linewidth', ceil(SIZE/5));
            text(1.02*max(handles.data(:,1)),IVVV(end),num2str(0.1*j),'Color','red','FontSize',SIZE,'fontweight','bold')
            
            if j == 1 % Write the title once
                % Title (Left Adjusted)
                t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'P(X<x,Y<y)'}));
                set(t, 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE+4);
                set(t, 'units', 'normalized');
                h1 = get(t, 'position');
                set(t, 'position', [1 h1(2) h1(3)])

            end
            
        else % if analytical density does exist, color code probability isoline with density level
            try
                ZZ = zeros(size(IUU));
                col = Dens;  % This is the color, vary with x in this case.
                surface([IUU';IUU'],[IVVV';IVVV'],[ZZ';ZZ'],[col';col'],...
                    'facecol','no',...
                    'edgecol','interp',...
                    'linew',2);
                colormap(jet)
                if j == 1 % && i == 1
                    cb = colorbar('location','south');
                    set(cb, 'xlim', [0 1]);
                    set(cb,'position',[cb.Position(1) cb.Position(2) 0.6*cb.Position(3) 0.5*cb.Position(4)])
                end
                
                
                if j == 1 % Write the title once
                    t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'P(X<x,Y<y)'}));
                    set(t, 'units', 'normalized', 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE);
                    h1 = get(t, 'position');
                    set(t, 'position', [1 h1(2) h1(3)])
                end
                
                set(gca,'fontsize',14)
                
                text(1.02*max(handles.data(:,1)),IVVV(end),num2str(0.1*j),'Color','red','FontSize',10,'fontweight','bold')
            catch
            end
        end
    end
    
end
box on; %axis square
axis([min(handles.data(:,1)) 1*max(handles.data(:,1)) min(handles.data(:,2)) 1*max(handles.data(:,2))])
end

function MvCAT_Survival_Plot(EP,EBVP,PAR,ID_CHOSEN,Family,handles)
PWD1 = pwd;
% Get size of screen in inches
%Sets the units of your root object (screen) to inches
set(0,'units','inches');
%Obtains this inch information
Inch_SS = get(0,'screensize');
% Remove zero and find minimum size of screen dimensions
Inch_SS( Inch_SS == 0 ) = [];
Inch_SS = min( Inch_SS );

%% Plot empirical and copula-based bivariate probability

hh = msgbox({'........................................',...
    '........................................',...
    'MvCAT is ploting copulas',...
    'if you run t copula, be patient!',...
    '........................................',...
    '........................................'});


for ik = 1:length(ID_CHOSEN)
    % Define the figure size
    h = figure('visible','off');
    set(gcf,'color','w','units','inches','position',[0.4 0.4 0.85*Inch_SS 0.85*Inch_SS],'paperpositionmode','auto');
    
    % First plot the results of
    ax1 = axes('units','normalized'); axpos1 = [0.45 0.45 0.45 0.45]; set(ax1,'position',axpos1);
    box on; % axis square
    
    % Sample from everywhere in the square
    x = [linspace(1e-5,.95,400) linspace(0.95+1e-5,1-1e-5,500)];
    [xx,yy] = meshgrid(x,x);
    S = [xx(:),yy(:)];
    
    try
        % Find probability of samples
        [~,~,P] = Copula_Families_CDF(S,EBVP,Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))),1);
        EP1 = cdf(handles.PD_U1{handles.counter_D_U1},icdf( handles.PD_U1{handles.counter_D_U1}, S(:,1)));
        EP2 = cdf(handles.PD_U2{handles.counter_D_U2},icdf( handles.PD_U2{handles.counter_D_U2}, S(:,2)));
        
        P = 1 - EP1 - EP2 + P;
        
        % Plot fitted copula contours
        Prob_Plot1_2(S,P,0,Family,ID_CHOSEN,ik,handles,PAR)
        % Plot probability points
        plot(handles.data(:,1),handles.data(:,2),'b.','markersize',15)
    catch
        % Do nothing!
    end
    grid on;
    
    % set(gca,'fontsize',14)
    
    % Plot marginal of variable 1
    ax2 = axes('units','normalized'); axpos2 = [0.45 0.1 0.45 0.25]; set(ax2,'position',axpos2);
    box on;
    [DATA_U1, ID_D_U1] = sort(handles.data(:,1));
    plot(DATA_U1, EP(ID_D_U1, 1),'linewidth',2);
    axis([min(handles.data(:,1)) 1*max(handles.data(:,1)) 0 1])
    set(gca,'ytick',0:0.25:1)
    xlabel(handles.U1_name,'fontname','times','fontweight','bold','fontsize',12)
    ylabel('Probability','fontname','times','fontweight','bold','fontsize',12)
    grid on;
    
    set(gca,'fontsize',14)
    
    % Plot marginal of variable 2
    ax3 = axes('units','normalized'); axpos3 = [0.1 0.45 0.25 0.45]; set(ax3,'position',axpos3);
    box on;
    [DATA_U2, ID_D_U2] = sort(handles.data(:,2),'descend');
    plot(-EP(ID_D_U2, 2), DATA_U2,'linewidth',2);
    axis([-1 0 min(handles.data(:,2)) 1*max(handles.data(:,2))])
    set(gca,'xtick',-1:0.25:0,'xticklabel',{'1','0.75','0.5','0.25','0'})
    ylabel(handles.U2_name,'fontname','times','fontweight','bold','fontsize',12)
    xlabel('Probability','fontname','times','fontweight','bold','fontsize',12)
    ax = gca;
    ax.XTickLabelRotation = 90;
    grid on;
    
    set(gca,'fontsize',14)
    
    % Save the graph to folder
    if ispc
        mkdir([pwd,'\Results\Survival_Copula'])
        cd([pwd,'\Results\Survival_Copula'])
    else
        mkdir([pwd,'/Results/Survival_Copula'])
        cd([pwd,'/Results/Survival_Copula'])
    end
    if ik == 1
        delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
    end
    eval(strcat('saveas(h,''Survival_Copula Data Space-',num2str(ik),'.png'')'))
    eval(strcat('saveas(h,''Survival_Copula Data Space-',num2str(ik),'.fig'')'))
    cd(PWD1)
    close(h)
    
end

try
close(hh); 
catch
end

end

% Plot joint probability contours; this is written based on observed data
% and their probabilities, but fitted copulas can readily be replaced
function Prob_Plot1_2(EP,EBVP,Emp,Family,ID_CHOSEN,ik,handles,PAR)
hold on;
% Sort data based on joint probability
[P_Sort, ID_Pr] = sort(EBVP);
% Associated uniform marginal probabilities
U1  = EP(ID_Pr, 1);
U2  = EP(ID_Pr, 2);

% Probability contours and their acceptable lower and upper bounds
P = [0.01 0.05 0.1:0.1:0.9];
if Emp
    P_LB = P - 0.0025*ones(1,length(P)); P_UB = P + 0.0025*ones(1,length(P));
else
    P_LB = P - 0.0005*ones(1,length(P)); P_UB = P + 0.0005*ones(1,length(P));
end

% Define size of text
SIZE = 14;

% Loop through probability contours
for j = 1:length(P)
    % Find indices associated with each probability contour
    ID_Contour = find( P_Sort(:) >= P_LB(j) & P_Sort(:) <= P_UB(j) );
    
    % Sort first uniform marginal
    [UU, ID_U] = sort( U1(ID_Contour) );
    % Associated second uniform marginal
    VV = U2(ID_Contour);
    VVV = VV(ID_U);
    
    % Compute inverse of cdf for each varaible
    IUU = icdf( handles.PD_U1{handles.counter_D_U1}, UU );
    IVVV = icdf( handles.PD_U2{handles.counter_D_U2}, VVV );
    
    % Trick: remove infinity if there is any
    IDNAN = find( isinf(IUU) | isinf(IVVV) | isnan(IUU) | isnan(IVVV) );
    IUU(IDNAN) = []; IVVV(IDNAN) = [];
    
    if ~Emp
        % Calculate densities along the probability isoline
        [Dens] = Copula_Families_PDF([UU,VV(ID_U)],Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))));
        % Normalize Densities to the highest density value
        Dens = Dens / max(Dens);
        Dens(IDNAN) = [];
        
        if any(isnan(Dens)) % If analytical density doesn't exist, plot with red
            % Now plot
            plot(IUU, IVVV, 'r-', 'linewidth', ceil(SIZE/5));
            text(min(handles.data(:,1)),IVVV(1),num2str(P(j)),'Color','red','FontSize',SIZE,'fontweight','bold')
                        
            if j == 1 % Write the title once
                % Title (Left Adjusted)
                t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'P(X>x,Y>y)'}));
                set(t, 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE+4);
                set(t, 'units', 'normalized');
                h1 = get(t, 'position');
                set(t, 'position', [1 h1(2) h1(3)])

            end
            
        else % if analytical density does exist, color code probability isoline with density level
            try
                ZZ = zeros(size(IUU));
                col = Dens;  % This is the color, vary with x in this case.
                surface([IUU';IUU'],[IVVV';IVVV'],[ZZ';ZZ'],[col';col'],...
                    'facecol','no',...
                    'edgecol','interp',...
                    'linew',2);
                colormap(jet)
                if j == 1 % && i == 1
                    cb = colorbar('location','south');
                    set(cb, 'xlim', [0 1]);
                    set(cb,'position',[cb.Position(1) cb.Position(2) 0.6*cb.Position(3) 0.5*cb.Position(4)])
                end
                
                
                if j == 1 % Write the title once
                    t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'P(X>x,Y>y)'}));
                    set(t, 'units', 'normalized', 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE);
                    h1 = get(t, 'position');
                    set(t, 'position', [1 h1(2) h1(3)])
                    
                end
                
                set(gca,'fontsize',14)
                
                text(min(handles.data(:,1)),IVVV(1),num2str(P(j)),'Color','red','FontSize',10,'fontweight','bold')
            catch
            end
        end
    end
    
end
box on; %axis square
axis([min(handles.data(:,1)) 1*max(handles.data(:,1)) min(handles.data(:,2)) 1*max(handles.data(:,2))])
end

function MvCAT_Copula_Prob_Plot(EP,EBVP,PAR,ID_CHOSEN,Family,handles)
PWD1 = pwd;
% Get size of screen in inches
%Sets the units of your root object (screen) to inches
set(0,'units','inches');
%Obtains this inch information
Inch_SS = get(0,'screensize');
% Remove zero and find minimum size of screen dimensions
Inch_SS( Inch_SS == 0 ) = [];
Inch_SS = min( Inch_SS );

%% Plot empirical and copula-based bivariate probability

hh = msgbox({'........................................',...
    '........................................',...
    'MvCAT is ploting copulas',...
    'if you run t copula, be patient!',...
    '........................................',...
    '........................................'});


for ik = 1:length(ID_CHOSEN)
    % Define the figure size
    h = figure('visible','off');
    set(gcf,'color','w','units','inches','position',[0.4 0.4 0.85*Inch_SS 0.85*Inch_SS],'paperpositionmode','auto');
    
    % First plot the results 
    ax1 = axes('units','normalized'); axpos1 = [0.15 0.2 0.7 0.7]; set(ax1,'position',axpos1); hold on;
    box on; % axis square
    
    % Sample from everywhere in the square
    x = [linspace(1e-5,.95,400) linspace(0.95+1e-5,1-1e-5,500)];
    [xx,yy] = meshgrid(x,x);
    S = [xx(:),yy(:)];
    
    try
        % Plot empirical bivariate probability contours
        Prob_Plot2(EP,EBVP,1,Family,ID_CHOSEN,ik,handles,PAR)
        
        % Find probability of samples
        [~,~,P] = Copula_Families_CDF(S,EBVP,Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))),1);
        
        % Plot fitted copula contours
        Prob_Plot2(S,P,0,Family,ID_CHOSEN,ik,handles,PAR)
        % Plot probability points
        plot(EP(:,1),EP(:,2),'b.','markersize',10)
    catch
        % Do nothing!
    end
    
    % Define size of text
    SIZE = 14;
    
    % Add some info to the graph
    text(1.25,0.1,'Color coded: Fitted','Color','red','FontSize',SIZE,'fontweight','bold','fontname','times','rotation',90)
    text(1.25,0.7,'Black: Empirical','Color','black','FontSize',SIZE,'fontweight','bold','fontname','times','rotation',90);
    
    % Save the graph to folder
    if ispc
        mkdir([pwd,'\Results\Copula_Prob_Space'])
        cd([pwd,'\Results\Copula_Prob_Space'])
    else
        mkdir([pwd,'/Results/Copula_Prob_Space'])
        cd([pwd,'/Results/Copula_Prob_Space'])
    end
    if ik == 1
        delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
    end
    eval(strcat('saveas(h,''Copula Probability Space-',num2str(ik),'.png'')'))
    eval(strcat('saveas(h,''Copula Probability Space-',num2str(ik),'.fig'')'))
    cd(PWD1)
    close(h)
end
try
close(hh)
catch
end

end

% Plot joint probability contours; this is written based on observed data
% and their probabilities, but fitted copulas can readily be replaced
function Prob_Plot2(EP,EBVP,Emp,Family,ID_CHOSEN,ik,handles,PAR)
% Sort data based on joint probability
[P_Sort, ID_Pr] = sort(EBVP);
% Associated uniform marginal probabilities
U1  = EP(ID_Pr, 1);
U2  = EP(ID_Pr, 2);

% Probability contours and their acceptable lower and upper bounds
P = 0.1:0.1:0.9;
if Emp
    P_LB = P - 0.0025*ones(1,9); P_UB = P + 0.0025*ones(1,9);
else
    P_LB = P - 0.0005*ones(1,9); P_UB = P + 0.0005*ones(1,9);
end

% Define size of text
SIZE = 14;
T_SIZE = -0.1;


% Loop through probability contours
for j = 1:9
    % Find indices associated with each probability contour
    ID_Contour = find( P_Sort(:) >= P_LB(j) & P_Sort(:) <= P_UB(j) );
    
    % Sort first uniform marginal
    [UU, ID_U] = sort( U1(ID_Contour) );
    % Associated second uniform marginal
    VV = U2(ID_Contour);
    
    % Plot each probability contour
    if Emp && handles.EmProbIsLine
        plot(UU, VV(ID_U), 'k-', 'linewidth', ceil(SIZE/5));
    end
    if ~Emp
        % Calculate densities along the probability isoline
        [Dens] = Copula_Families_PDF([UU,VV(ID_U)],Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))));
        % Normalize Densities to the highest density value
        Dens = Dens / max(Dens);
        
        if any(isnan(Dens)) % If analytical density doesn't exist, plot with red
            % Now plot
            plot(UU, VV(ID_U), 'r-', 'linewidth', ceil(SIZE/5));
            text(1.01,VV(ID_U(end)),num2str(0.1*j),'Color','red','FontSize',SIZE,'fontweight','bold')
            
            if j == 1 % Write the title once
                % Title (Left Adjusted)
                t = title(strcat('\color{red}',upper(Family{ID_CHOSEN(ik)})));
                set(t, 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE+4);
                set(t, 'units', 'normalized');
                h1 = get(t, 'position');
                set(t, 'position', [1 h1(2) h1(3)])
            end
            
        else % if analytical density does exist, color code probability isoline with density level
            ZZ = zeros(size(Dens));
            col = Dens;  % This is the color, vary with x in this case.
            surface([UU';UU'],[VV(ID_U)';VV(ID_U)'],[ZZ';ZZ'],[col';col'],...
                'facecol','no',...
                'edgecol','interp',...
                'linew',2);
            colormap(jet)
            if j == 1 % && i == 1
                h = colorbar('location','northoutside');
                set(h, 'ylim', [0 1]);
            end
            text(1.01,VV(ID_U(end)),num2str(0.1*j),'Color','red','FontSize',SIZE,'fontweight','bold')
            
            if j == 1 % Write the title once
                t = title(strcat('\color{red}',upper(Family{ID_CHOSEN(ik)})),'rotation',90);
                set(t, 'units', 'normalized', 'verticalAlignment', 'bottom','fontname','times','fontweight','bold','fontsize',SIZE+4);
                h1 = get(t, 'position');
                set(t, 'position', [T_SIZE 0 h1(3)])
            end
        end
    end
    set(gca,'xtick',0:0.2:1)
    set(gca,'ytick',0:0.2:1)
    
    
end
box on; axis square
eval(['xlabel(''Probability of ',handles.U1_name,''',''fontname'',''times'',''fontweight'',''bold'',''fontsize'',SIZE)'])
eval(['ylabel(''Probability of ',handles.U2_name,''',''fontname'',''times'',''fontweight'',''bold'',''fontsize'',SIZE)'])
end

function [SSR,RES,P] = Copula_Families_CDF(EP,EBVP,Family,PAR,Option)

% Assign input variables
u = EP(:,1);
v = EP(:,2);

%% References used in this research:
% [1] Paul Embrechts, Filip Lindskog and Alexander McNeil, "Modelling Dependence with Copulas and Applications to Risk Management", 2001, Department of Mathematics, ETHZ, CH-8092 Zurich, Switzerland
% [2] Genest, Christian, and Anne-Catherine Favre. "Everything you always wanted to know about copula modeling but were afraid to ask." Journal of hydrologic engineering 12.4 (2007): 347-368.
% [3] Nelsen, Roger B. "Properties and applications of copulas: A brief survey." Proceedings of the First Brazilian Conference on Statistical Modeling in Insurance and Finance,(Dhaene, J., Kolev, N., Morettin, PA (Eds.)), University Press USP: Sao Paulo. 2003.
% [4] Huynh, Van-Nam, Vladik Kreinovich, and Songsak Sriboonchitta, eds. Modeling dependence in econometrics. Springer, 2014.

switch Family
    %% Matlab built-ins
    case 'Gaussian'
        P = copulacdf('Gaussian',EP,PAR);
    case 't'
        P = copulacdf('t',EP,PAR(1),PAR(2));
    case 'Clayton'
        P = copulacdf('Clayton',EP,PAR);
    case 'Frank'
        P = copulacdf('Frank',EP,PAR);
    case 'Gumbel'
        P = copulacdf('Gumbel',EP,PAR);
        
        %% One parameter copulas
    case 'Independence' % Copula #6 % DOUBLE-CHEKCED
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        P = u.*v;
        
    case 'AMH' % 'Ali-Mikhail-Haq' % Copula #7 % DOUBLE-CHEKCED
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 <= PAR(1) <= 1 is violated!'));
        end
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        P = u.*v ./ (1 - PAR(1)*(1-u).*(1-v));
        
    case 'Joe' % Copula #8 % DOUBLE-CHEKCED
        if PAR(1) < 1
            error(message('Condition 1 <= PAR(1) is violated!'));
        end
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        P = 1 - ( (1-u).^PAR(1) + (1-v).^PAR(1) - (1-u).^PAR(1) .* (1-v).^PAR(1) ) .^ (1/PAR(1));
        
    case 'FGM' % 'Farlie-Gumbel-Morgenstern' % Copula #9 % DOUBLE-CHECKED with Nelsen 2003
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 <= PAR(1) <= 1 is violated!'));
        end
        % Based on: https://people.math.ethz.ch/~embrecht/ftp/copchapter.pdf & http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v .* ( 1 + PAR(1)*(1-u).*(1-v) );
        
    case 'Plackett' % Copula #10 % DOUBLE-CHEKCED
        if PAR(1) <= 0
            error(message('Condition 0 < PAR(1)  is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = (1 + (PAR(1)-1).*(u+v) - sqrt( (1+(PAR(1)-1)*(u+v)).^2 - 4*PAR(1)*(PAR(1)-1)*u.*v ) ) / (2*(PAR(1)-1));
        
    case 'Cuadras-Auge' % Copula #11 %DOUBLE-CHECKED
        if PAR(1) < 0 || PAR(1) > 1
            error(message('Condition 0 =< PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = min(u,v).^PAR(1) .* (u.*v).^(1-PAR(1));
        
    case 'Raftery' % Copula #12 %DOUBLE-CHECKED
        if PAR(1) < 0 || PAR(1) >= 1
            error(message('Condition 0 =< PAR(1) < 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        id1 = find(u <= v); id2 = find(u > v);
        P(id1) = u(id1) - (1-PAR(1))/(1+PAR(1)) * u(id1).^(1/(1-PAR(1))) .* ( v(id1).^(-PAR(1)/(1-PAR(1))) - v(id1).^(1/(1-PAR(1))) );
        P(id2) = v(id2) - (1-PAR(1))/(1+PAR(1)) * v(id2).^(1/(1-PAR(1))) .* ( u(id2).^(-PAR(1)/(1-PAR(1))) - u(id2).^(1/(1-PAR(1))) );
        
    case 'Shih-Louis' % Copula #13  %DOUBLE-CHECKED
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        theta = u + v - 1; theta( theta>=0 ) = 1; theta( theta<0 ) = 0;
        if PAR(1) > 0
            P = (1-PAR(1)) * u.*v + PAR(1) * min(u,v);
        else
            P = (1+PAR(1)) * u.*v + PAR(1) * (u-1+v).*theta;
        end
        
    case 'Linear-Spearman' % Copula #14 %DOUBLE-CHECKED
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 =< PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        if 0<= PAR(1) && PAR(1) <= 1
            id1 = find( v <= u ); id2 = find( v > u );
            P(id1) = ( u(id1) + PAR(1)*(1-u(id1)) ) .* v(id1);
            P(id2) = ( v(id2) + PAR(1)*(1-v(id2)) ) .* u(id2);
        elseif -1 <= PAR(1) && PAR(1) <= 0
            id1 = find( u + v < 1 ); id2 = find( u + v >= 1 );
            P(id1) = (1+PAR(1)) * u(id1).*v(id1);
            P(id2) = u(id2).*v(id2) + PAR(1)*(1-u(id2)).*(1-v(id2));
        end
        
    case 'Cubic' % Copula #15 %DOUBLE-CHECKED
        if PAR(1) < -1 || PAR(1) > 2
            error(message('Condition -1 =< PAR(1) <= 2 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v.* ( 1 + PAR(1)*(u-1).*(v-1).*(2*u-1).*(2*v-1) );
        
    case 'Burr' % Copula #16 %DOUBLE-CHECKED
        if PAR(1) <= 0
            error(message('Condition 0 < PAR(1) is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u + v - 1 + ( (1-u).^(-1/PAR(1)) + (1-v).^(-1/PAR(1)) - 1 ).^(-PAR(1));
        
    case 'Nelsen' % Copula #17 %DOUBLE-CHECKED
        % Third equation after "2.43 Nelsen's copulas"
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = -1/PAR(1) * log( 1 + ( (exp(-PAR(1)*u)-1).*(exp(-PAR(1)*v)-1) ) ./ (exp(-PAR(1))-1) );
        
    case 'Galambos' % Copula #18  % DOUBLE-CHEKCED
        if PAR(1) < 0
            error(message('Condition 0 <= PAR(1) is violated!'));
        end
        % Based on Huynh 2014
        P = u.*v .* exp( ( (-log(u)).^(-PAR(1)) + (-log(v)).^(-PAR(1)) ).^(-1/PAR(1)) );
        
        %% Two parameter copulas
    case 'Marshal-Olkin' % Copula #19 %DOUBLE-CHECKED
        if PAR(1) < 0 || PAR(2) < 0
            error(message('Condition 0 =< PAR(1)  or 0 =< PAR(2) is violated!'));
        end
        % Based on: https://people.math.ethz.ch/~embrecht/ftp/copchapter.pdf & http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = min( u.^(1-PAR(1)).*v, u.*v.^(1-PAR(2)) );
        
    case 'Fischer-Hinzmann' % Copula #20 %DOUBLE-CHECKED
        if PAR(1) < 0 || PAR(1) > 1
            error(message('Condition 0 <= PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = ( PAR(1)*(min(u,v)).^PAR(2) + (1-PAR(1))*(u.*v).^PAR(2) ).^(1/PAR(2));
        
    case 'Roch-Alegre' % Copula #21 %DOUBLE-CHECKED
        if PAR(1) <= 0 || PAR(2) < 1
            error(message('Condition 0 < PAR(1) or 1 <= PAR(2)  is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = exp( 1 - ( ( ((1-log(u)).^PAR(1)-1).^PAR(2) + ((1-log(v)).^PAR(1)-1).^PAR(2) ).^(1/PAR(2)) + 1 ).^(1/PAR(1)) );
        
    case 'Fischer-Kock' % Copula #22 %DOUBLE-CHECKED
        % r: PAR(1), theta: PAR(2)
        if PAR(1) < 1 || PAR(2) > 1 || PAR(2) < -1
            error(message('Condition 1 <= PAR(1) or -1 <= PAR(2) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v .* ( 1 + PAR(2)*( 1-u.^(1/PAR(1)) ).*( 1-v.^(1/PAR(1)) ) ).^PAR(1);
        
    case 'BB1' % Copula #23 % DOUBLE-CHEKCED
        if PAR(1) <= 0 || PAR(2) < 1
            error(message('Condition 0 < PAR(1) or 1 <= PAR(2) is violated!'));
        end
        % Based on Genest 2007
        P = ( 1 + ( (u.^(-PAR(1))-1).^PAR(2) + (v.^(-PAR(1))-1).^PAR(2) ).^(1/PAR(2)) ).^(-1/PAR(1));
        
    case 'BB5' % Copula #24 % DOUBLE-CHEKCED
        if PAR(1) < 1 || PAR(2) <= 0
            error(message('Condition 1 <= PAR(1) or 0 < PAR(2) is violated!'));
        end
        % Based on Genest 2007
        P = exp( -( (-log(u)).^PAR(1) + (-log(v)).^PAR(1) - ( (-log(u)).^(-PAR(1)*PAR(2)) + (-log(v)).^(-PAR(1)*PAR(2)) ).^(-1/PAR(2)) ).^(1/PAR(1)) );
        
        %% Three parameter copulas
    case 'Tawn' % Copula #25 %DOUBLE-CHECKED
        % delta: PAR(1), rho: PAR(2), theta: PAR(3)
        if PAR(3) < 1 || PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 0 || PAR(2) > 1
            error(message('Condition 0 <= PAR(1 & 2) <= 1 or 1 <= PAR(3) is violated!'));
        end
        % Based on: http://www.springer.com/us/book/9783319033945
        P = exp( log(u.^(1-PAR(1))) + log(v.^(1-PAR(2))) - ( (-PAR(1)*log(u)).^PAR(3) + (-PAR(2)*log(v)).^PAR(3) ).^(1/PAR(3)) );
        
        %% Rest of these copulas are too complex for the optimization algorithm, or costly to evaluate, or don't provide more info compared to previous ones
        % These are included in the code for the sake of completeness
    case 'Husler-Reiss' % Copula #18 % DOUBLE-CHEKCED
        if PAR(1) < 0
            error(message('Condition 0 <= PAR(1) is violated!'));
        end
        % Based on: http://www.springer.com/us/book/9783319033945: EQUATION IS CORRECTED! & DOUBLE-CHEKCED with Genest 2007
        P = exp( log(u).*normcdf(1/PAR(1)+0.5*PAR(1)*log(log(u)./log(v))) + log(v).*normcdf(1/PAR(1)+0.5*PAR(1)*log(log(u)./log(v))) );
        
    case 'Huang-Kotz' % Copula #28 % DOUBLE-CHEKCED
        if PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 1
            error(message('Condition 0 <= PAR(1) <= 1 or PAR(2) >= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v + PAR(1)*u.*v .* (1-u).^PAR(2).*(1-v).^PAR(2);
        
    case 'Cube' % DOUBLE-CHEKCED
        % a: PAR(1), q0: PAR(2), q1: PAR(3), q2: PAR(4)
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % Section 2.65
        id1 = find(u <= PAR(1) & v <= PAR(1)); id2 = find(u <= PAR(1) & PAR(1) < v);
        id3 = find(v <= PAR(1) & PAR(1) < u); id4 = find(PAR(1) < u & PAR(1) < v);
        P(id1) = PAR(4)  * u(id1).*v(id1);
        P(id2) = u(id2) .* ( PAR(4)*PAR(1) + PAR(3)*(v(id2)-PAR(1)) );
        P(id3) = v(id3) .* ( PAR(4)*PAR(1) + PAR(3)*(u(id3)-PAR(1)) );
        P(id4) = PAR(4)*PAR(1)^2 + PAR(3)*PAR(1)*(u(id4)+v(id4)-2*PAR(1)) + PAR(2)*(u(id4)-PAR(1)).*(v(id4)-PAR(1));
        
    case 'Schmitz' % DOUBLE-CHEKCED
        if PAR(1) < 1 || rem(PAR(1),1) ~= 0
            error(message('Condition 1 <= PAR(1) or PAR(1) being integer is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % Section 2.37
        P = v - ( (1-u).^(1/PAR(1)) + v.^(1/PAR(1)) ).^PAR(1);
        
    case 'Knockaert' % DOUBLE-CHEKCED
        % epsilon: PAR(1), delta: PAR(2), m: PAR(3), n: PAR(4)
        if PAR(1) == 1 || PAR(1) == -1, Check = 'true'; else Check = 'false'; end
        if ~Check || PAR(2) < 0 || PAR(2) > 2*pi || rem(PAR(3),1) ~= 0 || rem(PAR(4),1) ~= 0
            error(message('Conditions are violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v + PAR(1)./(4*pi^2*PAR(3)*PAR(4)) .* ( cos(2*pi*(PAR(3)*v-PAR(2))) + cos(2*pi*(PAR(4)*u-PAR(2))) - cos(2*pi*(PAR(4)*u+PAR(3)*v-PAR(2))) - cos(2*pi*PAR(2)) );
        
    case 'Frechet' % DOUBLE-CHEKCED
        if PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 0 || PAR(2) > 1 || PAR(1) + PAR(2) > 1
            error(message('Condition 0 <= PAR(1),PAR(2) <= 1 or PAR(1)+PAR(2) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = PAR(1) * min(u,v) + (1-PAR(1)-PAR(2)) * u.*v + PAR(2) * max(u+v-1,0);
end
%% Make output a column vector
P = P(:);
RES = nan(size(P)); SSR = nan(size(P));
if Option == 2
    % Residuals
    RES = P - EBVP;
    % Calculate sum of squared residuals
    SSR = sum( RES.^2 );
end
end

function [D] = Copula_Families_PDF(EP,Family,PAR)
% D stands for density

% Assign input variables
u = EP(:,1);
v = EP(:,2);

%% References used in this research:
% [1] Paul Embrechts, Filip Lindskog and Alexander McNeil, "Modelling Dependence with Copulas and Applications to Risk Management", 2001, Department of Mathematics, ETHZ, CH-8092 Zurich, Switzerland
% [2] Genest, Christian, and Anne-Catherine Favre. "Everything you always wanted to know about copula modeling but were afraid to ask." Journal of hydrologic engineering 12.4 (2007): 347-368.
% [3] Nelsen, Roger B. "Properties and applications of copulas: A brief survey." Proceedings of the First Brazilian Conference on Statistical Modeling in Insurance and Finance,(Dhaene, J., Kolev, N., Morettin, PA (Eds.)), University Press USP: Sao Paulo. 2003.
% [4] Huynh, Van-Nam, Vladik Kreinovich, and Songsak Sriboonchitta, eds. Modeling dependence in econometrics. Springer, 2014.

switch Family
    %% Matlab built-ins
    case 'Gaussian'
        D = copulapdf('Gaussian',EP,PAR);
    case 't'
        D = copulapdf('t',EP,PAR(1,1),PAR(1,2));
    case 'Clayton'
        D = copulapdf('Clayton',EP,PAR);
    case 'Frank'
        D = copulapdf('Frank',EP,PAR);
    case 'Gumbel'
        D = copulapdf('Gumbel',EP,PAR);
        
        %% One parameter copulas
    case 'Independence' % Copula #6 % DOUBLE-CHEKCED
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        % P = u.*v;
        D = ones( length(u), 1);
        
    case 'AMH' % 'Ali-Mikhail-Haq' % Copula #7 % DOUBLE-CHEKCED
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 <= PAR(1) <= 1 is violated!'));
        end
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        % P = u.*v ./ (1 - PAR(1)*(1-u).*(1-v));
        D = (u.*v.*PAR(1))./(PAR(1).*(u - 1).*(v - 1) - 1).^2 - 1./(PAR(1).*(u - 1).*(v - 1) - 1) + (u.*PAR(1).*(v - 1))./(PAR(1).*(u - 1).*(v - 1) - 1).^2 + (v.*PAR(1).*(u - 1))./(PAR(1).*(u - 1).*(v - 1) - 1).^2 - (2.*u.*v.*PAR(1).^2.*(u - 1).*(v - 1))./(PAR(1).*(u - 1).*(v - 1) - 1).^3;
        
    case 'Joe' % Copula #8 % DOUBLE-CHEKCED
        if PAR(1) < 1
            error(message('Condition 1 <= PAR(1) is violated!'));
        end
        % Based on Wikipedia: https://en.wikipedia.org/wiki/Copula_(probability_theory)
        % P = 1 - ( (1-u).^PAR(1) + (1-v).^PAR(1) - (1-u).^PAR(1) .* (1-v).^PAR(1) ) .^ (1/PAR(1));
        D = PAR(1).*(1 - u).^(PAR(1) - 1).*(1 - v).^(PAR(1) - 1).*((1 - u).^PAR(1) + (1 - v).^PAR(1) - (1 - u).^PAR(1).*(1 - v).^PAR(1)).^(1./PAR(1) - 1) - ((1./PAR(1) - 1).*(PAR(1).*(1 - u).^(PAR(1) - 1) - PAR(1).*(1 - u).^(PAR(1) - 1).*(1 - v).^PAR(1)).*(PAR(1).*(1 - v).^(PAR(1) - 1) - PAR(1).*(1 - u).^PAR(1).*(1 - v).^(PAR(1) - 1)).*((1 - u).^PAR(1) + (1 - v).^PAR(1) - (1 - u).^PAR(1).*(1 - v).^PAR(1)).^(1./PAR(1) - 2))./PAR(1);
        
    case 'FGM' % 'Farlie-Gumbel-Morgenstern' % Copula #9 % DOUBLE-CHECKED with Nelsen 2003
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 <= PAR(1) <= 1 is violated!'));
        end
        % Based on: https://people.math.ethz.ch/~embrecht/ftp/copchapter.pdf & http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = u.*v .* ( 1 + PAR(1)*(1-u).*(1-v) );
        D = u.*PAR(1).*(v - 1) + v.*PAR(1).*(u - 1) + PAR(1).*(u - 1).*(v - 1) + u.*v.*PAR(1) + 1;
        
    case 'Plackett' % Copula #10 % DOUBLE-CHEKCED
        if PAR(1) <= 0
            error(message('Condition 0 < PAR(1)  is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = (1 + (PAR(1)-1).*(u+v) - sqrt( (1+(PAR(1)-1).*(u+v)).^2 - 4.*PAR(1).*(PAR(1)-1).*u.*v ) ) ./ (2.*(PAR(1)-1));
        D = -((2.*(PAR(1) - 1).^2 - 4.*PAR(1).*(PAR(1) - 1))./(2.*(((u + v).*(PAR(1) - 1) + 1).^2 - 4.*u.*v.*PAR(1).*(PAR(1) - 1)).^(1./2)) - ((2.*(PAR(1) - 1).*((u + v).*(PAR(1) - 1) + 1) - 4.*u.*PAR(1).*(PAR(1) - 1)).*(2.*(PAR(1) - 1).*((u + v).*(PAR(1) - 1) + 1) - 4.*v.*PAR(1).*(PAR(1) - 1)))./(4.*(((u + v).*(PAR(1) - 1) + 1).^2 - 4.*u.*v.*PAR(1).*(PAR(1) - 1)).^(3./2)))./(2.*PAR(1) - 2);
        
    case 'Cuadras-Auge' % Copula #11 %NOT WORKING
        if PAR(1) < 0 || PAR(1) > 1
            error(message('Condition 0 =< PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = min(u,v).^PAR(1) .* (u.*v).^(1-PAR(1));
        D = nan( length(u), 1);
        
    case 'Raftery' % Copula #12 % HIGH ERROR MARGIN BECAUSE IT IS NOT WORKING FOR U == V; WE MANUALLY SET D TO ZERO FOR THIS CASE (ID3)  
        if PAR(1) < 0 || PAR(1) >= 1
            error(message('Condition 0 =< PAR(1) < 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % id1 = find(u < v); id2 = find(u > v); id3 = find(u == v);
        % P(id1) = u(id1) - (1-PAR(1))/(1+PAR(1)) * u(id1).^(1/(1-PAR(1))) .* ( v(id1).^(-PAR(1)/(1-PAR(1))) - v(id1).^(1/(1-PAR(1))) );
        % P(id2) = v(id2) - (1-PAR(1))/(1+PAR(1)) * v(id2).^(1/(1-PAR(1))) .* ( u(id2).^(-PAR(1)/(1-PAR(1))) - u(id2).^(1/(1-PAR(1))) );
        
        % D(id1) = -(1./(v(id1).^(1./(PAR(1) - 1) + 1).*(PAR(1) - 1)) + (v(id1).^(PAR(1)./(PAR(1) - 1) - 1).*PAR(1))./(PAR(1) - 1))./(u(id1).^(1./(PAR(1) - 1) + 1).*(PAR(1) + 1));
        % D(id2) = -(1./(u(id2).^(1./(PAR(1) - 1) + 1).*(PAR(1) - 1)) + (u(id2).^(PAR(1)./(PAR(1) - 1) - 1).*PAR(1))./(PAR(1) - 1))./(v(id2).^(1./(PAR(1) - 1) + 1).*(PAR(1) + 1));
        % D(id3) = 0;
        D = nan( length(u), 1);
        
    case 'Shih-Louis' % Copula #13  %NOT WORKING
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % theta = u + v - 1; theta( theta>=0 ) = 1; theta( theta<0 ) = 0;
        % if PAR(1) > 0
        %    P = (1-PAR(1)) * u.*v + PAR(1) * min(u,v);
        % else
        %    P = (1+PAR(1)) * u.*v + PAR(1) * (u-1+v).*theta;
        % end
        D = nan( length(u), 1);
        
    case 'Linear-Spearman' % Copula #14 %NOT WORKING
        if PAR(1) < -1 || PAR(1) > 1
            error(message('Condition -1 =< PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        if 0<= PAR(1) && PAR(1) <= 1
            % id1 = find( v <= u ); id2 = find( v > u );
            % P(id1) = ( u(id1) + PAR(1)*(1-u(id1)) ) .* v(id1);
            % P(id2) = ( v(id2) + PAR(1)*(1-v(id2)) ) .* u(id2);
            
            % D = (1 - PAR(1)) .* ones(length(u),1);
            D = nan( length(u), 1);
            
        elseif -1 <= PAR(1) && PAR(1) <= 0
            % id1 = find( u + v < 1 ); id2 = find( u + v >= 1 );
            % P(id1) = (1+PAR(1)) * u(id1).*v(id1);
            % P(id2) = u(id2).*v(id2) + PAR(1)*(1-u(id2)).*(1-v(id2));
            
            % D = (1 + PAR(1)) .* ones(length(u),1);
            D = nan( length(u), 1);
        end
        
    case 'Cubic' % Copula #15 %DOUBLE-CHECKED
        if PAR(1) < -1 || PAR(1) > 2
            error(message('Condition -1 =< PAR(1) <= 2 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = u.*v.* ( 1 + PAR(1)*(u-1).*(v-1).*(2*u-1).*(2*v-1) );
        D = v.*(PAR(1).*(2.*u - 1).*(2.*v - 1).*(u - 1) + 2.*PAR(1).*(2.*u - 1).*(u - 1).*(v - 1)) + u.*(PAR(1).*(2.*u - 1).*(2.*v - 1).*(v - 1) + 2.*PAR(1).*(2.*v - 1).*(u - 1).*(v - 1)) + u.*v.*(PAR(1).*(2.*u - 1).*(2.*v - 1) + 4.*PAR(1).*(u - 1).*(v - 1) + 2.*PAR(1).*(2.*u - 1).*(v - 1) + 2.*PAR(1).*(2.*v - 1).*(u - 1)) + PAR(1).*(2.*u - 1).*(2.*v - 1).*(u - 1).*(v - 1) + 1;

    case 'Burr' % Copula #16 %DOUBLE-CHECKED
        if PAR(1) <= 0
            error(message('Condition 0 < PAR(1) is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        %P = u + v - 1 + ( (1-u).^(-1/PAR(1)) + (1-v).^(-1/PAR(1)) - 1 ).^(-PAR(1));
        D = (PAR(1) + 1)./(PAR(1).*(1 - u).^(1./PAR(1) + 1).*(1 - v).^(1./PAR(1) + 1).*(1./(1 - u).^(1./PAR(1)) + 1./(1 - v).^(1./PAR(1)) - 1).^(PAR(1) + 2));
        
    case 'Nelsen' % Copula #17 %DOUBLE-CHECKED
        % Third equation after "2.43 Nelsen's copulas"
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = -1/PAR(1) * log( 1 + ( (exp(-PAR(1)*u)-1).*(exp(-PAR(1)*v)-1) ) ./ (exp(-PAR(1))-1) );
        D = (PAR(1).*exp(-u.*PAR(1)).*exp(-v.*PAR(1)).*(exp(-u.*PAR(1)) - 1).*(exp(-v.*PAR(1)) - 1))./((exp(-PAR(1)) - 1).^2.*(((exp(-u.*PAR(1)) - 1).*(exp(-v.*PAR(1)) - 1))./(exp(-PAR(1)) - 1) + 1).^2) - (PAR(1).*exp(-u.*PAR(1)).*exp(-v.*PAR(1)))./((exp(-PAR(1)) - 1).*(((exp(-u.*PAR(1)) - 1).*(exp(-v.*PAR(1)) - 1))./(exp(-PAR(1)) - 1) + 1));

    case 'Galambos' % Copula #18  % DOUBLE-CHEKCED
        if PAR(1) < 0
            error(message('Condition 0 <= PAR(1) is violated!'));
        end
        % Based on Huynh 2014
        % P = u.*v .* exp( ( (-log(u)).^(-PAR(1)) + (-log(v)).^(-PAR(1)) ).^(-1/PAR(1)) );
        D = exp(1./(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1))) - exp(1./(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1)))./((-log(u)).^(PAR(1) + 1).*(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1) + 1)) - exp(1./(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1)))./((-log(v)).^(PAR(1) + 1).*(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1) + 1)) + exp(1./(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1)))./((-log(u)).^(PAR(1) + 1).*(-log(v)).^(PAR(1) + 1).*(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(2./PAR(1) + 2)) + (PAR(1).*exp(1./(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1))).*(1./PAR(1) + 1))./((-log(u)).^(PAR(1) + 1).*(-log(v)).^(PAR(1) + 1).*(1./(-log(u)).^PAR(1) + 1./(-log(v)).^PAR(1)).^(1./PAR(1) + 2));

        %% Two parameter copulas
    case 'Marshal-Olkin' % Copula #19 % VERY HIGH ERROR MARGIN BECAUSE IT IS NOT WORKING FOR U == V; WE MANUALLY SET D TO ZERO FOR THIS CASE (ID3); AND PDF HAS U AND V IN DENOMINATOR (PROBLEMATIC AT 0)
        if PAR(1) < 0 || PAR(2) < 0
            error(message('Condition 0 =< PAR(1)  or 0 =< PAR(2) is violated!'));
        end
        % Based on: https://people.math.ethz.ch/~embrecht/ftp/copchapter.pdf & http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = min( u.^(1-PAR(1)).*v, u.*v.^(1-PAR(2)) );
        % idx1 = find( u.^(1-PAR(1)).*v < u.*v.^(1-PAR(2))); idx2 = find( u.^(1-PAR(1)).*v > u.*v.^(1-PAR(2))); idx3 = find( u.^(1-PAR(1)).*v == u.*v.^(1-PAR(2)));
        % D(idx1) = -(PAR(1) - 1)./u(idx1).^PAR(1);
        % D(idx2) = -(PAR(2) - 1)./v(idx2).^PAR(2);
        % D(idx3) = 0;
        D = nan( length(u), 1);
        
    case 'Fischer-Hinzmann' % Copula #20 % NOT WORKING
        if PAR(1) < 0 || PAR(1) > 1
            error(message('Condition 0 <= PAR(1) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = ( PAR(1).*(min(u,v)).^PAR(2) + (1-PAR(1)).*(u.*v).^PAR(2) ).^(1./PAR(2));
        % idx1 = find( u < v); idx2 = find( u > v); idx3 = find( u == v);
        % D(idx1) = - ((PAR(2).*(u(idx1).*v(idx1)).^(PAR(2) - 1).*(PAR(1) - 1) + u(idx1).*v(idx1).*PAR(2).*(u(idx1).*v(idx1)).^(PAR(2) - 2).*(PAR(1) - 1).*(PAR(2) - 1)).*(u(idx1).^PAR(2).*PAR(1) - (u(idx1).*v(idx1)).^PAR(2).*(PAR(1) - 1)).^(1./PAR(2) - 1))./PAR(2) - u(idx1).*(u(idx1).^(PAR(2) - 1).*PAR(1).*PAR(2) - v(idx1).*PAR(2).*(u(idx1).*v(idx1)).^(PAR(2) - 1).*(PAR(1) - 1)).*(1./PAR(2) - 1).*(u(idx1).*v(idx1)).^(PAR(2) - 1).*(PAR(1) - 1).*(u(idx1).^PAR(2).*PAR(1) - (u(idx1).*v(idx1)).^PAR(2).*(PAR(1) - 1)).^(1./PAR(2) - 2);
        % D(idx2) = - (u(idx2).*v(idx2)).^(PAR(2) - 1).*(PAR(1) - 1).*(v(idx2).^PAR(2).*PAR(1) - (u(idx2).*v(idx2)).^PAR(2).*(PAR(1) - 1)).^(1./PAR(2) - 1) - v(idx2).*(v(idx2).^(PAR(2) - 1).*PAR(1).*PAR(2) - u(idx2).*PAR(2).*(u(idx2).*v(idx2)).^(PAR(2) - 1).*(PAR(1) - 1)).*(1./PAR(2) - 1).*(u(idx2).*v(idx2)).^(PAR(2) - 1).*(PAR(1) - 1).*(v(idx2).^PAR(2).*PAR(1) - (u(idx2).*v(idx2)).^PAR(2).*(PAR(1) - 1)).^(1./PAR(2) - 2) - u(idx2).*v(idx2).*(u(idx2).*v(idx2)).^(PAR(2) - 2).*(PAR(1) - 1).*(PAR(2) - 1).*(v(idx2).^PAR(2).*PAR(1) - (u(idx2).*v(idx2)).^PAR(2).*(PAR(1) - 1)).^(1./PAR(2) - 1);
        % D(idx3) = 0;
        D = nan( length(u), 1);
        
    case 'Roch-Alegre' % Copula #21 %DOUBLE-CHECKED
        if PAR(1) <= 0 || PAR(2) < 1
            error(message('Condition 0 < PAR(1) or 1 <= PAR(2)  is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = exp( 1 - ( ( ((1-log(u)).^PAR(1)-1).^PAR(2) + ((1-log(v)).^PAR(1)-1).^PAR(2) ).^(1/PAR(2)) + 1 ).^(1/PAR(1)) );
        D = (exp(1 - ((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1))).*(1 - log(u)).^(PAR(1) - 1).*(1 - log(v)).^(PAR(1) - 1).*((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(2./PAR(1) - 2).*(((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(2./PAR(2) - 2).*((1 - log(u)).^PAR(1) - 1).^(PAR(2) - 1).*((1 - log(v)).^PAR(1) - 1).^(PAR(2) - 1))./(u.*v) - (PAR(1).*exp(1 - ((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1))).*(1./PAR(1) - 1).*(1 - log(u)).^(PAR(1) - 1).*(1 - log(v)).^(PAR(1) - 1).*((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1) - 2).*(((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(2./PAR(2) - 2).*((1 - log(u)).^PAR(1) - 1).^(PAR(2) - 1).*((1 - log(v)).^PAR(1) - 1).^(PAR(2) - 1))./(u.*v) - (PAR(1).*PAR(2).*exp(1 - ((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1))).*(1./PAR(2) - 1).*(1 - log(u)).^(PAR(1) - 1).*(1 - log(v)).^(PAR(1) - 1).*((((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1) - 1).*(((1 - log(u)).^PAR(1) - 1).^PAR(2) + ((1 - log(v)).^PAR(1) - 1).^PAR(2)).^(1./PAR(2) - 2).*((1 - log(u)).^PAR(1) - 1).^(PAR(2) - 1).*((1 - log(v)).^PAR(1) - 1).^(PAR(2) - 1))./(u.*v);
 
    case 'Fischer-Kock' % Copula #22 %DOUBLE-CHECKED
        % r: PAR(1), theta: PAR(2)
        if PAR(1) < 1 || PAR(2) > 1 || PAR(2) < -1
            error(message('Condition 1 <= PAR(1) or -1 <= PAR(2) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % P = u.*v .* ( 1 + PAR(2)*( 1-u.^(1/PAR(1)) ).*( 1-v.^(1/PAR(1)) ) ).^PAR(1);
        D = (PAR(2).*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1) + 1).^PAR(1) + u.*u.^(1./PAR(1) - 1).*PAR(2).*(v.^(1./PAR(1)) - 1).*(PAR(2).*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1) + 1).^(PAR(1) - 1) + v.*v.^(1./PAR(1) - 1).*PAR(2).*(u.^(1./PAR(1)) - 1).*(PAR(2).*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1) + 1).^(PAR(1) - 1) + (u.*u.^(1./PAR(1) - 1).*v.*v.^(1./PAR(1) - 1).*PAR(2).*(PAR(2).*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1) + 1).^(PAR(1) - 1))./PAR(1) + (u.*u.^(1./PAR(1) - 1).*v.*v.^(1./PAR(1) - 1).*PAR(2).^2.*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1).*(PAR(2).*(u.^(1./PAR(1)) - 1).*(v.^(1./PAR(1)) - 1) + 1).^(PAR(1) - 2).*(PAR(1) - 1))./PAR(1);

    case 'BB1' % Copula #23 % DOUBLE-CHEKCED ==> PROBLEMATIC AROUND ZERO FOR U AND V
        if PAR(1) <= 0 || PAR(2) < 1
            error(message('Condition 0 < PAR(1) or 1 <= PAR(2) is violated!'));
        end
        % Based on Genest 2007
        % P = ( 1 + ( (u.^(-PAR(1))-1).^PAR(2) + (v.^(-PAR(1))-1).^PAR(2) ).^(1/PAR(2)) ).^(-1/PAR(1));
        D = (PAR(1).*(1./u.^PAR(1) - 1).^(PAR(2) - 1).*(1./v.^PAR(1) - 1).^(PAR(2) - 1).*((1./u.^PAR(1) - 1).^PAR(2) + (1./v.^PAR(1) - 1).^PAR(2)).^(2./PAR(2) - 2).*(1./PAR(1) + 1))./(u.^(PAR(1) + 1).*v.^(PAR(1) + 1).*(((1./u.^PAR(1) - 1).^PAR(2) + (1./v.^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1) + 2)) - (PAR(1).*PAR(2).*(1./u.^PAR(1) - 1).^(PAR(2) - 1).*(1./v.^PAR(1) - 1).^(PAR(2) - 1).*((1./u.^PAR(1) - 1).^PAR(2) + (1./v.^PAR(1) - 1).^PAR(2)).^(1./PAR(2) - 2).*(1./PAR(2) - 1))./(u.^(PAR(1) + 1).*v.^(PAR(1) + 1).*(((1./u.^PAR(1) - 1).^PAR(2) + (1./v.^PAR(1) - 1).^PAR(2)).^(1./PAR(2)) + 1).^(1./PAR(1) + 1));
 
    case 'BB5' % Copula #24 % DOUBLE-CHEKCED  ==> PROBLEMATIC AROUND ZERO FOR U AND V
        if PAR(1) < 1 || PAR(2) <= 0
            error(message('Condition 1 <= PAR(1) or 0 < PAR(2) is violated!'));
        end
        % Based on Genest 2007
        % P = exp( -( (-log(u)).^PAR(1) + (-log(v)).^PAR(1) - ( (-log(u)).^(-PAR(1)*PAR(2)) + (-log(v)).^(-PAR(1)*PAR(2)) ).^(-1/PAR(2)) ).^(1/PAR(1)) );
        D = (exp(-((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(1./PAR(1))).*((PAR(1).*(-log(u)).^(PAR(1) - 1))./u - PAR(1)./(u.*(-log(u)).^(PAR(1).*PAR(2) + 1).*(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2) + 1))).*((PAR(1).*(-log(v)).^(PAR(1) - 1))./v - PAR(1)./(v.*(-log(v)).^(PAR(1).*PAR(2) + 1).*(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2) + 1))).*((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(2./PAR(1) - 2))./PAR(1).^2 - (exp(-((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(1./PAR(1))).*(1./PAR(1) - 1).*((PAR(1).*(-log(u)).^(PAR(1) - 1))./u - PAR(1)./(u.*(-log(u)).^(PAR(1).*PAR(2) + 1).*(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2) + 1))).*((PAR(1).*(-log(v)).^(PAR(1) - 1))./v - PAR(1)./(v.*(-log(v)).^(PAR(1).*PAR(2) + 1).*(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2) + 1))).*((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(1./PAR(1) - 2))./PAR(1) + (PAR(1).*PAR(2).*exp(-((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(1./PAR(1))).*(1./PAR(2) + 1).*((-log(u)).^PAR(1) + (-log(v)).^PAR(1) - 1./(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2))).^(1./PAR(1) - 1))./(u.*v.*(-log(u)).^(PAR(1).*PAR(2) + 1).*(-log(v)).^(PAR(1).*PAR(2) + 1).*(1./(-log(u)).^(PAR(1).*PAR(2)) + 1./(-log(v)).^(PAR(1).*PAR(2))).^(1./PAR(2) + 2));
 
        %% Three parameter copulas
    case 'Tawn' % Copula #25 %DOUBLE-CHECKED
        % delta: PAR(1), rho: PAR(2), theta: PAR(3)
        if PAR(3) < 1 || PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 0 || PAR(2) > 1
            error(message('Condition 0 <= PAR(1 & 2) <= 1 or 1 <= PAR(3) is violated!'));
        end
        % Based on: http://www.springer.com/us/book/9783319033945
        % P = exp( log(u.^(1-PAR(1))) + log(v.^(1-PAR(2))) - ( (-PAR(1)*log(u)).^PAR(3) + (-PAR(2)*log(v)).^PAR(3) ).^(1/PAR(3)) );
        D = exp(log(u.^(1 - PAR(1))) + log(v.^(1 - PAR(2))) - ((-PAR(1).*log(u)).^PAR(3) + (-PAR(2).*log(v)).^PAR(3)).^(1./PAR(3))).*((u.^(PAR(1) - 1).*(PAR(1) - 1))./u.^PAR(1) - (PAR(1).*((-PAR(1).*log(u)).^PAR(3) + (-PAR(2).*log(v)).^PAR(3)).^(1./PAR(3) - 1).*(-PAR(1).*log(u)).^(PAR(3) - 1))./u).*((v.^(PAR(2) - 1).*(PAR(2) - 1))./v.^PAR(2) - (PAR(2).*((-PAR(1).*log(u)).^PAR(3) + (-PAR(2).*log(v)).^PAR(3)).^(1./PAR(3) - 1).*(-PAR(2).*log(v)).^(PAR(3) - 1))./v) - (PAR(3).*PAR(1).*PAR(2).*exp(log(u.^(1 - PAR(1))) + log(v.^(1 - PAR(2))) - ((-PAR(1).*log(u)).^PAR(3) + (-PAR(2).*log(v)).^PAR(3)).^(1./PAR(3))).*(1./PAR(3) - 1).*((-PAR(1).*log(u)).^PAR(3) + (-PAR(2).*log(v)).^PAR(3)).^(1./PAR(3) - 2).*(-PAR(1).*log(u)).^(PAR(3) - 1).*(-PAR(2).*log(v)).^(PAR(3) - 1))./(u.*v);
 
        %% Rest of these copulas are too complex for the optimization algorithm, or costlPAR(1) to evaluate, or don't provide more info compared to previous ones
        % These are included in the code for the sake of completeness
    case 'Husler-Reiss' % Copula #18 % DOUBLE-CHEKCED
        if PAR(1) < 0
            error(message('Condition 0 <= PAR(1) is violated!'));
        end
        % Based on: http://www.springer.com/us/book/9783319033945: EQUATION IS CORRECTED! & DOUBLE-CHEKCED with Genest 2007
        P = exp( log(u).*normcdf(1/PAR(1)+0.5*PAR(1)*log(log(u)./log(v))) + log(v).*normcdf(1/PAR(1)+0.5*PAR(1)*log(log(u)./log(v))) );
        
    case 'Huang-Kotz' % Copula #28 % DOUBLE-CHEKCED
        if PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 1
            error(message('Condition 0 <= PAR(1) <= 1 or PAR(2) >= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v + PAR(1)*u.*v .* (1-u).^PAR(2).*(1-v).^PAR(2);
        
    case 'Cube' % DOUBLE-CHEKCED
        % a: PAR(1), q0: PAR(2), q1: PAR(3), q2: PAR(4)
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % Section 2.65
        id1 = find(u <= PAR(1) & v <= PAR(1)); id2 = find(u <= PAR(1) & PAR(1) < v);
        id3 = find(v <= PAR(1) & PAR(1) < u); id4 = find(PAR(1) < u & PAR(1) < v);
        P(id1) = PAR(4)  * u(id1).*v(id1);
        P(id2) = u(id2) .* ( PAR(4)*PAR(1) + PAR(3)*(v(id2)-PAR(1)) );
        P(id3) = v(id3) .* ( PAR(4)*PAR(1) + PAR(3)*(u(id3)-PAR(1)) );
        P(id4) = PAR(4)*PAR(1)^2 + PAR(3)*PAR(1)*(u(id4)+v(id4)-2*PAR(1)) + PAR(2)*(u(id4)-PAR(1)).*(v(id4)-PAR(1));
        
    case 'Schmitz' % DOUBLE-CHEKCED
        if PAR(1) < 1 || rem(PAR(1),1) ~= 0
            error(message('Condition 1 <= PAR(1) or PAR(1) being integer is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        % Section 2.37
        P = v - ( (1-u).^(1/PAR(1)) + v.^(1/PAR(1)) ).^PAR(1);
        
    case 'Knockaert' % DOUBLE-CHEKCED
        % epsilon: PAR(1), delta: PAR(2), m: PAR(3), n: PAR(4)
        if PAR(1) == 1 || PAR(1) == -1, Check = 'true'; else Check = 'false'; end
        if ~Check || PAR(2) < 0 || PAR(2) > 2*pi || rem(PAR(3),1) ~= 0 || rem(PAR(4),1) ~= 0
            error(message('Conditions are violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = u.*v + PAR(1)./(4*pi^2*PAR(3)*PAR(4)) .* ( cos(2*pi*(PAR(3)*v-PAR(2))) + cos(2*pi*(PAR(4)*u-PAR(2))) - cos(2*pi*(PAR(4)*u+PAR(3)*v-PAR(2))) - cos(2*pi*PAR(2)) );
        
    case 'Frechet' % DOUBLE-CHEKCED
        if PAR(1) < 0 || PAR(1) > 1 || PAR(2) < 0 || PAR(2) > 1 || PAR(1) + PAR(2) > 1
            error(message('Condition 0 <= PAR(1),PAR(2) <= 1 or PAR(1)+PAR(2) <= 1 is violated!'));
        end
        % Based on: http://www.maths.manchester.ac.uk/~saralees/chap20.pdf
        P = PAR(1) * min(u,v) + (1-PAR(1)-PAR(2)) * u.*v + PAR(2) * max(u+v-1,0);
end
%% Make output a column vector
D = D(:);

end

function Copula_Hist(TPAR,PAR,ID_CHOSEN,Family)
PWD1 = pwd;
% How many subplots?
dummy = PAR.LO(ID_CHOSEN,:); % Choose paramaters of selected copulas
NN = length(dummy(~isnan(dummy))); % How many parameters total: Number of total subplots

% How many plots, each inculding 5 subplots?
NP = ceil(NN/6); % Number of figures

% counter for ID_CHOSEN
ik = 0;

% How many subplots go into the current figure
NS = min(NN,6);

% Number of rows & columns in the plot
if NS <= 3
    NR = 1; NC = NS;
else
    NR = 2; NC = ceil(NS/2);
end

for ij = 1:NP
    h = figure('visible','off');
    % Define figure size
    set(gcf,'color','w','units','normalized','position',[.05 .05 .85 .85],'paperpositionmode','auto');
    
    i = 0; % subplot counter
    while i < min(NN-(ij-1)*NS,NS) && ik < length(ID_CHOSEN)% ik <26
        % Increase the counter of ID_CHOSEN
        ik = ik + 1;
        if ID_CHOSEN(ik) == 6 % Independent copula doesn't have any parameters
            continue
        end
        % Take not-nan parameters
        par_hist = TPAR(:,:,ID_CHOSEN(ik)); id_nan = find(isnan(par_hist(1,:))); id_not_nan = 1:(id_nan(1)-1); par_hist = par_hist(:,id_not_nan);
        ii = 0; % counter for number of parameters in each family
        while ii < length(id_not_nan) && i<6
            i = i + 1; % increase subplot counter
            ii = ii + 1; % increase counter of parameters in each family
            
            subplot(NR,NC,i);
            % Histogram of the posterior samples
            [N,X] = hist(par_hist(:,ii));
            % Plot posterior samples as bars
            % This the correct way: the area underneath the histogram should be 1
            % bar( X, trapz(X,N) )
            % This is the beautiful way
            bar(X,N/sum(N))
            % Get axis ranges
            ylim([0 0.4])
            % Make sure plots are square
            axis square
            
            % Plot the default value from matlab on top
            hold on; plot(PAR.LO( ID_CHOSEN(ik), ii),0.4,'r*','markersize',12,'linewidth',3);
            
            % Add theoretical parameter value if available
            if ~isnan( PAR.T(ID_CHOSEN(ik), ii) )
                plot(PAR.T(ID_CHOSEN(ik),1),0.4,'go','markersize',12,'linewidth',3);
                if i == 1
                    legend('MCMC','Local Opt.','Theoretical','location','northeast','Orientation','horizontal');
                end
            else
                if i == 1
                    legend('MCMC','Local Opt.','location','northeast','Orientation','horizontal');
                end
            end
            
            % Plot the best parameter estimated by MCMC and the 95% uncertainty range
            plot(PAR.MC( ID_CHOSEN(ik), ii), 0, 'bx', 'markersize',15,'linewidth',3); plot( prctile(par_hist(:,ii),2.5), 0, 'b+', prctile(par_hist(:,ii),97.5), 0, 'b+', 'markersize',12,'linewidth',3)
            
            % Define size of text
            if NS == 1
                SIZE = 16;
            elseif NS <= 3
                SIZE = 14;
            else SIZE = 12;
            end
            
            % Title
            eval(strcat(['title(''Par ',num2str(ii),' of ',upper(Family{ID_CHOSEN(ik)}),' Copula'',''fontname'',''times'',''fontsize'',',num2str(SIZE),',''fontweight'',''bold'')']));
        end
    end
    
    % Save the graph to folder
    if ispc
        mkdir([pwd,'\Results\ParameterHist'])
        cd([pwd,'\Results\ParameterHist'])
    else
        mkdir([pwd,'/Results/ParameterHist'])
        cd([pwd,'/Results/ParameterHist'])
    end
    if ik == 1
        delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
    end
    % Save the graph to folder
    eval(['saveas(h,''Parameter Histogram-',num2str(ij),'.png'')'])
    eval(['saveas(h,''Parameter Histogram-',num2str(ij),'.fig'')'])
    cd(PWD1)
    close(h)
end
end

function DesignValue = MvCAT_ReturnPeriod(EBVP,PAR,ID_CHOSEN,Family,handles)
PWD1 = pwd;
% Get size of screen in inches
%Sets the units of your root object (screen) to inches
set(0,'units','inches');
%Obtains this inch information
Inch_SS = get(0,'screensize');
% Remove zero and find minimum size of screen dimensions
Inch_SS( Inch_SS == 0 ) = [];
Inch_SS = min( Inch_SS );

% Set axis limits for U1 and U2
X_Axis = [min(handles.data(:,1)) 1.5*max(handles.data(:,1))];
Y_Axis = [min(handles.data(:,2)) 1.5*max(handles.data(:,2))];

% Preassign design value
DesignValue = nan(25,2);

%% Plot

hh = msgbox({'........................................',...
    '........................................',...
    'MvCAT is ploting copulas',...
    'if you run t copula, be patient!',...
    '........................................',...
    '........................................'});

% Sampling frequency
mu = 1;

for ik = 1:length(ID_CHOSEN)
    % Define the figure size
    h = figure('visible','off');
    set(gcf,'color','w','units','inches','position',[0.4 0.4 0.85*Inch_SS 0.85*Inch_SS],'paperpositionmode','auto');
    
    % First plot the results of
    ax1 = axes('units','normalized'); axpos1 = [0.45 0.45 0.45 0.45]; set(ax1,'position',axpos1);
    box on; % axis square
    
    % Sample from everywhere in the square
    x = [linspace(1e-5,.95,400) linspace(0.95+1e-5,1-1e-5,500)];
    [xx,yy] = meshgrid(x,x);
    S = [xx(:),yy(:)];
    
    try
        % Find probability of samples
        [~,~,P] = Copula_Families_CDF(S,EBVP,Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))),1);
        % Calculate return period
        RP = mu ./ (1- P);
        
        % Plot fitted copula contours
        DesignValue(ID_CHOSEN(ik),:) = Prob_Plot3(S,RP,Family,ID_CHOSEN,ik,handles,PAR,X_Axis,Y_Axis);
        % Plot data points
        plot(handles.data(:,1),handles.data(:,2),'b.','markersize',15)
        grid on
    catch
        DesignValue(ID_CHOSEN(ik),1:2) = nan(1,2);
        % Do nothing!
    end
    
    set(gca,'fontsize',14)
    
    ax2 = axes('units','normalized'); axpos2 = [0.45 0.1 0.45 0.25]; set(ax2,'position',axpos2);
    box on;
    
    % Compute inverse of cdf for each varaible
    ix = icdf(handles.PD_U1{handles.counter_D_U1},x);
    
    % Calculate associated return period
    RP_x = mu ./ (1- x);
    
    % Sort data for plotting (not necessarily here due to sorted nature of data)
    [DATA_U1, ID_D_U1] = sort(ix);
    semilogy(DATA_U1, RP_x(ID_D_U1),'linewidth',2);
    axis([X_Axis 0 200])
    set(gca,'ytick',[0,25,50,100,200])
    xlabel(handles.U1_name,'fontname','times','fontweight','bold','fontsize',12)
    ylabel('Return period','fontname','times','fontweight','bold','fontsize',12)
    grid on;
    
    set(gca,'fontsize',14)
    
    ax3 = axes('units','normalized'); axpos3 = [0.1 0.45 0.25 0.45]; set(ax3,'position',axpos3);
    box on;
    
    % Compute inverse of cdf for each varaible
    ix = icdf(handles.PD_U2{handles.counter_D_U2},x);
    
    % Calculate associated return period
    RP_x = mu ./ (1- x);
    
    [DATA_U2, ID_D_U2] = sort(ix);
    semilogx(-RP_x(ID_D_U2), DATA_U2, 'linewidth', 2);
    axis([-200 0 Y_Axis])
    set(gca,'xtick',[-200,-100,-50,-25,0],'xticklabel',{'200','100','50','25','0'}')
    xlabel('Return period','fontname','times','fontweight','bold','fontsize',12)
    ylabel(handles.U2_name,'fontname','times','fontweight','bold','fontsize',12)
    ax = gca;
    ax.XTickLabelRotation = 90;
    grid on;
    
    set(gca,'fontsize',14)
    
    % Save the graph to folder
    if ispc
        mkdir([pwd,'\Results\ReturnPeriod'])
        cd([pwd,'\Results\ReturnPeriod'])
    else
        mkdir([pwd,'/Results/ReturnPeriod'])
        cd([pwd,'/Results/ReturnPeriod'])
    end
    if ik == 1
        delete('*.txt'); delete('*.mat'); delete('*.png'); delete('*.fig');
    end
    eval(strcat('saveas(h,''Return Period-',num2str(ik),'.png'')'))
    eval(strcat('saveas(h,''Return Period-',num2str(ik),'.fig'')'))
    cd(PWD1)
    close(h)
end
try
close(hh)
catch
end

end

% Plot joint probability contours; this is written based on observed data
% and their probabilities, but fitted copulas can readily be replaced
function DesignValue = Prob_Plot3(EP,EBVP,Family,ID_CHOSEN,ik,handles,PAR,X_Axis,Y_Axis)
hold on;
% Sort data based on joint probability
[P_Sort, ID_Pr] = sort(EBVP);
% Associated uniform marginal probabilities
U1  = EP(ID_Pr, 1);
U2  = EP(ID_Pr, 2);

% Probability contours and their acceptable lower and upper bounds
P = [2,5,10,25,50,100];
P_LB = P - 0.005*P; P_UB = P + 0.005*P;

% Define size of text
SIZE = 12;

% Loop through probability contours
for j = 1:6
    % Find indices associated with each probability contour
    ID_Contour = find( P_Sort(:) >= P_LB(j) & P_Sort(:) <= P_UB(j) );
    
    % Sort first uniform marginal
    [UU, ID_U] = sort( U1(ID_Contour) );
    % Associated second uniform marginal
    VV = U2(ID_Contour);
    VVV = VV(ID_U);
    
    % Compute inverse of cdf for each varaible
    IUU = icdf(handles.PD_U1{handles.counter_D_U1},UU);
    IVVV = icdf(handles.PD_U2{handles.counter_D_U2},VVV);
    
    % Trick: remove infinity if there is any
    IDNAN = find( isinf(IUU) | isinf(IVVV) | isnan(IUU) | isnan(IVVV) );
    IUU(IDNAN) = []; IVVV(IDNAN) = [];
    
    % Calculate densities along the probability isoline
    [Dens] = Copula_Families_PDF([UU,VV(ID_U)],Family{ID_CHOSEN(ik)},PAR(ID_CHOSEN(ik),~isnan(PAR(ID_CHOSEN(ik),:))));
    % Normalize Densities to the highest density value
    Dens = Dens / max(Dens);
    Dens(IDNAN) = [];
    
    if any(isnan(Dens)) % If analytical density doesn't exist, plot with red
        % Now plot
        plot(IUU, IVVV, 'r-', 'linewidth', ceil(SIZE/5));
        text(1.02*X_Axis(2),IVVV(end),num2str(P(j)),'Color','red','FontSize',SIZE,'fontweight','bold')
        
        if j == 1 % Write the title once
            % Title (Left Adjusted)
            t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'Return Period'}));
            set(t, 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE+4);
            set(t, 'units', 'normalized');
            h1 = get(t, 'position');
            set(t, 'position', [1 h1(2) h1(3)])
        end
        
        % Design value
        IUU_design(1,j) = nan;
        IVVV_design(1,j) = nan;
        
    else % if analytical density does exist, color code probability isoline with density level
        ZZ = zeros(size(IUU));
        col = Dens;  % This is the color, vary with x in this case.
        surface([IUU';IUU'],[IVVV';IVVV'],[ZZ';ZZ'],[col';col'],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
        colormap(jet)
        if j == 1
            cb = colorbar('location','south');
            set(cb, 'xlim', [0 1]);
            set(cb,'position',[cb.Position(1) cb.Position(2) 0.6*cb.Position(3) 0.5*cb.Position(4)])
        end
        text(1.02*X_Axis(2),IVVV(end),num2str(P(j)),'Color','red','FontSize',SIZE,'fontweight','bold')
        
        if j == 1 % Write the title once
            t = title(strcat('\color{red}',{upper(Family{ID_CHOSEN(ik)});'Return Period'}));
            set(t, 'units', 'normalized', 'horizontalAlignment', 'right','fontname','times','fontweight','bold','fontsize',SIZE);
            h1 = get(t, 'position');
            set(t, 'position', [1 h1(2) h1(3)])
        end
        
        % Find maximum density on each RP level
        [~,id_design] = max(Dens);
        % Design value
        IUU_design(1,j) = IUU(id_design);
        IVVV_design(1,j) = IVVV(id_design);
    end
    
end
box on; %axis square
axis([X_Axis Y_Axis])

% Calculate design value
DesignValue = [sum(1./P .* IUU_design)/sum(1./P) sum(1./P .* IVVV_design)/sum(1./P)];
end




