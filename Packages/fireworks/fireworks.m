function fireworks
%%
global AxesSize ;
AxesSize = 70000 ;
global BackgroundColor;
BackgroundColor = [0 0 0];

figure('MenuBar','none', 'ToolBar','none');
Handle = gcf ;
while 1
    Num = 100 ;
    Radio = 0:360/Num:360 ;
    V = rand(1,Num+1)*3000 ;
    
    L0 = 5000*(2.*rand(1, 2) -0.5) ;
    Lx0 = L0(1); Ly0 = L0(2);
    test_fashe(Handle, Lx0, Ly0) ;
    
    test_press(Lx0, Ly0, Radio, V, Handle) ;
    if ~ishandle(Handle)
        break ;
    end
end

% ------------------------------------
function test_fashe(Handle, Lx0, Ly0)
%%

Num = 20 ;
XStep = (Lx0+0) / Num ;
YStep = (Ly0+50000) / Num ;

% start position
XData = 0 ;
YData = -50000 ;

global AxesSize BackgroundColor;
LineHandle=plot([XData,Lx0],[YData,Ly0],'b-','LineWidth',3, 'Visible', 'off') ;
set(gca,'XLim',[-AxesSize,AxesSize],'YLim',[-AxesSize,AxesSize],...
    'color',BackgroundColor,'XTick',[],'YTick',[]) ;

for i = 0 : Num-1
    
    BeforeXData = XData ;
    BeforeYData = YData ;
    XData = BeforeXData+XStep;
    YData = BeforeYData+YStep;
    
    if ~ishandle(Handle)
        return ;
    end

    set(LineHandle, 'XData', [BeforeXData,XData], ...
        'YData', [BeforeYData,YData], 'Visible', 'on' ) ;
    pause(0.03) ;
    drawnow ;
end

% ------------------------------------
function test_press(Lx0, Ly0, Radio, V, Handle) 
%%

g = 10 ;
t = 0:0.2:40 ;
Detal = 3.1415926/180 ;
Ttime = length(t) ;

global AxesSize BackgroundColor;

Vx = V.*sin(Detal.*Radio) ;
Vy = V.*cos(Detal.*Radio) ;

ColorStr = {'r','g','b','y', 'm', 'c', 'w'} ;

RandValue = randperm(length(ColorStr)) ;
CurColor = ColorStr{RandValue} ;
particleHandle = plot(nan,nan,'o', 'MarkerEdgeColor',CurColor, ...
    'MarkerFaceColor',CurColor,'MarkerSize',10);
set(gca,'XLim',[-AxesSize,AxesSize],'YLim',[-AxesSize,AxesSize],...
    'color',BackgroundColor,'XTick',[],'YTick',[]) ;

for i = 1:Ttime
    Vx = (Ttime-1)*Vx/Ttime ;
    Vy = (Ttime-1)*Vy/Ttime ;
    Lx = Lx0 + Vx.*t(i) ;
    Ly = Ly0 + Vy.*t(i) - 0.5*g*t(i)^2 ;
    
    if ~ishandle(Handle)
        return ;
    end
    
    set(particleHandle, 'XData', Lx, 'YData', Ly) ;
    drawnow ;
end

MarkerSize = 10 ;
Ttime = 200 ;
for i = 1 : Ttime
    MarkerSize = max([MarkerSize - 0.05, 0.01]) ;
    Ly = Ly - 100 ;
    
    if ~ishandle(Handle)
        return ;
    end
    set(particleHandle, 'XData', Lx, 'YData', Ly, 'MarkerSize',MarkerSize);
    drawnow ;
end
