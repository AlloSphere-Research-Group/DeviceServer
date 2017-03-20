The Device Server has a delegate class for the application called (ahem) DeviceServer. This delegate is provides access to many of the important features of the application, such as the DeviceManager (manages devices), the ApplicationManager (manages client applications connected to the server), LuaManager and more.

In this template, the DeviceServer is referred to as ds. The application manager is referred to as am. The DeviceManager is referred to as dm. There is a trend.

===Steps to create a Device Server plugin===

1. Modify the YourProjectName.lua file to create a device description.

2. Add necessary device drivers to project. If you need to add a framework as opposed to a static library, see addendum

3. If your plugin does not require a GUI, set the shouldDisplayInterface method to return NO;

4. Instantiate drivers as needed in the awakeFromNib method of your YourDeviceNameManager.m file

5. Either create devices when your drivers are instantiated or setup your GUI to trigger device creation. In the template, a device is created by default when the connect button is pressed in the GUI. Devices are created by sending the createDeviceWithName: message to the DeviceManager.

6. Direct messages from any devices managed by your plugin to the ApplicationManager.

7. !!!!!!IMPORTANT!!!!!!

In order for your device to actually be seen in the Device Server, you need to add it to the Master Device List, which is part of the Device Server XCode Project. You do -not- need to recompile the Device Server, just change the lua file and restart it if it's currently running.

8. You should be finished. Build your bundle and then rebuild the DeviceServer.






Addendum: Adding Frameworks

Frameworks that are to be distributed with your plugin (not frameworks included in OS X) need to be linked weakly in order to be loaded dynamically with bundles. You do this by adding code similar to the following to your manager's init method:

NSString *frameworkPath=[[[NSBundle bundleForClass:[self class]] bundlePath]
								 stringByAppendingPathComponent:@"Contents/Frameworks/WiiRemote.framework"];
        
NSBundle *framework=[NSBundle bundleWithPath:frameworkPath];

if([framework load]) {
	NSLog(@"Framework loaded");
}else{
	NSLog(@"Error, framework failed to load\nAborting.");
	exit(1);
}

You then add a Copy Files Build Phase to your project and make sure your framework is copied to the Frameworks directory. Finally, you add a flag to weakly link the framework:

-weak_framework YourFrameWorkName

... in the Other Linker Flags of your build settings.

See the Wiimote Plugin as an example of a plugin that uses a framework.

See the following website for details on the process:
http://www.far-blue.co.uk/hacks/plugin-frameworks.html
