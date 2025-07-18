% Step 4: 定义补偿计算
function repair_cost = calculate_repair_cost(area_increase, current_orientation_value, new_orientation_value)
    % 计算修缮补偿
    if new_orientation_value > current_orientation_value
        % 采光高于现居住地，面积每多1%，少补偿2/3万修缮款
        repair_cost = area_increase * 2/3; % 这里补偿金额是简化版，根据实际情况调整
    elseif new_orientation_value == current_orientation_value
        % 采光相等，面积每多1%，少补偿0.5万修缮款
        repair_cost = area_increase * 0.5; 
        if area_increase >= 0.30
            repair_cost = repair_cost + 5; % 补偿最大为5万元
        end
    else
        % 如果采光低于现居住地，不提供修缮款
        repair_cost = 0;
    end
end
