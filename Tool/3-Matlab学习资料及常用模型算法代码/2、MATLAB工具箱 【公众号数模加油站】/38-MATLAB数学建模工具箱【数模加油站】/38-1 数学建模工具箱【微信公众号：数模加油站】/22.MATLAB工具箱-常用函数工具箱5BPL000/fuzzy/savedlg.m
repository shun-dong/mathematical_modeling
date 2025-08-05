function savedlg(action,figList)
%SAVEDLG Graphical user interface save warning dialog.
%   SAVEDLG(action,figList) builds a figure that warns the user
%   that system data will be lost unless it is saved before the figure
%   closes.

%   Ned Gulley, 9-15-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 1997/12/01 21:45:21 $

if ~isstr(action),
    % For initialization, the fis matrix is passed in as the parameter
    fis=action;
    action='#initialize';
end;

if strcmp(action,'#initialize'),
    labelStr1='Save FIS before closing?';
    labelStr2='If you close now, your system data will be lost.';

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    figPos(3:4)=[360 140];
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=160;
    btnHt=23;
 
    %====================================
    % The FIGURE
    figNumber=figure( ...
        'NumberTitle','off', ...
        'Color',[0.9 0.9 0.9], ...
        'Visible','off', ...
        'MenuBar','none', ...
        'UserData',fis, ...
        'Units','pixels', ...
        'Position',figPos, ...
        'Tag','gui2ws', ...
        'BackingStore','off');
    figPos=get(figNumber,'position');

    %====================================
    % The MAIN frame 
    top=maxTop-border;
    bottom=border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 1 1 1];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %====================================
    % The UPPER frame 
    top=maxTop-spacing-border;
    bottom=border+5*spacing+2*btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    varFrmHndl=uicontrol( ...
        'Units','pixel', ...
        'Style','frame', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    varSpacing=(top-bottom-2*btnHt);
    %------------------------------------
    % The STRING 1 text field
    n=1;
    labelStr=labelStr1;
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The STRING 2 text field
    n=2;
    labelStr=labelStr2;
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %====================================
    % The CLOSE frame 
    bottom=border+spacing;
    top=bottom+2*btnHt+spacing;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The SAVE TO WS button
    labelStr='Save to workspace...';
    callbackStr='savedlg #save2workspace';
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'UserData',figList, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The SAVE TO DISK button
    labelStr='Save to disk...'; 
    callbackStr='savedlg #save2disk';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom+btnHt+spacing btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'UserData',figList, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The DON'T SAVE button
    labelStr='Don''t Save';
    callbackStr='savedlg #dontsave';
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'UserData',figList, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CANCEL button
    labelStr='Cancel'; 
    callbackStr='close(gcf)';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');

    % Uncover the figure
    set(figNumber, ...
        'Visible','on', ...
        'HandleVisibility','callback');

elseif strcmp(action,'#save2workspace')
    fis=get(gcf,'UserData');
    % The button's UserData contains the list of figures to be deleted

    figList=get(gco,'UserData');
    close(gcf)
    allFigs=get(0,'Children');
    for count=1:length(figList),
        if any(allFigs==figList(count)),
            close(figList(count))
        end
    end
    wsdlg(fis,fis.name,'gui2ws');

elseif strcmp(action,'#save2disk')
    % The button's UserData contains the list of figures to be deleted
    fis=get(gcf,'UserData');
    figList=get(gco,'UserData');
    allFigs=get(0,'Children');
    for count=1:length(figList),
        if any(allFigs==figList(count)),
            close(figList(count))
        end
    end
    fisName=fis.name;
    fisgui('#saveas',fisName,fisName)
    close(gcf)

elseif strcmp(action,'#dontsave')
    % The button's UserData contains the list of figures to be deleted
    figList=get(gco,'UserData');
    close(gcf)
    allFigs=get(0,'Children');
    for count=1:length(figList),
        if any(allFigs==figList(count)),
            close(figList(count))
        end
    end

end
