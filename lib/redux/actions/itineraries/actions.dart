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
class SelectItineraryAction {
  final String selectedItineraryId;
  final Map<String, dynamic> selectedItinerary;
  final String destinationId;
  final bool loading;
  SelectItineraryAction(this.selectedItineraryId, this.loading, this.destinationId, this.selectedItinerary);
}

class SetItineraryLoadingAction {
  final bool loading;
  SetItineraryLoadingAction(this.loading);
}

class SetSelectItineraryLoadingAction {
  final bool loading;
  SetSelectItineraryLoadingAction(this.loading);
}

class SetItineraryBuilderLoadingAction {
  final bool loading;
  SetItineraryBuilderLoadingAction(this.loading);
}

class UpdateDayAfterAddAction {
  final String dayId;
  final String justAdded;
  final Map<String, dynamic> itinerary;
  final String destinationId;
  final List<dynamic> itineraryItems;

  UpdateDayAfterAddAction(this.dayId, this.itineraryItems, this.justAdded, this.itinerary, this.destinationId);
}

class UpdateDayAfterDeleteAction {
  final String dayId;
  final String id;

  UpdateDayAfterDeleteAction(this.dayId, this.id);
}