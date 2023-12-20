function savefile_name = pick_curve()
%PICK_CURVE 从图像中交互式地提取曲线数据
%   savefile_name = PICK_CURVE()从图像中交互式地提取曲线数据，保存到
%   .mat文件中。该函数允许用户从图像中提取曲线数据。用户可以手动选择图像中
%   的参考点和采样点，然后函数会计算出从像素位置到真实坐标系的仿射变换，并
%   保存相关数据。
%
%   Input:
%   无
%
%   Output:
%   savefile_name - 保存数据的.mat文件名
%
%   See also: ginput, imread, questdlg

%   Author: yjy @ https://github.com/3plus10i
%   Created on: : 2021-03-17
%   Revision: 2021-09-24

%Origin comment:
% 拾取图片中的点/曲线/图形的坐标
% 2021年3月17日
% yjy@SCUT
% 2021年9月24日
% 	增加从文件导入采样点功能，主要用于采样意外失败时减少重复工作量
%	优化导入逻辑
% Notes:
% 1. 该函数涉及到3个坐标系：
%    a. p(pixel)坐标系，横向向右为x，纵向向下为y，这是从ginput中获取的坐标所用的坐标系；
%    b. r(real)坐标系，正常的直角坐标系，这是返回数据应该在的坐标系；
%    c. m(matrix)坐标系，纵向向下为row，横向向右为col，这是对图像数据矩阵进行索引时用的坐标系，都是正整数；
% 2. 程序中从鼠标采样到数据，需要转化的是p->r，关系为r = A*p+b;
% 3. 程序中进行图像裁剪需要p->m，关系为m = round( [0,1;1,0]*p );
% 4. 最后画图将坐标范围调整为与裁剪区域一致时，除了p->r的变换，还要注意由于坐标系方向变化引起的横纵坐标大小关系的变换。



%% 读取图片
imgfile = uigetimagefile();
im_raw = imread(imgfile);

% 对黑白图处理一下，方便人工操作
im = im_raw;
% im = 255 - im_raw;
% im(im<100) = 100;

%% 人工获取参考点
flag = 0;
while ~flag
    rp = questdlg("选定2个以上已知真实坐标的点作为参考点，并记录下它们的真实坐标，按Enter结束采样",...
        "获取参考点[1/3]",...
        "开始选取","从mat导入","不转换坐标","开始选取");
    if strcmp(rp,"不转换坐标")
        ref = [0,1;1,0;1,1];
        ref_real = [0,1;1,0;1,1];
        flag = 1;
        disp("使用默认参考点")
    elseif strcmp(rp,"开始选取")
        ref_real = []; % 选取的参考点的真实坐标
        fig = figure();
        imshow(im);
        title("选定2个以上已知真实坐标的参考点，并记录下它们的真实坐标，按Enter结束采样")
        max_fig(fig);
        try
            ref = ginput(); % enter结束采样
        catch
            flag = 0; % 重来
        end
        close;
        while isempty(ref_real)
            rp = questdlg("在命令行按顺序输入参考点的真实坐标（eg:[10,2;20,2;15,4];）",...
            "获取参考点[1/4]",...
            "ok","abort","ok");
            if strcmp(rp,"abort")
                savefile_name = "";
                return
            end
            ref_real = input("等待输入真实坐标>>");
        end
        if(any(size(ref_real)==1))
            ref_real = reshape(ref_real(:),2,[])';
        end
        flag = 1;
    elseif strcmp(rp,"从mat导入")
        [file,path] = uigetfile('*.mat',"选取数据文件");
        data_ = fullfile(path,file);
        try
            load(data_,"ref","ref_real");
            ref;
            ref_real;
            disp("从以下文件导入参考点数据："+data_)
            flag = 1;
        catch
            disp("导入参考点数据失败！")
        end
    end
end

% 保存参考数据
savefile_name = imgfile+"_"+datestr(now(),30)+".mat";
save(savefile_name,'ref')
save(savefile_name,'ref_real',"-append")
disp("参考点数据已保存在"+savefile_name)


%% 截取图片 & 人工获取采样点
    %% 截取图片
