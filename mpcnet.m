function [H,P] = mpcnet(mpc)
%MPCNET ���ڻ���matpower case������ṹ
%   [H,P] = mpcnet(mpc) ����mpc������ṹ
%   �ú�������Bioinformatic Toolbox�ĺ�����Matpower Toolbox�����ݣ�����matpower 
%   case������ṹ���������ָ����matpower case��Ȼ����ת��Ϊ�ڲ���Ÿ�ʽ��Ȼ��
%   ���ᴴ��һ���ڵ������б�����Ƿ������������ᴴ��һ��ϡ���������ʾ���磬��ʹ��
%   biograph��������������ʾ����ͼ��
%   
%   1. ����ڵ���������100�������ᷢ�����棬��Ϊͼ�ο��ܻ�ܸ��ӡ�
%   2. ������ڵ�ᱻ���Ϊ"Gen"����ɫΪ��ɫ��ƽ��ڵ�ᱻ���Ϊ"Gen*"��
%   3. ��֧��Ȩ��Ĭ��Ϊ��֧��ţ�ʹ�������ʶ��
%   4. ���matpower case�ǳ�������Ľ����mpc.successΪtrue�������֧Ȩ�ػᱻ
%      ����Ϊ�Ӷ˹�������MW�������Ҽ�ͷ����ʾ��ͼ�ϡ�
%   5. �ڵ�ı�ǩ����ʾ�为�ػ򷢵���Ĺ��ʡ�
%
%   ��лmatpower�ŶӺ�Bioinformatic Toolbox�Ŷӡ�
%
%   Input:
%       mpc - matpower case�����ƻ�·��
%
%   Output:
%       H - biograph�������ͼ
%       P - biograph����
%
% See also: define_constants, loadcase, ext2int, biograph, view

% Author: yjy @ https://github.com/3plus10i
% Created on: : 2019-08-29
% Revision: 2023-12-04

%Origin comment:
% ��װ�� network1.m, ������matpower case������ṹ
% 2019-08-29
% plot based on Bioinformatic Toolbox, data based on Matpower Toolbox
% 2019-09-04

% ����biograph�Ѿ���R2022a�б��Ƴ��������������Ҳ���ٿ����ˡ�
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


% [Dist,Path]=graphshortestpath(R,1,20) %��ڵ�1���ڵ�20�����·��  

% set(H.Nodes(Path),'Color',[1 0.4 0.4]);
% edges=getedgesbynodeid(H,get(H.Nodes(Path),'ID'));  
% set(edges,'LineColor',[1 0 0]);
