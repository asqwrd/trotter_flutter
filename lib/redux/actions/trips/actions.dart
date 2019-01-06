

enum Actions { UpdateTrip }

class GetTripsAction {
  final List<dynamic> trips;
  GetTripsAction(this.trips);
}

class UpdateTripsFromTripAction {
  final Map<String,dynamic> trip;
  UpdateTripsFromTripAction(this.trip);
}

class UpdateTripsDestinationAction {
  final String tripId;
  final dynamic destination;
  
  UpdateTripsDestinationAction(this.tripId, this.destination);
}

class SetTripsLoadingAction {
  final bool loading;
  SetTripsLoadingAction(this.loading);
}