function spinit(SPTfig)
%SPINIT Initialization for SPECTVIEW (Spectrum Viewer Client)

%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.11 $

shh = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');

if nargin < 2
    SPTfig = findobj(0,'tag','sptool');
end

% ====================================================================
% set defaults and initialize userdata structure

    rulerPrefs = sptool('getprefs','ruler',SPTfig);
    colorPrefs = sptool('getprefs','color',SPTfig);
    spectviewPrefs = sptool('getprefs','spectview',SPTfig);

    ud.prefs.tool.ruler = spectviewPrefs.rulerEnable;    % rulers enabled
    ud.prefs.tool.zoompersist = spectviewPrefs.zoomFlag; % is zoom mode persistant or
       % does it go away when you zoom once?

    ud.prefs.minsize = [150 425]; 
      % minsize(1)   - minimum width of main axes in pixels
      % minsize(2)   - minimum height of figure in pixels

    ud.prefs.colororder = colorPrefs.colorOrder;
    ud.prefs.linestyleorder = colorPrefs.linestyleOrder;
    
    ud.prefs.xaxis.label = 'Frequency';
    ud.prefs.xaxis.grid = 1;
    ud.prefs.yaxis.label = '';
    ud.prefs.yaxis.grid = 1;

    ud.prefs.title.mode = 'auto';  % can be 'auto' or 'manual'
    ud.prefs.title.manualstring = '';  % title string in case mode is manual

    markerStr = { '+' 'o' '*' '.' 'x' ...
         'square' 'diamond' 'v' '^' '>' '<' 'pentagram' 'hexagram' }';
    typeStr = {'vertical' 'horizontal' 'track' 'slope'}';
    
    ud.prefs.ruler.color = rulerPrefs.rulerColor;
    ud.prefs.ruler.marker = markerStr{rulerPrefs.rulerMarker};
    ud.prefs.ruler.markersize = rulerPrefs.markerSize;
    ud.prefs.ruler.type = typeStr{rulerPrefs.initialType};

    ud.sz = sptsizes;

    ud.spect = [];  % structure array of currently visible spectra
    ud.lines = [];
    ud.patches = {};
    ud.linecache.h = [];  % no line objects defined yet
    ud.SPToolIndices = [];
    ud.focusIndex = [];
    ud.focusline = [];
    ud.colorCount = 0;  % number of colors allocated thus far
    ud.colororder = num2cell(evalin('base',ud.prefs.colororder),2);
    ud.linestyleorder = num2cell(evalin('base',ud.prefs.linestyleorder),2);

    ud.pointer = 0;  % == -1 watch, 0 arrow/drag indicators, 1 zoom,
                     %     2 help

    ud.tabfig = [];  % handle to settings dialog box figure

    ud.limits.xlim = [0 1];
    ud.limits.ylim = [0 1];

    ud.justzoom = [ 0 0 ] ;
    
    switch computer
    case 'MAC2'
        ud.maxPopupEntries = 300;
    otherwise
        % most platforms don't scroll beyond screen
        ud.maxPopupEntries = 24;
    end
    ud.inheritList = [];  % see local fcn newInheritString (spectview) for
                          % explanation
    
    screensize = get(0,'screensize');
    fp = get(0,'defaultfigureposition');
    ud.left_width = 180;
    
    %fw = fp(3)+ud.prefs.tool.ruler*ud.sz.rw+ud.left_width; % figure width
    fw = 610;  % slightly less than the minimum width of 640 pixels 
               % (assuming 640x480 is smallest screen size)
    fw = min(fw,screensize(3)-50);
    fh = ud.prefs.minsize(2);
    fp = [fp(1)-(fw-fp(3))/2 fp(2)+fp(4)-fh fw fh];
% CREATE FIGURE

figname = prepender('Spectrum Viewer');
fig = figure('createfcn','',...
         'closerequestfcn','sbswitch(''spectview'',''SPTclose'')',...
         'tag','spectview',...
         'numbertitle','off',...
         'integerhandle','off',...
         'handlevisibility','callback',...
         'menubar','none',...
         'position',fp,...
         'userdata',ud,...
         'inverthardcopy','off',...
         'paperpositionmode','auto',...
         'units','pixels',...
         'visible','off',...
         'name',figname);
         
set(fig,'renderer','painters') %make sure this is manually set to prevent
                               % going into zbuffer when creating confidence
                               % patches
                               
    % ====================================================================
    % MENUs
    %  create cell array with {menu label, callback, tag}

 %  MENU LABEL                     CALLBACK                      TAG
