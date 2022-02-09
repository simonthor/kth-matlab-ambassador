function plotActivityResults(mdl,rawSensorDataTest,humanActivityTest,delay)
% Use trained model to predict activity on new sensor data
% Copyright (c) 2015, MathWorks, Inc.
if nargin < 4
    delay = 0.02;
end
g = 9.81; % in m/s^2
time = linspace(0,2.56,128);

fig = figure('Name','Human Activity Detection','NumberTitle','off','Visible','off');
fig.Position(3:4) = 600; 
movegui('center')
fig.Visible = 'on';

ax1 = subplot(2,1,1,'Parent',fig,'Xgrid','on','Ygrid','on',...
    'XLim',[time(1) time(end)],'YLim',[-2*g 2*g]);
ax2 = subplot(2,1,2,'Parent',fig,'Xgrid','on','Ygrid','on',...
    'XLim',[time(1) time(end)],'YLim',[-2 2]);
% axis(ax1,'square'), axis(ax2,'square')

clr = get(groot,'DefaultAxesColorOrder');
L(1) = line(time,g*rawSensorDataTest.total_acc_x_test(1,:),'color',clr(1,:),'Parent',ax1,'LineWidth',1.5,'DisplayName','Accelerometer X');
L(2) = line(time,g*rawSensorDataTest.total_acc_y_test(1,:),'color',clr(2,:),'Parent',ax1,'LineWidth',1.5,'DisplayName','Accelerometer Y');
L(3) = line(time,g*rawSensorDataTest.total_acc_z_test(1,:),'color',clr(3,:),'Parent',ax1,'LineWidth',1.5,'DisplayName','Accelerometer Z');

L(4) = line(time,  rawSensorDataTest.body_gyro_x_test(1,:),'color',clr(4,:),'Parent',ax2,'LineWidth',1.5,'DisplayName','Gyroscope X');
L(5) = line(time,  rawSensorDataTest.body_gyro_y_test(1,:),'color',clr(5,:),'Parent',ax2,'LineWidth',1.5,'DisplayName','Gyroscope Y');
L(6) = line(time,  rawSensorDataTest.body_gyro_z_test(1,:),'color',clr(6,:),'Parent',ax2,'LineWidth',1.5,'DisplayName','Gyroscope Z');

xlabel(ax1,'Time (s)')
ylabel(ax1,'(Accelerometer Readings (m \cdot s^{-2})')
legend(ax1,'show')
title(ax1,sprintf('Human Activity Mobile Sensor Data'));

xlabel(ax2,'Time (s)')
ylabel(ax2,'Gyroscope Readings rad \cdot sec{-1}')
legend(ax2,'show')
title(ax2,['Classifier: ', getClassifierName(mdl)]);

ann1 = annotation(fig,'textbox',[ax1.Position(1:3) 0.04],...
    'String','Predicted Activity : NA','FontSize',12,'FitBoxToText','off',...
    'BackgroundColor',[0 0.7 0.3],'HorizontalAlignment','Center','VerticalAlignment','middle','FaceAlpha',0.5);
ann2 = annotation(fig,'textbox',[ax1.Position(1) ax1.Position(2)+0.04 ax1.Position(3) 0.04],...
    'String','Actual Activity      : NA','FontSize',12,'FitBoxToText','off',...
    'BackgroundColor',[0 0.7 0.3],'HorizontalAlignment','Center','VerticalAlignment','middle','FaceAlpha',0.5);

%% Loop through the raw data and plot the sensor values
try
for ii = 600:height(humanActivityTest)
    
    activity = predict(mdl,humanActivityTest{ii,1:end-1});

    if activity == humanActivityTest.activity(ii)
        predclr = [0 0.7 0.3];
    else
        predclr = [1 0 0];
    end
	set(ann1,'String',['Predicted Activity   : ' char(activity)],...
        'BackgroundColor',predclr);
    set(ann2,'String',['Actual Activity        : ' char(humanActivityTest.activity(ii))],...
        'BackgroundColor',[0 0.7 0.3]);
    
    L(1).YData = g*rawSensorDataTest.total_acc_x_test(ii,:);
    L(2).YData = g*rawSensorDataTest.total_acc_y_test(ii,:);
    L(3).YData = g*rawSensorDataTest.total_acc_z_test(ii,:);

	L(4).YData =   rawSensorDataTest.body_gyro_x_test(ii,:);
    L(5).YData =   rawSensorDataTest.body_gyro_y_test(ii,:);
    L(6).YData =   rawSensorDataTest.body_gyro_z_test(ii,:);

    drawnow
    pause(delay)
end
catch err
end

function cname = getClassifierName(trainedClassifier)
    cname = class(trainedClassifier);
    if isa(trainedClassifier,'ClassificationECOC')
        cname = 'SVM';
    end
    pos = strfind(cname,'.');
    if ~isempty(pos)
      cname = cname(pos(end)+1:end);
    end