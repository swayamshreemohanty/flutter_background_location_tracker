String landMarkExtractor({required String address}) {
  int stopIndex = 0;
  for (var i = 0; i < address.length; i++) {
    if (address[i] == ",") {
      stopIndex = i;
      break;
    }
  }
  return address.substring(0, stopIndex);
}
