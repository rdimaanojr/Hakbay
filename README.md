# Hakbay

**Members:** <br/>
Maria Angela Banasihan <br/>
Hugz Christian Bernados <br/>
Ronaldo Jr. Dimaano <br/>
**Section:** CD-1L <br/>

## About This App
Hakbay is a travel planning application that aims to guide you through your journey. The name Hakbay is a combination of three Filipino words: gabay (guide), hakbang (step), and akbay (link arms with someone). It captures the core of our app, which is to guide users through each step of their journey while instilling a sense of community and support. Hakbay, like a trusted friend walking beside you, is here to provide guidance, promote progress, and foster a community of shared experiences.

## Installation Guide
0. You can clone this app, flutter pub get and flutter run or flutter build apk
1. Allow installation of unknown apps
  - Go to your phone's settings and enable enable Install unknown apps
2. Tranfer the APK to your phone by:
  - USB cable: Copy the APK to your device’s storage
  - Email: We can email you the apk
  - Google Drive: We can send you the APK uploaded 
3. Install the APK 
4. Open to launch your Flutter app

## How to Use the App
## Account Setup 
### Sign Up:
1. Tap 'Sign up' if you don't have an account yet.
2. Enter your:
  - First Name
  - Last Name
  - Email address
  - Unique username
  - Password
3. Tap "Sign Up"
4. (Optional) Add your interests and travel styles

### Sign In:
1. Enter your username and password
2. Tap "Sign In"

## Core Features

### 1. Travel Plans

#### Create a New Plan:
- Tap the "+" button on the Travel Plans screen
- Enter:
  - Plan name
  - Trip date(s)
  - Location 
  - details (optional)
- Save your plan

#### Manage Itinerary:
1. Open an existing travel plan
2. Tap "+" to add an itinerary
3. Enter daily activities with:
   - Time slots
   - Locations
   - Activity name

#### Share Plans:
- Open the plan you want to share
- Tap the share icon at the upper right
- Generate QR code (can save to phone) and let other scan it
- You can also delete an itinerary 

### 2. 👥 Find Similar Travelers
- Navigate to "Similar People" tab
- Browse users with similar interests/styles
- Tap any profile to view:
  - Full name
  - Username
  - Shared interests
  - Travel preferences
- Tap Add Friend icon to connect

### 3. Profile Management

#### Update Profile Picture:
- Tap camera icon
- Select between camera and gallery
- Capture or select your photo

#### Edit Profile:
- Go to your Profile tab
- Tap the edit (pencil) icon
- Update fields:
  - Name
  - Phone number
  - Interests
  - Travel styles
  - Profile Visibility
- Save changes

## Advanced Features

### Trip Reminders
Set custom notifications for upcoming trips:

1. When creating/editing a plan:
   - Enable push notifications
   - Set reminder timeframe 

2. Notification triggers:
   - Automatic alerts as trip date approaches
   - Configurable multiple reminders

### QR Code Sharing
**Sharing a plan:**
1. Open plan → Tap Share icon
2. Generate QR Code
3. Choose to:
   - Let other user scan it
   - Save to device gallery

**Accepting shared plans:**
1. In-app scanner:
   - Navigate to "Travel Plan"
   - Tap QR Code icon
   - Point camera at QR code

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
- https://pub.dev/packages/flutter_local_notifications/example
- https://www.youtube.com/watch?v=--PQXg_mx9I&t=629s