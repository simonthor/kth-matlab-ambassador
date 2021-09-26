function stl_mario_main()
% STL_MARIO_MAIN - The main file for Mario Demo for MATLAB
% Usage:
% ------
%  stl_mario_main;

% History
% -------
% Date              Updater             Modification
% ----              -------             ------------
% Dec.30,2011       M. Zhang            wrote it
% Jan.13,2012       M. Zhang            converted to 32-color as used in FC
% Dec.29,2012       M. Zhang            added sprites for skidding/jumping
% Jan.02,2013       M. Zhang            added full support for walking/skidding
%                                       and added a variable monitor
% Jan 11,2013       M. Zhang            added primitive collision detection
% Jan 19,2013       M. Zhang            added comments for subfunction ShowMario
% Feb 25,2013       M. Zhang            added JUMPING (from standing position only)
%                                       and LANDING; thus UPGRADED to 0.3.
% Feb 28,2013       M. Zhang            added JUMPING (from walking and sprinting)
%                                       and manipulation in the air.
%                                       UPGRADED to 0.36
% Mar 01,2013       M. Zhang            added JUMPING (from skidding)
%                                       and refined air manipulation to
%                                       better emulate the behavior of the
%                                       Mario as in the original NES game.
%                                       The dynamics of Mario is now fully
%                                       programmed (without interaction
%                                       with other objects)
%                                       UPGRADED to 0.4
% Mar 02,2013       M. Zhang            added COLLISION DETECTION for
%                                       landing (only when Mario goes downwards);
%                                       implemented correct handling for
%                                       drawing and coll.det. when Mario
%                                       approaches or goes out of the canvas
%                                       boundary.
%                                       UPGRADED to 0.45
% Mar 02,2013       M. Zhang            VER 0.45 ARCHIVED
% Mar 02,2013       M. Zhang            cleared obsolete functions,
%                                       UPGRADED to 0.46
% Mar 02,2013       M. Zhang            added FREE FALLING (from a ledge)
%                                       UPGRADED to 0.55
% Mar 02,2013       M. Zhang            VER 0.55 ARCHIVED
% Mar 03,2013       M. Zhang            added COLLISION DETECTION (partially)
%                                       during the rising phase.
%                                       UPGRADED to 0.57
% Mar 03,2013       M. Zhang            VER 0.57 ARCHIVED
% Mar 04,2013       M. Zhang            completed COLLISION DETECTION for
%                                       the rising phase.
%                                       Upgraded to VER 0.58
% Mar 04,2013       M. Zhang            VER 0.58 ARCHIVED
% Mar 23,2013       M. Zhang            Fixed all noticeable bugs on collision
%                                       detection. Now collision detection
%                                       is (presumably) fully functional
%                                       Attempted to use hitPoints instead
%                                       of hit boxes but did not succeed.
%                                       UPGRADED to 0.70
% Mar 23,2013       M. Zhang            VER 0.70 ARCHIVED
%                                       Containing the 'hitpoint' code
% Mar 24,2013       M. Zhang            Cleaned up a bit
%                                       Now handled collision and drawing 
%                                       when Mario reaches the edge of the
%                                       stage
%                                       Added several text messages
%                                       UPGRADED to 0.90
% Mar 24,2013       M. Zhang            VER 0.90 ARCHIVED
% Apr 19,2013       M. Zhang            Changed Renderer from OpenGL to
%                                       Painter, thus increased drawing
%                                       speed on slow computers
%                                       UPGRADED to 0.91
% Apr 19,2013       M. Zhang            VER 0.91 ARCHIVED
% Apr 20,2013       M. Zhang            Added Music!
%                                       Commented out an output statement
%                                       that causes error when
%                                       Mario jumps outside the upper
%                                       border
%                                       UPGRADED to 1.00
% Apr 20,2013       M. Zhang            Ver 1.00 ARCHIVED
% Apr 20,2013       M. Zhang            * Added a try - catch block
%                                       so that the window and audioplayer
%                                       will be deleted upon error
%                                       * Corrected a bug that occurs when
%                                       Mario is ABOUT to land on the ground 
%                                       from an absolute horizontal falling 
%                                       * UPGRADED to 1.10
% Apr 20,2013       M. Zhang            Ver 1.10 ARCHIVED
% ----              -------             ------------
% Copyright (C) Stellari Studio, 2011-2013
% Mingjing Zhang @ Vision & Media Lab, Simon Fraser University, Canada

%% Variable Declaration
try
MarioVer = '1.10';     % Last updated Apr 20, 2013
MainAxesSize = [];    % The size of the main axes, same as GAME_RESOLUTION
GAME_RESOLUTION = []; % The resolution of the game screen, fixed at 240x256
FPS = [];             % Frames-per-second, ideally over 60
nUpdatesPerSec = [];  % Number of event updates per second, must be 60

SPRITE_PAL_SIZE = []; % How many colors a sprite could use. Always 4
MSPRITE_OFFSET = [];  % The beginning of the SPPal in the palette

FRAME_DURATION = [];  % The duration of one single frame, ideally less than 1/60
MAX_FRAME_SKIP = [];  % The maximum of frame skips allowed if the game runs sluggishly
DEFAULT_FRAME_SKIP = [];  %
MainFigureInitPos = [];  % The initial position of the main figure
MainFigureSize = [];  % The size of the figure
MainAxesInitPos = []; % The initial position of the axes IN the figure

CyclePalFrames = []; %

CyclePalIndices = [];

% Handles
MainFigureHdl = [];
MainAxesHdl = [];
CurrentStageBkgdHandle = [];
CurrentBrickHandle = [];

% Keyboard-related variables
KeyStatus = [];
LastKeyStatus = [];
LastFrameKeyStatus = [];
KeyNames = [];
KeyFuncs = [];

KeyLRStatus = 0;
KeyAccelStatus = 0;
KeyJumpAvailFlag = true;

% Variables for Debugging
ShowFPS = false;
SHOWFPS_FRAMES = 60;

% Mario Related Constants
BODY_STAT = [];
DIRECTION = [];
ACTION = [];
MOTION_STAT = [];
HIT_STAT = [];
COLLISION = [];
CONST_STOP_SKIDDING_V = []; % The speed threshold that Mario will stop skidding
CONST_NFRAME_SPRINT_DEACCX = [];  % The # of frames that Mario would
deaccel_ind = 1;
sprint_deaccx_counter = [];
% When you actually paint the mario
% Mario.curA

% Collision Flags
ThisCollision = 0;
CloseReq = false;

key = [];
%% Initialization
initVariable;
initWindow;

playSound = questdlg('Do you want sound?','','Yes');
playSound = strcmp(playSound, 'Yes');

allmusic = [];
if playSound
    if exist('mario_music.mat','file')
        allmusic = load('mario_music.mat');
    else
        warning('STL_MARIO_MAIN(): mario_music.mat not found. Music disabled');
        playSound = false;
    end    
end

%% Load StageList
% 'StageList' is a cell array whose elements are the names (string) of the stage
% variables.
% 'StatSpriteLib' is a 16x16x3xN array containing the graphical data of each
% static sprite
% 'pal_all' contains the palette
StageList = [];
StatSpriteLib = [];
pal_all = [];

% 'StatSpritePalset0' means this matrix contains 0-based indices
if exist('mario_stages.mat','file')
    load('mario_stages.mat','StageList','StatSpriteLib','StatSpritePalset0', 'pal_all');
else
    error('STL_MARIO_MAIN(): mario_stages.mat not found.');
end

if exist('MarioData.mat','file')
    load('MarioData.mat','MarioSprite');
else
    error('STL_MARIO_MAIN(): MarioData.mat not found.');
end

