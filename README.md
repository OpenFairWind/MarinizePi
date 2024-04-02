# MarinizePi
A simple script to marinize the Raspberry Pi OS.

* Prepare an SD card with Raspberry Pi Imager:

  Raspberry Pi 0w 512MB: Not tested
  
  Raspberry Pi 3 1GB: 32-bit Lite Raspberry Pi OS
  
  Raspberry Pi 4 4GB: 32-bit Lite Raspberry Pi OS
  
  Raspberry Pi 4 8GB: 64-bit Lite Raspberry Pi OS

  Raspberry Pi 5: Not tested


  You can configure your OS to connect to your WiFi router with an Internet connection.
  Setup your WiFi network and password
  Setup user/password for the Raspberry Pi (usually pi/raspberry)
  Setup the Raspberry Pi name (usually raspberrypi)

* Remove any USB hardware

* Power up your Raspberry Pi
  You don't need a display.

* Connect to your Raspberry Pi
  Connect to your WiFi router using any browser
  Check for the connected WiFi devices
  Find your newly installed Raspberry Pi
  Get the Raspberry Pi IP Address (i.e., 192.168.1.x with x varying from 1 to 254)
  Open your terminal application
  Type:
  ```
    ssh pi@192.168.1.x
  ```
  Type your password, then hit the return key

* Marinize your Pi
  Act as super user
  ```
  sudo -i
  apt install screen -y
  screen
  ```
  Perform the marinization (it takes long time)
  ```
  curl https://raw.githubusercontent.com/OpenFairWind/MarinizePi/main/marinizepi.sh|bash
  ```

