function savefile_name = pick_curve()
%PICK_CURVE ��ͼ���н���ʽ����ȡ��������
%   savefile_name = PICK_CURVE()��ͼ���н���ʽ����ȡ�������ݣ����浽
%   .mat�ļ��С��ú��������û���ͼ������ȡ�������ݡ��û������ֶ�ѡ��ͼ����
%   �Ĳο���Ͳ����㣬Ȼ����������������λ�õ���ʵ����ϵ�ķ���任����
%   ����������ݡ�
%
%   Input:
%   ��
%
%   Output:
%   savefile_name - �������ݵ�.mat�ļ���
%
%   See also: ginput, imread, questdlg

%   Author: yjy @ https://github.com/3plus10i
%   Created on: : 2021-03-17
%   Revision: 2021-09-24

%Origin comment:
% ʰȡͼƬ�еĵ�/����/ͼ�ε�����
% 2021��3��17��
% yjy@SCUT
% 2021��9��24��
% 	���Ӵ��ļ���������㹦�ܣ���Ҫ���ڲ�������ʧ��ʱ�����ظ�������
%	�Ż������߼�
% Notes:
% 1. �ú����漰��3������ϵ��
%    a. p(pixel)����ϵ����������Ϊx����������Ϊy�����Ǵ�ginput�л�ȡ���������õ�����ϵ��
%    b. r(real)����ϵ��������ֱ������ϵ�����Ƿ�������Ӧ���ڵ�����ϵ��
%    c. m(matrix)����ϵ����������Ϊrow����������Ϊcol�����Ƕ�ͼ�����ݾ����������ʱ�õ�����ϵ��������������
% 2. �����д������������ݣ���Ҫת������p->r����ϵΪr = A*p+b;
% 3. �����н���ͼ��ü���Ҫp->m����ϵΪm = round( [0,1;1,0]*p );
% 4. ���ͼ�����귶Χ����Ϊ��ü�����һ��ʱ������p->r�ı任����Ҫע����������ϵ����仯����ĺ��������С��ϵ�ı任��



%% ��ȡͼƬ
imgfile = uigetimagefile();
im_raw = imread(imgfile);

% �Ժڰ�ͼ����һ�£������˹�����
im = im_raw;
% im = 255 - im_raw;
% im(im<100) = 100;

%% �˹���ȡ�ο���
flag = 0;
while ~flag
    rp = questdlg("ѡ��2��������֪��ʵ����ĵ���Ϊ�ο��㣬����¼�����ǵ���ʵ���꣬��Enter��������",...
        "��ȡ�ο���[1/3]",...
        "��ʼѡȡ","��mat����","��ת������","��ʼѡȡ");
    if strcmp(rp,"��ת������")
        ref = [0,1;1,0;1,1];
        ref_real = [0,1;1,0;1,1];
        flag = 1;
        disp("ʹ��Ĭ�ϲο���")
    elseif strcmp(rp,"��ʼѡȡ")
        ref_real = []; % ѡȡ�Ĳο������ʵ����
        fig = figure();
        imshow(im);
        title("ѡ��2��������֪��ʵ����Ĳο��㣬����¼�����ǵ���ʵ���꣬��Enter��������")
        max_fig(fig);
        try
            ref = ginput(); % enter��������
        catch
            flag = 0; % ����
        end
        close;
        while isempty(ref_real)
            rp = questdlg("�������а�˳������ο������ʵ���꣨eg:[10,2;20,2;15,4];��",...
            "��ȡ�ο���[1/4]",...
            "ok","abort","ok");
            if strcmp(rp,"abort")
                savefile_name = "";
                return
            end
            ref_real = input("�ȴ�������ʵ����>>");
        end
        if(any(size(ref_real)==1))
            ref_real = reshape(ref_real(:),2,[])';
        end
        flag = 1;
    elseif strcmp(rp,"��mat����")
        [file,path] = uigetfile('*.mat',"ѡȡ�����ļ�");
        data_ = fullfile(path,file);
        try
            load(data_,"ref","ref_real");
            ref;
            ref_real;
            disp("�������ļ�����ο������ݣ�"+data_)
            flag = 1;
        catch
            disp("����ο�������ʧ�ܣ�")
        end
    end
end

% ����ο�����
savefile_name = imgfile+"_"+datestr(now(),30)+".mat";
save(savefile_name,'ref')
save(savefile_name,'ref_real',"-append")
disp("�ο��������ѱ�����"+savefile_name)


%% ��ȡͼƬ & �˹���ȡ������
    %% ��ȡͼƬ