themePlayer = [];
%% Main Game Cycle
for i_stage = 1:length(StageList)
    %% Load the current stage
    StageTemp = load('mario_stages.mat', StageList{i_stage});
    CurrentStage = StageTemp.(StageList{i_stage});
    
    %% Music Handling
    if playSound
        [CurrentStage.music CurrentStage.fs] = makeMusic();
        if ~isempty(themePlayer)
            delete(themePlayer);
        end
            
        themePlayer = audioplayer(CurrentStage.music, CurrentStage.fs);
        set(themePlayer, 'StopFcn', @stl_AudioplayerStopFcn);
    end
        
    
    %% Setup the stage background (i.e. backdrop and indestructable objects)
    curMapSize = size(CurrentStage.statMapInd);
    CurrentStage.statMapInd = [CurrentStage.statMapInd; zeros(1,curMapSize(2),3)];
    CurrentStage.statMapInd = [CurrentStage.statMapInd, CurrentStage.statMapInd(:,[end end],:)];
    CurrentStage.statMapInd(:,end,:) = 1;
    CurrentStage.statImpassable = sum(CurrentStage.statMapInd(:,:,2:3),3)~=0;
   
    % Add a single line at the bottom; This is very important to handle out
    % of boundary pixels/collisions
    
    curSpriteSize = CurrentStage.spriteSize;
    curStageSize = curMapSize(1:2).*curSpriteSize(1:2);
    
    % Allocate space for the background
    CurrentStageBkgd = uint8(zeros(curStageSize(1:2)));
    
    % Put each sprite on the background according to the stage map
    for map_i = 1:curMapSize(1) %size(CurrentStage.statMapInd,1)
        for map_j = 1:curMapSize(2) %size(CurrentStage.statMapInd,2)
            
            % Draw 3 layers of map
            % Layer 1: Background objects (cloud, bushes, ...)
            % Layer 2: Indestructible objects (steel blocks, ...)
            % Layer 3: Destructible objects (bricks, ...)
            for i_layer = 1:3
                % Calculate the position of the current sprite
                i = (map_i-1).*curSpriteSize(1) +1;
                j = (map_j-1).*curSpriteSize(2) +1;
                
                % Put the current sprite (only if the index is not zero)
                if CurrentStage.statMapInd(map_i,map_j,i_layer) ~=0
                    
                    % Paint the sprite using the specified palette set
                    CurrentStageBkgd(i:i+curSpriteSize(1)-1,j:j+curSpriteSize(2)-1) = ...
                        StatSpriteLib(:,:,CurrentStage.statMapInd(map_i, map_j,i_layer)) + ...
                        StatSpritePalset0(CurrentStage.statMapInd(map_i, map_j,i_layer)).* ...
                        SPRITE_PAL_SIZE;
                else
                    continue;
                end

            end
        end
    end
    set(CurrentStageBkgdHandle, 'CData', CurrentStageBkgd, 'Visible', 'on');
    colormap(pal_all([CurrentStage.stageBGPal,CurrentStage.stageSPPal],:));
    %% Main Game Loop for each stage
    % Here, number of 'Frame' actually means the number of times the world
    % gets updated. So named to keep consistent with the former game:
    % Stellaria
    cycle_total_frames = cumsum(CyclePalFrames);
    frame_updated = false;   % Whether the world is actually updated
    
    CurrentFrameNo = 0;      % the number of the current frame
    camera_step = 1.5;
    camera_pos_x = [1 GAME_RESOLUTION(1)];
    %     camera_pos_x_new = cameria_pos_x;
    
    if ShowFPS
        fps_text_handle = text(10,10, 'FPS:60.0');
        var_text_handle = text(10,20, 'Var = '); % Display a variable
        total_frame_update = 0;
    end
    prompt_text_handle = text(30,80,'','Color',[1 1 1],...
        'FontSize',24,...
        'HorizontalAlignment','left');
    
    % Show Mario
    Mario.Visible = true;
    if playSound; themePlayer.play(); end
    stageStartTime = tic;
    c = stageStartTime;
    FPS_lastTime = toc(stageStartTime);
     terminateFlag = false;
    while 1
        loops = 0;
        curTime = toc(stageStartTime);
        colormap_updated = false;
        while (curTime >= ((CurrentFrameNo) * FRAME_DURATION) && loops < MAX_FRAME_SKIP)
            
            if KeyStatus(3)  % If left key is pressed
                if camera_pos_x(1)<1
                    error('stl_mario_main(): XLim(1) < 0');
                end
                camera_pos_x = camera_pos_x - min(camera_pos_x(1)-1, camera_step);
            end
            if KeyStatus(4)
                if camera_pos_x(2) > curStageSize(2)
                    error('stl_mario_main(): XLim(2) too large');
                end
                camera_pos_x = camera_pos_x + min(curStageSize(2)-camera_pos_x(2), camera_step);
            end
            
            %% Process Mario
            if ~terminateFlag
                processMario;
            end
            
            %% Cycling the Palette
            cur_state = mod(CurrentFrameNo, cycle_total_frames(end));
            if cur_state <= cycle_total_frames(1)
                cycle_color = CyclePalIndices(1);
            elseif cur_state <=cycle_total_frames(2)
                cycle_color = CyclePalIndices(2);
            elseif cur_state <=cycle_total_frames(3)
                cycle_color = CyclePalIndices(3);
            elseif cur_state <= cycle_total_frames(4)
                cycle_color = CyclePalIndices(4);
            end
            if CurrentStage.stageBGPal(CurrentStage.stageCycleColor) ~= cycle_color
                CurrentStage.stageBGPal(CurrentStage.stageCycleColor) = cycle_color;
                colormap_updated = true;
            end
            
            % Update the cycle variables
            CurrentFrameNo = CurrentFrameNo + 1;
            loops = loops + 1;
            frame_updated = true;
        end
        
        %% Redraw the frame if the world has been processed
        if frame_updated
            a = tic;
            currentFrameBkg = CurrentStageBkgd(:,round(camera_pos_x(1):camera_pos_x(2)),:);
            showMario;
            set(CurrentStageBkgdHandle, 'CData', currentFrameBkg);
            
            if colormap_updated
                set(MainFigureHdl,'colormap',pal_all([CurrentStage.stageBGPal CurrentStage.stageSPPal],:));
            end
            drawnow;


%             b = toc(a);
%             lastTime = c;
            c = toc(stageStartTime);
            frame_updated = false;
            if ShowFPS
                total_frame_update = total_frame_update + 1;
                %                 set(fps_text_handle, 'String',sprintf('%.2f',1./b),'Position', [newXLim(1)+10,10]);
                varname = 'Mario.Direction';%'Mario.curFrame';
                if mod(total_frame_update,SHOWFPS_FRAMES) == 0 % If time to update fps
                    set(fps_text_handle, 'String',sprintf('FPS: %.2f',SHOWFPS_FRAMES./(c-FPS_lastTime)));
                    FPS_lastTime = toc(stageStartTime);
                end
                set(var_text_handle, 'String', sprintf('%s = %.2f', varname, eval(varname)));
            end
            
            if Mario.Pos(2) > curStageSize(1)
                initVariable;           
            end
            if Mario.Pos(1) > curStageSize(2)
                set(prompt_text_handle,'String', {'Brought to you by', ...
                    'Mingjing Zhang @ Simon Fraser University',...
                    '',...
                    'Thank you for playing this demo', ...
                    'Press ENTER to quit'},'FontSize',16,'Color',[1 1 1],'BackgroundColor',[0 0 1]);
                drawnow;
%                 set(gcf,'KeyPressFcn','','KeyReleaseFcn','');
                terminateFlag = true;
                if KeyStatus(7)
                    CloseReq = true;
                end
                
%                 CloseReq = true;
            elseif Mario.Pos(1) > curStageSize(2) - 400
                set(prompt_text_handle,'String', 'Please leave on the right side of the stage','FontSize',16);                
            end
        end
        if CloseReq
            delete(MainFigureHdl);
            if exist('themePlayer','var') && strcmp(get(themePlayer,'Type'),'audioplayer')
                themePlayer.stop();
                delete(themePlayer);
            end
            clear all;
            return;
        end
    end
