# trotter_flutter

Trotter built in flutter.  Links to docs to get started and up and running.  I recommend VsCode for developing in flutter.
https://flutter.io/docs/get-started/install

**Notes:**<br>
The install guide showed show you how to setup your computer so that you have all the platform tools.
Once you have flutter and all the needed tools set up follow these steps.
<br>
<br>
**Backend**<br>
 You need to make sure you have the backend setup and the server running locally
 Instructions for backend is here https://github.com/asqwrd/trotter-api
 <br>
 <br>
 **Run locally on Android**<br>
 1. Make sure adb is installed on your computer
 2. Follow these instructions to enable developer mode and usb debugging on Android
      - Enable Developer mode -https://developer.android.com/studio/debug/dev-options#enable
      - Enable USB Debugging - https://developer.android.com/studio/debug/dev-options#debugging
 3. Check that your phone is recognized by your computer by running `adb devices`
     - This should return the device name of you phone like below
         > List of devices attached <br>
         > DEVICE_NAME	device
 4.  Once you have your device name run `adb -s {DEVICE_NAME} reverse tcp:3002 tcp:{PORT}`
      - Subsitute {DEVICE_NAME} with the name you got in `adb devices`
      - Substitute {PORT} with the port you use to run the backend server ie 3002
      - This command allows your phone see the backend server running locally so you can make calls to the api.

**Build release**
1. `flutter build appbundle --release`
2. Sign the build
     - Navigate to `/build/app/outputs/bundle/release`
     - Manually sign using keystore `jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore ../android/key.jks app.aab key`
3. Upload signed build to Play console

    
