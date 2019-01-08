

enum TripActions { UpdateTrip, DeleteTrip }

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

class DeleteTripAction {
  final String tripId;
  final bool success;
  
  DeleteTripAction(this.tripId, this.success);
}

class UndoTripDeleteAction {
  final dynamic trip;
  final int index;
  final bool success;
  
  UndoTripDeleteAction(this.trip, this.index, this.success);
}

class CreateTripAction {
  final dynamic trip;
  final bool success;
  
  CreateTripAction(this.trip, this.success);
}
