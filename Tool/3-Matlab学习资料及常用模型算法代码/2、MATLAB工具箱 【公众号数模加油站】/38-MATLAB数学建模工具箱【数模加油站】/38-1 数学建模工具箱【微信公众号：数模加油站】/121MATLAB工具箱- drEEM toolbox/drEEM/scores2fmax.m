function [FMax,scores]=scores2fmax(data,f)

% Convert model scores to Fmax
%   
% USEAGE:
%           [FMax,scores]=scores2fmax(data,f)
%
% INPUTS
%      data: data structure containing model with f components.
%         f: number of components in model.
%
% OUTPUTS
%      FMax: fluorescence intensity maxima corresponding to the scores 
%            in data.Modelf
%        A : (optional) model scores 
%             
% Examples:
%  F6=scores2fmax(val6,6)
%  [F5,scores5]=scores2fmax(val5,5)
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% scores2fmax: Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(2,2)
nargoutchk(1,2)
M=getfield(data,{1,1},['Model' int2str(f)]);
scores=M{1};
FMax=NaN*ones(size(scores,1),size(M{2},2));
for i=1:size(scores,1)
    FMax(i,:)=(scores(i,:)).*(max(M{2}).*max(M{3}));
end


