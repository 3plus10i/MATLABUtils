function summary = checkmpc(mpc, fname)
%CHECKMPC 检查matpower case的基本情况和各种特殊状态
%   SUMMARY = CHECKMPC(MPC) 检查给定的matpower case (MPC)并返回一个摘要。
%   摘要包含了各种检查的结果，例如节点顺序、停运线路、变压移相、节点导纳、单连通性、停运机组和同点多机等。
%   如果MPC的数据不多(少于100行)，则结果还将打印到命令行。
%
%   SUMMARY = CHECKMPC(MPC, FNAME) 检查给定的matpower case (MPC)并将结果打印到名为FNAME的txt文件中。
%   如果FNAME为空值，则程序静默进行，既不写入文件也不再命令行打印，检查结果将仅保存在返回值中。
%   
%   示例：
%       summary = checkmpc(mpc)
%       summary = checkmpc(mpc, '')
%       summary = checkmpc(mpc, 'myFile')
%
%   参见：LOADCASE, DEFINE_CONSTANTS

%   Author: yjy @ https://github.com/3plus10i
%   Created on: : 2019-10-08


%Original comments:
% 检查matpower case的情况和特殊状态 2019.10.08

%TODO 最大变比 改为 变比范围，值为【最小变比，最大变比】
%TODO 增加详细模式，变比的统计输出所有结果而非统计结果
%TODO 增加分析并联线路情况


if nargin<2
    fid = [];
    isdisp = true;
elseif isempty(fname)
    fid = [];
    isdisp = false;
else
    if ~strcmpi(fname(end-3:end),'.txt')
        fname = [fname,'.txt'];
    end
    fid = fopen(fname,'w');
    isdisp = false;
end

define_constants;
mpc = loadcase(mpc);
[bus, gen, branch] = deal(mpc.bus, mpc.gen, mpc.branch);
nb = size(bus,1);
ng = size(gen,1);

obj = {
    {'节点顺序' '是否顺序' '最大值'}
    {'停运线路' '行数' '始终点' '线路容量'}
%     {'并联线路' '线路始末' '并联重数' '所在行数'} %TODO
    {'变压移相' '数目' '最大变比' '位置' '最大移相' '位置'}
    {'节点导纳' '非零节点数' '最大有功' '最大无功'}
    {'单连通性' '岛数'}
    {'停运机组' '所在行数' '节点' '额定出力' '容量'}
    {'同点多机' '多机节点' '在运机组重数' '所在行数'}
    };
title_row_index = ones(size(obj,1),1);
summary = {};
nrow = 0; % nrow always update immediately after summary is updated


%% 检查

