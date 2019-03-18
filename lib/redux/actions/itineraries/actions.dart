class CreateItineraryAction {
  final dynamic itinerary;
  final bool success;
  
  CreateItineraryAction(this.itinerary, this.success);
}

class GetItineraryAction {
  final Map<String, dynamic> itinerary;
  final Map<String, dynamic> destination;
  final String color; 
  GetItineraryAction(this.itinerary, this.destination,this.color);
}

class GetItineraryBuilderAction {
  final Map<String, dynamic> itinerary;
  final Map<String, dynamic> destination;
  final String color; 
  GetItineraryBuilderAction(this.itinerary, this.destination,this.color);
}

class SetItineraryLoadingAction {
  final bool loading;
  SetItineraryLoadingAction(this.loading);
}

class SetItineraryBuilderLoadingAction {
  final bool loading;
  SetItineraryBuilderLoadingAction(this.loading);
}

class UpdateDayAfterAddAction {
  final String dayId;
  final String justAdded;
  final List<dynamic> itineraryItems;

  UpdateDayAfterAddAction(this.dayId, this.itineraryItems, this.justAdded);
}