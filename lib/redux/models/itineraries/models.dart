import 'package:redux/redux.dart';
import '../../middleware/index.dart';
import '../models.dart';

class ItineraryViewModel {
  final Function() onGetItinerary;
  final Function() onGetSelectedItinerary;
  final dynamic itinerary;


  ItineraryViewModel({
    this.onGetItinerary,
    this.onGetSelectedItinerary,
    this.itinerary
  });

  factory ItineraryViewModel.create(Store<AppState> store, id) {
    dynamic _itinerary = store.state.selectedItinerary.selectedItinerary;
    _onGetItinerary() async {
      await fetchItinerary(store, id);  
    }

    _onGetSelectedItinerary() async {
      _itinerary = await fetchSelectedItinerary(store, id);
      return _itinerary;  
    }
    

    return ItineraryViewModel(
      onGetItinerary: _onGetItinerary,
      onGetSelectedItinerary: _onGetSelectedItinerary,
      itinerary: _itinerary
    );
  }
}