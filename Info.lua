return {
  LrSdkVersion = 3.0,
  LrSdkMinimumVersion = 1.3,

  LrToolkitIdentifier = 'com.kreativlos.tools',

  LrPluginName = "Kreativlos Tools",
  
  -- Add the menu item to the Library menu.
  LrExportMenuItems = {
    {title = "Bilder markieren", file = "SelectImages.lua"}
  },

  VERSION = {major = 10, minor = 0, revision = 0}
}
