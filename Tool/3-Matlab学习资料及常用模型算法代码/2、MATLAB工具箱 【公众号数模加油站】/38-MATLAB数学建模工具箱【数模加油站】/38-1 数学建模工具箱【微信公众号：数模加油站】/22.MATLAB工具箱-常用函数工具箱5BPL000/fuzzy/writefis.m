function [fileName,pathName,errorStr]=writefis(fis,fileName,dlgStr)
%WRITEFIS Save FIS to disk.
%   WRITEFIS(FISMAT) brings up a UIPUTFILE dialog box to assist
%   with the naming and directory location of the file.
%
%   WRITEFIS(FISMAT,'filename') writes a FIS file corresponding
%   to the FIS matrix FISMAT to a disk file called 'filename' in
%   the current directory.
%
%   WRITEFIS(FISMAT,'filename','dialog') brings up a UIPUTFILE
%   dialog box with the default name 'filename' supplied.
%
%   The extension '.fis' is added to 'filename' if it is not 
%   already present.
%
%   See also READFIS.

%   Ned Gulley, 5-25-94  Kelly Liu, 7-9-96
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.18 $  $Date: 1997/12/01 21:46:01 $


pathName=[];
errorStr=[];

if nargin<1,
    errorStr='No FIS matrix provided.';
    if nargout<3, error(errorStr); end
    return
end

if nargin>1,
    fileName=deblank(fileName);
end

if nargin<3,
    dlgStr=' ';
end

if nargin<2,
    fileName='*.fis';
end

pathName=[];
if (nargin<2) | strcmp(dlgStr,'dialog'),
    pos=get(0,'DefaultFigurePosition');
    [fileName,pathName]=uiputfile([fileName '.fis'],'Save FIS',pos(1),pos(2));
    if ~fileName | isempty(fileName),
        errorStr='No file name was specified';
        if nargout<3, error(errorStr); end
        return; 
    end
end

len=length(fileName);
% To make things as easy as possible, strip off everything after the
% period (if there is one), then attach ".fis" to the end.
% That way, if there's no .fis on the end, one will get put one there
% This also takes care of the VMS situation with it semi-colons
dotIndex=find(fileName=='.');
if ~isempty(dotIndex),
    fileName(dotIndex(1):len)=[];
end
fis.name=fileName;
fileExt='.fis';
fid=fopen([pathName fileName fileExt],'w');
if fid==-1, 
    errorStr=['Unable to write to file "' fileName '"'];
    if nargout<3, error(errorStr); end
    return; 
end
fprintf(fid,'[System]\n');

str=['Name=''' fis.name '''\n'];
fprintf(fid,str);

% Structure

str=['Type=''' fis.type '''\n'];
fprintf(fid,str);
str=['Version=2.0\n'];
fprintf(fid,str);

str=['NumInputs=' num2str(length(fis.input)) '\n'];
fprintf(fid,str);

str=['NumOutputs=' num2str(length(fis.output)) '\n'];
fprintf(fid,str);


str=['NumRules=' num2str(length(fis.rule)) '\n'];
fprintf(fid,str);
str=['AndMethod=''' fis.andMethod '''\n'];
fprintf(fid,str);

str=['OrMethod=''' fis.orMethod '''\n'];
fprintf(fid,str);

str=['ImpMethod=''' fis.impMethod '''\n'];
fprintf(fid,str);

str=['AggMethod=''' fis.aggMethod '''\n'];
fprintf(fid,str);

str=['DefuzzMethod=''' fis.defuzzMethod '''\n'];
fprintf(fid,str);

for varIndex=1:length(fis.input),
    fprintf(fid,['\n[Input' num2str(varIndex) ']\n']);
    str=['Name=''' fis.input(varIndex).name '''\n'];
    fprintf(fid,str);
    str=['Range=' mat2str(fis.input(varIndex).range) '\n'];
    fprintf(fid,str);
    str=['NumMFs=' num2str(length(fis.input(varIndex).mf)) '\n'];
    fprintf(fid,str);

    for mfIndex=1:length(fis.input(varIndex).mf),
        str=['MF' num2str(mfIndex) '=''' fis.input(varIndex).mf(mfIndex).name ''':'];
        fprintf(fid,str);
        str=['''' fis.input(varIndex).mf(mfIndex).type ''','];
        fprintf(fid,str);
        str=[mat2str(fis.input(varIndex).mf(mfIndex).params) '\n'];
        fprintf(fid,str);
    end
end
for varIndex=1:length(fis.output),
    fprintf(fid,['\n[Output' num2str(varIndex) ']\n']);    
    str=['Name=''' fis.output(varIndex).name '''\n'];
    fprintf(fid,str);
    str=['Range=' mat2str(fis.output(varIndex).range) '\n'];
    fprintf(fid,str);
    str=['NumMFs=' num2str(length(fis.output(varIndex).mf)) '\n'];
    fprintf(fid,str);

    for mfIndex=1:length(fis.output(varIndex).mf),
        str=['MF' num2str(mfIndex) '=''' fis.output(varIndex).mf(mfIndex).name ''':'];
        fprintf(fid,str);
        str=['''' fis.output(varIndex).mf(mfIndex).type ''','];
        fprintf(fid,str);
        str=[mat2str(fis.output(varIndex).mf(mfIndex).params) '\n'];
        fprintf(fid,str);
    end
end

str=['\n[Rules]\n'];
fprintf(fid,str);
for ruleIndex=1:length(fis.rule),
    antecedent=mat2str(fis.rule(ruleIndex).antecedent);
    if length(fis.input)>1
       antecedent=antecedent(2:end-1);
    end
    consequent=mat2str(fis.rule(ruleIndex).consequent);
    if length(fis.output)>1
       consequent=consequent(2:end-1);
    end
    str=[antecedent ', ' consequent ' ('...
         mat2str(fis.rule(ruleIndex).weight) ') : '...
         mat2str(fis.rule(ruleIndex).connection)...
          '\n'];
    fprintf(fid,str);
end

fclose(fid);
