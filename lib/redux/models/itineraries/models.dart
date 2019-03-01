import 'package:redux/redux.dart';
import '../../middleware/index.dart';
import '../models.dart';

class ItineraryViewModel {
  final Function() onGetItinerary;


  ItineraryViewModel({
    this.onGetItinerary
  });

  factory ItineraryViewModel.create(Store<AppState> store, id) {
    _onGetItinerary() async {
      await fetchItinerary(store, id);  
    }

    

    return ItineraryViewModel(
      onGetItinerary: _onGetItinerary,
    );
  }
}