mc={ 
 'File'                              ' '                        'filemenu'
 '>&Close^w'                         'spectview(''SPTclose'')'  'closemenu'
 'Options'                           ' '                        'optionsmenu'                
 '>&Magnitude Scale'                 ' '                        'magscale'
 '>>&dB'                             'spectview(''magscale'',''db'')'   'dbMag'
 '>>&Linear'                         'spectview(''magscale'',''lin'')' 'linearMag'
 '>&Frequency Range'                 ' '                        'freqrange'
 '>>&[0, Fs/2]'                      'spectview(''freqrange'',''half'')' 'half'
 '>>&[0, Fs]'                        'spectview(''freqrange'',''whole'')' 'whole'
 '>>&[-Fs/2, Fs/2]'                  'spectview(''freqrange'',''neg'')' 'negative'
 '>&Frequency Scale'                 ' '                        'freqscale'
 '>>&Linear'                         'spectview(''freqscale'',''lin'')' 'linearFreq'
 '>>&Log'                            'spectview(''freqscale'',''log'')' 'logFreq'
 '&Window'                            winmenu('callback')     'winmenu'};
 
    menu_handles = makemenu(fig, char(mc(:,1)), ...
                            char(mc(:,2)), char(mc(:,3)));
                            
    ud.hand.magscaleMenu = menu_handles(5:6);
    ud.hand.freqrangeMenu = menu_handles(8:10);
    ud.hand.freqscaleMenu = menu_handles(12:13);

    set(ud.hand.magscaleMenu(spectviewPrefs.magscale),'checked','on')
    set(ud.hand.freqscaleMenu(spectviewPrefs.freqscale),'checked','on')
    set(ud.hand.freqrangeMenu(spectviewPrefs.freqrange),'checked','on')
    
    set(menu_handles,'handlevisibility','callback')
    
    winmenu(fig)
    
    % ====================================================================
    % Create Main axes
    mainaxes = axes('units','pixels',...
         'box','on',...
         'handlevisibility','callback', ...
         'tag','mainaxes');
    % create a copy that will be underneath the main axes, and
    % will be used as a border during panning operations to prevent
    % background erasemode from clobbering the main axes plot box.
    temp = copyobj(mainaxes,fig);
    mainaxes_border = mainaxes;
    mainaxes = temp;

    set(mainaxes_border,'xtick',[],'ytick',[],'visible','off',...
          'tag','mainaxes_border')

    set(get(mainaxes,'title'),'FontAngle',  get(mainaxes, 'FontAngle'), ...
        'FontName',   get(mainaxes, 'FontName'), ...
        'FontSize',   get(mainaxes, 'FontSize'), ...
        'FontWeight', get(mainaxes, 'FontWeight'), ...
        'color',get(mainaxes,'xcolor'),...
        'tag','mainaxestitle',...
        'interpreter','none')
    set(get(mainaxes,'xlabel'),'string',ud.prefs.xaxis.label,...
         'tag','mainaxesxlabel')
    set(get(mainaxes,'ylabel'),'string',ud.prefs.yaxis.label,...
         'tag','mainaxesylabel')
    if (spectviewPrefs.freqscale == 2)
        set(mainaxes,'xscale','log')
    end     
    ud.mainaxes = mainaxes;
    ud.mainaxes_border = mainaxes_border;
    
    % ====================================================================
    % Create frames and uicontrols for property editor
    frame_props = {'units','pixels','style','frame'};
    
    ud.hand.propFrame = uicontrol(frame_props{:},'tag','propFrame');
    ud.hand.signalFrame = uicontrol(frame_props{:},'tag','signalFrame');
    ud.hand.paramFrame = uicontrol(frame_props{:},'tag','paramFrame');

    text_props = {'units','pixels','style','text'};
    % ud.hand.propLabel = uicontrol(text_props{:},'string','',...
     %     'fontsize',12,'tag','propLabel');
    ud.hand.propLabel = get(ud.mainaxes,'title');
    ud.hand.signalLabel = uicontrol(text_props{:},'string','Signal',...
          'tag','signalLabel');
    ud.hand.siginfo1Label = uicontrol(text_props{:},'string','<None>',...
          'horizontalalignment','left','tag','siginfo1Label');
    ud.hand.siginfo2Label = uicontrol(text_props{:},'string','',...
          'horizontalalignment','left','tag','siginfo2Label');
    ud.hand.paramLabel = uicontrol(text_props{:},'string','Parameters',...
          'tag','paramLabel');
    
    label_props = {text_props{:}, 'horizontalalignment','right' };
    
    ud.hand.revertButton = uicontrol('style','pushbutton',...
            'units','pixels',...
            'string','Revert','callback','spectview(''revert'')',...
            'enable','off','tag','revertButton');
    ud.hand.applyButton = uicontrol('style','pushbutton',...
            'units','pixels',...
            'string','Apply','callback','spectview(''apply'')',...
            'enable','off','tag','applyButton');

    % Get methods structure.
    ud.methods = [];
    ud.methods = spmethp(ud.methods); % calls one in signal/private
    % now call each one found on path:
    p = sptool('getprefs','plugins',SPTfig);
    if p.plugFlag
        ud.methods = sptool('callall','spmeth',ud.methods);
    end
    
    ud.hand.methodLabel = uicontrol(label_props{:},'string','Method',...
           'tag','methodLabel');
    ud.hand.methodPopup = uicontrol('style','popupmenu',...
            'units','pixels',...
            'string',{ud.methods.methodName},...
            'tag','methodPopup',...
            'callback','spectview(''changeMethod'')');
            
    edit_props = {'style','edit', 'horizontalalignment','left',...
                  'units','pixels',...
                  'backgroundcolor','white' };
    
    ud.hand.confidenceCheckbox = uicontrol('style','checkbox',...
            'units','pixels',...
            'value',0,'string','Conf. Int.',...
            'callback','spectview(''confidence'',''check'')',...
            'tag','confidenceCheckbox');
    ud.hand.confidenceEdit = uicontrol(edit_props{:},...
            'units','pixels',...
            'string','.95',...
            'tag','confidenceEdit',...
            'callback','spectview(''confidence'',''edit'')');
            
    ud.hand.inheritPopup = uicontrol('style','popupmenu',...
            'units','pixels',...
            'string',{'Inherit from'},...
            'tag','inheritPopup',...
            'callback','spectview(''inherit'')');
    
    N = 9;  % maximum number of parameters
    for i=1:N
        ud.hand.label(i) = uicontrol(label_props{:},...
            'tag',['label' num2str(i)]);
        ud.hand.uicontrol(i) = uicontrol(edit_props{:},...
            'callback',['spectview(''paramChange'',' sprintf('%.9g',i) ')'],...
            'tag',['uicontrol' num2str(i)]);
    end
    
    
    % save ud before calling toolbar since toolbar modifies it
    set(fig,'userdata',ud)
    
    confid.enable = get(ud.hand.confidenceCheckbox,'value');
    confid.level = get(ud.hand.confidenceCheckbox,'string');

    spectview('fillParams',fig,ud.methods(1).methodName,ud.methods(1).default,...
                confid)
    
    set(fig,'userdata',ud)
    
    % ====================================================================
    % now add toolbar
    btnlist = {'mousezoom' 'zoomout' 'zoominy' 'zoomouty' 'zoominx' ...
               'zoomoutx'  'help'}';
    tb_callbackstr = {
       'sbswitch(''spzoom'',''mousezoom'')'
       'sbswitch(''spzoom'',''zoomout'')'
       'sbswitch(''spzoom'',''zoominy'')'
       'sbswitch(''spzoom'',''zoomouty'')'
       'sbswitch(''spzoom'',''zoominx'')'
       'sbswitch(''spzoom'',''zoomoutx'')'
       'sbswitch(''spectview'',''help'')' };
    zoombar('fig',fig,'btnlist',btnlist,'callbacks',tb_callbackstr,...
            'left_width',3,'right_width',sptlegend('width',fig)+2*ud.sz.lbs); 
            
    % create legend - changes userdata
    sptlegend(fig,'spectview(''changefocus'')','spectview')
    
    set(fig,'resizefcn',...
            appstr(get(fig,'resizefcn'),'sbswitch(''spresize'')'))
            
    set(fig,'windowbuttonmotionfcn','sbswitch(''spmotion'')')

    spresize(0,fig)
    
    if ud.prefs.tool.ruler
       ruler
       ud = get(fig,'userdata');
       ud.ruler.evenlySpaced = 0;
       set(fig,'userdata',ud)
    end

    set(fig,'visible','on')
    set(0,'showhiddenhandles',shh);
