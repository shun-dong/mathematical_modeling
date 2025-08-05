% The drEEM Toolbox for MATLAB (ver. 0.1.0)
% Version 0.1.0 1-June-2013
% Download from http://www.models.life.ku.dk/
%
% Copyright drEEM (C) 2013  Kathleen R. Murphy
% University of New South Wales, School of Civil & Environmental
% Engineering, UNSW 2052, Australia, krm@unsw.edu.au
%
% Copyright nwayparafac (C) 2013  Rasmus Bro & Claus Andersson
% Copenhagen University, DK-1958 Frederiksberg, Denmark, rb@life.ku.dk
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation version 3 of the License <http://www.gnu.org/licenses/>
%
% This program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with 
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin 
% Street, Fifth Floor, Boston, MA  02110-1301, USA.
%
%-----------------------------------------------
%GENERAL
%
%lookforconflicts          Check for conflicting functions
%
%-----------------------------------------------
%DATA IMPORT/EXPORT
%
%readineems                Load EEMs and assemble into a 3-way dataset
%readinscans               Load Scans and assemble into a 2-way dataset
%modelout                  Calculate Fmax and export models to Excel
%
%-----------------------------------------------
%DATA MANIPULATION
%
%assembledataset           Assemble EEMs and metadata into a dataset
%classinfo                 Summarise metadata associated with a dataset
%subdataset                Remove samples/wavelengths from a dataset
%smootheem                 Excise or smooth Rayleigh and Raman scatter
%splitds                   Sort, split and combine samples into new datasets
%zap                       Remove parts of EEMs from selected samples
%matchsamples              Match related samples in different datasets
%
%-----------------------------------------------
%AUXILIARY FUNCTIONS USING PARAFAC
%
%splitanalysis             Generate PARAFAC models nested in dataset splits
%splitvalidation           Validate PARAFAC models 
%specsse                   Plot sum of squared error residuals
%loadingsandleverages      Display PARAFAC loadings and leverages
%outliertest               Fast PARAFAC to identify unusual samples or wavelengths 
%randinitanal              PARAFAC with random initialisation and iteration
%nwayparafac               Multiway PARAFAC model (from nway toolbox)
%describecomp              Describe components in terms of Ex and Em maxima
%normeem                   Normalise EEM dataset to reduce collinearity
%scores2fmax               Obtain Fmax from model scores
%
%-----------------------------------------------
%PLOTTING
%
%eemview                   Customised EEM contour plots
%comparespectra            PARAFAC spectra in overlaid plots
%spectralloadings          PARAFAC spectra in individual plots
%fingerprint               PARAFAC spectra in contour plots
%compare2models            Compare measured, modeled and residual EEMs for two models
%relcomporder              Match up PARAFAC components in various split models
%compcorrplot              Plot scores for PARAFAC components against each other 
%
%-----------------------------------------------
%SPECTRAL CORRECTION
%
%ramanintegrationrange     Empirical calculator of Raman peak emission boundaries
%fdomcorr                  Apply spectral and/or inner filter corrections to EEMs
%undilute                  Adjust fluorescence intensities to account for dilution
%-----------------------------------------------
%
% References:
% (1) Reference for the drEEM toolbox
%     Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% (2) Reference for the N-way toolbox
%     Andersson C. A. and R. Bro, Chemom. Intell. Lab. Syst., 2000, 52, 1–4.
%  
% $ Version 0.1.0 $ September 2013 $ First Release