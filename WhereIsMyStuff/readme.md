Where's My Stuff Version 1.0

This App helpes to keep track of a persons stuff when he travels around places.
Especially when having a secondary home it's practical to know how much t-shirts or trousers you have left there. The user can create his own items in a few categories and can put a certain amount to a predefined Location.
When the person is at a place which he has stored he can see his items he has put there. The Items can now be selected to carry with in the virtual suitcase. 
When the user arrives at a position he has stored the app is asking him if he wants to put the stuff there.
A full history of the journeys can be seen on the Dashboard

Build Instructions

CocoaPods
   pod 'Mapbox-iOS-SDK', '\~> 5.9'                                               
   pod 'MapboxGeocoder.swift', '\~> 0.11'


Known Issues:
Suitcase will just be unloaded by tap on accept in the notification (when user is outside of the app) or by a alert action sheet popping up (when user in app).
Mapboxmap not always centered when searching for new locations (probably not my own issue)