% {'节点顺序' '是否顺序' '最大值'}
nobj = 1;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
if any(bus(:, BUS_I) ~= (1:nb)')
    summary(nrow+1,1:item) = {[],0,max(bus(:, BUS_I))};
    nrow = nrow+1;
else
    summary(nrow+1,1:item) = {[],1,nb};
    nrow = nrow+1;
end

% {'停运线路' '行数' '始终点' '线路容量'}
nobj = 2;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
idx = find(branch(:,BR_STATUS)==0);
if ~isempty(idx)
    for i=1:length(idx)
        ft = sprintf('%d - %d',branch(idx(i),[F_BUS,T_BUS]));
        rate = branch(idx(i),RATE_A);
        summary(nrow+1,1:item) = {i,idx(i),ft,rate};
        nrow = nrow+1;
    end
else
    summary(nrow+1,1:item) = {[],0,'0-0',0};
    nrow = nrow+1;
end

% {'变压移相' '数目' '最大变比' '位置' '最大移相' '位置'}
nobj = 3;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
idx = find(branch(:,TAP)~=0|branch(:,SHIFT)~=0);
if ~isempty(idx)
    [tapm,tapmi] = max(branch(:,TAP));
    tapmi2 = branch(tapmi,[F_BUS,T_BUS]);
    tapmi2 = sprintf('%d, %d - %d',tapmi,tapmi2);
    [shm,shmi] = max(branch(:,SHIFT));
    shmi2 = branch(shmi,[F_BUS,T_BUS]);
    shmi2 = sprintf('%d, %d - %d',shmi,shmi2);
    summary(nrow+1,1:item) = {[] length(idx) tapm tapmi2 shm shmi2};
    nrow = nrow+1;
else
    summary(nrow+1,1:item) = {[],0,0,'0,0-0',0,'0,0-0'};
    nrow = nrow+1;
end


% {'节点导纳' '非零节点数' '最大有功' '最大无功'}
nobj = 4;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
idx = bus(:,GS)~=0|bus(:,BS)~=0;
[~,gm] = max(abs(bus(:,GS)));
gm = bus(gm,GS);
[~,bm] = max(abs(bus(:,BS)));
bm = bus(bm,BS);
summary(nrow+1,1:item) = {[] sum(idx) gm bm};
nrow = nrow+1;

% {'单连通性' '岛数'}
nobj = 5;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
[groups,isolated] = find_islands(mpc);
nis = numel(groups)+length(isolated);
summary(nrow+1,1:item) = {[] nis};
nrow = nrow+1;


% {'停运机组' '所在行数' '节点' '额定出力' '容量'}
nobj = 6;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
idx = find(gen(:,GEN_STATUS)==0);
if ~isempty(idx)
    for i=1:length(idx)
        bs = gen(idx(i),[GEN_BUS,PG]);
        sgen = gen(idx(i),[PMAX,QMAX]);
        sgen = sprintf('%+5.2f %+5.2fi',sgen(1),sgen(2));
        summary(nrow+1,1:item) = {i idx(i) bs(1) bs(2) sgen};
        nrow = nrow+1;
    end
else
    summary(nrow+1,1:item) = {[],0,0,0,0};
    nrow = nrow+1;
end

% {'同点多机' '多机节点' '在运机组重数' '所在行数'}
nobj = 7;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
order.e2i = sparse(bus(:,BUS_I), 1, 1:nb);
order.i2e = bus(:,BUS_I);
Cg = sparse(order.e2i(gen(:, GEN_BUS)), (1:ng)', gen(:,GEN_STATUS), nb, ng);
multigenb = bus(sum(Cg,2)>1,BUS_I);
if isempty(multigenb)
    summary(nrow+1,1:item) = {[] 0 0 0};
    nrow = nrow+1;
else
    multigen = sum(Cg,2);
    multigen = multigen(multigen>1);
    [~,genrow] = ismember(multigenb,gen(:,GEN_BUS));
    for i=1:length(multigenb)
        summary(nrow+1,1:item) = {i multigenb(i) multigen(i) genrow(i)};
        nrow = nrow+1;
    end
end


%% 输出
% width = 18;
tmp = 0;
for i=1:numel(summary)
    ch = 1; % character width
    if any(i==title_row_index)
            ch = 2;
    end
    if length(ch*num2str(summary{i}))>tmp
        tmp = ch*length(num2str(summary{i}));
    end
end
width = tmp+4;
    
if isdisp
    if nrow > 100
        isdisp = false; % 节点数过多，不打印到命令行
    end
end

myprt(fid,['MPC ',inputname(1),'状态统计 ',char(datetime('now','Format','yyyyMMddHHmmss')),'\n'],isdisp);
myprt(fid,['总节点数 ' num2str(nb) '\n'],isdisp);
if ~isempty(fid)
    offset = 4+size(obj,1);
    myprt(fid,'目录\n',isdisp);
    dot = '.'; % dot(ones(1,10))
    for i=1:size(obj,1)
        fprintf(fid,[obj{i}{1},dot(ones(1,22-2*length(obj{i}{1}))),'%d\n'],offset+title_row_index(i));
    end
    myprt(fid,'\n',isdisp);
end

for i=1:size(summary,1)
    ch = 1;
    if any(i==title_row_index)
        ch = 2;
    end
    for j=1:size(summary,2)
        tmp = width - length(num2str(summary{i,j}))*ch;
        myprt(fid,[num2str(summary{i,j}),blanks(tmp)],isdisp);
    end
    myprt(fid,'\n',isdisp)
end
if ~isempty(fid)
    fclose(fid);
    myprt('', ['MPC ',inputname(1),'状态统计已保存在',fname,'\n'], isdisp)
elseif isdisp
    myprt('', ['MPC ',inputname(1),'状态统计已完成\n'], isdisp)
end

summary(2:end+1,:) = summary;
summary(1,:)={[]};
summary(1,1)={1+title_row_index};
summary(1,2)={['MPC ',inputname(1),'状态统计 ',char(datetime('now','Format','yyyyMMddHHmmss'))]};
summary(1,3)={['总节点数 ', num2str(nb)]};


function myprt(fid, str, isdisp)
% 给定了文件id默认是不打印的
% 如果没有给定文件id，且写明了要disp，则打印到命令行
if ~isempty(fid)
    fprintf(fid, str);
elseif isdisp
    fprintf(str);
end
