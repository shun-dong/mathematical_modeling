function out=addmf(fis,varType,varIndex,MFLabel,MFType,MFParams)
%  Synopsis
%  a = addmf(a,varType,varIndex,mfName,mfType,mfParams)
%  
%  Description
%  A membership function can only be added to a variable name for an FIS that
%  already exists. Indices are assigned to membership functions in the order
%  in which they are added, so the first membership function added to a
%  variable will always be known as membership function number one for that
%  variable. You cannot add a membership function to input variable number two
%  of a system if only one input has been defined. The function requires six
%  input arguments in this order: the name of the FIS, the type of the
%  variable (input or output), the index of the variable, the name of the new
%  membership function, the type of the new membership function, and the
%  vector of parameters which specify the membership function.
%  
%  Example
%  a=newfis('tipper');
%  a=addvar(a,'input','service',[0 10]);
%  a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%  a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%  a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%  plotmf(a,'input',1)
%  
%  See Also
%  addrule, addvar, plotmf, rmmf, rmvar

%  Kelly Liu 7-10-96
%  Copyright (c) 1994-98 by The MathWorks, Inc.
%  $Revision: 1.10 $  $Date: 1997/10/30 20:23:59 $

numInputs=length(fis.input);
numOutputs=length(fis.output);


out=fis;
if ~isempty(fis.input)
  if strcmp(varType,'input'),   
    MFindex=length(fis.input(varIndex).mf)+1;
    out.input(varIndex).mf(MFindex).name=MFLabel;
    out.input(varIndex).mf(MFindex).type=MFType;
    out.input(varIndex).mf(MFindex).params=MFParams;
    
  elseif strcmp(varType,'output'),    
    MFindex=length(fis.output(varIndex).mf)+1;  
    out.output(varIndex).mf(MFindex).name=MFLabel;
    out.output(varIndex).mf(MFindex).type=MFType;
    out.output(varIndex).mf(MFindex).params=MFParams;
    
  end
else
 disp('No Input Variable yet');
end
