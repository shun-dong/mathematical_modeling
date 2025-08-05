function fisgui(action,oldName,newName)
%FISGUI Handle generic figure management tasks for fuzzy GUI.
%   This functions handles menu creation and the execution of the
%   "File" menu items like "Save", "Save As...", "Close", and so on.

%   Kelly Liu 5-3-96  Ned Gulley, 6-9-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.27 $  $Date: 1997/12/01 21:44:54 $

% The arguments oldName and newName are used only for the renaming option

if strcmp(action,'#initialize'),
    %====================================
    figNumber=gcf;
    oldfis=get(gcf,'UserData');
    fis=oldfis{1};
    tag=get(figNumber,'Tag');

    labelStr=menulabel('&File ');
    fileHndl=uimenu(figNumber,'Label',labelStr);
        [labelStr,accelStr]=menulabel('&New Mamdani FIS ^n');
        uimenu(fileHndl,'Label',labelStr, ...
            'Accelerator',accelStr, ...
            'Tag', 'newmamdani',...
            'Callback','fisgui #newmamdani');
        [labelStr,accelStr]=menulabel('New Sugeno FIS');
        uimenu(fileHndl,'Label',labelStr, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #newsugeno');
        [labelStr,accelStr]=menulabel('&Open FIS from disk... ^o');
        uimenu(fileHndl,'Label',labelStr, ...
            'Separator','on', ...
            'Accelerator',accelStr, ...
            'Tag', 'openfis',...
            'Callback','fisgui #openfis');
        [labelStr,accelStr]=menulabel('&Save to disk ^s');
        uimenu(fileHndl,'Label',labelStr, ...
            'Accelerator',accelStr, ...
            'Tag','save', ...
            'Callback','fisgui #save');
        uimenu(fileHndl,'Label','Save to disk as...', ...
            'Tag','saveas', ...
            'Callback','fisgui #saveas');
        uimenu(fileHndl,'Label','Open FIS from workspace...', ...
            'Separator','on', ...
            'Tag', 'openfis',...
            'Callback','fisgui #ws2gui');
        callbackStr=[ ...
            ' oldfis=get(gcf,''UserData''); ', ...
            ' fis=oldfis{1};',...
            ' fisName=fis.name; ', ...
            ' s=[fisName ''=fis;'']; ', ...
            ' eval(s); ', ...
            ' statmsg(gcf,[''Saved variable '' fisName '' to workspace.''])'];
        [labelStr,accelStr]=menulabel('Save &to workspace ^t');
        uimenu(fileHndl,'Label',labelStr, ...
            'Accelerator',accelStr, ...
            'Callback',callbackStr);
        uimenu(fileHndl,'Label','Save to workspace as...', ...
            'Callback','fisgui #gui2ws');

        [labelStr,accelStr]=menulabel('&Print... ^p');
        uimenu(fileHndl,'Label',labelStr, ...
            'Separator','on', ...
            'Accelerator',accelStr, ...
            'Callback','printdlg');


        [labelStr,accelStr]=menulabel('&Close window ^w');
        uimenu(fileHndl,'Label',labelStr, ...
            'Separator','on', ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #close');

    labelStr=menulabel('&Edit ');
    editHndl=uimenu(figNumber, ...
        'Label',labelStr, ...
        'Tag','editmenu');

    labelStr=menulabel('&View ');
    viewHndl=uimenu(figNumber,'Label',labelStr);
        [labelStr,accelStr]=menulabel('Edit &FIS properties... ^1');
        uimenu(viewHndl, ...
            'Label',labelStr, ...
            'Tag','fuzzy', ...
            'UserData',1, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #findgui');
        [labelStr,accelStr]=menulabel('Edit &membership functions... ^2');
        uimenu(viewHndl, ...
            'Label',labelStr, ...
            'Tag','mfedit', ...
            'UserData',2, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #findgui');
        [labelStr,accelStr]=menulabel('Edit &rules... ^3');
        uimenu(viewHndl, ...
            'Label',labelStr, ...
            'Tag','ruleedit', ...
            'UserData',3, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #findgui');
        [labelStr,accelStr]=menulabel('Edit &anfis... ^4');
        if strcmp(fis.type, 'mamdani')
           enablethis='off';
        else
           enablethis='on';
        end
        uimenu(viewHndl, ...
            'Label',labelStr, ...
            'Tag','anfisedit', ...
            'UserData',6, ...
            'Accelerator',accelStr, ...
            'Enable', enablethis, ...
            'Callback','fisgui #findgui');
        [labelStr,accelStr]=menulabel('&View rules... ^5');
        uimenu(viewHndl, ...
            'Separator','on', ...
            'Label',labelStr, ...
            'Tag','ruleview', ...
            'UserData',4, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #findgui');
        [labelStr,accelStr]=menulabel('View &surface... ^6');
        uimenu(viewHndl, ...
            'Label',labelStr, ...
            'Tag','surfview', ...
            'UserData',5, ...
            'Accelerator',accelStr, ...
            'Callback','fisgui #findgui');

    % Disable the "View" item that points at the current window
%    hndl=findobj(figNumber,'Type','uimenu','Tag',tag);
%    set(hndl,'Enable','off');

elseif strcmp(action,'#findgui'),
    %====================================
    figNumber=watchon;
    menuHndl=gcbo;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    tag=get(menuHndl,'Tag');

    nameList=[ ...
        'FIS Editor                '
        'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];

    % Figure out what the current GUI type is based on the figure's tag
    currGui=get(menuHndl,'UserData');
    name=deblank(nameList(currGui,:));
    if ~isempty(name)
      fisName=fis.name;
      newFigNumber=findobj(0,'Name',[name ': ' fisName]);
      statmsg(figNumber,['Opening ' name]);
      if isempty(newFigNumber),
        eval([tag '(fis);']);
      elseif strcmp(get(newFigNumber,'Visible'),'off'),
        figure(newFigNumber)
        eval([tag ' #update']);
      else
        figure(newFigNumber);
      end
    end
    statmsg(figNumber,'Ready');
    watchoff(figNumber);

elseif strcmp(action,'#openfis'),
    %====================================
    figNumber=watchon;
    [fis,errorStr]=readfis;
    if isempty(fis),
        statmsg(figNumber,errorStr);
    else
        msgStr='Opening file';
        statmsg(figNumber,msgStr);
        fuzzy(fis);
        statmsg(figNumber,'Ready');
    end
    watchoff(figNumber);

elseif strcmp(action,'#saveas');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    oldName=fis.name;

    [newName,pathName,errorStr]=writefis(fis,oldName,'dialog');
    if ~isempty(errorStr),
        statmsg(figNumber,errorStr)
    else
        if ~strcmp(oldName,newName),
            fisgui('#fisname',oldName,newName);
        end

        % Put the path name along with a time stamp into the menu items'
        % user data
        pathHndl=findobj(figNumber,'Type','uimenu','Tag','save');
        set(pathHndl,'UserData',pathName);
        timeHndl=findobj(figNumber,'Type','uimenu','Tag','saveas');
        set(timeHndl,'UserData',clock);

        statmsg(figNumber,['Saved FIS "' newName '" to disk']);
    end
    watchoff(figNumber);

elseif strcmp(action,'#save');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    name=fis.name;
    if strcmp(name(1:8), 'Untitled');
         fisgui('#saveas')
         return;
    end
    statmsg(figNumber,'Saving FIS to disk');

    fisName=fis.name;
    nameList=[ ...
        'FIS Editor                '
        'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];
    currTime=clock;
    timeBuffer=inf;
    pathBuffer=[];
    for count=1:5,
        % Look for any open related figure that has done a "Save as" and
        % use the path from the most recent time
        guiName=deblank(nameList(count,:));
        newFigNumber=findobj(0,'Name',[guiName ': ' fisName]);
            if newFigNumber,
            % Get the path name along with a time stamp from the menu items'
            % user data
            timeHndl=findobj(newFigNumber,'Type','uimenu','Tag','saveas');
            timeStamp=get(timeHndl,'UserData');
            pathHndl=findobj(newFigNumber,'Type','uimenu','Tag','save');
            pathName=get(pathHndl,'UserData');

            if ~isempty(timeStamp),
                if etime(currTime,timeStamp)<timeBuffer,
                    timeBuffer=etime(currTime,timeStamp);
                    pathBuffer=pathName;
                end
            end
        end
    end

    [fisName,pathName,errorStr]=writefis(fis,[pathName fisName]);
    if ~isempty(errorStr),
        statmsg(figNumber,errorStr)
    else
        statmsg(figNumber,['Saved FIS "' fisName '" to disk']);
    end
    watchoff(figNumber);

elseif strcmp(action,'#gui2ws');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    statmsg(figNumber,'Saving FIS to workspace');

    fisName=fis.name;
    wsdlg(fis,fisName,'gui2ws');
    watchoff(figNumber);

elseif strcmp(action,'#ws2gui');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    statmsg(figNumber,'Opening FIS from workspace');

    fisName=fis.name;
    wsdlg(fis,fisName,'ws2gui');
    watchoff(figNumber);

elseif strcmp(action,'#newmamdani');
    %====================================
    figNumber=watchon;
    newFis=newfis('Untitled','mamdani');
    newFis=addvar(newFis,'input','input1',[0 1]);
    newFis=addvar(newFis,'output','output1',[0 1]);

    statmsg(figNumber,'Opening FIS Editor for new Mamdani system');
    fuzzy(newFis);
    watchoff(figNumber);

elseif strcmp(action,'#newsugeno');
    %====================================
    figNumber=watchon;
    newFis=newfis('Untitled','sugeno');
    newFis=addvar(newFis,'input','input1',[0 1]);
    newFis=addvar(newFis,'output','output1',[0 1]);

    statmsg(figNumber,'Opening FIS Editor for new Sugeno system');
    fuzzy(newFis);
    watchoff(figNumber);

elseif strcmp(action,'#close');
    %====================================
    figNumber=gcf;
    allfis=get(figNumber,'UserData');
    fis=allfis{1};
    nameList=[ ...
        'FIS Editor                '
        'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];

    fisName=fis.name;
    visFigList=[];
    invisFigList=[];
    % See who's left onscreen
    for count=1:size(nameList, 1),
        name=deblank(nameList(count,:));
        visFigList=[visFigList findobj(0, 'Type', 'figure',...
            'Name',[name ': ' fisName],'Visible','on')'];
        invisFigList=[invisFigList findobj(0, 'Type', 'figure', ...
            'Name',[name ': ' fisName],'Visible','off')'];
    end

    if length(visFigList)==1,
        % This is the last visible relative. Closing this will mean losing data.
        savedlg(fis,[visFigList invisFigList])
    else
        set(figNumber,'Visible','off');
    end

elseif strcmp(action,'#fisname'),
    %====================================
    figNumber=watchon;

    newName=deblank(newName);
    newName=fliplr(deblank(fliplr(newName)));
    nameStr='FIS Editor';
    newFigNumber=findobj(0,'Name',[nameStr ': ' oldName]);
    if newFigNumber,
        newFigNumber=newFigNumber(1);
        oldfis=get(newFigNumber,'UserData');
        fis=oldfis{1};
        fis.name=newName;
        msgStr=['Renamed FIS to "' newName '"'];
        statmsg(newFigNumber,msgStr);
        set(newFigNumber, ...
            'Name',['FIS Editor: ' newName]);
        pushundo(newFigNumber, fis);
        txtHndl=findobj(newFigNumber,'Type','text','Tag','fisname');
        set(txtHndl,'String',newName);
        txtHndl=findobj(newFigNumber,'Type','uicontrol','Tag','fisname');
        set(txtHndl,'String',newName);
    end

    % Give the appropriate name to all other related GUI windows
    nameStrMatrix=[ ...
        'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];
    for count=1:5,
        nameStr=deblank(nameStrMatrix(count,:));
        newFigNumber=findobj(0,'Name',[nameStr ': ' oldName]);
        if ~isempty(newFigNumber),
            newFigNumber=newFigNumber(1);
            fis=get(newFigNumber,'UserData');
            fis.name=newName;
            msgStr=['Renamed FIS to "' newName '"'];
            statmsg(newFigNumber,msgStr);
            set(newFigNumber, ...
                'Name',[nameStr ': ' newName]); 
            pushundo(newFigNumber, fis);
        end
    end
    watchoff(figNumber);

end