end
catch err
    delete(MainFigureHdl);
    if exist('themePlayer','var') && strcmp(get(themePlayer,'Type'),'audioplayer')
        themePlayer.stop();
        delete(themePlayer);
    end
    rethrow(err);
%     return
end
%% ---------------- Regular Subfunctions ----------------------------------

%% Initializations

    function initVariable()
        % initVariable - initialize variables
        %         a = [3 4]
        %         b =[5 6 7];
        %         a = b([1 2 3]);
        MainAxesSize = [256 240];
        GAME_RESOLUTION = MainAxesSize;
        FPS = 60;
%         nUpdatesPerSec = 60;
        
        SPRITE_PAL_SIZE = 4;
        MSPRITE_OFFSET = 16;
        
        
        FRAME_DURATION = 1./FPS;
        MAX_FRAME_SKIP = 5;
%         DEFAULT_FRAME_SKIP = 2;
        MainFigureSize = MainAxesSize .* 2;
        MainFigureInitPos = [300 50];
        MainAxesInitPos = [0 0];
        
        KeyNames = {'w','s','a','d','j','k','return','space'};
%         KeyFuncs = {'up','down','left','right','sprint','jump','start','select'};
        KeyStatus = false(1, length(KeyNames));
        LastKeyStatus = KeyStatus;
        LastFrameKeyStatus = KeyStatus;
        ShowFPS = true;
        CyclePalFrames = [24 8 8 8];
        CyclePalIndices = [40 24 8 24];
        
        % Mario Related Constants
        % -------------------------------
        BODY_STAT.SMALL = 1;
        BODY_STAT.BIG = 2;
        BODY_STAT.FIERY = 3;
        % -------------------------------
        DIRECTION.RIGHT = 1;
        DIRECTION.LEFT = -1;
        % -------------------------------
        ACTION.STANDING = 1;
        ACTION.WALKING = 2;
        ACTION.SKIDDING = 3;
        ACTION.JUMPING = 4;
        ACTION.SQUATTING = 5;
        % ------------------------------
        MOTION_STAT.NOTHING = 0;
        MOTION_STAT.WALKING.NORMAL = 1;
        MOTION_STAT.WALKING.SPRINTING = 2;
        MOTION_STAT.JUMPING.UP = 1;
        MOTION_STAT.JUMPING.DOWN = 2;
        MOTION_STAT.JUMPING.FALL = 3;
        MOTION_STAT.JUMPING.REBOUNCE = 4;
        % -------------------------
        HIT_STAT.UP = 2;
        HIT_STAT.DOWN = 1;
        HIT_STAT.LEFT = 3;
        HIT_STAT.RIGHT = 4;
        % -------------------------
        COLLISION.SIDE_OVERLAP_X = 2;
        COLLISION.BOTTOM_OVERLAP_Y = 0;
        COLLISION.TOP_OVERLAP_Y = 2;
        COLLISION.STAND_ON_LEDGE_X = 4;
        COLLISION.HIT_BLOCK_X = [8+1e-8 8];
        
        COLLISION.TOP = 1;
        COLLISION.LEFT = [2 3];
        COLLISION.RIGHT = [4 5];
        COLLISION.BOTTOM = [6 7];
        % -------------------------
        CONST_STOP_SKIDDING_V = 0.6;
        CONST_NFRAME_SPRINT_DEACCX = 10;
        sprint_deaccx_counter = CONST_NFRAME_SPRINT_DEACCX;
        %% Mario Initialization
        % Objects
        Mario.bodyState = BODY_STAT.SMALL;  % 1: small, 2: big, 3: fiery
        Mario.Direction = DIRECTION.RIGHT;  % 1: right, -1: left
        Mario.curAction = ACTION.STANDING;  % 1: standing, 2: walking, 3: jumping, 4: skidding
        Mario.curFrame = 1;   % 1-3 for walking and 1 for all other cases
        Mario.curFrameLim = 1;
        Mario.nextAction = ACTION.STANDING;
        Mario.nextFrame = 1;
        Mario.nextFrameLim = 1;
        Mario.nextDirection = Mario.Direction;
        Mario.onGround = true; % true if standing on the ground; false otherwise
        Mario.nextOnGround = true;
        Mario.motionStat = MOTION_STAT.NOTHING; % 1: normal walking 2: sprinting, 3: jumping, 4: falling
        Mario.nextMotionStat = Mario.motionStat;
        
        Mario.palset0 = 0;
        Mario.Pos = [40 176];    % X = 40 ,Y = 176
        Mario.NextPos = Mario.Pos;
        Mario.Vxy = [0 0];
        Mario.NextVxy = Mario.Vxy;
        Mario.Axy = [0 0];
        Mario.Gravity = 0;
        Mario.pixelsy = 2:33;
        Mario.pixelsx = 1:16;
        Mario.Handle = 0;       % Image handle for Mario (may not be used)
        Mario.Visible = true;  % Visibility
        
        %% Constants for Mario
        Mario.VX_MAX = [1.5 2.5]; % Maximum Speed for (1) walking (2) sprinting
        Mario.VY_MAX = [4 4 5];
        Mario.VY_MAX_DOWN = 4;
        Mario.ACCELX = [0.0375 0.0556]; % Acceleration for (1) walking (2) sprinting
        Mario.JUMP_BACK_ACCELX = [0.0725 0.0725 0.1]; %0.0833;
        Mario.ACCELY_UP = [32 30 40];            % Upward Acceleration for (1) standing/slow walk jump
        Mario.ACCELY_DOWN = [112 96 144];          % Downward Accleration for (1) standing/slow walk jump
        % * This number was directly taken from the code
        Mario.DEACCELX = [0.0375 0.05]; % The deacceleration for sprinting is slightly different.
        Mario.DEACCX_SKID = [0.0208 0.0415 0.0938];
        % Deacceleration for skidding:
        % If the speed is lower than 18h,
        %   then acceleration = v*0.0013 + 0.0415, otherwise
        %       accel = 0.0938
        Mario.WALKCOUNTER_INIT = 6; % The initial counter for walking
        
        Mario.walkCycle = [7 4 2];  % The number of frames one action status lasts
        % WalkCycle will change if:
        % When mario accelerates, its speed goes over one of the following limits:
        Mario.speedThresholdsUp = [1.125 2];
        % Or
        % When mario deaccelerates, its speed goes below one of the following limits:
        Mario.speedThresholdsDown = [0.625 1.5];
        
        Mario.gravityThreshold =[1 1.5];
        
        % The current frame within a walking period
        Mario.walkCounter = Mario.WALKCOUNTER_INIT;
        
        %         Mario.WalkFrameRepeatCount = 6;
        %         Mario.WalkFrameRepeatLim = 7;
        Mario.curWalkCycle = Mario.walkCycle(1);
        Mario.corr = [0 0]; % position cor5rection on x and y
        Mario.airSpeedLimitIdx = 1;
        Mario.velocityXChanged = false;
        Mario.vxFlipCounter = 0;
        
        % hitPoints is 1-indexed already
        Mario.hitPoints = [9 3;   % Top
                            3 4;    % Left 1
                            3 12;   % Left 2
                            14 4;   % Right 1
                            14 12;  % Right 2
                            4 16;   % Bottom 1
                            13 16];  % Bottom 2
        Mario.hitPoints(:,2) = Mario.hitPoints(:,2) + 16;                        
    end

    function initWindow()
        % initWindow - initialize the main window, axes and image objects
        MainFigureHdl = figure('Name', ['Mario MAT ' MarioVer], ...
            'NumberTitle' ,'off', ...
            'Units', 'pixels', ...
            'Position', [MainFigureInitPos, MainFigureSize], ...
            'MenuBar', 'figure', ...
            'Renderer', 'Painter',...\
            'UserData', 'stl_mario_main',...
            'KeyPressFcn', @stl_KeyDown,...
            'KeyReleaseFcn', @stl_KeyUp,...
            'CloseRequestFcn', @stl_CloseReqFcn);
        MainAxesHdl = axes('Parent', MainFigureHdl, ...
            'Units', 'normalized',...
            'Position', [MainAxesInitPos, 1-MainAxesInitPos.*2], ...
            'color', [0 0 0], ...
            'XLim', [0 MainAxesSize(1)]-0.5, ...
            'YLim', [0 MainAxesSize(2)]-0.5, ...
            'YDir', 'reverse', ...
            'NextPlot', 'add', ...
            'Visible', 'on', ...
            'XTick',[], ...
            'YTick',[]);
        CurrentStageBkgdHandle = image(0, 0, [],...
            'Parent', MainAxesHdl,...
            'Visible', 'off');
        CurrentBrickHandle = image(0, 0, [], ...
            'Parent', MainAxesHdl,...
            'Visible', 'off');
        Mario.Handle = image(0, 0, [], ...
            'Parent', MainAxesHdl, ...
            'Visible', 'off');
    end

