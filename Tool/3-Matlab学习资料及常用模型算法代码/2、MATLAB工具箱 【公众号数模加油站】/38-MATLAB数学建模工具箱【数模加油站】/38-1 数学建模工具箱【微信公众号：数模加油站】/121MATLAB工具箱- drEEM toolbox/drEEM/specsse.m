function specsse(data,n)

% Plot SSE (sum of squared error residuals) in excitation and emission 
% dimensions for one or more models, to help determine the appropriate
% number of PARAFAC components. A small decrease in SSE indicates that the
% last component added might be unnesscessary or detrimental.
%
%INPUT: specsse(data,n)
% data: A data structure containing PARAFAC models with the same number(s)
%       of components as indicated in the range of n
%    n: Number(s) of components in models to be plotted
%
%EXAMPLES:
%     specsse(Test2,3)
%     specsse(Test2,3:6)
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

emptymat=cell([length(n) 1]);
E_ex=emptymat;E_em=emptymat;
M=emptymat;E=emptymat;
for i=n;
    Model=['Model' int2str(i)];
    if isfield(data,Model)
        M{i}=nmodel(data.(Model));
        E{i}=data.X-M{i};
        intE_em=misssum(squeeze(misssum((permute(E{i},[2 1 3])).^2)));
        intE_ex=misssum(squeeze(misssum((permute(E{i},[3 1 2])).^2)));
        E_ex{i}=intE_em;
        E_em{i}=intE_ex;
    end
end

leg=[num2str((n)') repmat(' comp.',[length(n) 1])];
lincol=hsv(length(n));

h=figure;
subplot(2,1,1),
for i=1:length(n)
    plot(data.Ex,E_ex{n(i)},'color',lincol(i,:)),hold on
end
legend(leg)
axis tight
xlabel('Ex. (nm)')
ylabel('Sum of Squared Error')

subplot(2,1,2),
for i=1:length(n)
    plot(data.Em,E_em{n(i)},'color',lincol(i,:)),hold on
end
legend(leg)
axis tight
xlabel('Em. (nm)')
ylabel('Sum of Squared Error')
set(h,'name',['Sum of Squared Error: ' num2str(n) ' components'])
