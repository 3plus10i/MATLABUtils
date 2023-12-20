function summary = checkmpc(mpc, fname)
%CHECKMPC ���matpower case�Ļ�������͸�������״̬
%   SUMMARY = CHECKMPC(MPC) ��������matpower case (MPC)������һ��ժҪ��
%   ժҪ�����˸��ּ��Ľ��������ڵ�˳��ͣ����·����ѹ���ࡢ�ڵ㵼�ɡ�����ͨ�ԡ�ͣ�˻����ͬ�����ȡ�
%   ���MPC�����ݲ���(����100��)������������ӡ�������С�
%
%   SUMMARY = CHECKMPC(MPC, FNAME) ��������matpower case (MPC)���������ӡ����ΪFNAME��txt�ļ��С�
%   ���FNAMEΪ��ֵ�������Ĭ���У��Ȳ�д���ļ�Ҳ���������д�ӡ����������������ڷ���ֵ�С�
%   
%   ʾ����
%       summary = checkmpc(mpc)
%       summary = checkmpc(mpc, '')
%       summary = checkmpc(mpc, 'myFile')
%
%   �μ���LOADCASE, DEFINE_CONSTANTS

%   Author: yjy @ https://github.com/3plus10i
%   Created on: : 2019-10-08


%Original comments:
% ���matpower case�����������״̬ 2019.10.08

%TODO ����� ��Ϊ ��ȷ�Χ��ֵΪ����С��ȣ�����ȡ�
%TODO ������ϸģʽ����ȵ�ͳ��������н������ͳ�ƽ��
%TODO ���ӷ���������·���


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
    {'�ڵ�˳��' '�Ƿ�˳��' '���ֵ'}
    {'ͣ����·' '����' 'ʼ�յ�' '��·����'}
%     {'������·' '��·ʼĩ' '��������' '��������'} %TODO
    {'��ѹ����' '��Ŀ' '�����' 'λ��' '�������' 'λ��'}
    {'�ڵ㵼��' '����ڵ���' '����й�' '����޹�'}
    {'����ͨ��' '����'}
    {'ͣ�˻���' '��������' '�ڵ�' '�����' '����'}
    {'ͬ����' '����ڵ�' '���˻�������' '��������'}
    };
title_row_index = ones(size(obj,1),1);
summary = {};
nrow = 0; % nrow always update immediately after summary is updated


%% ���

% {'�ڵ�˳��' '�Ƿ�˳��' '���ֵ'}
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

% {'ͣ����·' '����' 'ʼ�յ�' '��·����'}
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

% {'��ѹ����' '��Ŀ' '�����' 'λ��' '�������' 'λ��'}
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


% {'�ڵ㵼��' '����ڵ���' '����й�' '����޹�'}
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

% {'����ͨ��' '����'}
nobj = 5;
item = length(obj{nobj});
summary(nrow+1,1:item) = obj{nobj};
nrow = nrow+1;
title_row_index(nobj) = nrow;
[groups,isolated] = find_islands(mpc);
nis = numel(groups)+length(isolated);
summary(nrow+1,1:item) = {[] nis};
nrow = nrow+1;


% {'ͣ�˻���' '��������' '�ڵ�' '�����' '����'}
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

% {'ͬ����' '����ڵ�' '���˻�������' '��������'}
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


%% ���
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
        isdisp = false; % �ڵ������࣬����ӡ��������
    end
end

myprt(fid,['MPC ',inputname(1),'״̬ͳ�� ',char(datetime('now','Format','yyyyMMddHHmmss')),'\n'],isdisp);
myprt(fid,['�ܽڵ��� ' num2str(nb) '\n'],isdisp);
if ~isempty(fid)
    offset = 4+size(obj,1);
    myprt(fid,'Ŀ¼\n',isdisp);
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
    myprt('', ['MPC ',inputname(1),'״̬ͳ���ѱ�����',fname,'\n'], isdisp)
elseif isdisp
    myprt('', ['MPC ',inputname(1),'״̬ͳ�������\n'], isdisp)
end

summary(2:end+1,:) = summary;
summary(1,:)={[]};
summary(1,1)={1+title_row_index};
summary(1,2)={['MPC ',inputname(1),'״̬ͳ�� ',char(datetime('now','Format','yyyyMMddHHmmss'))]};
summary(1,3)={['�ܽڵ��� ', num2str(nb)]};


function myprt(fid, str, isdisp)
% �������ļ�idĬ���ǲ���ӡ��
% ���û�и����ļ�id����д����Ҫdisp�����ӡ��������
if ~isempty(fid)
    fprintf(fid, str);
elseif isdisp
    fprintf(str);
end