%% Game logics
%% Collision Detection
    function [hitStat] = detCollision()
        hitStat = false(1,4);

        if Mario.bodyState == BODY_STAT.SMALL;
            nVertBlocks = 2;
            MarioMatPos = Mario.Pos([2 1])./curSpriteSize + [2 1];  % in [y x], 1-indexed
            MarioNextMatPos = Mario.NextPos([2 1])./curSpriteSize + [2 1];
            MarioLocalIndsRow = floor(MarioNextMatPos(1)) + [0 1]; % floor(MarioNextMatPos(1))+1];
        else
            nVertBlocks = 3;
            MarioMatPos = Mario.Pos([2 1])./curSpriteSize + [1 1];  % in [y x], 1-indexed
            MarioNextMatPos = Mario.NextPos([2 1])./curSpriteSize + [1 1];
            MarioLocalIndsRow = floor(MarioNextMatPos(1)) + [0 1 2];
        end
        MarioLocalIndsCol = [floor(MarioNextMatPos(2)), ceil(MarioNextMatPos(2))];

        nHoriBlocks = 2;
        
        % MarioLocalIndsRow contains at least 2 different blocks, even when Mario
        % occupies exactly one. The rationale is: the distance tolerance
        % between Mario and the ground is 0 pixels, as opposed to -2
        % pixels. So it's possible for Mario to be standing on the ground
        % even though it does not overlap with it.
%         MarioOverlap = mod(MarioNextMatPos,1).*curSpriteSize;
        
        % The 'niche'(4 or 6 background tiles) around Mario
        virtualRows = MarioLocalIndsRow;
        virtualRows(virtualRows < 1 | virtualRows > curMapSize(1)) = curMapSize(1) + 1;
        virtualCols = MarioLocalIndsCol;
        virtualCols(virtualCols < 1) = curMapSize(2) + 2; 
        MarioLocalEnv = sum(CurrentStage.statMapInd(virtualRows, virtualCols,2:3),3)~=0;
%         MarioLocalIndsCol
        %% Overlap region
        % How much area Mario overlaps with each tile.
        ColOverlap = ((1-abs(MarioNextMatPos(2)-MarioLocalIndsCol))).*curSpriteSize(2);
        RowOverlap = ((1-abs(MarioNextMatPos(1)-MarioLocalIndsRow(:)))).*curSpriteSize(1);
        
        ColOverlap = floor(ColOverlap(ones(1,nVertBlocks),:));
        RowOverlap = floor(RowOverlap(:,ones(1,nHoriBlocks)));
        
        if MarioLocalIndsCol(1) == MarioLocalIndsCol(2) % If Mario occupies only one block
            if RowOverlap(end,1) >= COLLISION.BOTTOM_OVERLAP_Y
                hitStat(HIT_STAT.DOWN) = true;
            elseif RowOverlap(1,1) >= COLLISION.TOP_OVERLAP_Y;
                hitStat(HIT_STAT.UP) = true;
            end
            return;
        end
        %% Check if Mario touches anything

        thisSide = MarioLocalEnv(1,:);
        marioTopCollide = thisSide & RowOverlap(1,:) >= 2 & ColOverlap(1,:) >= [8+1e-10 8];
        if Mario.Vxy(2) < 0
            % If Mario is jumping up
            
            marioLeftCollide = any(MarioLocalEnv(:,1) & ColOverlap(:,1) > 2);
            marioRightCollide = any(MarioLocalEnv(:,end) & ColOverlap(:,end) > 2);
                        
            % As for the block on the left, Mario must has MORE THAN 8 pixels under
            % it to be able to hit it; For the right one, EXACTLY 8 pixels are
            % enough

            if any(marioTopCollide)
                % which block is hit
                ThisMovedBlock = [MarioLocalIndsRow(1) MarioLocalIndsCol(marioTopCollide)];
                %                 Mario.NextPos(2) = Mario.Pos(2); % Do not bounce Mario back %[MarioLocalIndsRow(1)-1].*curSpriteSize(1);
                Mario.NextVxy(2) = 0;
                Mario.nextMotionStat = MOTION_STAT.JUMPING.DOWN;
                hitStat(HIT_STAT.UP) = 1;
            else
                hitStat(HIT_STAT.UP) = 0;
%                 if ~all(MarioLocalEnv(1,:)) %marioLeftCollide && marioRightCollide
                if marioLeftCollide % If any collision with objects horizontally,
                    % then Mario is not bounced back immediately.
                    % the solid block(s) would slowly push Mario outward
                    if Mario.Vxy(1) <= 0
                        Mario.NextVxy(1) = 0;
                        Mario.NextPos(1) = Mario.NextPos(1) + min(1,ColOverlap(1,1)-2);
                        hitStat(HIT_STAT.LEFT) = true;
                        hitStat(HIT_STAT.RIGHT) = false;
                    end
                elseif marioRightCollide
                    if Mario.Vxy(1) >= 0
                        Mario.NextVxy(1) = 0;
                        Mario.NextPos(1) = Mario.NextPos(1) - min(1,ColOverlap(1,end)-2);
                        hitStat(HIT_STAT.LEFT) = false;
                        hitStat(HIT_STAT.RIGHT) = true;
                    end
                else
                    hitStat(HIT_STAT.LEFT) = false;
                    hitStat(HIT_STAT.RIGHT) = false;
                end
            end
        end

        if Mario.Vxy(2) >= 0   % If Mario is falling
            thisSide = MarioLocalEnv(end,:); %MarioLocalIndsRow(2),MarioLocalIndsCol);

            marioLeftCollide = (MarioLocalEnv(:,1) & ColOverlap(:,1) > 2 & RowOverlap(:,1) >= 0);

            marioRightCollide = (MarioLocalEnv(:,end) & ColOverlap(:,end) > 2 & RowOverlap(:,end) >= 0);
            marioRightSlightCollide = marioRightCollide & RowOverlap(:,end) < 2;
            marioBottomCollide = thisSide & ((ColOverlap(end,:) >= 4 & RowOverlap(end,:) <= 5)); %| ...
%                 (ColOverlap(1,:)<4 & RowOverlap(end,:) > 0 ));
%             marioOverallCollide = double(marioBottomCollide) + double([marioLeftCollide marioRightCollide]);
            
            if any(marioBottomCollide)  % and there is a ground beneath his feet
                % If there is not too much overlap
                Mario.NextPos(2) = [MarioLocalIndsRow(1)-2].*curSpriteSize(1);
                Mario.NextVxy(2) = 0;   % No more y movements
                
%                 ThisCollision = 1;
                hitStat(HIT_STAT.DOWN) = 1;
                marioLeftCollide = any(MarioLocalEnv(1:end-1,1) & ColOverlap(1:end-1,1) > 2);
                marioRightCollide = any(MarioLocalEnv(1:end-1,end) & ColOverlap(1:end-1,end) > 2);
                marioOverallCollide = double(marioBottomCollide) + double([marioLeftCollide marioRightCollide]);

                if any(marioRightCollide)
