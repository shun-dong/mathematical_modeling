function fingerprint(data,f)
%Plot a PARAFAC model in fingerprint mode (contour plots).
%
%USEAGE: 
%       fingerprint(data,f)
%
%INPUTS: 
%        data: data structure containing a PARAFAC model in data. Modelf
%           f: Number of components in the model to be fitted.
%
%OUTPUTS:
%    A figure with f plots will be produced, where each plot shows the 
%    spectra (in contours) for one of the components. The plots are shown
%    in the order that the components were resolved by PARAFAC
%     i.e. plot 1 -> component 1.

%Examples
%   fingerprint(LSmodel6,6)
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, (yr), 
%     DOI:10.1039/c3ay41160e. 
%
% fingerprint; Copyright (C) 2013 Kathleen R. Murphy
% The University of New South Wales
% Dept Civil and Environmental Engineering
% Water Research Center
% UNSW 2052
% Sydney
% krm@unsw.edu.au
%
% $ Version 0.1.0 $ September 2013 $ First Release

narginchk(2,2)
M = data.(['Model' int2str(f)]);
[~,B,C]=fac2let(M);
rc=      [1 1;1 2;1 3;2 2;  2 3;  2 3;  2 4;  2 4;  3 3;   2 5;     3 4;       3 4;     4 4;      4 4];
ylabpos={{1},{1},{1},{1,3},{1,4},{1,4},{1,5},{1,5},{1,4,7},{1,4,7},{1,4,7,11},{1,4,7,11},{1,5,9,12},{1,5,9,12}};
xlabpos={{1},{2},{2},{3:4},{3:6},{4:6},{5:8},{5:8},{7:9},  {7:10}, {9:12},    {9:12},     {12:16}, {12:16}};

figure
set(gcf,'Name',['Contour plot for ' num2str(f) '-comp. model']);
for i=1:f
    subplot(rc(f,1),rc(f,2),i)
    Comp=reshape((krb(C(:,i),B(:,i))'),[1 data.nEm data.nEx]);
    contourf(data.Ex,data.Em,(squeeze(Comp(1,:,:))));
    v=axis;
    handle=title(['Comp ' int2str(i)]);
    set(handle,'Position',[0.9*v(2) 1.05*v(3) 1],'FontWeight','bold','color',[1 1 1]);
    if ismember(i,cell2mat(ylabpos{f}))
        ylabel('Em. (nm)')
    end
    if ismember(i,cell2mat(xlabpos{f}))
        xlabel('Ex. (nm)')
    end
end
