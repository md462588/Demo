%% DTI_making with TE information
clear;

addpath('C:\script');
addpath('F:\Tama\script');
addpath('F:\Tama');
addpath('F:\Tama\fieldtrip-20211102');
addpath('F:\Tama\fieldtrip-20211102\utilities');
addpath('F:\Tama\fieldtrip-20211102\plotting')
fsadir = 'C:\script\fsaverage';

% ***** set parameters ***
Method = 'Raw'; 
SD_sig = 1.96;
sn = 10;

list_1={'T'};
list_2={'1_Onset'};
p1=size(list_1,2); p2=size(list_2,2);

for q1=1:p1
n1=char(list_1(1,q1));
for q2=1:p2
n2=char(list_2(1,q2));
Task='What';
Timing='P1onset';
task = [n1 n2]; % Res_On, Stim_On;
durations = {200};
for duration = durations
duration = cell2mat(duration);
slide = 100;
time_bin = 10;

NF = '1000';
NS = '500000';
NSK = strcat(num2str(str2num(NS)/1000), 'k');
thres = '0.05';
SS = '0';
condition = 'ROI2ROI'; %  'ROI2ROI', 'ROI2SEED', 'SEED2ROI'
% *****set movie parameter**************
Connect_thres = 0.5 ;
min_transparency = 0.1;
% ******************************
% ******************************

datadir = ['F:\GitHub\Data\duration' num2str(duration) 'ms\'];

% load tract data
Tract1 = load(['F:\GitHub\Data\fiber_limit_' num2str(NF) '\' Task '\' Timing '\thres' num2str(thres)...
    '\tract_' condition '_' Task '_' Timing '_' NSK '_fa_threshold_' num2str(thres) '_stepsize_' num2str(SS) '.mat']);

% load tract data
Tract2 = load(['F:\GitHub\Data\fiber_limit_' num2str(NF) '\' Task '\' Timing '\thres' num2str(thres)...
    '\tract_' condition '_' Task '_' Timing '_' NSK '_fa_threshold_' num2str(thres) '_stepsize_' num2str(SS) '.mat']);
time=[0:10:200];
Time = time;
t1 = [Time(1):slide:Time(end)-duration];
t2 = [Time(1)+duration:slide:Time(end)];
tt = cat(1,t1,t2);clear t1 t2
Times={};
for n=1:size(tt,2)
Times{n}=[tt(1,n) tt(2,n)];
end

for time = Times;
time = cell2mat(time);
    savedir = ['F:\GitHub\Result\duration' num2str(duration) 'ms\sphere' num2str(sn) '\time' num2str(time(1)) '_' num2str(time(2))]; % Set export directory
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end

    % load TE information
    
    TE = readtable(['F:\GitHub\Data\duration' num2str(duration) 'ms\Final_Combination_' Method '_' task '_' num2str(time(1)) '_' num2str(time(2)) '_transfer_entropy_ave100.xlsx']);
   
    savename = fullfile(savedir,['tract_with_ave100_TE_' ...
        condition '_' Task '_' Timing '_' NSK '_fa_threshold_' num2str(thres) '_stepsize_' num2str(SS)]);

    % if contains NaN, remove it
    N = find(isnan(TE.TEvalue));
    if ~isempty(N)
    TE(N,:) = [];
    end
    clear N

    % load sphere information
         Sphere = load([datadir, 'sphere_position_Combination_' ...
            Method '_' Task '_' Timing '_transfer_entropy_ave100_sphere' num2str(sn) '_time' num2str(time(1)) '_' num2str(time(2)) '.mat']);
        
    % 4dimension
    for i = 1:size(Sphere.Coordinate.Position,1)
        ii = cell2mat(Sphere.Coordinate.Position(i));
        if ndims(ii) == 3
            ii = repmat(ii,1,1,1,2);
            Sphere.Coordinate.Position(i) = {ii};
        end
        clear ii
    end

    Sphere.Coordinate = Sphere.Coordinate.Position;

    % ***** set condition ********************
    fontsize = 4; % for font, 6

    left_name = [Task ' ' Timing];%need to change
    right_name = [Task ' ' Timing];

    % *** for movie ***
    Export_Movie = 0; % 1 = generate movie file
    movie_time_range =[time(1) time(2)];
    frame_number=3; % Increase the frame number if you want to slow motion.

    % *** for snapshots ***
    Export_Fig = 1;% 1 = generate snapshot file

    Export_times = [200];

    % ************************************************************************************
    % ************************************************************************************
    TE = table2cell(TE);
    Sphere1 = Sphere.Coordinate; Sphere2 = Sphere1;

    amp_color_range=[-1 1];  % = transparency
    Timeunit = 10; % ms
    TIME = [time(1):Timeunit:time(2)];% それぞれのtime毎にsetする必要あるため記載した。

    Side1 = Tract1.Data.tract_name;
    Side2 = Tract2.Data.tract_name;
    Setting.fnum = size(Tract1.Data.Alpha,2);
    Setting.Time_all = Tract1.Data.time;

    Alpha1 = Tract1.Data.Alpha';
    Alpha2 = Tract2.Data.Alpha';
    Tract_1 = Tract1.Tract;
    Tract_2 = Tract2.Tract;

    tra_name1 = Tract1.Data.tract_name;
    tra_name2 = Tract2.Data.tract_name;

    Title = [task];

    [ftver, ftpath] = ft_version;
    mesh_lh = load([ftpath filesep 'template/anatomy/surface_pial_left.mat']);
    mesh_rh = load([ftpath filesep 'template/anatomy/surface_pial_right.mat']);

    % *** generate movie ***
    Generating_movies_Demo(Sphere1,Sphere2,Setting,savename,amp_color_range,Timeunit,frame_number,movie_time_range,fontsize,Title,left_name,right_name,Export_Movie,Export_Fig,Export_times,Tract_1,Tract_2,mesh_lh,mesh_rh,Side1,Side2,tra_name1,tra_name2,TE,TIME)

    disp(['Done ......time' num2str(time(1)) '_' num2str(time(2)) ' ms'])

end
end
end
end