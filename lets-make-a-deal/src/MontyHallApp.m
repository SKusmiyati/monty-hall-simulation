classdef MontyHallApp < matlab.apps.AppBase
    properties (Access = public)
        UIFigure
        ModeDropDown
        StartButton
        StayButton
        SwitchButton
        StatusLabel
        PintuPanel
    end

    properties (Access = private)
        prizeDoor
        chosenDoor
        openedDoors
        numDoors
    end

    methods (Access = private)

        % Start
        function StartButtonPushed(app, ~)
            app.StatusLabel.Text = "Pilih pintu!";
            app.chosenDoor = [];
            app.openedDoors = [];

            switch app.ModeDropDown.Value
                case 'Easy', app.numDoors = 3;
                case 'Medium', app.numDoors = 5;
                case 'Hard', app.numDoors = 10;
            end
            app.prizeDoor = randi(app.numDoors);

            delete(app.PintuPanel.Children);
            for i=1:app.numDoors
                uibutton(app.PintuPanel,'Text',"Pintu "+i, ...
                    'Position',[20+(i-1)*70, 20, 60, 40], ...
                    'ButtonPushedFcn',@(btn,event) app.DoorButtonPushed(i));
            end
        end

        function DoorButtonPushed(app, doorNum)
            if isempty(app.chosenDoor)
                app.chosenDoor = doorNum;
                app.StatusLabel.Text = "Pilih pintu "+doorNum+". Membuka zonk...";
                pause(1);
                app.openHostDoor();
            else
                app.StatusLabel.Text = "Gunakan Stay / Switch!";
            end
        end

        function openHostDoor(app)
            c = setdiff(1:app.numDoors,[app.chosenDoor, app.openedDoors, app.prizeDoor]);
            if ~isempty(c)
                openDoor = c(randi(numel(c)));
                app.openedDoors(end+1) = openDoor;
                btns = app.PintuPanel.Children;
                btn = btns(app.numDoors - openDoor + 1);
                btn.Text = "ZONK!";
                btn.Enable = 'off';
                btn.BackgroundColor = [0.8 0.8 0.8];
            end
            app.StatusLabel.Text = "Stay atau Switch?";
        end

        function StayButtonPushed(app, ~)
            app.StatusLabel.Text = "STAY di pintu "+app.chosenDoor;
            app.nextRound();
        end

        function SwitchButtonPushed(app, ~)
            app.StatusLabel.Text = "Klik pintu lain!";
            app.chosenDoor = [];
        end

        function nextRound(app)
            remaining = setdiff(1:app.numDoors, app.openedDoors);
            if numel(remaining) > 2
                pause(1); app.openHostDoor();
            else
                btns = app.PintuPanel.Children;
                for i=1:app.numDoors
                    btn = btns(app.numDoors - i + 1);
                    if i==app.prizeDoor
                        btn.Text = "HADIAH!";
                        btn.BackgroundColor = [0.5 1 0.5];
                    else
                        btn.Text = "ZONK!";
                        btn.BackgroundColor = [1 0.5 0.5];
                    end
                    btn.Enable = 'off';
                end
                if app.chosenDoor==app.prizeDoor
                    app.StatusLabel.Text="MENANG!";
                else
                    app.StatusLabel.Text="Kalah, hadiah di pintu "+app.prizeDoor;
                end
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Position',[100 100 800 300],'Name','Monty Hall App');

            app.ModeDropDown = uidropdown(app.UIFigure,...
                'Items',{'Easy','Medium','Hard'},...
                'Position',[20 250 100 22]);

            app.StartButton = uibutton(app.UIFigure,'push',...
                'Text','Start','Position',[140 250 100 22],...
                'ButtonPushedFcn',@(btn,event) StartButtonPushed(app));

            app.StayButton = uibutton(app.UIFigure,'push',...
                'Text','Stay','Position',[20 210 100 22],...
                'ButtonPushedFcn',@(btn,event) StayButtonPushed(app));

            app.SwitchButton = uibutton(app.UIFigure,'push',...
                'Text','Switch','Position',[140 210 100 22],...
                'ButtonPushedFcn',@(btn,event) SwitchButtonPushed(app));

            app.StatusLabel = uilabel(app.UIFigure,'Text','Status...',...
                'Position',[20 180 300 22]);

            app.PintuPanel = uipanel(app.UIFigure,'Position',[20 20 760 140],...
                'Title','Pintu');
        end
    end

    methods (Access = public)
        function app = MontyHallApp
            createComponents(app)
            if nargout==0; clear app; end
        end
    end
end
