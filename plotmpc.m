function  [h, G] = plotmpc(mpc, varargin)
%PLOTMPC 绘制 Matpower case 的图形表示。
%   [H, G] = PLOTMPC(MPC) 使用 MATPOWER case 结构体 MPC 绘制电力系统的图形表示。
%
%   [H, G] = PLOTMPC(MPC, 'layoutMode', LAYOUTMODE) 使用指定的布局模式绘制图形。
%   可用的布局模式有 'auto'（默认），'force' 和 'layered'。
%
%   [H, G] = PLOTMPC(MPC, 'displayPowerFlow', DISPLAYPOWERFLOW) 控制是否在图形中显示功率流动。
%   如果 DISPLAYPOWERFLOW 为 true（默认），则显示功率流动。如果为 false，则不显示。
%
%   返回值：
%   H 是绘制的图形的句柄，G 是图形的 GRAPH 对象。
%
%   示例：
%   [h, G] = plotmpc(case9, 'layoutMode', 'force', 'displayPowerFlow', false);
%
%   参见：GRAPH, PLOT.

%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2023-12-29

% 解析输入参数
p = inputParser;
addOptional(p, 'layoutMode', 'auto', @(x) ismember(x, {'auto', 'force', 'layered'}));
addOptional(p, 'displayPowerFlow', true, @islogical);
parse(p, varargin{:});
layoutMode = p.Results.layoutMode;
displayPowerFlow = p.Results.displayPowerFlow;

% 定义常量
BUS_I = 1;
BUS_TYPE = 2;
PD = 3;
QD = 4;
VM = 8;
VA = 9;
GEN_BUS = 1;
PG = 2;
QG = 3;
VG = 6;
F_BUS = 1;
T_BUS = 2;
BR_R = 3;
BR_X = 4;
PF = 14;
QF = 15;

mpc = loadcase(mpc);
mpc = ext2int(mpc);
isResult = size(mpc.branch,2) >= PF;

nNode = length(mpc.bus(:,BUS_I));
if nNode>100
    warning('Too many nodes, the figure could be complex.');
end

% 节点信息
nodeColor = ones(nNode,1) * [0 0.4470 0.7410];
nodeNumber = cell(nNode,1);
nodeType = cell(nNode,1);
nodePower = cell(nNode,1);
nodeVoltage = cell(nNode,1);
nodeLabel = cell(nNode,1);
for i=1:nNode
    nodeNumber{i} = num2str(mpc.order.bus.i2e(i)); % use original number
    % nodeNumber = num2str(i); % use consecutively(internal) number
    switch mpc.bus(i,BUS_TYPE)
        case 1
            nodeType{i} = 'Load';
            nodePower{i} = cpl2str(mpc.bus(i,[PD, QD]));
        case 2
            nodeType{i} = 'Gen';
            nodeColor(i,:) = [0.9290 0.6940 0.1250];
            idx = find(mpc.gen(:,GEN_BUS)==mpc.bus(i,BUS_I));
            nodePower{i} = cpl2str(mpc.bus(idx,[PG, QG]));
        case 3
            nodeType{i} = 'Gen*';
            nodeColor(i,:) = [0.9290 0.6940 0.1250];
            idx = find(mpc.gen(:,GEN_BUS)==mpc.bus(i,BUS_I));
            nodePower{i} = cpl2str(mpc.bus(idx,[PG, QG]));
        otherwise
            nodeType{i} = '';
            nodePower{i} = '';
    end
    nodeVoltage{i} = cpl2str(mpc.bus(i,[VM, VA]));
    nodeLabel{i} = [nodeNumber{i}, '(', nodeType{i}, ')'];
end

% 边信息
edgeLabel = cell(size(mpc.branch, 1), 1);
if isResult && displayPowerFlow
    % 如果有潮流信息而且需要显示，就用有向图
    for i = 1:size(mpc.branch, 1)
        edgeLabel{i} = [num2str(i), '   ', cpl2str(mpc.branch(i, [PF,QF]))];
    end
else
    for i = 1:size(mpc.branch, 1)
        edgeLabel{i} = num2str(i);
    end
end

if isResult
    % 如果有潮流信息，就用有向图
    G = digraph(mpc.branch(:, F_BUS), mpc.branch(:, T_BUS));
else
    % 如果没有潮流信息
    G = graph(mpc.branch(:, F_BUS), mpc.branch(:, T_BUS));
end

% 绘制图形
h = plot(G, ...
    'NodeLabel',nodeLabel, ...
    'EdgeLabel',edgeLabel, ...
    'NodeColor',nodeColor, ...
    'Marker', 'o', ...
    'MarkerSize', 8);

% 制作数据提示
row = dataTipTextRow('Voltage', nodeVoltage);
h.DataTipTemplate.DataTipRows(1) = row;
row = dataTipTextRow('Power', nodePower);
h.DataTipTemplate.DataTipRows(2) = row;
h.DataTipTemplate.DataTipRows(3:end) = [];

% 设置细节
if nNode > 30 && strcmp(layoutMode,'auto')
    layoutMode = 'layered';
end
layout(h,layoutMode)
h.NodeFontAngle = 'normal';
h.NodeFontSize = 10;
h.EdgeFontAngle = 'normal';
if isResult
    h.ArrowPosition = 0.2;
end

function str = cpl2str(realPart, imagPart)
    if nargin == 1 && numel(realPart) == 2
        imagPart = realPart(2);
        realPart = realPart(1);
    end
    if imagPart >= 0
        str = sprintf('%.2f+j%.2f', realPart, imagPart);
    else
        str = sprintf('%.2f-j%.2f', realPart, abs(imagPart));
    end
end

end