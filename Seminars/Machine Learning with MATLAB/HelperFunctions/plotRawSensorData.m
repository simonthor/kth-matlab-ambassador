function plotRawSensorData(rawSensor1,rawSensor2,rawSensor3,activity,n_obs)

if nargin < 5 
    n_obs = size(rawSensor1,1);
end
g = 9.81;

rawTS(:,1) = reshape(rawSensor1(1:n_obs,:)',[],1);
rawTS(:,2) = reshape(rawSensor2(1:n_obs,:)',[],1);
rawTS(:,3) = reshape(rawSensor3(1:n_obs,:)',[],1);

activityType = repelem(activity(1:n_obs),128*ones(numel(activity(n_obs)),1));

fig = figure('Name','Human Activity Detection','NumberTitle','off',...
    'Units','Normalized','Visible','off');
fig.Position(3:4) = [0.7,0.95]; 
movegui('center')
fig.Visible = 'on';

ax(1) = subplot(3,1,1,'Parent',fig,'Xgrid','on','Ygrid','on',...
    'YLim',[-3*g 2*g]);
ax(2) = subplot(3,1,2,'Parent',fig,'Xgrid','on','Ygrid','on',...
    'YLim',[-3*g 2*g]); 
ax(3) = subplot(3,1,3,'Parent',fig,'Xgrid','on','Ygrid','on',...
    'YLim',[-3*g 2*g]);

clr = get(groot,'DefaultAxesColorOrder');
axes(ax(1)), gscatter(1:size(rawTS,1),g*rawTS(:,1),activityType,clr,'.',8,'on')
axes(ax(2)), gscatter(1:size(rawTS,1),g*rawTS(:,2),activityType,clr,'.',8,'off')
axes(ax(3)), gscatter(1:size(rawTS,1),g*rawTS(:,3),activityType,clr,'.',8,'off')

title(ax(1),inputname(1),'Interpreter','none')
title(ax(2),inputname(2),'Interpreter','none')
title(ax(3),inputname(3),'Interpreter','none')

linkaxes(ax,'x')

grid(ax(1),'on')
grid(ax(2),'on')
grid(ax(3),'on')

ylabel(ax(1),'(Acc-X (m \cdot s^{-2})')
ylabel(ax(2),'(Acc-Y (m \cdot s^{-2})')
ylabel(ax(3),'(Acc-Z (m \cdot s^{-2})')

xlabel(ax(1),'Time (sec)'), ax(1).XTickLabel = [];
xlabel(ax(2),'Time (sec)'), ax(2).XTickLabel = [];
xlabel(ax(3),'Time (sec)'), ax(3).XTickLabel = [];

end
