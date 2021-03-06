# MatWsDrone

Matlab websocket gateway to Ar.Drone

## Note

If you have the [Instrument Control Toolbox](https://www.mathworks.com/products/instrument/) installed, you will be better of with using the [native ARDrone-Matlab interface](https://github.com/SaidBenaissa/ARDrone-Matlab) instead of `MatWsDrone`.

## Installation
Install [tbxmananger](http://www.tbxmanager.com) for Matlab per the instructions on its webpage.

Then, in Matlab, run:
```
>> tbxmanager install matwsdrone wsclient matwebsocks matlabjson eventcollector
```
to install all dependencies.

Next, install the `matwebsocks` library by running
```
>> matws_install
```
and **restart Matlab** (really, this is necessary).

Finally, install [Docker](https://docs.docker.com/engine/installation/) and pull two images:
```
$ docker pull kvasnica/swsb
$ docker pull kvasnica/wspydrone
```

## Usage

1. In the terminal window, start the [Simple Websocket Broker](https://github.com/kvasnica/swsb) by

        $ docker run -it -p 8025:8025 kvasnica/swsb

2. Make sure your computer is connected to the Ar.Drone via wifi and start the [wspydrone](https://github.com/kvasnica/wspydrone) gateway:

        $ docker run -it --net=host kvasnica/wspydrone

3. In Matlab, start the client:

        >> drone = MatWsDrone()

4. Now you can communicate with the drone using one of the following commands:

* `drone.takeoff()` - make the drone take off
* `drone.hover()`   - make the drone hover
* `drone.halt()`    - shut down the drone
* `drone.land()`    - land the drone
* `drone.reset()`   - emergency landing
* `drone.trim()`    - flat trim the drone
* `drone.setSpeed(v)`            - set the drone's speed
* `drone.setSampling(Ts)`        - set measurement sampling
* `drone.move([lr, rb, vv, va])` - set speed
* `drone.connect()` - opens the websocket (done automatically when creating MatWsDrone() instance)
* `drone.close()`   - closes the websocket

Navigation data are transmitted from the drone at a fixed sampling rate (0.5 seconds by default, can be changed by `drone.setSampling(Ts)`). The data are available in
```
>> drone.NavData
ans =

  struct with fields:

            vy: -14.0373
         theta: -5
            vx: 55.0681
            vz: 0
           psi: -53
      altitude: 290
       battery: 80
    num_frames: 0
    ctrl_state: 262144
           phi: 0
```

To connect the client to an instance of [swsb](https://github.com/kvasnica/swsb) that runs on a different server, use
```
>> drone = MatWsDrone('ws://server:port/t/topic')
```

## Troubleshooting

* Make sure your computer (or the one which runs the `wspydrone` gateway) is connected to the drone via wifi.
* Restart `wspydrone` and/or `swsb`.
* Restart Matlab.
* If problems remain, submit a bug report.

## Links

* [swsb](https://github.com/kvasnica/swsb) - Simple Websocket Broker
* [wspydrone](https://github.com/kvasnica/wspydrone) - Websocket gateway to [python-ardrone](https://github.com/venthur/python-ardrone) for AR.Drone firmware 1.5.1

## License

This software is published under the terms of the MIT License:

http://www.opensource.org/licenses/mit-license.php
