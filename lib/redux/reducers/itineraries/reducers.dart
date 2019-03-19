import 'package:redux/redux.dart';
import '../../actions/itineraries/actions.dart';
import '../../middleware/itineraries/middleware.dart';

Map<String, dynamic> updateDayAfterAddReducer(dynamic state, dynamic action) {
  var itinerary = state.itinerary;
  var index = itinerary["days"].indexWhere((day)=> day['id'] == action.dayId);
  var itineraryItems = action.itineraryItems;
  var justAddedIndex = itineraryItems.indexWhere((itin)=> itin['id'] == action.justAdded);
  itineraryItems[justAddedIndex]['justAdded'] = true;
  itinerary["days"][index]["itinerary_items"] = itineraryItems;
  
  return itinerary;
}
Map<String, dynamic> updateDayAfterDeleteReducer(dynamic state, dynamic action) {
  var itinerary = state.itinerary;
  var index = itinerary["days"].indexWhere((day)=> day['id'] == action.dayId);
  var itineraryItems = itinerary["days"][index]["itinerary_items"];
  itineraryItems.removeWhere((item)=> item['id'] == action.id);
  itinerary["days"][index]["itinerary_items"] = itineraryItems;
  
  return itinerary;
}

ItineraryData getItineraryReducer(dynamic state, dynamic action) {
  if(action is GetItineraryAction){
    return ItineraryData(
      itinerary: action.itinerary,
      color: action.color,
      destination: action.destination,
      loading: true
    );
  }
  if(action is SetItineraryLoadingAction){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: action.loading
    );
  }
  return state;
}

ItineraryData getItineraryBuilderReducer(dynamic state, dynamic action) {
  if(action is GetItineraryBuilderAction){
    return ItineraryData(
      itinerary: action.itinerary,
      color: action.color,
      destination: action.destination,
      loading: true
    );
  }
  if(action is UpdateDayAfterAddAction){
    return ItineraryData(
      itinerary: updateDayAfterAddReducer(state, action),
      color: state.color,
      destination: state.destination,
      loading: state.loading
    );
  }
  if(action is UpdateDayAfterDeleteAction){
    return ItineraryData(
      itinerary: updateDayAfterDeleteReducer(state, action),
      color: state.color,
      destination: state.destination,
      loading: state.loading
    );
  }
  if(action is SetItineraryBuilderLoadingAction){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: action.loading
    );
  }
  return state;
}

bool itineraryLoadingReducer(dynamic state, action) {
  return action.loading;
}


final Reducer <List<dynamic>> itineraryReducer = combineReducers <List<dynamic>>([
  //new TypedReducer<dynamic, UpdateDayAfterAddAction>(updateDayAfterAddReducer),
]);