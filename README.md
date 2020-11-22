# ON STAGE
 Switch an "ON STAGE" LED sign on/off via BLE HM-10 module

The base is an "ON STAGE" LED sign powered by 2x AA 1.5V batteries. The connection has to be changed, so it maches to the following schematic:
![Schematic](https://github.com/schreinerman/onstage/raw/master/schematic/schematic.png)

Connect to the HM-10 module via serial converter with 9600,8,N,1. (some configurations are 115200 baud)

Sending `AT+VERS?` or `AT+VERR?` should generate the answer `HMSoft V540`. If not, the firmware has to be updated.

As next the module has to be changed to be accessed by BLE also.
```
AT+MODE1  // makes it possible to receive AT commands via BLE
AT+PWRM0  // Activates 0.4 mA unconnected,  8 mA connected
```
The software will send following commands:
```
AT+PIO20 // turn off the PIO2 GPIO, so LED will turned off
AT+PIO21 // turn on the PIO2 GPIO, so LED will turned on
```

See also a good tutorial on HM-10 at following webpage: http://esp32-server.de/hm-10/
