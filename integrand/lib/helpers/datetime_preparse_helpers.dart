String parseXXSlashXXSlashXXXXIntoParsableByDateTime(String dateString) {
  List<String> split = dateString.split("/");
  for (int i = 0; i < split.length; i++) {
    int asInt = int.parse(split[i]);
    if (asInt < 10) {
      split[i] = "0$asInt";
    }
  }
  return "${split[2]}-${split[0]}-${split[1]}";
}