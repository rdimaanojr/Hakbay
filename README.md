# Hakbay

## Database Model
This is how the database should look like in the Firestore. The main collections are `users`, `travel_plans`, and `friend_requests`.
```bash
/
├── users (collection)
│   └── {uid} (document)
│       ├── uid: string
│       ├── fname: string
│       ├── lname: string
│       ├── username: string
│       ├── email: string
│       ├── phone: string
│       ├── profilePic: string?
│       ├── isPrivate: bool
│       ├── interests: [string]
│       ├── travelStyles: [string]
│       ├── travelPlans: [string]   // references to travelPlans/{planId}
│       ├── friends: [string]       // uid of accepted friends
│       ├── outgoingFriendRequests: [string] // requestId of sent requests
│       └── incomingFriendRequests: [string] // requestId of received requests

├── friendRequests (collection)
│   └── {requestId} (document)
│       ├── senderId: string
│       ├── receiverId: string
│       ├── status: string ("pending" | "accepted" | "rejected")
│       └── timestamp: datetime

├── travelPlans (collection)
│   └── {planId} (document)
│       ├── planId: string
│       ├── name: string
│       ├── startDate: datetime
│       ├── endDate: datetime
│       ├── location: map
│       │   ├── name: string
│       │   ├── latitude: double?
│       │   └── longitude: double?
│       ├── accomodation: string?
│       ├── notes: string?
│       ├── checklist: [string]
│       └── itinerary: map?
│           ├── "0": map
│           │   ├── name: string
│           │   ├── time: datetime
│           │   ├── description: string?
│           │   └── location: map?
│           ├── "1": map
│           │   ├── name: string
│           │   ├── time: datetime
│           │   ├── description: string?
│           │   └── location: map?
│           └── ...
```

## use of `.copyWith()` method
To promote immutability and clean state management, please use `.copyWith()` implemented in each model when you need to update an object. This allows to create a modified copy with changing the original object.

You only need to pass the parameters you want to change. You can **update more than one parameters at once**.

Refer to these examples to know how to use them.
```dart
// To update a user's first name and last name
final updatedUser = user.copyWith(fname: "First", lname: "Last");

// To change a friend request from pending to accepted
final updatedRequest = request.copyWith(status: "accepted");
```

## go_route
Import the package in your dart file.
```dart
import 'package:go_router/go_router.dart';
```
Add your route in the router configuration in `main.dart`
```dart
final GoRouter _router = GoRouter(
  initialLocation: "/",
  routes: [
    ...
    GoRoute(
      path: "/init-travel-styles",
      builder: (context, state) => const InitTravelStylesScreen(),
    ),
    // add it here. like this one above ^^
  ],
);
```

To use it, simply call `.go()`
```dart
context.go('/path');
```

If you need to go insert a screen on top of another screen, (e.g. edit profile page on top of profile page), use `.push()` and `.pop()`
```dart
// push screen on top
context.push('/edit-profile');

// go back
context.pop();
```

And just like `Navigator` you can pass objects inside it. Examples below.
```dart
context.push('/path', userData);
context.pop(userData);
```

## Screens
**Authentication**
- [ ] sign-in `/`
- [ ] sign-up `/sign-up`

**Initialization**
- [ ] init interests `/init/interests`
- [ ] init travel styles`/init/travel-styles`

**Main Interface**
- [ ] home `/home`
- [ ] find similar people `/explore`
- [ ] friends `/friends`
- [ ] all friend requests `/friends/requests`
- [ ] profile `/profile`
- [ ] edit profile `/profile/edit`
- [ ] profile qr code `/profile/qr`

**Travel Plan**
- [ ] add travel plan `/travels/new`
- [ ] view travel plan `/travels/view/:planId`
- [ ] edit travel plan `/travels/edit/:planId`
- [ ] expand itinerary `/travels/view/:planId/itinerary`
- [ ] travel plan qr `/travels/view/:planId/qr`

**Users**
- [ ] view (another) user profile `/user/:uid`
	- [ ] public/friend
	- [ ] locked (private)


## logger
For easy debugging, use the logging system in `utils/logger.dart` instead of printing. 

Import the logger in your dart file.
```dart
import 'package:hakbay/utils/logger.dart';
```

To use, call the appropriate "letter" methods.
```dart
logger.t("trace log");
logger.d("debug log");
logger.i("info log");
logger.w("warning log");
logger.e("error log", error: error);
logger.f("fatal log", error: error, stackTrace: stackTrace);
```


## References
- https://www.geeksforgeeks.org/flutter-changing-app-icon/
- https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
- https://api.flutter.dev/flutter/widgets/Navigator/pushReplacementNamed.html
- https://api.flutter.dev/flutter/widgets/Navigator/pushNamedAndRemoveUntil.html
- https://docs.flutter.dev/release/breaking-changes/buttons
- https://api.flutter.dev/flutter/material/NavigationBar-class.html
- https://medium.com/@mustafatahirhussein/converting-image-to-base64-and-vice-versa-flutter-guide-79618db596c8
- https://medium.com/@rajflutter/image-to-base64-in-flutter-1d4e933f5a3f