function [H,P] = mpcnet(mpc)
%MPCNET 用于绘制matpower case的网络结构
%   [H,P] = mpcnet(mpc) 绘制mpc的网络结构
%   该函数基于Bioinformatic Toolbox的函数和Matpower Toolbox的数据，绘制matpower 
%   case的网络结构。它会加载指定的matpower case，然后将其转换为内部编号格式。然后
%   它会创建一个节点名称列表，并标记发电机。最后，它会创建一个稀疏矩阵来表示网络，并使用
%   biograph函数来创建和显示网络图。
%   
%   1. 如果节点数量超过100，函数会发出警告，因为图形可能会很复杂。
%   2. 发电机节点会被标记为"Gen"且着色为红色，平衡节点会被标记为"Gen*"。
%   3. 分支的权重默认为分支编号，使其更易于识别。
%   4. 如果matpower case是潮流计算的结果（mpc.success为true），则分支权重会被
%      设置为从端功率流（MW），并且箭头会显示在图上。
%   5. 节点的标签会显示其负载或发电机的功率。
%
%   感谢matpower团队和Bioinformatic Toolbox团队。
%
%   Input:
%       mpc - matpower case的名称或路径
%
%   Output:
%       H - biograph对象的视图
%       P - biograph对象
%
% See also: define_constants, loadcase, ext2int, biograph, view

% Author: yjy @ https://github.com/3plus10i
% Created on: : 2019-08-29
% Revision: 2023-12-04

%Origin comment:
% 封装自 network1.m, 用来画matpower case的网络结构
% 2019-08-29
% plot based on Bioinformatic Toolbox, data based on Matpower Toolbox
% 2019-09-04

% 由于biograph已经在R2022a中被移除，所以这个函数也不再可用了。
warning('This function is no longer available because biograph has been removed in R2022b.');
warning('Please use PLOTMPC function instead.');
[H, P] = plotmpc(mpc);
return


define_constants;
mpc = loadcase(mpc);
mpc = ext2int(mpc);

nnode = length(mpc.bus(:,BUS_I));
if nnode>100, warning('Too many nodes, the figure could be complex.');end
nodename = cell(nnode,1);
for i=1:nnode % node IDs
    nodename{i,1} = num2str(mpc.order.bus.i2e(i)); % use original number
%     nodename{i,1} = num2str(i); % use consecutively(internal) number
end

balance=mpc.bus(:,BUS_TYPE)==3;
balance=mpc.bus(balance,BUS_I);
balance=find(mpc.gen(:,GEN_BUS)==balance);
for i=1:size(mpc.gen,1) % mark generators
    if i~=balance
        ext = ' Gen';
    else
        ext = ' Gen*';
    end
    nodename{mpc.gen(i,GEN_BUS)} = [nodename{mpc.gen(i,GEN_BUS)}, ext];        
end

branch = mpc.branch(:,[F_BUS,T_BUS]);
branch(:,3) = (1:size(branch,1))'; % branch weight is branch No. by defualt making it ezer to recognize
startnote = branch(:,1)'; % Strat
endnote = branch(:,2)'; % End
weight = branch(:,3)'; % Weight
% if any(~mpc.branch(:,BR_STATUS)) % make outage lines weight like 0.xx %
% outages have been deleted by ext2int()
%     for i = find(~mpc.branch(:,BR_STATUS))
%         weight(i) = weight(i)*10^(-ceil(log10( weight(i) )));
%     end
% end

ShowArrowsValue = 'off';
DescriptionValue = 'Branch weight = branch No.';
try % TODO optimize logic
    if mpc.success % power flow arrows and values
        ShowArrowsValue = 'on';
        DescriptionValue = 'Branch weight = from end powerflow (MW)';
        weight = roundn(mpc.branch(:,PF),-1);
        weight(abs(weight)<1e-1)=1e-2; % or the graph will break
        temp = startnote(weight<0); % correct arrow dirction
        startnote(weight<0) = endnote(weight<0);
        endnote(weight<0) = temp;
        weight = abs(weight);
    end
catch
    
end

R=sparse(startnote,endnote,weight,nnode,nnode);  % CM
P=biograph(R,nodename,'ShowWeights','on'...
                     ,'ShowArrows', ShowArrowsValue...
                     ,'Description', DescriptionValue...
                     );
H=view(P);
generator = mpc.gen(:,GEN_BUS);
set(H.Nodes(generator),'Color',[1 0.4 0.4]); % red generators

nodelabel = cell(nnode,1);
for i=1:nnode % label node property
    nodelabel{i,1} = ['Load:',num2str(roundn( mpc.bus(i,PD)+1j*mpc.bus(i,QD),-1 )),' MVA'];
    if strcmp(ShowArrowsValue,'on') && mpc.bus(i,BUS_TYPE)>1
        temp = num2str( roundn(  mpc.gen(mpc.gen(:,GEN_BUS)==i,PG)+1j*mpc.gen(mpc.gen(:,GEN_BUS)==i,QG),-1  ) );
        nodelabel{i,1} = [nodelabel{i,1},' Gen:',temp,' MVA'];
    end
    set(H.Nodes(i),'label',nodelabel{i,1});
end


% [Dist,Path]=graphshortestpath(R,1,20) %求节点1到节点20的最短路径  

% set(H.Nodes(Path),'Color',[1 0.4 0.4]);
% edges=getedgesbynodeid(H,get(H.Nodes(Path),'ID'));  
% set(edges,'LineColor',[1 0 0]);
