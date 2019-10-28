import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';

class ItineraryStore extends Store {
  ItineraryData _itinerary = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null,
      error: null);
  get itinerary => _itinerary;

  SelectItineraryData _selectedItinerary = SelectItineraryData(
    loading: false,
    updating: false,
    selectedItineraryId: null,
    selectedItinerary: null,
    destinationId: null,
  );
  get selectedItinerary => _selectedItinerary;

  ItineraryData _itineraryBuilder = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null,
      error: null);
  get itineraryBuilder => _itineraryBuilder;

  setItinerary(dynamic itinerary, dynamic destination, String color) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: itinerary,
          color: color,
          destination: destination,
          loading: false,
          error: _itinerary.error);
    });
  }

  setItineraryBuilder(dynamic itinerary, dynamic destination, String color) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: color,
          destination: destination,
          loading: true,
          error: _itinerary.error);
    });
  }

  setSelectedItinerary(String selectedItineraryId, String destinationId,
      dynamic selectedItinerary,
      [bool loading]) {
    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: loading != null ? loading : _selectedItinerary.loading,
          updating: _selectedItinerary.updating,
          selectedItineraryId: selectedItineraryId == null
              ? _selectedItinerary.selectedItineraryId
              : selectedItineraryId,
          selectedItinerary: selectedItinerary == null
              ? _selectedItinerary.selectedItinerary
              : selectedItinerary,
          destinationId: destinationId);
    });
  }

  updateSelectedItinerary(String dayId, List<dynamic> itineraryItems,
      String justAdded, Map<String, dynamic> itinerary, String destinationId,
      [bool loading]) {
    var selectedItinerary = _selectedItinerary.selectedItinerary;
    var index =
        selectedItinerary["days"].indexWhere((day) => day['id'] == dayId);
    selectedItinerary["days"][index]["itinerary_items"] = itineraryItems;

    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: loading != null ? loading : _selectedItinerary.loading,
          updating: _selectedItinerary.updating,
          selectedItineraryId: itinerary['id'],
          selectedItinerary: selectedItinerary,
          destinationId: destinationId);
    });
  }

  updateItineraryBuilder(String dayId, List<dynamic> itineraryItems,
      String justAdded, Map<String, dynamic> itinerary,
      [String destinationId]) {
    var itinerary = _itineraryBuilder.itinerary;
    var index = itinerary["days"].indexWhere((day) => day['id'] == dayId);
    var justAddedIndex =
        itineraryItems.indexWhere((itin) => itin['id'] == justAdded);
    if (justAddedIndex > 0) itineraryItems[justAddedIndex]['justAdded'] = true;
    itinerary["days"][index]["itinerary_items"] = itineraryItems;
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: _itineraryBuilder.error);
    });
  }

  updateStartLocation(dynamic startLocation) {
    var itinerary = _itineraryBuilder.itinerary;
    itinerary['start_location'] = startLocation;
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: _itineraryBuilder.error);
    });
  }

  updateItineraryBuilderDelete(String dayId, String id) {
    var itinerary = _itineraryBuilder.itinerary;
    var index = itinerary["days"].indexWhere((day) => day['id'] == dayId);
    var itineraryItems = itinerary["days"][index]["itinerary_items"];
    itineraryItems.removeWhere((item) => item['id'] == id);
    itinerary["days"][index]["itinerary_items"] = itineraryItems;
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: _itineraryBuilder.error);
    });
  }

  setItineraryError(String error) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: _itinerary.itinerary,
          color: _itinerary.color,
          destination: _itinerary.destination,
          loading: _itinerary.loading,
          error: error);
    });
  }

  setItineraryBuilderError(String error) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: _itineraryBuilder.itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: error);
    });
  }

  setItineraryBuilderLoading(bool loading) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: _itineraryBuilder.itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: loading,
          error: _itineraryBuilder.error);
    });
  }

  setSelectItineraryLoading(bool loading) {
    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: loading,
          updating: _selectedItinerary.updating,
          selectedItineraryId: _selectedItinerary.selectedItineraryId,
          selectedItinerary: _selectedItinerary.selectedItinerary,
          destinationId: _selectedItinerary.destinationId);
    });
  }

  setSelectItineraryUpdating(bool updating) {
    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: _selectedItinerary.loading,
          updating: updating,
          selectedItineraryId: _selectedItinerary.selectedItineraryId,
          selectedItinerary: _selectedItinerary.selectedItinerary,
          destinationId: _selectedItinerary.destinationId);
    });
  }

  setItineraryLoading(bool loading) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: _itinerary.itinerary,
          color: _itinerary.color,
          destination: _itinerary.destination,
          loading: loading,
          error: _itinerary.error);
    });
  }
}
