import 'package:flutter/material.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:go_router/go_router.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlacePicker(
      apiKey: 'AIzaSyAxZmyWb8vf8w-UcVgFbK26IGKE-Y9hlJU',
      onPlacePicked: (result) {
        context.pop(result); 
      },
      enableNearbyPlaces: false,
      usePinPointingSearch: true,
      searchInputConfig: SearchInputConfig(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        autofocus: false,
        textDirection: TextDirection.ltr,
      ),
      searchInputDecorationConfig: const SearchInputDecorationConfig(
        hintText: "Enter travel location...",
        hintStyle: TextStyle(color: Colors.white70),
        enabled: true,
      ),
    );
  }
}
