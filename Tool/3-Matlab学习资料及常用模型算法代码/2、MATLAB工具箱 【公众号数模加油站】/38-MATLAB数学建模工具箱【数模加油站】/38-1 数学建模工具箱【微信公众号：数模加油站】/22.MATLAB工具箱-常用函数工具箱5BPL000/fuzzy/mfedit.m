function mfedit(action,varType,varIndex);
%MFEDIT Membership function editor.
%   The Membership Function (MF) Editor is used to create, 
%   remove, and modify the MFs for a given fuzzy system. On 
%   the left side of the diagram is a "variable palette" 
%   region that you use to select the current variable by 
%   clicking once on one of the displayed boxes. Information   
%   about the current variable is displayed in the text region 
%   below the palette area.
%
%   To the right is a plot of all the MFs for the current 
%   variable. You can select any of these by clicking once on 
%   the line or name of the MF. Once selected, you can modify 
%   the properties of the MF using the controls in the lower right.  
%   MFs are added and removed using the Edit menu.    
%
%   See also 
%       fuzzy, ruleedit, ruleview, surfview, anfisedit

%   Kelly Liu 6-26-96 Ned Gulley, 4-30-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.51 $  $Date: 1997/12/01 21:45:08 $

if get(0,'ScreenDepth')>2,
   figColor=[0.9 0.9 0.9];
   selectColor=[1 0 0];
   unselectColor=[0 0 0];
   inputColor=[1 1 0.8];
   outputColor=[0.8 1 1];
else
   figColor=[1 1 1];
   selectColor=[0 0 0.1];
   unselectColor=[0 0 0.1];
   inputColor=[1 1 1];
   outputColor=[1 1 1];
end

if nargin<1,
   newFis=newfis('Untitled');
   newFis=addvar(newFis,'input','input1',[0 1]);
   newFis=addvar(newFis,'output','output1',[0 1]);
   action=newFis;
end

if isstr(action),
   if action(1)~='#',
      % The string "action" is not a switch for this function, 
      % so it must be a disk file
      fis=readfis(action);
      action='#initialize';
   end
else
   % For initialization, the fis matrix is passed in as the parameter
   fis=action;
   action='#initialize';
end;

