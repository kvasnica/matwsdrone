classdef MatWsDrone < handle
    % MatWsDrone: Matlab Websocket gateway to Ar.Drone
    %
    %   drone = MatWsDrone()
    %   drone = MatWsDrone('ws://127.0.0.1:8025/t/ardrone')
    %
    % Methods:
    %   drone.connect() - opens the websocket
    %   drone.close()   - closes the websocket
    %   drone.takeoff() - make the drone take off
    %   drone.hover()   - make the drone hover
    %   drone.halt()    - shut down the drone
    %   drone.land()    - land the drone
    %   drone.reset()   - emergency landing
    %   drone.trim()    - flat trim the drone
    %   drone.setSampling(Ts)        - set measurement sampling in seconds
    %   drone.move([lr, rb, vv, va]) - set speed in four axes 
    %                                  (see "help MatWsDrone/move")
    %
    % Navigation data are transmitted from the drone at a fixed sampling
    % rate (0.5 seconds by default, can be changed by drone.setSampling(Ts)). 
    % The data are available via
    %
    %   data = drone.NavData
    %
    % data =
    %
    %   struct with fields:
    %
    %             vy: -14.0373
    %          theta: -5
    %             vx: 55.0681
    %             vz: 0
    %            psi: -53
    %       altitude: 290
    %        battery: 80
    %     num_frames: 0
    %     ctrl_state: 262144
    %            phi: 0
    %
    % Requires wslient, matwebsocks, matlabjson, eventcollector libraries:
    %
    %    tbxmanager install wsclient matwebsocks matlabjson eventcollector
    %
    % Requires the SWSB broker (https://github.com/kvasnica/swsb) and the
    % wspydrone gateway (https://github.com/kvasnica/wspydrone) to be
    % running somewhere (preferrably on the local machine that is connected
    % to the Ar.Drone via wifi).
    %
    % Links: 
    %  https://github.com/kvasnica/matwsdrone
    %  https://github.com/kvasnica/wspydrone
    %  https://github.com/kvasnica/swsb
    %  https://github.com/venthur/python-ardrone

    properties
        Client % instance of WSClient
        NavData = [] % navdata returned by the drone
    end
    
    methods
        function obj = MatWsDrone(url)
            % MatWsDrone constructor
            %
            %   drone = MatWsDrone('ws://127.0.0.1:8025/t/ardrone')
            tbxmanager require wsclient matwebsocks matlabjson eventcollector
            if nargin<1
                url = 'ws://127.0.0.1:8025/t/ardrone';
            end
            obj.Client = WSClient(url, ...
                'decoder', @(m) json.load(m), ...
                'encoder', @(m) json.dump(m));
            obj.Client.addlistener('MessageReceived', @(~, msg) obj.processMessage(msg));
            obj.connect();
        end

        function processMessage(obj, msg)
            % Processes incomming messages
            decoded = msg.Message;
            if isfield(decoded, 'ping')
                disp(decoded.ping);
            else
                obj.NavData = decoded;
            end
        end
        
        function connect(obj)
            % Connects to the websocket
            obj.Client.connect();
        end
        
        function close(obj)
            % Closes the websocket
            obj.Client.close();
        end
    
        function sendCommand(obj, cmd, args)
            % Sends a command to the websocket
            %
            % Encodes the command and its optional arguments as a json
            % dictionary and sends it via the websocket to the gateway.
            
            narginchk(2, 3);
            data.command = cmd;
            if nargin==3
                data.args = args;
            end
            obj.Client.send(data); % will be json-ified by the encoder
        end
        
        function halt(obj)
            % Shutdown the drone
            %
            % This method does not land or halt the actual drone, but the
            % communication with the drone. You should call it at the end of your
            % application to close all sockets, pipes, processes and threads related
            % with this object.
            obj.sendCommand('halt');
        end
        
        function hover(obj)
            % Make the drone hover
            obj.sendCommand('hover');
        end

        function land(obj)
            % Make the drone land
            obj.sendCommand('land');
        end
        
        function reset(obj)
            % Toggle the drone's emergency state
            obj.sendCommand('reset');
        end

        function takeoff(obj)
            % Make the drone takeoff
            obj.sendCommand('takeoff');
        end

        function trim(obj)
            % Flat trim the drone
            obj.sendCommand('trim');
        end

        function ping(obj)
            % Ping the websocket gateway
            obj.sendCommand('ping');
        end

        function setSpeed(obj, v)
            % Set the drone's speed
            %
            %   drone.setSpeed(v)
            %
            % "v" must be a float in the interval [0, 1]
            narginchk(2, 2);
            assert(isa(v, 'double') && isscalar(v), 'The speed must be a double scalar.');
            obj.sendCommand('set_speed', v);
        end

        function setSampling(obj, Ts)
            % Set the drone's sampling period for measurements
            %
            %   drone.setSampling(Ts)
            %
            % "Ts" must be a float in the interval [0.05, Inf]
            narginchk(2, 2);
            assert(isa(Ts, 'double') && isscalar(Ts), 'The sampling time must be a double scalar.');
            obj.sendCommand('set_sampling', Ts);
        end

        function move(obj, data)
            % Makes the drone move (translate/rotate)
            %
            %   drone.move([lr, rb, vv, va])
            %
            % lr: left-right tilt speed [-1, 1]
            % rb: font-back tilt speed [-1, 1]
            % vv: vertical speed [-1, 1]
            % va: angular speed [-1, 1]
            narginchk(2, 2);
            assert(isa(data, 'double'), 'Data must be a 1x4 vector');
            assert(isequal(size(data), [1 4]), 'Data must be a 1x4 vector');
            obj.sendCommand('move', data);
        end

    end
    
end