%                     if ~any(marioRightCollide(1:end-1)|marioRightSlightCollide(1:end-1))
%                        Mario.NextPos(2) = Mario.NextPos(2) - RowOverlap(end,2);
%                         hitStat(HIT_STAT.DOWN) = true;
% %                         
%                     else
                        Mario.NextVxy(1) = 0;
                        Mario.NextPos(1) = Mario.NextPos(1) - min(1,ColOverlap(1,end)-2);
                        hitStat(HIT_STAT.LEFT) = false;
                        hitStat(HIT_STAT.RIGHT) = true;
                        if marioBottomCollide(1)
                            hitStat(HIT_STAT.DOWN) = true;
                        else
                            hitStat(HIT_STAT.DOWN) = false;
                        end
%                     end
                elseif any(marioLeftCollide)
                    Mario.NextVxy(1) = 0;
                    Mario.NextPos(1) = Mario.NextPos(1) + min(1,ColOverlap(1,1)-2);
                    hitStat(HIT_STAT.LEFT) = true;
                    hitStat(HIT_STAT.RIGHT) = false;
                    if marioBottomCollide(2)
                        hitStat(HIT_STAT.DOWN) = true;
                    else
                        hitStat(HIT_STAT.DOWN) = false;
                    end
                end            
            elseif any(thisSide)   
               % If Mario is not supported by anything under his feet, but there is something in its local surroundings
                    hitStat(HIT_STAT.DOWN) = false;
                    if all(MarioLocalEnv(1,:)) %marioRightCollide && marioLeftCollide
                        % I really hope something like this will never
                        % happen
%                         hitStat(HIT_STAT.UP) = 1;
                    elseif any(marioRightCollide)
                        if ~any(marioTopCollide)
                            if Mario.NextVxy(1) >= 0
                                Mario.NextVxy(1) = 0;
                            end
                            Mario.NextPos(1) = Mario.NextPos(1) - min(1,ColOverlap(1,end)-2);
                            hitStat(HIT_STAT.LEFT) = false;
                            hitStat(HIT_STAT.RIGHT) = true;
                            hitStat(HIT_STAT.DOWN) = false;
                        end
                    elseif any(marioLeftCollide)
                        if ~any(marioTopCollide)
                            if Mario.NextVxy(1) <= 0
                                Mario.NextVxy(1) = 0;
                            end
                            Mario.NextPos(1) = Mario.NextPos(1) + min(1,ColOverlap(1,1)-2);
                            hitStat(HIT_STAT.LEFT) = false;
                            hitStat(HIT_STAT.RIGHT) = true;
                            hitStat(HIT_STAT.DOWN) = false;
                        end
                    end
            end
        end
%             ThisCollision = marioRightCollide;
    end
%% Process Mario
    function processMario()
        % Update Position/Velocity
        if ~Mario.onGround && Mario.Vxy(1)*Mario.NextVxy(1) <= 0 && Mario.Vxy(1)~=Mario.NextVxy(1)
            Mario.velocityXChanged = true;
            Mario.vxFlipCounter = Mario.vxFlipCounter + 1;
        else
            Mario.velocityXChanged = false;
        end
        Mario.Vxy = Mario.NextVxy;
        Mario.Pos = Mario.NextPos;
        % Update Status
        Mario.onGround = Mario.nextOnGround;
        Mario.curAction = Mario.nextAction; % STANDING/WALKING/SKIDDING
        Mario.curFrame = Mario.nextFrame;   %
        Mario.curFrameLim = Mario.nextFrameLim;
        Mario.Direction = Mario.nextDirection;
        Mario.motionStat = Mario.nextMotionStat;
        
        camera_pos_x(1) = max(1, floor(Mario.Pos(1))-50);
        camera_pos_x(2) = camera_pos_x(1) + GAME_RESOLUTION(1) - 1;
        if camera_pos_x(2) > curStageSize(2)
            camera_pos_x(2) = curStageSize(2);
            camera_pos_x(1) = camera_pos_x(2) - GAME_RESOLUTION(1) + 1;
        end
        % Update curFrame
        if Mario.curFrame > Mario.curFrameLim
            Mario.curFrame = 1;
        end
        % Update Action
        
        % Keyboard Processing
        % Left and Right Status
        KeyLRStatus = KeyStatus(4) - KeyStatus(3);
        LastKeyLRStatus = LastFrameKeyStatus(4) - LastFrameKeyStatus(3);
        KeyAccelStatus = KeyStatus(5);
        LastKeyAccelStatus = LastFrameKeyStatus(5);
        KeyJumpStatus = KeyStatus(6);
        
        if Mario.onGround
            if ~KeyJumpStatus
                KeyJumpAvailFlag = true;   % If Mario's on the ground and the jump key was released
            end
            if Mario.curAction == ACTION.STANDING
                if KeyJumpStatus && KeyJumpAvailFlag    % If Jump Key is pressed, then jump
                    % and after landing, the user must release the jump key
                    % in order to jump again.
                    Mario.minvy = 0;
                    Mario.Axy(2) = 0;
                    Mario.Gravity = Mario.ACCELY_UP(1);
                    Mario.accay = Mario.Gravity;
                    
                    Mario.accay_carry = 0;
                    Mario.minvy_carry = 0;
                    Mario.nextAction = ACTION.JUMPING;   % Let's jump!
                    Mario.nextOnGround = false;
                    Mario.nextMotionStat = MOTION_STAT.JUMPING.UP;
                    Mario.jumpInitStat = 1;             % speed less than 0x10
                    Mario.UPGravity = Mario.ACCELY_UP(Mario.jumpInitStat);
                    Mario.DOWNGravity = Mario.ACCELY_DOWN(Mario.jumpInitStat);
                    
                    Mario.Vxy(2) = -Mario.VY_MAX(Mario.jumpInitStat);
                    Mario.airSpeedLimitIdx = 2;
                    if KeyLRStatus~=0    % If jumping and left or right is pressed
                        % That's not going to change Mario's direction
                        % And the acceleration key doesn't work in the air
                        Mario.Axy(1) = Mario.ACCELX(1).*Mario.Direction;     % Accelerating
                    end
                    Mario.nextFrame = 1;
                    KeyJumpAvailFlag = false;
                    Mario.vxFlipCounter = 0;
                    
                else
                    if KeyLRStatus~=0    % If not jumping but left or right is pressed
                        Mario.nextAction = ACTION.WALKING;  % Start walking
                        Mario.nextDirection = KeyLRStatus;
                        Mario.Axy(1) = Mario.ACCELX(1+KeyAccelStatus).*Mario.nextDirection;     % Accelerating
                        Mario.nextFrame = 1;                % Start from the first frame
                        Mario.nextFrameLim = 3;             % 3 Frames in the walking cycle
                        Mario.walkCounter = 6;              % The first movement lasts only 1 frame (7-6)
                    end
                end
            elseif Mario.curAction == ACTION.WALKING
                if KeyJumpStatus && KeyJumpAvailFlag
                    Mario.minvy = 0;
                    Mario.Axy(2) = 0;
                    if abs(Mario.Vxy(1)) <= Mario.gravityThreshold(1)+0.001
                        Mario.jumpInitStat = 1;             % speed less than 0x10
                        Mario.airSpeedLimitIdx = 1;
                        
                    elseif abs(Mario.Vxy(1)) <= Mario.gravityThreshold(2)+0.001
                        Mario.jumpInitStat = 2;             % speed more than 0x10
                        Mario.airSpeedLimitIdx = 1;
                        
                    else
                        Mario.jumpInitStat = 3;
                        Mario.airSpeedLimitIdx = 2;
                        
                    end
                    Mario.UPGravity = Mario.ACCELY_UP(Mario.jumpInitStat);
                    Mario.DOWNGravity = Mario.ACCELY_DOWN(Mario.jumpInitStat);
                    Mario.Vxy(2) = -Mario.VY_MAX(Mario.jumpInitStat);
                    Mario.Gravity = Mario.UPGravity;
                    Mario.accay = Mario.Gravity;
                    
                    Mario.accay_carry = 0;
                    Mario.minvy_carry = 0;
                    Mario.nextAction = ACTION.JUMPING;   % Let's jump!
                    Mario.nextOnGround = false;
                    Mario.nextMotionStat = MOTION_STAT.JUMPING.UP;
                    if KeyLRStatus~=0    % If jumping and left or right is pressed
                        % That's not going to change Mario's direction
                        % i.e. if Mario started with facing right, then he
                        % will always face right in the air.
                        % And the acceleration key doesn't work in the air
                        Mario.Axy(1) = Mario.ACCELX(1).*Mario.Direction;     % Accelerating
                    end
                    Mario.nextFrame = 1;
                    KeyJumpAvailFlag = false;
                    Mario.vxFlipCounter = 0;
                else
                    if KeyLRStatus~=0   % If not jumping but left or right is pressed
                        if KeyAccelStatus % If this button is pressed
                            sprint_deaccx_counter = CONST_NFRAME_SPRINT_DEACCX;
                        else
                            sprint_deaccx_counter = max(sprint_deaccx_counter-1,0);
                        end
                        if KeyLRStatus == Mario.Direction  % If the key is of the same direction as Mario goes
                            %                             disp((KeyAccelStatus && sprint_deaccx_counter >0));
                            %                             disp(Mario.Axy(1));
                            Mario.Axy(1) = Mario.ACCELX(1+(KeyAccelStatus | sprint_deaccx_counter >0) ).*Mario.Direction; % then accelerate Mario
                            % And there is no need to change the status
                        elseif KeyLRStatus == -Mario.Direction % If the key is of the opposite direction
                            %                             disp(Mario.Vxy(1))
                            if abs(Mario.Vxy(1)) < CONST_STOP_SKIDDING_V  % If the Velocity is low
                                
                                Mario.nextDirection = -Mario.Direction;
                                Mario.Vxy(1) = Mario.ACCELX(1).*Mario.nextDirection; % Then immediately turn around
                                Mario.Axy(1) = Mario.ACCELX(1).*Mario.nextDirection; % And accelerate in that direction
                                Mario.nextFrame = 1;                % Start from the first frame
                                Mario.walkCounter = 6;
                            else
                                if abs(Mario.Vxy(1))<=1.5
                                    deaccel_skid = Mario.DEACCX_SKID(1).* ...
                                        abs(Mario.Vxy(1)) + Mario.DEACCX_SKID(2);
                                else
                                    deaccel_skid = Mario.DEACCX_SKID(3);
                                end
                                Mario.Axy(1) = -deaccel_skid.*Mario.Direction; % then deaccelerate Mario
                                Mario.nextAction = ACTION.SKIDDING; % Start skidding
                                Mario.nextFrame = 1;
                                Mario.nextFrameLim = 1;
                            end
                        end
                    else   % If no left or right key is pressed
                        % then start deaccelerating
                        if LastKeyLRStatus == Mario.Direction
                            if abs(Mario.Vxy(1)) >= Mario.speedThresholdsDown(2)
                                deaccel_ind = 2;
                            else
                                deaccel_ind = 1;
                            end
                        end
                        
                        Mario.Axy(1) = -Mario.DEACCELX(deaccel_ind).*Mario.Direction;
                        % if the velocity is going to be zero or minus in
                        % the next frame, then stop Mario
                        if abs(Mario.Axy(1) + Mario.Vxy(1))<1e-3 ...
                                || sign((Mario.Axy(1) + Mario.Vxy(1))*Mario.Vxy(1)) < 1 ...
                                || (KeyAccelStatus && abs(Mario.Vxy(1))<Mario.speedThresholdsDown(1))
                            %                             disp(Mario.Vxy(1));
                            Mario.nextAction = ACTION.STANDING;  % Stop walking
                            %                             disp(Mario.nextAction);
                            Mario.Vxy(1) = 0;
                            Mario.Axy(1) = 0;
                            %                             Mario.Axy(1) = -Mario.Vxy(1);       % Make sure the velocity is 0 on the next frame
                            Mario.nextFrame = 1;                % Start from the first frame
                            Mario.nextFrameLim = 1;             % only 1 frame in the 'standing cycle'
                        end
                    end
                end
            elseif Mario.curAction == ACTION.SKIDDING
