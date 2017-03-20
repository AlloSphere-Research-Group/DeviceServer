{
	"patcher" : 	{
		"fileversion" : 1,
		"rect" : [ 35.0, 44.0, 743.0, 405.0 ],
		"bglocked" : 0,
		"defrect" : [ 35.0, 44.0, 743.0, 405.0 ],
		"openrect" : [ 0.0, 0.0, 0.0, 0.0 ],
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 0,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"boxes" : [ 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "pack 0. 0.",
					"numoutlets" : 1,
					"fontsize" : 12.0,
					"outlettype" : [ "" ],
					"patching_rect" : [ 225.0, 225.0, 63.0, 20.0 ],
					"id" : "obj-13",
					"fontname" : "Arial",
					"numinlets" : 2
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "multislider",
					"prototypename" : "M4L.black.16",
					"border_left" : 0,
					"setstyle" : 3,
					"candicane4" : [ 0.180392, 0.576471, 0.898039, 1.0 ],
					"numoutlets" : 2,
					"border_right" : 0,
					"peakcolor" : [ 1.0, 1.0, 1.0, 1.0 ],
					"candicane3" : [ 0.0, 0.854902, 0.278431, 1.0 ],
					"outlettype" : [ "", "" ],
					"candicane8" : [ 0.180392, 0.576471, 0.898039, 1.0 ],
					"bordercolor" : [ 0.301961, 0.337255, 0.403922, 1.0 ],
					"bgcolor" : [ 0.094118, 0.113725, 0.137255, 1.0 ],
					"slidercolor" : [ 1.0, 0.603922, 0.0, 1.0 ],
					"thickness" : 1,
					"candicane2" : [ 0.921569, 0.94902, 0.05098, 1.0 ],
					"candicane7" : [ 1.0, 0.921569, 0.0, 1.0 ],
					"patching_rect" : [ 225.0, 255.0, 450.0, 136.0 ],
					"contdata" : 1,
					"ghostbar" : 50,
					"size" : 2,
					"id" : "obj-34",
					"candicane6" : [ 1.0, 0.403922, 0.0, 1.0 ],
					"border_bottom" : 0,
					"spacing" : 3,
					"candicane5" : [ 1.0, 1.0, 1.0, 1.0 ],
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "route /X /Y",
					"numoutlets" : 3,
					"fontsize" : 12.0,
					"outlettype" : [ "", "", "" ],
					"patching_rect" : [ 225.0, 195.0, 67.0, 20.0 ],
					"id" : "obj-7",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "OSC messages from DeviceServer",
					"linecount" : 2,
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 255.0, 150.0, 150.0, 34.0 ],
					"id" : "obj-6",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "deviceserver abstraction",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 15.0, 30.0, 200.0, 20.0 ],
					"id" : "obj-4",
					"fontname" : "Arial Bold",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Attributes;\n@host (IP or hostname);\n@port (number);",
					"linecount" : 3,
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 15.0, 90.0, 185.0, 48.0 ],
					"id" : "obj-3",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "Arguments: application name",
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 15.0, 60.0, 185.0, 20.0 ],
					"id" : "obj-2",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "inlet 2: OSC messages to DeviceServer",
					"linecount" : 2,
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 510.0, 75.0, 150.0, 34.0 ],
					"id" : "obj-12",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "comment",
					"text" : "inlet 1: connect/discconnect (toggle 0/1)",
					"linecount" : 2,
					"numoutlets" : 0,
					"fontsize" : 12.0,
					"patching_rect" : [ 300.0, 75.0, 162.0, 34.0 ],
					"id" : "obj-11",
					"fontname" : "Arial",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "toggle",
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"patching_rect" : [ 225.0, 30.0, 66.0, 66.0 ],
					"id" : "obj-5",
					"numinlets" : 1
				}

			}
, 			{
				"box" : 				{
					"maxclass" : "newobj",
					"text" : "deviceserver Test1 @host 127.0.0.1 @port 12000",
					"numoutlets" : 1,
					"fontsize" : 12.0,
					"outlettype" : [ "" ],
					"patching_rect" : [ 225.0, 120.0, 275.0, 20.0 ],
					"id" : "obj-1",
					"fontname" : "Arial",
					"numinlets" : 2
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"source" : [ "obj-13", 0 ],
					"destination" : [ "obj-34", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 1 ],
					"destination" : [ "obj-13", 1 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-7", 0 ],
					"destination" : [ "obj-13", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-1", 0 ],
					"destination" : [ "obj-7", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
, 			{
				"patchline" : 				{
					"source" : [ "obj-5", 0 ],
					"destination" : [ "obj-1", 0 ],
					"hidden" : 0,
					"midpoints" : [  ]
				}

			}
 ]
	}

}