flag = 0;
while ~flag
    % ��ͼƬ����ʱ��ȡͼƬ�е��ص㲿��
    rp = questdlg("�Ƿ���Ҫֻ��ȡͼƬһ�����Է�����������",...
        "��ȡ[2/3]",...
        "��","��","abort","��");
    if strcmp(rp,"��")
        cut_area = [0,0;size(im,2),size(im,1)];
    elseif strcmp(rp,"��")
        fig = figure();
        imshow(im);
        title("ѡȡ����Ŀ��ͼ�εľ������򣬵��������[���Ͻ�]��[���½�]")
        max_fig(fig);
        cut_area = ginput(2); % enter��������
        close;
        cut_area = round(cut_area);
        im = im(cut_area(1,2):cut_area(2,2),cut_area(1,1):cut_area(2,1),:);
    else % strcmp(rp,"abort")
        savefile_name = "";
        return
    end

    %% �˹���ȡ������
    
    rp = questdlg("����ѡȡ�����ϵĵ㣬��Enter��������",...
        "����[3/3]",...
        "��ʼ����","��mat����","abort","��ʼ����");
    if strcmp(rp,"abort")
        savefile_name = "";
        return
    elseif strcmp(rp,"��mat����")
        [file,path] = uigetfile('*.mat',"ѡȡ�����ļ�");
        data_ = fullfile(path,file);
        try
            load(data_,"p");
            p;
            disp("�������ļ�����ο������ݣ�"+data_)
            flag = 1;
        catch
            disp("����ο�������ʧ�ܣ�")
            flag = 0;
        end
    else
        fig = figure('CloseRequestFcn',@warn_closereq);% �ӹرվ���
        imshow(im);
        title("����ѡȡ�����ϵĵ㣬��Enter��������")
        max_fig(fig);
        try
            p = ginput(); % enter��������
        catch
            disp("�ѷ�������")
            return
        end
        set(fig,'CloseRequestFcn','closereq') % �ظ��رջص�
        close
        % �ü�����
        p(:,1) = p(:,1) + cut_area(1,1);
        p(:,2) = p(:,2) + cut_area(1,2);
        % �����������
        save(savefile_name,'p',"-append")
        disp("���������ѱ�����"+savefile_name)
        flag = 1;
    end
end
%% ��������λ��p����ʵ����ϵ����p_real�ģ�ƽ�ƺ����ţ�����任
% |pr1|   | a1    | |p1|   |b1|
% |pr2| = |    a2 | |p2| + |b2|
disp("���ڻ�������")
c1 = [ref(:,1),ones(size(ref,1),1)]\ref_real(:,1);
c2 = [ref(:,2),ones(size(ref,1),1)]\ref_real(:,2);
A(1,1)=c1(1);b(1,1)=c1(2);
A(2,2)=c2(1);b(2,1)=c2(2);
save(savefile_name,'A',"-append")
save(savefile_name,'b',"-append")

%% ������ʵ���ݵ�
p_real = (A*p'+b)';
disp("���껻�����")
x = p_real(:,1);
y = p_real(:,2);
save(savefile_name,'p_real',"-append")
save(savefile_name,'x',"-append")
save(savefile_name,'y',"-append")

readme = [
    savefile_name;
    "p:��������������";
    "ref:�ο�����������";
    "p_real:��������ʵ����";
    "ref_real:�ο�����ʵ����";
    "x:��������ʵ����-������";
    "y:��������ʵ����-������";
    "A,b:������λ��p����ʵ����ϵ����p_real�ģ�ƽ�ƺ����ţ�����任����";
];
save(savefile_name,'readme',"-append")

disp("ʶ�������ѱ�����"+savefile_name)

%% ��ͼ
figure('Name',"pick curve result")
[~,tmp] = fileparts(imgfile);
subplot(1,2,1)
imshow(im_raw)
title(tmp+" ԭʼͼ��",'Interpreter','none')

subplot(1,2,2)
plot(x,y,'o-');
title(tmp+" �������",'Interpreter','none')
grid on
cut_area_real(1,:) = ( A*cut_area(1,:)' + b )';
cut_area_real(2,:) = ( A*cut_area(2,:)' + b )';
range = [sort(cut_area_real(:,1))', sort(cut_area_real(:,2))'];
axis(range)
end


%%
% ��󻯴��ں���
function max_fig(h)
    size_ = get(0);
    if isstruct(size_)
        size_ = size_.ScreenSize;
    end
    set(h,'position',size_);
end

% �ر���ʾ����
function warn_closereq(src,callbackdata)
   selection = questdlg("�ر�ͼ������ʧ�������ݣ���ʹ��Enter�����������������Ƿ�����رգ�",...
      "����",...
      "�رղ���������","ȡ��","ȡ��"); 
   switch selection 
      case '�رղ���������'
         delete(gcf)
      case 'ȡ��'
      return 
   end
end

