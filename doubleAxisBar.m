function h = doubleAxisBar(y1, y2, varargin)
%DOUBLEAXISBAR Plots a double-axis bar chart.
%   h = DOUBLEAXISBAR(y1, y2, 'ParameterName', ParameterValue) creates
%   a double-axis bar chart with data matrices y1 and y2. The function returns
%   the handle to the figure.
%
%   Input arguments:
%   - y1: n1 x g matrix representing data for the left axis.
%   - y2: n2 x g matrix representing data for the right axis.
%
%   Parameter Names (Name-Value pairs):
%   - 'ylabel1': Label for the left axis.
%   - 'ylabel2': Label for the right axis.
%   - 'xlabel': Label for the x-axis.
%   - 'title': Title for the chart.
%   - 'legend': Cell array of legend labels.
%
%   Output:
%   - h: Handle to the created figure.
%
%   Example:
%   h = doubleAxisBarModified(y1, y2, 'ylabel1', 'Custom Left Label', ...
%                             'ylabel2', 'Custom Right Label', 'xlabel', ...
%                             'Custom X Label', 'title', 'Custom Title', ...
%                             'legend', {'Group A', 'Group B'});
%

%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2023-12-20
    
    % Parse input args
    p = inputParser;
    addParameter(p, 'ylabel1', '');
    addParameter(p, 'ylabel2', '');
    addParameter(p, 'xlabel', '');
    addParameter(p, 'title', '');
    addParameter(p, 'legend', {});
    parse(p, varargin{:});
    
    assert(size(y1,2)==size(y2,2),...
        'The number of columns (groups) of the two matrices must be equal');

    % Draw
    h = figure;
    yyaxis left;
    bar([y1; NaN(size(y2))]');
    yyaxis right;
    bar([NaN(size(y1)); y2]');
    
    % Set other graphic elements,
    if ~isempty(p.Results.xlabel)
        xlabel(p.Results.xlabel);
    end
    if ~isempty(p.Results.ylabel1)
        yyaxis left;
        ylabel(p.Results.ylabel1);
    end
    if ~isempty(p.Results.ylabel2)
        yyaxis right;
        ylabel(p.Results.ylabel2);
    end
    if ~isempty(p.Results.title)
        title(p.Results.title);
    end
    if ~isempty(p.Results.legend)
        lgd = p.Results.legend;
        lgd = [lgd(1:size(y1,1)),...
            repmat({''}, 1, size([y1;y2],1)),...
            lgd(size(y1,1)+1:end)];
        legend(lgd);
    end
    
end
