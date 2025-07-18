   % Function to calculate compensation
    function calculateCompensation(areaInput, compensationInput, distanceInput, densityInput)
        % Fetch the input data
        area = str2double(areaInput.Value);
        compensation = str2double(compensationInput.Value);
        distance = str2double(distanceInput.Value);
        density = str2double(densityInput.Value);

        % Placeholder for modeling logic, for example:
        % Assume compensation = area * factor - distance * factor + some adjustment based on density
        result = area * 1000 - distance * 500 + density * 2000;

        % Update the results display
        resultsText.String = ['Calculated Compensation: ¥', num2str(result)];
    end