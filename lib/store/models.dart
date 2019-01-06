
import 'package:trotter_flutter/store/index.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewModel {
  //final List<dynamic> trips;
  final Function() onGetTrips;
  //final bool loading;


  ViewModel({
    //this.trips,
    this.onGetTrips,
    //this.loading
  });

  factory ViewModel.create(Store<AppState> store) {
    _onGetTrips() async {
      
        var data = await fetchTrips(store);  
        store.dispatch(
          new GetTripsAction(
            data.trips, 
          )
        );
      //}
    }
    

    return ViewModel(
      //trips: store.state.trips,
      onGetTrips: _onGetTrips,
    );
  }
}