%                 disp(Mario.Vxy(1));
                if KeyJumpStatus && KeyJumpAvailFlag
                    Mario.minvy = 0;
                    Mario.Axy(2) = 0;
                    
                    if abs(Mario.Vxy(1)) <= Mario.gravityThreshold(1)+0.001
                        Mario.jumpInitStat = 1;             % speed less than 0x10
                        Mario.airSpeedLimitIdx = 1;
                    elseif abs(Mario.Vxy(1)) <= Mario.gravityThreshold(2)+0.001
                        Mario.jumpInitStat = 2;             % speed more than 0x10
                        Mario.airSpeedLimitIdx = 1;
                    else
                        Mario.jumpInitStat = 3;
                        Mario.airSpeedLimitIdx = 2;
                    end
                    Mario.UPGravity = Mario.ACCELY_UP(Mario.jumpInitStat);
                    Mario.DOWNGravity = Mario.ACCELY_DOWN(Mario.jumpInitStat);
                    Mario.Vxy(2) = -Mario.VY_MAX(Mario.jumpInitStat);
                    Mario.Gravity = Mario.UPGravity;
                    Mario.accay = Mario.Gravity;
                    
                    Mario.accay_carry = 0;
                    Mario.minvy_carry = 0;
                    Mario.nextAction = ACTION.JUMPING;   % Let's jump!
                    Mario.nextOnGround = false;
                    Mario.nextMotionStat = MOTION_STAT.JUMPING.UP;
                    Mario.nextDirection = -Mario.Direction;
                    
                    if KeyLRStatus~=0    % If jumping and left or right is pressed
                        % That's not going to change Mario's direction
                        % i.e. if Mario started with facing right, then he
                        % will always face right in the air.
                        % And the acceleration key doesn't work in the air
                        Mario.Axy(1) = Mario.ACCELX(1).*Mario.Direction;     % Accelerating
                    end
                    Mario.nextFrame = 1;
                    KeyJumpAvailFlag = false;
                    Mario.vxFlipCounter = 0;
                    
                else
                    if KeyLRStatus~=0   % If not jumping but left or right is pressed
                        if KeyLRStatus == Mario.Direction  % If the key is of the same direction as Mario proceeds in
                            % Back to walking
                            Mario.nextAction = ACTION.WALKING;  % Start walking
                            Mario.nextDirection = KeyLRStatus;
                            Mario.Axy(1) = Mario.ACCELX(1+KeyAccelStatus).*Mario.nextDirection;     % Accelerating
                            Mario.nextFrame = 1;                % Start from the first frame
                            Mario.nextFrameLim = 3;             % 3 Frames in the walking cycle
                            Mario.walkCounter = 6;
                        elseif KeyLRStatus == -Mario.Direction % If the key is of the opposite direction
                            if abs(Mario.Vxy(1)) < CONST_STOP_SKIDDING_V  % If the Velocity is low
                                Mario.nextAction = ACTION.WALKING;  % Start walking
                                Mario.nextDirection = -Mario.Direction;
                                Mario.Vxy(1) = Mario.ACCELX(1).*Mario.nextDirection; % Then immediately turn around
                                Mario.Axy(1) = Mario.ACCELX(1).*Mario.nextDirection; % And accelerate in that direction
                                Mario.nextFrame = 1;                % Start from the first frame
                                Mario.walkCounter = 6;
                            else
                                % No need to change
                            end
                        end
                    else
                        if abs(Mario.Vxy(1)) < CONST_STOP_SKIDDING_V  % If the Velocity is low
                            Mario.nextAction = ACTION.WALKING;  % Start walking
                            Mario.nextDirection = -Mario.Direction;
                            Mario.Vxy(1) = Mario.ACCELX(1).*Mario.Direction;
                            % Then immediately turn around but still
                            % goes in the same direction
                            Mario.Axy(1) = Mario.ACCELX(1).*Mario.nextDirection; % And accelerate in that direction
                            Mario.nextFrame = 1;                % Start from the first frame
                            Mario.walkCounter = 6;
                        else
                            
                        end
                    end
                end
            end
            
        else   % If Mario is not on the ground
            %             fprintf('Pos = %d, MINVY = %d, ACCAY = %d\n', Mario.Pos(2), Mario.minvy, Mario.accay);
            if Mario.curAction == ACTION.WALKING