flag = 0;
while ~flag
    % 在图片过大时截取图片中的重点部分
    rp = questdlg("是否需要只截取图片一部分以方便鼠标采样？",...
        "截取[2/3]",...
        "是","否","abort","是");
    if strcmp(rp,"否")
        cut_area = [0,0;size(im,2),size(im,1)];
    elseif strcmp(rp,"是")
        fig = figure();
        imshow(im);
        title("选取包含目标图形的矩形区域，点击该区域[左上角]和[右下角]")
        max_fig(fig);
        cut_area = ginput(2); % enter结束采样
        close;
        cut_area = round(cut_area);
        im = im(cut_area(1,2):cut_area(2,2),cut_area(1,1):cut_area(2,1),:);
    else % strcmp(rp,"abort")
        savefile_name = "";
        return
    end

    %% 人工获取采样点
    
    rp = questdlg("依次选取曲线上的点，按Enter结束采样",...
        "采样[3/3]",...
        "开始采样","从mat导入","abort","开始采样");
    if strcmp(rp,"abort")
        savefile_name = "";
        return
    elseif strcmp(rp,"从mat导入")
        [file,path] = uigetfile('*.mat',"选取数据文件");
        data_ = fullfile(path,file);
        try
            load(data_,"p");
            p;
            disp("从以下文件导入参考点数据："+data_)
            flag = 1;
        catch
            disp("导入参考点数据失败！")
            flag = 0;
        end
    else
        fig = figure('CloseRequestFcn',@warn_closereq);% 加关闭警告
        imshow(im);
        title("依次选取曲线上的点，按Enter结束采样")
        max_fig(fig);
        try
            p = ginput(); % enter结束采样
        catch
            disp("已放弃采样")
            return
        end
        set(fig,'CloseRequestFcn','closereq') % 回复关闭回调
        close
        % 裁剪矫正
        p(:,1) = p(:,1) + cut_area(1,1);
        p(:,2) = p(:,2) + cut_area(1,2);
        % 保存采样数据
        save(savefile_name,'p',"-append")
        disp("采样数据已保存在"+savefile_name)
        flag = 1;
    end
end
%% 求解从像素位置p到真实坐标系坐标p_real的（平移和缩放）仿射变换
% |pr1|   | a1    | |p1|   |b1|
% |pr2| = |    a2 | |p2| + |b2|
disp("正在换算坐标")
c1 = [ref(:,1),ones(size(ref,1),1)]\ref_real(:,1);
c2 = [ref(:,2),ones(size(ref,1),1)]\ref_real(:,2);
A(1,1)=c1(1);b(1,1)=c1(2);
A(2,2)=c2(1);b(2,1)=c2(2);
save(savefile_name,'A',"-append")
save(savefile_name,'b',"-append")

%% 计算真实数据点
p_real = (A*p'+b)';
disp("坐标换算完成")
x = p_real(:,1);
y = p_real(:,2);
save(savefile_name,'p_real',"-append")
save(savefile_name,'x',"-append")
save(savefile_name,'y',"-append")

readme = [
    savefile_name;
    "p:采样点像素坐标";
    "ref:参考点像素坐标";
    "p_real:采样点真实坐标";
    "ref_real:参考点真实坐标";
    "x:采样点真实坐标-横坐标";
    "y:采样点真实坐标-纵坐标";
    "A,b:从像素位置p到真实坐标系坐标p_real的（平移和缩放）仿射变换参数";
];
save(savefile_name,'readme',"-append")

disp("识别数据已保存在"+savefile_name)

%% 画图
figure('Name',"pick curve result")
[~,tmp] = fileparts(imgfile);
subplot(1,2,1)
imshow(im_raw)
title(tmp+" 原始图像",'Interpreter','none')

subplot(1,2,2)
plot(x,y,'o-');
title(tmp+" 采样结果",'Interpreter','none')
grid on
cut_area_real(1,:) = ( A*cut_area(1,:)' + b )';
cut_area_real(2,:) = ( A*cut_area(2,:)' + b )';
range = [sort(cut_area_real(:,1))', sort(cut_area_real(:,2))'];
axis(range)
end


%%
% 最大化窗口函数
function max_fig(h)
    size_ = get(0);
    if isstruct(size_)
        size_ = size_.ScreenSize;
    end
    set(h,'position',size_);
end

% 关闭提示函数
function warn_closereq(src,callbackdata)
   selection = questdlg("关闭图窗将丢失采样数据，请使用Enter键正常结束采样，是否继续关闭？",...
      "警告",...
      "关闭并丢弃数据","取消","取消"); 
   switch selection 
      case '关闭并丢弃数据'
         delete(gcf)
      case '取消'
      return 
   end
end

