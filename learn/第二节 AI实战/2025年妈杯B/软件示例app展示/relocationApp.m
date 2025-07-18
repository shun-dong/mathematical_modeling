function relocationApp
    % 创建主窗口
    fig = uifigure('Position', [100, 100, 800, 600], 'Name', '老旧街区搬迁决策软件');
    
    % 输入框区域：地块信息
    uicontrol(fig, 'Style', 'text', 'Position', [20, 550, 100, 30], 'String', '地块ID');
    landIDInput = uicontrol(fig, 'Style', 'edit', 'Position', [120, 550, 100, 30]);

    uicontrol(fig, 'Style', 'text', 'Position', [20, 500, 100, 30], 'String', '院落ID');
    courtyardIDInput = uicontrol(fig, 'Style', 'edit', 'Position', [120, 500, 100, 30]);

    uicontrol(fig, 'Style', 'text', 'Position', [20, 450, 100, 30], 'String', '地块面积 (m²)');
    landAreaInput = uicontrol(fig, 'Style', 'edit', 'Position', [120, 450, 100, 30]);

    uicontrol(fig, 'Style', 'text', 'Position', [20, 400, 100, 30], 'String', '地块朝向');
    orientationInput = uicontrol(fig, 'Style', 'edit', 'Position', [120, 400, 100, 30]);

    uicontrol(fig, 'Style', 'text', 'Position', [20, 350, 100, 30], 'String', '是否有居民');
    hasResidentsInput = uicontrol(fig, 'Style', 'edit', 'Position', [120, 350, 100, 30]);

    % 按钮区域：生成选择方案
    generateButton = uicontrol(fig, 'Style', 'pushbutton', 'Position', [250, 100, 150, 30], 'String', '生成搬迁方案', 'Callback', @(src, event) generateOptions());

    % 显示方案选择框
    optionsList = uicontrol(fig, 'Style', 'listbox', 'Position', [20, 150, 300, 150]);

    % 输入补偿金额框
    uicontrol(fig, 'Style', 'text', 'Position', [350, 550, 100, 30], 'String', '补偿金额');
    compensationInput = uicontrol(fig, 'Style', 'edit', 'Position', [450, 550, 100, 30]);

    % 提交补偿按钮
    submitCompensationButton = uicontrol(fig, 'Style', 'pushbutton', 'Position', [450, 100, 150, 30], 'String', '提交补偿金额', 'Callback', @(src, event) submitCompensation());

    % 生成搬迁方案
    function generateOptions()
        landID = landIDInput.Value;
        courtyardID = courtyardIDInput.Value;
        landArea = str2double(landAreaInput.Value);
        orientation = orientationInput.Value;
        hasResidents = strcmpi(hasResidentsInput.Value, 'yes');

        if hasResidents
            options = {['方案1: 地块ID: ', landID, '，院落ID: ', courtyardID, '，搬迁补偿：20000元'];
                       ['方案2: 地块ID: ', landID, '，院落ID: ', courtyardID, '，搬迁补偿：25000元']};
        else
            options = {['方案3: 地块ID: ', landID, '，院落ID: ', courtyardID, '，搬迁补偿：15000元'];
                       ['方案4: 地块ID: ', landID, '，院落ID: ', courtyardID, '，搬迁补偿：10000元']};
        end
        optionsList.String = options;
    end

    % 提交补偿金额
    function submitCompensation()
        compensationAmount = str2double(compensationInput.Value);
        selectedOption = optionsList.Value;
        if isempty(selectedOption)
            msgbox('请选择一个方案!', '错误', 'error');
        else
            msgbox(['您选择了: ', selectedOption, '，补偿金额为: ', num2str(compensationAmount)], '提交成功');
        end
    end
end
