export 'trips/reducers.dart';
export 'itineraries/reducers.dart';
export 'auth/reducers.dart';

import '../actions/index.dart';

bool offlineReducer(dynamic state, action) {
  if(action is OfflineAction)
    return action.offline;
  return state;
}