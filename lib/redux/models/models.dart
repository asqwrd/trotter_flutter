
import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';
import '../middleware/index.dart';


class AppState {
  final List<dynamic> trips;
  final bool tripLoading;
  AppState({
    @required this.trips,
    @required this.tripLoading
  });
  AppState.initialState()
    : trips = List.unmodifiable(<dynamic>[]),
    tripLoading = false;
}
class ViewModel {
  //final List<dynamic> trips;
  final Function() onGetTrips;
  final Function(dynamic) onUpdateTripsFromTrip;
  //final bool loading;


  ViewModel({
    //this.trips,
    this.onGetTrips,
    this.onUpdateTripsFromTrip
    //this.loading
  });

  factory ViewModel.create(Store<AppState> store) {
    _onGetTrips() async {
      
        await fetchTrips(store);  
      //}
    }
    

    return ViewModel(
      //trips: store.state.trips,
      onGetTrips: _onGetTrips,
    );
  }
}