if strcmp(action,'#initialize'),
   fisName=fis.name;
   fisType=fis.type;

    if isfield(fis, 'input')
      numInputs=length(fis.input);
    else
      numInputs=0;
    end

    if isfield(fis, 'output')
      numOutputs=length(fis.output);
    else
      numOutputs=0;
    end
    if isfield(fis, 'rule')
      numRules=length(fis.rule);
    else
      numRules=0;
    end
   
   %===================================
   % Information for all objects
   frmColor=192/255*[1 1 1];
   btnColor=192/255*[1 1 1];
   popupColor=192/255*[1 1 1];
   editColor=255/255*[1 1 1];
   border=6;
   spacing=6;
   figPos=get(0,'DefaultFigurePosition');
   maxRight=figPos(3);
   maxTop=figPos(4);
   btnWid=100;
   btnHt=22;
   
   %====================================
   % The FIGURE
   thisfis{1}=fis;
   figNumber=figure( ...
      'Name',['Membership Function Editor: ' fisName], ...
      'NumberTitle','off', ...
      'Visible','off', ...
      'Color',figColor, ...
      'MenuBar','none', ...
      'UserData',thisfis, ...
      'Position',figPos, ...
      'KeyPressFcn','mfedit #keypress', ...
      'DefaultAxesFontSize',8, ...
      'Tag','mfedit', ...
      'DoubleBuffer', 'on', ...
      'BackingStore','off');
   figPos=get(figNumber,'position');
   
   %====================================
   % The MENUBAR items
   % First create the menus standard to every GUI
   fisgui #initialize
   
   editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
   uimenu(editHndl,'Label','Add MFs...', ...
      'Callback','mfedit #addmfs');
   uimenu(editHndl,'Label','Add custom MF...', ...
      'Tag','addcustommf', ...
      'Callback','mfedit #addcustommf');
   uimenu(editHndl,'Label','Remove current MF', ...
      'Tag','removemf', ...
      'Enable','off', ...
      'Callback','mfedit #removemf');
   uimenu(editHndl,'Label','Remove all MFs', ...
      'Tag','removeallmf', ...
      'Callback','mfedit #removeallmfs');
   uimenu(editHndl,'Label','Undo', ...
      'Separator','on', ...
      'Enable','off', ...
      'Tag','undo', ...
      'Callback','popundo(gcf)');
   
   %====================================
   % The MAIN frame 
   top=(maxTop)*0.47;
   bottom=border; 
   right=maxRight-border;
   left=border;
   frmBorder=spacing;
   frmPos=[left-frmBorder bottom-frmBorder ...
         right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
   
   %====================================
   % The MAIN axes
   tickColor=[0.5 0.5 0.5];
   axBorder=40;
   axPos=[left+axBorder+(right-left)/5 top+axBorder ...
         4/5*(right-left)-1.5*axBorder maxTop-top-border-1.5*axBorder];
   btnDownFcn='mfedit #deselectmf';
   param.CurrMF=-1;
   param.Action='';
   mainAxHndl=axes( ...
      'Units','pixel', ...
      'XColor',tickColor,'YColor',tickColor, ...
      'Color',inputColor, ...
      'Position',axPos, ...
      'Tag','mainaxes', ...
      'Userdata', param, ...
      'ButtonDownFcn',btnDownFcn, ...
      'Box','on');
   titleStr='Membership function plots';
   title(titleStr,'Color','black');
   
   %====================================
   % The VARIABLE PALETTE axes
   axBorder=5;
   axPos=[left+axBorder top+2*axBorder ...
         1/5*(right-left)-1.5*axBorder maxTop-top-border-7*axBorder];
   axHndl=axes( ...
      'Units','pixel', ...
      'Visible','off', ...
      'XColor',tickColor,'YColor',tickColor, ...
      'Position',axPos, ...
      'Tag','variables', ...
      'Box','on');
   axes(mainAxHndl)
   %draw frame
   mainFrmHndl=uicontrol( ...
      'Style','frame', ...
      'Units','pixel', ...
      'Position',frmPos, ...
      'BackgroundColor',frmColor);
   %====================================
   % The VARIABLE frame 
   top=top-spacing;
   bottom=border+4*spacing+btnHt;
   left=border+spacing;
   right=left+2*btnWid+spacing;
   frmBorder=spacing;
   frmPos=[left-frmBorder bottom-frmBorder ...
         right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
   varFrmHndl=uicontrol( ...
      'Style','frame', ...
      'Units','pixel', ...
      'Position',frmPos, ...
      'BackgroundColor',frmColor);
   
   varSpacing=(top-bottom-5*btnHt)/4;
   %------------------------------------
   % The VARIABLE label field
   n=1;
   labelStr='Current Variable';
   pos=[left top-btnHt*n-varSpacing*(n-1) 2*btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE NAME text field
   n=2;
   name='varname';
   labelStr='Name';
   pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE NAME display field
   pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'Units','pixel', ...
      'Position',pos, ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',popupColor, ...
      'String',' ', ...
      'Tag',name);
   
   %------------------------------------
   % The VARIABLE TYPE text field
   n=3;
   labelStr='Type';
   pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE TYPE display field
   labelStr=' input| output';
   name='vartype';
   pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',popupColor, ...
      'Units','pixel', ...
      'Position',pos, ...
      'Tag',name, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE RANGE text field
   n=4;
   labelStr='Range';
   pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE RANGE edit field
   name='varrange';
   callbackStr='mfedit #varrange';
   pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','edit', ...
      'Units','pixel', ...
      'Position',pos, ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',editColor, ...
      'Callback',callbackStr, ...
      'Tag',name);
   
   %------------------------------------
   % The VARIABLE DISPLAY RANGE text field
   n=5;
   labelStr='Display Range';
   pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The VARIABLE DISPLAY RANGE edit field
   name='disprange';
   callbackStr='mfedit #disprange';
   pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','edit', ...
      'Units','pixel', ...
      'Position',pos, ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',editColor, ...
      'Callback',callbackStr, ...
      'Tag',name);
   
   %====================================
   % The MF frame 
   bottom=border+7*spacing+2*btnHt;
   left=right+3*spacing;
   right=maxRight-border-spacing;
   frmBorder=spacing;
   frmPos=[left-frmBorder bottom-frmBorder ...
         right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
   mfFrmHndl=uicontrol( ...
      'Style','frame', ...
      'Units','pixel', ...
      'Position',frmPos, ...
      'BackgroundColor',frmColor);
   
   mfBtnWid=1.2*btnWid;
   mfHSpacing=(right-left-2*mfBtnWid);
   mfVSpacing=(top-bottom-4*btnHt)/3;
   %------------------------------------
   % The MEMBERSHIP FUNCTION text field
   n=1;
   labelStr='Current Membership Function (click on MF to select)';
   pos=[left top-btnHt*n-mfVSpacing*(n-1) right-left btnHt];
   uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The MF Name text label
   n=2; m=1;
   labelStr='Name';
   pos=[left+(m-1)*(mfBtnWid+mfHSpacing) top-btnHt*n-mfVSpacing*(n-1) mfBtnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',frmColor, ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The MF NAME edit field
   m=2;
   callbackStr='mfedit #mfname';
   name='mfname';
   pos=[left+(m-1)*(mfBtnWid+mfHSpacing) top-btnHt*n-mfVSpacing*(n-1) mfBtnWid btnHt];
   hndl=uicontrol( ...
      'Style','edit', ...
      'Units','pixel', ...
      'Position',pos, ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',editColor, ...
      'Tag',name, ...
      'Callback',callbackStr);
   
   %------------------------------------
   % The MF TYPE text label
   n=3; m=1;
   labelStr='Type';
   pos=[left+(m-1)*(mfBtnWid+mfHSpacing) top-btnHt*n-mfVSpacing*(n-1) mfBtnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',frmColor, ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The MF TYPE popup menu
   m=2;
   callbackStr='mfedit #mftype';
   labelStr1=str2mat(' trimf',' trapmf',' gbellmf',' gaussmf',' gauss2mf',' sigmf');
   labelStr1=str2mat(labelStr1,' dsigmf',' psigmf',' pimf',' smf',' zmf');
   labelStr2=str2mat(' constant',' linear');
   name='mftype';
   pos=[left+(m-1)*(mfBtnWid+mfHSpacing) top-btnHt*n-mfVSpacing*(n-1) mfBtnWid btnHt];
   hndl=uicontrol( ...
      'Style','popupmenu', ...
      'Units','pixel', ...
      'UserData',labelStr2, ...
      'Position',pos, ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',popupColor, ...
      'Callback',callbackStr, ...
      'String',labelStr1, ...
      'Tag',name);
   
   %------------------------------------
   % The MF PARAMS text label
   n=4; m=1;
   labelStr='Params';
   pos=[left top-btnHt*n-mfVSpacing*(n-1) btnWid btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',frmColor, ...
      'Units','pixel', ...
      'Position',pos, ...
      'String',labelStr);
   
   %------------------------------------
   % The MF PARAMS edit field
   n=4;
   callbackStr='mfedit #mfparams';
   name='mfparams';
   pos=[left+btnWid top-btnHt*n-mfVSpacing*(n-1) right-left-btnWid btnHt];
   hndl=uicontrol( ...
      'Style','edit', ...
      'HorizontalAlignment','left', ...
      'BackgroundColor',editColor, ...
      'Units','pixel', ...
      'Position',pos, ...
      'Callback',callbackStr, ...
      'Tag',name);
 
   callbackStr='mfedit #plotmfs';
   name='numpoints';
   pos=[0.851 0.94 0.10 0.05];
   hndl=uicontrol( ...
      'Style','edit', ...
      'HorizontalAlignment','right', ...
      'BackgroundColor',editColor, ...
      'Units','normal', ...
      'Position',pos, ...
      'String', '181', ...
      'Callback',callbackStr, ...
      'Tag',name);
   pos=[0.74 0.94 0.10 0.05];

    hndl=uicontrol( ...
      'Style','text', ...
      'HorizontalAlignment','right', ...
      'BackgroundColor', figColor, ...
      'Units','normal', ...
      'Position',pos, ...
      'FontSize',8, ...
      'String', 'plot points:', ...
      'Tag','pointlabel');
  
   %====================================
   % The CLOSE frame 
   bottom=border+4*spacing+btnHt;
   top=bottom+btnHt;
   left=border+2*btnWid+5*spacing;
   right=maxRight-border-spacing;
   clsBtnWid=1.2*btnWid;
   clsSpacing=(right-left-3*clsBtnWid)/2;
   
   frmBorder=spacing;
   frmPos=[left-frmBorder bottom-frmBorder ...
         right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
   clsFrmHndl=uicontrol( ...
      'Style','frame', ...
      'Units','pixel', ...
      'Position',frmPos, ...
      'BackgroundColor',frmColor);
   
   %------------------------------------
   % The HELP button
   labelStr='Help';
   callbackStr='mfedit #help';
   helpHndl=uicontrol( ...
      'Style','push', ...
      'Position',[left bottom clsBtnWid btnHt], ...
      'BackgroundColor',btnColor, ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %------------------------------------
   % The CLOSE button
   labelStr='Close';
   callbackStr='fisgui #close';
   closeHndl=uicontrol( ...
      'Style','push', ...
      'Position',[right-clsBtnWid bottom clsBtnWid btnHt], ...
      'BackgroundColor',btnColor, ...
      'String',labelStr, ...
      'Callback',callbackStr);
   
   %====================================
   % The STATUS frame 
   top=border+spacing+btnHt;
   bottom=border+spacing;
   right=maxRight-border-spacing;
   left=border+spacing;
   frmBorder=spacing;
   frmPos=[left-frmBorder bottom-frmBorder ...
         right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
   topFrmHndl=uicontrol( ...
      'Style','frame', ...
      'Units','pixel', ...
      'Position',frmPos, ...
      'BackgroundColor',frmColor);
   
   %------------------------------------
   % The STATUS text window
   labelStr=' ';
   name='status';
   pos=[left bottom right-left btnHt];
   hndl=uicontrol( ...
      'Style','text', ...
      'BackgroundColor',frmColor, ...
      'HorizontalAlignment','left', ...
      'Units','pixel', ...
      'Position',pos, ...
      'Tag',name, ...
      'String',labelStr);
   
   % Plot the curves of the first input variable
   if nargin<3, varIndex=1; end
   if nargin<2, varType='input'; end
   
   mfedit('#update',varType,varIndex);
   
   % Uncover the figure
   set(figNumber, ...
      'Visible','on', 'HandleVisibility','callback');
   
elseif strcmp(action,'#update'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Clear the current variable plots and redisplay
   inputAxes=findobj(figNumber,'Type','axes','Tag','input');
   outputAxes=findobj(figNumber,'Type','axes','Tag','output');
   delete([inputAxes; outputAxes])
   varAxes=findobj(figNumber,'Type','axes','Tag','variables');
   axes(varAxes);
   mfedit #plotvars
   
   % The default initial variable is the first input
   % Select it and hilight it
   if nargin<3, varIndex=1; end
   if nargin<2, varType='input'; end
   
   currVarAxes=findobj(figNumber,'Type','axes','Tag',varType,'UserData',varIndex);
   if isempty(currVarAxes),
      statmsg(figNumber,'No variables for this system');
   else
      currVarAxesChildren=get(currVarAxes,'Children');
      set(figNumber,'CurrentObject',currVarAxesChildren(1));
      mfedit #selectvar
      statmsg(figNumber,'Ready');
   end
   
   watchoff(figNumber)
   
elseif strcmp(action,'#keypress'),
   %====================================
   figNumber=gcf;
   removeMFHndl=findobj(figNumber,'Type','uimenu','Tag','removemf');
   if abs(get(figNumber,'CurrentCharacter'))==127,
      if strcmp(get(removeMFHndl,'Enable'),'on'),
         mfedit #removemf
      end
   end
   
elseif strcmp(action,'#selectvar'),
   %====================================
   figNumber=watchon; 
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   fisType=fis.type;
   newCurrVarPatch=get(figNumber,'CurrentObject');
%   sss=get(newCurrVarPatch)
%   newCurrVarPatch = gcbo;
%   if isempty(newCurrVarPatch)| ~strcmp(get(newCurrVarPatch, 'Type'), 'patch')
%     newCurrVarPatch=findobj(figNumber, 'Tag', 'input1');
%   end
   newCurrVar=get(newCurrVarPatch,'Parent');
   varIndex=get(newCurrVar,'UserData');

   varType=get(newCurrVar,'Tag');
   
   % Deselect all others if necessary
   oldCurrVar=findobj(figNumber,'Type','axes','XColor',selectColor);
   if newCurrVar~=oldCurrVar,
      set(oldCurrVar,'XColor','k','YColor','k');
      set(oldCurrVar,'LineWidth',1);
   end
   
   % Now hilight the new selection
   set(newCurrVar,'XColor',selectColor,'YColor',selectColor);
   set(newCurrVar,'LineWidth',3);
   
   % Set all current variable display registers ...
   dispRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','disprange');
   customHndl=findobj(figNumber,'Type','uimenu','Tag','addcustommf');
   
   if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
      % Handle sugeno case
      dispRangeStr=' ';
      set(dispRangeHndl,'String',dispRangeStr,'UserData',dispRangeStr, ...
         'Enable','off');
      set(customHndl,'Enable','off');
   else
      dispRangeStr=[' ' mat2str(eval(['fis.' varType '(' num2str(varIndex) ').range']), 4)];   
      set(dispRangeHndl,'String',dispRangeStr,'UserData',dispRangeStr, ...
         'Enable','on');
      set(customHndl,'Enable','on');
   end
   
   if strcmp(get(figNumber,'SelectionType'),'open'),
      fisgui #findgui
   end
   
   % The VARIABLE NAME text field
   name='varname';
   hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
   
   varName=eval(['fis.' varType '(' num2str(varIndex),').name']);
   set(hndl,'String',varName);
   
   % The VARIABLE TYPE text field
   name='vartype';
   hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
   set(hndl,'String',varType);
   
   % The VARIABLE RANGE text field
   name='varrange';
   hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
   rangeStr=mat2str(eval(['fis.' varType '(' num2str(varIndex),').range']),4);
   labelStr=[' ' rangeStr];
   set(hndl,'String',labelStr);
   
   statmsg(figNumber,['Selected variable "' varName '"']);
   mfedit #plotmfs
   watchoff(figNumber)
   
elseif strcmp(action,'#selectmf'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
%   objHndl=get(figNumber,'CurrentObject');
   objHndl = gcbo;
   mainAxes=get(objHndl,'Parent');
   
   % Find the new current MF
   %    oldCurrMF=get(mainAxes,'UserData');
   param=get(mainAxes,'UserData');
   oldCurrMF=param.CurrMF;
   newCurrMF=get(objHndl,'UserData');
   % Deselect other currently selected MF curves
   if oldCurrMF~=newCurrMF, 
      if oldCurrMF~=-1 
         mfedit #deselectmf
      end
      param.CurrMF=newCurrMF;
      set(mainAxes,'UserData',param);
      
      
      % Determine the variable type and index
      fisType=fis.type;
      % Is the current variable input or output?
      currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
      varIndex=get(currVarAxes,'UserData');
      varType=get(currVarAxes,'Tag');
      
      % Find the info for the new MF

      mfType=localgetmfparam(fis, varType, varIndex, newCurrMF, 'type');
      mfName=localgetmfparam(fis, varType, varIndex, newCurrMF, 'name');
      mfParams=localgetmfparam(fis, varType, varIndex, newCurrMF, 'params');      
      % Set the MF name, type and params to the right value
      mfNameHndl=findobj(figNumber,'Type','uicontrol','Tag','mfname');
      set(mfNameHndl,'String',[' ' mfName],'Enable','on');
      
      mfTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','mftype');
      mfTypeList=get(mfTypeHndl,'String');
      if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
         % Prepare sugeno mf type popup menu
         if size(mfTypeList,1)>2,
            set(mfTypeHndl,'String',get(mfTypeHndl,'UserData'));
            set(mfTypeHndl,'UserData',mfTypeList);
         end
      else
         % Prepare mamdani mf type popup menu
         if size(mfTypeList,1)==2,
            set(mfTypeHndl,'String',get(mfTypeHndl,'UserData'));
            set(mfTypeHndl,'UserData',mfTypeList);
         end
         % Make the selected line bold
         currLineHndl=findobj(mainAxes,'Tag','mfline','UserData',newCurrMF);
         
         set(currLineHndl,'Color',selectColor);
         mfdrag('mf', currLineHndl, mfType, mfParams);
         set(currLineHndl,'LineWidth',2);
      end
      
      % Make the selected text bold
      currTxtHndl=findobj(mainAxes,'Type','text','UserData',newCurrMF);
      set(currTxtHndl,'Color',selectColor,'FontWeight','bold');
      
      mfTypeList=get(mfTypeHndl,'String');
      mfTypeValue=findrow(mfType,mfTypeList);
      if isempty(mfTypeValue),
         mfTypeList=str2mat(mfTypeList, [' ' mfType]);
         mfTypeValue=findrow(mfType,mfTypeList);
         set(mfTypeHndl,'String',mfTypeList,'Value',mfTypeValue);
         msgStr=['Installing custom membership function "' mfType '"'];
         statmsg(figNumber,msgStr);
      end
      set(mfTypeHndl,'Value',mfTypeValue,'Enable','on');
      curr_info = get(gca, 'CurrentPoint');
      
      hndl=findobj(figNumber, 'Tag','mfparams');
      set(hndl,'String',[' ' mat2str(mfParams,4)],'Enable','on', ...
         'Userdata', [curr_info(1,1) mfParams]);
      
      hndl=findobj(figNumber,'Type','uimenu','Tag','removemf');
      set(hndl,'Enable','on');
      
   end
   
   watchoff(figNumber)
   
elseif strcmp(action,'#deselectmf'),
   %====================================
   figNumber=get(0,'CurrentFigure');
   
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varType=get(currVarAxes,'Tag');
   
   mainAxes=findobj(figNumber,'Type','axes','Tag','mainaxes');
   param=get(mainAxes,'UserData');
   currMF=param.CurrMF;
   lineHndl=findobj(mainAxes,'Tag','mfline', 'UserData', currMF);
   %  for i=1:length(lineHndlList)
   %    thisparam=get(lineHndlList(i), 'UserData');
   %    if thisparam.CurrMF == currMF,
   %      lineHndl=lineHndlList(i);
   %      break;
   %    end
   %  end
   txtHndl=findobj(mainAxes,'Type','text','UserData',currMF);
   % Clear the current MF register
   param.CurrMF=-1;
   set(mainAxes,'UserData',param);
   
   if strcmp(varType,'input'),
      backgroundColor=inputColor;
   else 
      backgroundColor=outputColor;
   end
   set(lineHndl,'Color',backgroundColor);
   set(lineHndl,'LineWidth',1);
   set(lineHndl,'Color',unselectColor);
   %    set(lineHndl, 'Tag', 'line');
   set(txtHndl,'Color',unselectColor,'FontWeight','normal');
   
   % Clean up the MF fields
   hndl=findobj(figNumber,'Type','uicontrol','Tag','mfname');
   if strcmp(get(hndl,'Enable'),'on'),
      set(hndl,'String',' ','Enable','off');
      hndl=findobj(figNumber,'Tag','mftype');
      set(hndl,'Value',1,'Enable','off');
      hndl=findobj(figNumber,'Type','uicontrol','Tag','mfparams');
      set(hndl,'String',' ','Enable','off');
      hndl=findobj(figNumber,'Type','uimenu','Tag','removemf');
      set(hndl,'Enable','off');
   end
   
elseif strcmp(action,'#varrange'),
   %====================================
   figNumber=watchon; 
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   
   % Get the range
   oldRange=eval(['fis.' varType '(' num2str(varIndex) ').range']);
   
   varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','varrange');
   dispRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','disprange');
   newRangeStr=get(varRangeHndl,'String');
   
   newRangeStr=get(varRangeHndl,'String');
   % We'll put the brackets in later; no point in dealing with the hassle
   index=[find(newRangeStr=='[') find(newRangeStr==']')];
   newRangeStr(index)=32*ones(size(index));
   newRangeStr=['[' newRangeStr ']'];
   
   % Use eval try-catch to prevent really weird stuff...
   newRange=eval(newRangeStr,mat2str(oldRange,4));
   if length(newRange)~=2,
      statmsg(figNumber,'Range vector must have exactly two elements');
      newRange=oldRange;
   end
   if diff(newRange)<=0,
      statmsg(figNumber,'Range vector must be of the form [lowLimit highLimit]');
      newRange=oldRange;
   end
   
   rangeStr=mat2str(newRange,4);
   set(varRangeHndl,'String',[' ' rangeStr]);
   
   if ~all(newRange==oldRange),
      % Don't bother to do anything unless it's changed
      % Change all params here
      numMFs=eval(['length(fis.' varType '(' num2str(varIndex) ').mf)']);
      for count=1:numMFs,
         oldParams=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(count) ').params']);
         mfType=eval(['fis.' varType '(' num2str(varIndex)  ').mf(' num2str(count) ').type']);
         [newParams,errorStr]=strtchmf(oldParams,oldRange,newRange,mfType);
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(count) ').params=' mat2str(newParams) ';']);
         
      end
      eval(['fis.' varType '(' num2str(varIndex) ').range=' mat2str(newRange) ';']);
      
      updtfis(figNumber,fis,[4 5]);
      pushundo(figNumber,fis);
      
      % ... and plot
      set(dispRangeHndl,'String',[' ' rangeStr]);
      mfedit #plotmfs
   end
   
   watchoff(figNumber)
   
elseif strcmp(action,'#disprange'),
   %====================================
   figNumber=watchon; 
   oldRange=[];
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find current variable
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   
   varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','varrange');
   dispRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','disprange');
   % Get the old range
   oldRangeStr=get(dispRangeHndl,'UserData');
   newRangeStr=get(dispRangeHndl,'String');
   
   % We'll put the brackets in later; no point in dealing with the hassle
   index=[find(newRangeStr=='[') find(newRangeStr==']')];
   newRangeStr(index)=32*ones(size(index));
   newRangeStr=['[' newRangeStr ']'];
   
   % Use eval try-catch to prevent really weird stuff...
   newRange=eval(newRangeStr,mat2str(oldRange,4));
   
   if length(newRange)~=2,
      statmsg(figNumber,'Range vector must have exactly two elements');
      newRangeStr=oldRangeStr;
   end
   if diff(newRange)<=0,
      statmsg(figNumber,'Range vector must be of the form [lowLimit highLimit]');
      newRangeStr=oldRangeStr;
   end
   
   newRange=eval(newRangeStr,oldRangeStr);
   rangeStr=mat2str(newRange,4);
   set(dispRangeHndl,'String',[' ' rangeStr]);
   
   % ... and plot
   mfedit #plotmfs
   watchoff(figNumber)
   
elseif strcmp(action,'#mfname'),
   %====================================
   figNumber=watchon; 
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   mfNameHndl=findobj(figNumber,'Type','uicontrol','Tag','mfname');
   
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   if strcmp(varType,'input'),
      backgroundColor=inputColor;
   else 
      backgroundColor=outputColor;
   end
   thisuserdata=get(gca,'UserData');
   currMF=thisuserdata.CurrMF;

   oldName=eval(['fis.' varType '(' num2str(varIndex),').mf(' num2str(currMF),').name']);
   newName=deblank(get(mfNameHndl,'String'));
   % Strip off the leading space
   newName=fliplr(deblank(fliplr(newName)));
   % Replace any remaining blanks with underscores
   newName(find(newName==32))=setstr(95*ones(size(find(newName==32))));
   msgStr=['Renaming MF ' num2str(currMF) ' to "' newName '"'];
   statmsg(figNumber,msgStr);
   txtHndl=findobj(figNumber,'Type','text','UserData',currMF);
   set(txtHndl,'Color',backgroundColor);
   set(txtHndl,'String',newName);
   set(txtHndl,'Color',selectColor);
   set(mfNameHndl,'String',[' ' newName]);
   eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').name=''' newName  '''' '; ']);
   pushundo(figNumber,fis);
   updtfis(figNumber,fis,[3 4]);
   
   watchoff(figNumber)
   
elseif strcmp(action,'#mftype'),
   %====================================
   figNumber=watchon; 
%   mfTypeHndl=get(figNumber,'CurrentObject');
   mfTypeHndl=gcbo;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   fisType=fis.type;
   numInputs=length(fis.input);
   
   % Is the current variable input or output?
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   mainAxes=findobj(figNumber,'Type','axes','Tag','mainaxes');
   %  currMF=get(mainAxes,'UserData');
   param=get(mainAxes,'UserData');
   currMF=param.CurrMF;
   if strcmp(varType,'input'),
      backgroundColor=inputColor;
   else 
      backgroundColor=outputColor;
   end
   
   typeList=get(mfTypeHndl,'String');
   typeValue=get(mfTypeHndl,'Value');
   newType=deblank(typeList(typeValue,:));
   % Strip off the leading space
   newType=fliplr(deblank(fliplr(newType)));
   msgStr=['Changing MF ' num2str(currMF) ' type to "' newType '"'];
   statmsg(figNumber,msgStr);
   
   paramHndl=findobj(figNumber,'Tag','mfparams');
   
   % Now translate and insert the translated parameters
   if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
      % Handle the sugeno case
      oldParams=eval(['fis.' varType '(' num2str(varIndex) ').mf(',num2str(currMF) ').params']);
      if strcmp(newType,'constant'),
         % Pick off only the constant term
         newParams=oldParams(length(oldParams));
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type=''' newType '''' ';']);
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params=' mat2str(newParams) ';']);
      else
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type=''' newType '''' ';']);
         if length(oldParams)==1
          eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params=' '[' mat2str(zeros(1, numInputs)) ' ' mat2str(oldParams) ']' ';']);
         end  
      end
      newParams=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params']);
      mfParamHndl=findobj(figNumber,'Type','uicontrol','Tag','mfparams');
      set(mfParamHndl,'String',[' ' mat2str(newParams,4)]);
      pushundo(figNumber,fis);
      updtfis(figNumber,fis,[4 5]);
   else
      oldParams=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params']);
      oldType=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type']);
      oldType=deblank(oldType);
      newType=deblank(newType);
      [newParams,errorStr]=mf2mf(oldParams,oldType,newType);
      if isempty(newParams),
         statmsg(figNumber,errorStr);
         set(paramHndl,'String',[' ' mat2str(oldParams,4)]);
         val=findrow(oldType,typeList);
         set(mfTypeHndl,'Value',val);
      else
         % Set the MF params to the right value
         set(paramHndl,'String',[' ' mat2str(newParams,4)]);
         
         % Replot the new curve
         lineHndl=findobj(mainAxes,'Tag','mfline','UserData',currMF);
         %       lineHndlList=findobj(mainAxes,'Type','mfline');
         %       for i=1:length(lineHndlList)
         %         thisparam=get(lineHndlList(i), 'UserData');
         %         if ~isempty(thisparam) & thisparam.CurrMF == currMF,
         %           lineHndl=lineHndlList(i);
         %          break;
         %         end
         %       end
         
         txtHndl=findobj(mainAxes,'Type','text','UserData',currMF);
         % First erase the old curve
         set(lineHndl,'Color',backgroundColor);
         set(txtHndl,'Color',backgroundColor);
         x=get(lineHndl,'XData');
         mfType=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type']);
         
         y=evalmf(x,newParams,newType);
         set(lineHndl,'YData',y,'Color',selectColor);
         centerIndex=find(y==max(y));
         centerIndex=round(mean(centerIndex));
         txtPos=get(txtHndl,'Position');
         txtPos(1)=x(centerIndex);
         set(txtHndl,'Position',txtPos,'Color',selectColor);
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type=''' newType ''';']);
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params=' mat2str(newParams) ';']);
         pushundo(figNumber,fis);
         updtfis(figNumber,fis,[4 5]);
         mfdrag('mf', lineHndl, newType, newParams);
      end
      
   end
   
   watchoff(figNumber)
   
elseif strcmp(action,'#mfparams'),
   %====================================
   figNumber=watchon; 
%   mfParamHndl=get(figNumber,'CurrentObject');
   mfParamHndl = gcbo;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   fisType=fis.type;
   
   % Is the current variable input or output?
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   if strcmp(varType,'input'),
      backgroundColor=inputColor;
   else 
      backgroundColor=outputColor;
   end
   mainAxes=findobj(figNumber,'Type','axes','Tag','mainaxes');
   %currMF=get(mainAxes,'UserData');
   param=get(mainAxes,'UserData');
   currMF=param.CurrMF;
   newParamStr=get(mfParamHndl,'String');
   if isempty(newParamStr), newParamStr=' '; end
   % We'll put the brackets in later; no point in dealing with the hassle
   index=[find(newParamStr=='[') find(newParamStr==']')];
   newParamStr(index)=32*ones(size(index));
   newParamStr=['[' newParamStr ']'];
   % Use eval try-catch to prevent really weird stuff...
   newParams=eval(newParamStr,'[]');
   
   % Use the old parameters for error-checking
   oldParams=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params']);
   if ~isequal(size(newParams),size(oldParams)),
      newParams=oldParams;
      set(mfParamHndl,'String',[' ' mat2str(newParams,4)]);
      % Send status message to the user
      msgStr=['No change made to MF ' num2str(currMF)];
      statmsg(figNumber,msgStr);
   else
      % Send status message to the user
      msgStr=['Changing parameter for MF ' num2str(currMF) ' to ' newParamStr];
      statmsg(figNumber,msgStr);
      set(mfParamHndl,'String',[' ' mat2str(newParams,4)]);
      
      if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
         % Nothing to do for sugeno output case...
         eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params=' mat2str(newParams) ';']);
         pushundo(figNumber,fis);
         updtfis(figNumber,fis,[4 5]);
      else
         lineHndl=findobj(mainAxes,'Type','line','UserData',currMF);
         
         x=get(lineHndl,'XData');
         mfType=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').type']);
         
         y=eval('evalmf(x,newParams,mfType)','[]');
         
         if isempty(y),
            % There's been an error in the MF code, so don't change anything
            statmsg(figNumber,['Illegal parameter in membership function ' mfType]);
            newParams=oldParams;
            set(mfParamHndl,'String',[' ' mat2str(newParams,4)]);
         else
            % Replot the curve
            txtHndl=findobj(mainAxes,'Type','text','UserData',currMF);
            set(txtHndl,'Color',backgroundColor);
            set(lineHndl,'Color',backgroundColor);
            drawnow
            drawnow
            
            set(lineHndl,'YData',y);
            centerIndex=find(y==max(y));
            centerIndex=round(mean(centerIndex));
            txtPos=get(txtHndl,'Position');
            txtPos(1)=x(centerIndex);
            set(txtHndl,'Position',txtPos);
            set(lineHndl,'Color',selectColor);
            set(txtHndl,'Color',selectColor);
            eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(currMF) ').params=' mat2str(newParams) ';']);
            pushundo(figNumber,fis);
            mfdrag('mf', lineHndl, mfType, newParams);
            updtfis(figNumber,fis,[4 5]);
         end
      end
   end
   
   watchoff(figNumber)
   
elseif strcmp(action,'#plotmfs'),
   %====================================
   figNumber=gcf;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find the selected variable
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   if strcmp(varType,'input'),
      backgroundColor=inputColor;
   else 
      backgroundColor=outputColor;
   end
   
   fisType=fis.type;
   mainAxes=findobj(figNumber,'Tag','mainaxes');
   axes(mainAxes);
   varName=eval(['fis.' varType '(' num2str(varIndex) ').name']);
   numMFs=eval(['length(fis.' varType '(' num2str(varIndex) ').mf)']);
   
   if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
      % Handle sugeno case
      cla
     if isfield(fis, 'input')
       numInputs=length(fis.input);
     else
      numInputs=0;
     end

      inLabels=[];
      for i=1:numInputs
         inLabels=strvcat(inLabels, fis.input(i).name);
      end
      
      varRange=[-1 1];
      for count=1:numMFs,
         mfName=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(count) ').name']);
         txtStr=deblank(mfName);
         if numMFs>6,
            % Use two columns
            if (count-1)<(numMFs/2),
               % This is column one
               xPos=0.25*diff(varRange)+varRange(1);
               yPos=(count-1)/(numMFs/2-1);
            else
               % This is column two
               xPos=0.75*diff(varRange)+varRange(1);
               yPos=(count-round(numMFs/2)-1)/(round(numMFs/2)-1);
            end
         else
            % Only one column is necessary
            xPos=0;
            yPos=(count)/(numMFs);
         end
         
         text(xPos,yPos,txtStr, ...
            'Color',unselectColor, ...
            'UserData',count, ...
            'EraseMode','normal', ...
            'HorizontalAlignment','center', ...
            'FontSize',8, ...
            'ButtonDownFcn','mfedit #selectmf');
      end
      set(gca,'XTick',[],'YTick',[], ...
         'XLim',[-1 1],'YLim',[-0.2 1.2], ...
         'Color',backgroundColor);
   else
      % This is either an input variable or a mamdani output
      dispRangeHndl=findobj(figNumber,'Tag','disprange');
      varRange=eval(get(dispRangeHndl,'String'));
      ptsHndl = findobj(figNumber, 'Tag', 'numpoints');
      numPts=get(ptsHndl, 'String');
      numPts=str2num(numPts);
      cla
      % Draw all the lines
      set(gca, ...
         'YTick',[0 0.5 1],'XTickMode','auto', ...
         'YLim',[-0.05 1.2], ...
         'Color',backgroundColor);
      [xAllMFs,yAllMFs]=plotmf(fis,varType,varIndex,numPts);
      for mfIndex=1:numMFs,
         x=xAllMFs(:,mfIndex);
         y=yAllMFs(:,mfIndex);
         mfName=eval(['fis.' varType '(' num2str(varIndex) ').mf(' num2str(mfIndex) ').name']);
         line(x,y, ...
            'Color',unselectColor, ...
            'LineWidth',1, ...
            'UserData',mfIndex, ...
            'EraseMode','normal', ...
            'Tag', 'mfline',...
            'ButtonDownFcn','mfedit #selectmf')
         centerIndex=find(y==max(y));
         centerIndex=round(mean(centerIndex));
         text(x(centerIndex), 1.1 ,mfName, ...
            'HorizontalAlignment','center', ...
            'Color',unselectColor, ...
            'FontSize',8, ...
            'UserData',mfIndex, ...
            'EraseMode','normal', ...
            'Tag', 'mftext',...
            'ButtonDownFcn','mfedit #selectmf')
         param=get(gca, 'Userdata');
         param.CurrMF=-1;
         set(gca,'UserData',param,'XLim',varRange);
         set(gca,'XLim',varRange);
      end
   end
   
   xlabel([varType ' variable "' varName '"'],'Color','black');
   
   % Clean up the MF fields
   hndl=findobj(figNumber,'Type','uicontrol','Tag','mfname');
   set(hndl,'String',' ','Enable','off');
   hndl=findobj(figNumber,'Type','uicontrol','Tag','mftype');
   set(hndl,'Value',1,'Enable','off');
   hndl=findobj(figNumber,'Type','uicontrol','Tag','mfparams');
   set(hndl,'String',' ','Enable','off');
   
elseif strcmp(action,'#removemf'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find the selected variable and MF
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   mainAxes=findobj(figNumber,'Type','axes','Tag','mainaxes');
   param=get(mainAxes,'UserData');
   %  currMF=get(mainAxes,'UserData');
   currMF=param.CurrMF;
      
   lineHndl=findobj(mainAxes,'Type','line','UserData',currMF);
   
   txtHndl=findobj(mainAxes,'Type','text','UserData',currMF);
   
   [fis,errorStr]=rmmf(fis,varType,varIndex,'mf',currMF);
   if isempty(fis),
      statmsg(figNumber,errorStr);
   else
      delete(lineHndl);
      delete(txtHndl);
      updtfis(figNumber,fis,[3 4 5 6]);
      pushundo(figNumber,fis);
      mfedit #plotmfs
   end
   
   watchoff(figNumber)    
   
elseif strcmp(action,'#removeallmfs'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find the selected variable
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   mainAxes=findobj(figNumber,'Type','axes','Tag','mainaxes');
      
   lineHndlList=findobj(mainAxes,'Tag','mfline');
   txtHndlList=findobj(mainAxes,'Type','text');
   
   deleteFlag=1;
   count=eval(['length(fis.' varType '(' num2str(varIndex) ').mf)']);
   while count>=1,
      [fis,errorStr]=rmmf(fis,varType,varIndex,'mf',count);
      count=count-1;
      if isempty(fis),
         % if any of these MFs are used in the rule base, we can't delete
         deleteFlag=0;
         statmsg(figNumber,errorStr);
         count=0;
      end
   end
   if deleteFlag
      delete(lineHndlList);
      delete(txtHndlList);
      pushundo(figNumber,fis);
      updtfis(figNumber,fis,[]);
      mfedit #plotmfs
   end
   
   watchoff(figNumber)    
   
elseif strcmp(action,'#addcustommf'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find the selected variable and MF
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   
   cmfdlg(figNumber,fis,varType,varIndex);
   watchoff(figNumber);
   
elseif strcmp(action,'#addmfs'),
   %====================================
   figNumber=watchon;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   % Find the selected variable and MF
   currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
   varIndex=get(currVarAxes,'UserData');
   varType=get(currVarAxes,'Tag');
   
   mfdlg(figNumber,fis,varType,varIndex);
   mfdlgfig=findobj(0, 'Tag', 'mfdlg');
   waitfor(mfdlgfig);
   watchoff(figNumber);
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};
   updtfis(figNumber,fis,[3]);
elseif strcmp(action,'#plotvars'),
   %====================================
   figNumber=gcf;
   oldfis=get(figNumber,'UserData');
   fis=oldfis{1};

   if isfield(fis, 'input')
     numInputs=length(fis.input);
   else
     numInputs=0;
   end
   if isfield(fis, 'output')
     numOutputs=length(fis.output);
   else
     numOutputs=0;
   end

   for i=1:numInputs
      numInputMFs(i)=length(fis.input(i).mf);
   end
   
   for i=1:numOutputs
      numOutputMFs(i)=length(fis.output(i).mf);
   end
   if isfield(fis, 'rule')
     numRules=length(fis.rule);
   else
     numRules=0;
   end
   fisName=fis.name;
   fisType=fis.type;
   
   mainAxHndl=gca;
   set(mainAxHndl,'Units','pixel','XTick',[],'YTick',[])
   mainAxPos=get(mainAxHndl,'Position');
   axis([mainAxPos(1) mainAxPos(1)+mainAxPos(3) ...
         mainAxPos(2) mainAxPos(2)+mainAxPos(4)]);
   xCenter=mainAxPos(1)+mainAxPos(3)/2;
   yCenter=mainAxPos(2)+mainAxPos(4)/2;
   title('FIS Variables')
   set(get(mainAxHndl,'Title'),'Visible','on','FontSize',10,'Color','black')
   
   % Inputs first
   
   if get(0,'ScreenDepth')>2,
      inputColor=[1 1 0.5];
      outputColor=[0.5 1 1];
   else
      inputColor=[1 1 1];
      outputColor=[1 1 1];
   end
   
   tickColor=[0.5 0.5 0.5];
   fontSize=8;
   
   boxWid=(1/2)*mainAxPos(3);
   boxHt=(1/(max(4,numInputs)))*mainAxPos(4);
   xInset=boxWid/10;
   yInset=boxHt/5;
   
   for varIndex=1:numInputs,
      boxLft=mainAxPos(1);
      boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
      axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
      
      varName=eval(['fis.input(' num2str(varIndex) ').name']);
      axName='input';
      axHndl=axes( ...
         'Units','pixel', ...
         'Box','on', ...
         'XTick',[],'YTick',[], ...
         'XColor',tickColor,'YColor',tickColor, ...
         'YLim',[-0.1 1.1], ...
         'Color',inputColor, ...
         'Tag',axName, ...
         'UserData',varIndex, ...
         'Position',axPos);
      mfIndex=(1:numInputMFs(varIndex))+sum(numInputMFs(1:(varIndex-1)));
      colorOrder=get(gca,'ColorOrder');
      
      % Plot three cartoon membership functions in the box
      xMin=-1; xMax=1;
      x=(-1:0.1:1)';
      y1=exp(-(x+1).^2/0.32); y2=exp(-x.^2/0.32); y3=exp(-(x-1).^2/0.32);
      xlineMatrix=[x x x];
      ylineMatrix=[y1 y2 y3];
      line(xlineMatrix,ylineMatrix,'Color','black');
      xiInset=(xMax-xMin)/10;
      axis([xMin-xiInset xMax+xiInset -0.1 1.1])
      
      % Lay down a patch that simplifies clicking on the region
      patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
      set(patchHndl, ...
         'EdgeColor','none', ...
         'FaceColor','none', ...
         'ButtonDownFcn','mfedit #selectvar');
      
      % Now put on the variable name as a label
      xlabel(varName);
      labelName=[axName 'label'];
      set(get(axHndl,'XLabel'), ...
         'FontSize',fontSize, ...
         'Color','black', ...
         'Tag',labelName); 
   end
   
   % Now for the outputs
   boxHt=(1/(max(4,numOutputs)))*mainAxPos(4);
   
   for varIndex=1:numOutputs,
      boxLft=mainAxPos(1)+boxWid;
      boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
      axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
      
      varName=eval(['fis.output(' num2str(varIndex) ').name']);
      axName='output';
      axHndl=axes( ...
         'Units','pixel', ...
         'Box','on', ...
         'Color',outputColor, ...
         'XTick',[],'YTick',[], ...  
      'XLim',[xMin xMax],'YLim',[-0.1 1.1], ...
         'XColor',tickColor,'YColor',tickColor, ...
         'Tag',axName, ...
         'UserData',varIndex, ...
         'Position',axPos);
      mfIndex=(1:numOutputMFs(varIndex))+sum(numOutputMFs(1:(varIndex-1)));
      if ~strcmp(fisType,'sugeno'),
         % Only try to plot outputs it if it's not a Sugeno-style system
         x=[-1 -0.5 0 0.5 1]';
         xlineMatrix=[x x x];
         ylineMatrix=[0 1 0 0 0;0 0 1 0 0; 0 0 0 1 0]';
         line(xlineMatrix,ylineMatrix,'Color','black');
         xoInset=(xMax-xMin)/10;
      else
         text(0,0.5,'f(u)', ...
            'FontSize',fontSize, ...
            'Color','black', ...
            'HorizontalAlignment','center');
      end
      
      % Lay down a patch that simplifies clicking on the region
      patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
      set(patchHndl, ...
         'EdgeColor','none', ...
         'FaceColor','none', ...
         'ButtonDownFcn','mfedit #selectvar');
      
      xlabel(varName);
      labelName=[axName 'label'];
      set(get(axHndl,'XLabel'), ...
         'FontSize',fontSize, ...
         'Color','black', ...
         'Tag',labelName);
   end
   
   hndlList=findobj(figNumber,'Units','pixels');
   set(hndlList,'Units','normalized')
   
elseif strcmp(action,'#help');
   figNumber=watchon;
   helpwin(mfilename)
   watchoff(figNumber)
   
end;    % if strcmp(action, ...

function out=localgetmfparam(fis, varType, varNum, mfNum, param)
switch varType
case 'input'
   switch param
   case 'name'
      out=fis.input(varNum).mf(mfNum).name;
   case 'type'
      out=fis.input(varNum).mf(mfNum).type;
   case 'params'
      out=fis.input(varNum).mf(mfNum).params;
   end   
case 'output'
   switch param
   case 'name'
      out=fis.output(varNum).mf(mfNum).name;
   case 'type'
      out=fis.output(varNum).mf(mfNum).type;
   case 'params'
      out=fis.output(varNum).mf(mfNum).params;
   end   
end
	 
