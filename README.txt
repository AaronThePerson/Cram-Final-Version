README

CRAM - A GPS BASED STUDY GROUP FORMATION APP

Repository: https://github.com/AaronThePerson/Cram-Final-Version

To run the app with the provided files, you will need an environment that can open the Cram Final Version.xcworkspace file.

The source code is available within the Cram Final Version folder and is separated by controller and model. This app follows the MVC (Model-View-Controller) framework so non-Xcode generated was written for model and controllers. Views were managed using the Xcode's storyboard environment which is used to generate the view UI. Icon asserts were created from scratch or were provided by flaticon.com

The AppDelegate.swift file is the base loading file and contains registration with Firebase and initialize a Firebase Cloud Messaging token.

The UMaineTestLocation file is a coordinate pair centered at the UMaine library that can be used to simulate a user on the UMaine campus when locations services is enabled.

Potential problems if trying to run on a simulator:

There may be required setup within the environment to specify what user is trying to open the source code.

This app uses cocoapods to manage and install available SDKs. As a result, if pods are uninstalled during file transfer you will need to run "pod install" within this root file to recompile the files which will rebuild the 

If running the simulator within Xcode, the app must be compiled, launched, and then stopped once before simulated location services can be activated.