%                 if Mario.Vxy(1) < 0
%                     fprintf('Ax = %.2f, Vx = %s PosY = %d\n', Mario.Axy(1),dec2hex(256+round(Mario.Vxy(1).*16)), Mario.Pos(2));
%                 else
%                     fprintf('Ax = %.2f, Vx = %s PosY = %d\n', Mario.Axy(1), dec2hex(round(Mario.Vxy(1).*16)), Mario.Pos(2));
%                 end
            end
            if 1 %Mario.curAction == ACTION.JUMPING  % Then Mario is jumping
                if Mario.motionStat == MOTION_STAT.JUMPING.UP
                    if ~KeyJumpStatus || Mario.Vxy(2) >= 0
                        Mario.motionStat = MOTION_STAT.JUMPING.DOWN;
                    end
                end
                if Mario.motionStat == MOTION_STAT.JUMPING.DOWN
                    Mario.Gravity = Mario.DOWNGravity;
                end
                Mario.minvy = Mario.minvy + Mario.accay;
                Mario.accay = Mario.accay + Mario.Gravity;
                Mario.Axy(2) = floor(Mario.accay./256);    % If accumulate accel overflows, then Axy(2) will change
                Mario.accay = mod(Mario.accay, 256);
                
                Mario.corr(2) = floor(Mario.minvy./256);   % Y Correction
                Mario.minvy = mod(Mario.minvy, 256);
                %                 assert(Mario.minvy<256);
                %                 aaa = Mario.Vxy(2);
                if KeyLRStatus % if the left or right key is pressed
                    if Mario.jumpInitStat <= 2  % If start from <0x18
                        if Mario.Vxy(1)*Mario.Direction >0 % if Mario still has a forward speed
                            Mario.Axy(1) = Mario.ACCELX(1).*KeyLRStatus;
                        else
                            Mario.Axy(1) =  Mario.JUMP_BACK_ACCELX(Mario.jumpInitStat).*KeyLRStatus;
                            % When mario has a backward speed, then its
                            % acceleration turns to 0.075 pixel/frame^2 (regardless of
                            % whether which direction key is pressed. If no
                            % direction key is pressed, then A remains
                            % zero

                        end
                    else % If initial speed is higher than 0x18
                        if Mario.Vxy(1)*Mario.Direction > 0 % If Mario has forward speed
                            Mario.Axy(1) = Mario.ACCELX(2).*KeyLRStatus;
                        else % If the speed is negative
                            Mario.Axy(1) =  Mario.JUMP_BACK_ACCELX(Mario.jumpInitStat).*KeyLRStatus;
                            %                             Mario.jumpInitStat = 2;
                        end
                        if Mario.vxFlipCounter >= 2;
                            % If Mario changes its speed direction twice in
                            % the air, then it will be switch back to
                            % jumpstat 2.
                            Mario.jumpInitStat = 2;
                        end
                        if abs(Mario.Vxy(1)) <= Mario.gravityThreshold(2)
                            % If the speed ever falls below 18h, even just
                            % for a split second, then the speed limit
                            % cannot go back to 28h
                            Mario.airSpeedLimitIdx = 1;
                        end
                    end
                else    % If no button is pressed, then maintain the old speed
                    Mario.Axy(1) = 0;
                end
            end
        end
        % WALKING NEEDS SPECIAL PROCESSING
        if Mario.nextAction == ACTION.WALKING
            Mario.walkCounter = Mario.walkCounter + 1; % Update Walk Counter
            % Still count even when
            %% If a new frame cycle starts
            if Mario.onGround && Mario.walkCounter > Mario.curWalkCycle
                Mario.walkCounter = 1;  % Restarts the frame cycle
                Mario.nextFrame = Mario.curFrame + 1; % Go to the next frame
                Mario.nextFrameLim = 3;
                % Update WalkCounter if necessary
                if sign(Mario.Axy(1)) == Mario.Direction % If accelerating
                    if abs(Mario.Vxy(1)) < Mario.speedThresholdsUp(1)
                        Mario.curWalkCycle = Mario.walkCycle(1);
                    elseif abs(Mario.Vxy(1)) < Mario.speedThresholdsUp(2)
                        Mario.curWalkCycle = Mario.walkCycle(2);
                    else
                        Mario.curWalkCycle = Mario.walkCycle(3);
                    end
                elseif sign(Mario.Axy(1)) == -Mario.Direction
                    if abs(Mario.Vxy(1)) < Mario.speedThresholdsDown(1)
                        Mario.curWalkCycle = Mario.walkCycle(1);
                    elseif abs(Mario.Vxy(1)) < Mario.speedThresholdsDown(2)
                        Mario.curWalkCycle = Mario.walkCycle(2);
                    else
                        Mario.curWalkCycle = Mario.walkCycle(3);
                    end
                end
            end
        end
        Mario.NextVxy = Mario.Vxy + Mario.Axy;
        if Mario.onGround
            Mario.NextVxy(1) = valchop(Mario.NextVxy(1), Mario.VX_MAX(1+(KeyAccelStatus | sprint_deaccx_counter >0)));
        else
            Mario.NextVxy(1) = valchop(Mario.NextVxy(1), Mario.VX_MAX(Mario.airSpeedLimitIdx));
        end
        
        if Mario.NextVxy(2) > 0 % Only chops when Mario is falling down
            [Mario.NextVxy(2)] = valchop(Mario.NextVxy(2), Mario.VY_MAX_DOWN);
            if Mario.NextVxy(2) == Mario.VY_MAX_DOWN
                Mario.corr(2) = 0;
            end
        end
        Mario.NextPos(1) = Mario.Pos(1) + Mario.NextVxy(1);
        Mario.NextPos(2) = Mario.Pos(2) + Mario.Vxy(2) + Mario.corr(2);
        
        
        hitStat = detCollision;
        if hitStat(HIT_STAT.DOWN)
            if ~Mario.onGround % Recently landed on ground
                Mario.Vxy(2) = 0;
                Mario.NextVxy(2) = 0;
                Mario.Axy(2) = 0;
                Mario.NextAxy(2) = 0;
                Mario.nextOnGround = true;
                Mario.airSpeedLimitIdx = 1;
                if Mario.Vxy(1) * Mario.Direction > 0
                    Mario.nextAction = ACTION.WALKING;
                elseif Mario.Vxy(1) * Mario.Direction < 0
                    Mario.nextAction = ACTION.SKIDDING;
                    Mario.nextDirection = -Mario.Direction;
                    if abs(Mario.Vxy(1))<=1.5
                        deaccel_skid = Mario.DEACCX_SKID(1).* ...
                            abs(Mario.Vxy(1)) + Mario.DEACCX_SKID(2);
                    else
                        deaccel_skid = Mario.DEACCX_SKID(3);
                    end
                    Mario.Axy(1) = deaccel_skid.*Mario.Direction; % then deaccelerate Mario
                    Mario.nextAction = ACTION.SKIDDING; % Start skidding
                    Mario.nextFrame = 1;
                    Mario.nextFrameLim = 1;
                else
                    Mario.nextAction = ACTION.STANDING;
                    Mario.nextFrame = 1;
                    Mario.nextFrameLim = 1;
                    Mario.vxFlipCounter = 0;
                end
                Mario.corr(2) = 0; % Turn off vertical correction
            end
        else
            if Mario.onGround && Mario.nextAction~= ACTION.JUMPING % If Mario recently fell off a ledge
                Mario.nextAction = ACTION.WALKING;
                Mario.minvy = 0;
                Mario.Axy(2) = 0;
                if abs(Mario.Vxy(1)) <= Mario.gravityThreshold(1)+0.001
                    Mario.jumpInitStat = 1;             % speed less than 0x10
                    Mario.airSpeedLimitIdx = 1;
                elseif abs(Mario.Vxy(1)) <= Mario.gravityThreshold(2)+0.001
                    Mario.jumpInitStat = 2;             % speed more than 0x10
                    Mario.airSpeedLimitIdx = 1;
                else
                    Mario.jumpInitStat = 3;
                    Mario.airSpeedLimitIdx = 2;
                end
                
                %                 Mario.nextFrame = Mario.curFrame;
                
                Mario.UPGravity = Mario.ACCELY_UP(Mario.jumpInitStat);
                Mario.DOWNGravity = Mario.ACCELY_DOWN(Mario.jumpInitStat);
                Mario.nextVxy(2) = 0;
                Mario.Gravity = Mario.DOWNGravity;
                Mario.accay = 0; %Mario.Gravity;
                
                Mario.accay_carry = 0;
                Mario.minvy_carry = 0;
                Mario.nextOnGround = false;
                Mario.nextMotionStat = MOTION_STAT.JUMPING.FALL;
                if Mario.curAction == ACTION.SKIDDING
                    Mario.nextDirection = -Mario.Direction;
                else
                    Mario.nextDirection = Mario.Direction;
                end
            end
        end
        if hitStat(HIT_STAT.UP)
            Mario.nextMotionStat = MOTION_STAT.JUMPING.DOWN;
            Mario.nextVxy(2) = 0;
        end
        LastFrameKeyStatus = KeyStatus;
%         if KeyAccelStatus
% %             fprintf('%.3f,%.3f,%s,%s,%d\n',Mario.NextPos(1), Mario.NextPos(2), dec2hex(floor(Mario.NextPos(1))), dec2hex(floor(Mario.NextPos(2))),Mario.onGround);
%         end
    end
    function showMario()
        if Mario.Visible
            % Take a small piece out of the big canvas that is exactly as
            % large as the Mario Sprite.
            
            % Only draw valid pixels (within the visible range)
            vertRange = floor(Mario.Pos(2))+Mario.pixelsy;
            vertValidIndex = vertRange>=1 & vertRange<= GAME_RESOLUTION(2);  
            horiRange = floor(Mario.Pos(1))+Mario.pixelsx;
            horiValidIndex = horiRange>=1 & horiRange<= curStageSize(2); 

            marioBkg = CurrentStageBkgd(vertRange(vertValidIndex), horiRange(horiValidIndex),:);

            if Mario.Direction == DIRECTION.RIGHT
                curMarioData = MarioSprite(Mario.curAction).CData(vertValidIndex,horiValidIndex,Mario.curFrame);
                curMarioAlpha = MarioSprite(Mario.curAction).AlphaData(vertValidIndex,horiValidIndex,Mario.curFrame);
            else
                curMarioData = MarioSprite(Mario.curAction).CData(vertValidIndex,horiValidIndex(end:-1:1),Mario.curFrame);
                curMarioAlpha = MarioSprite(Mario.curAction).AlphaData(vertValidIndex,horiValidIndex(end:-1:1),Mario.curFrame);
                curMarioData = curMarioData(:,end:-1:1);
                curMarioAlpha = curMarioAlpha(:,end:-1:1);
            end
            % Reverse the Mario sprite if he is facing left

            
            % Draw the Mario sprite on this small patch of canvas
            % Q: Why do we have to make use of this 'small patch' instead
            % of directly drawing on the full-sized canvas?
            % A: Because otherwise we can't take advantage of the logical
            %    indexing array: curMarioAlpha
            marioBkg(curMarioAlpha) = curMarioData(curMarioAlpha) + ...
                Mario.palset0.*SPRITE_PAL_SIZE + MSPRITE_OFFSET;
            
            % Then paste the piece back to the big canvas.
            try
            currentFrameBkg(vertRange(vertValidIndex),  horiRange(horiValidIndex)+1-round(camera_pos_x(1))) = marioBkg;
            catch
                kaka = 333;
            end
            %                         currentFrameBkg(vertRange(vertValidIndex),  floor(Mario.Pos(1))+1-round(camera_pos_x(1))+Mario.pixelsx) = marioBkg;
        end
        
    end

%% Callback functions
    function stl_KeyUp(hObject, eventdata, handles)
        LastKeyStatus = KeyStatus;
        
        key = get(hObject,'CurrentKey');
        KeyStatus = (~strcmp(key, KeyNames) & LastKeyStatus);

    end
    function stl_KeyDown(hObject, eventdata, handles)
        LastKeyStatus = KeyStatus;
        key = get(hObject,'CurrentKey');
        
        KeyStatus = (strcmp(key, KeyNames) | LastKeyStatus);
    end
    function stl_CloseReqFcn(hObject, eventdata, handles)
        CloseReq = true;
    end
    function stl_AudioplayerStopFcn(hObject, eventdata, handles)
        themePlayer.play();
    end
%% Gadget functions
    function valchopped = valchop(val, threshold)
        % VALCHOP - chop the value bilaterally
        if val>threshold
            valchopped = threshold;
        elseif val<-threshold
            valchopped = -threshold;
        else
            valchopped = val;
        end
    end
    function [stageOrchWave, fs] = makeMusic()
        % This function was heavily modified from the submission #8442 on 
        % MATLAB Central contributed by James Humes
        stageTheme = allmusic.(CurrentStage.stageTune); % Dynamic Fieldname wins!
        fs = stageTheme.fs;
        stageWave = zeros(stageTheme.nchan, ceil(stageTheme.maxdur * fs) + 2);
        
        for iChan = 1:stageTheme.nchan
            thisToneStart = 1;
            for iKey = 1:numel(stageTheme.tune(iChan).key)
                [thisTone, thisToneLen] = note(stageTheme.tune(iChan).key(iKey), ...
                    stageTheme.tune(iChan).dur(iKey), fs);
                thisToneEnd = thisToneStart + thisToneLen - 1;
                stageWave(iChan, thisToneStart:thisToneEnd) = ...
                    stageWave(iChan, thisToneStart:thisToneEnd) + thisTone;
                thisToneStart = thisToneEnd;
            end
        end
        
        % Combine all the music channels
        stageOrchWave = sum(stageWave,1);
        
        % Scale the music
        stageOrchWave = stageOrchWave./max(abs(stageOrchWave));
    end
end
function [tone, len_tone]=note(keynum, dur, fs)
% This function was modified from the submission #8442 on MATLAB Central
% contributed by James Humes
tt = 0:(1/fs):dur;
len_tone = numel(tt);

if keynum == 2
    tone=rand(1,length(tt));
    return;
end

tone = zeros(1, len_tone);

if keynum == 0
    return;
end

basefreq=440*2^((keynum-49)/12);
freqs = [1 3 5 7 9]*basefreq;
res_coeffs = [.75 .65 .5 .222 .12 1]; % the last number is not used
for i = 1:min(numel(freqs),numel(res_coeffs)) % Use the smaller length
    tone = tone + res_coeffs(i) * sin( 2*pi*freqs(i) * tt);
end
end
