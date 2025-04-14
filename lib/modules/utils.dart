String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input; // Return the original string if it's empty
  }

  // Capitalize the first letter and combine with the rest of the string
  return input[0].toUpperCase() + input.substring(1);
}

String stripHTMLTagsFromMessage(String message) {
  // Removes HTML tags from a message
  // Meaning of [^>]*: the ^ means any character except the ones in the square brackets, and the * means any number of times
  return message.replaceAll(RegExp(r"<[^>]*>"), "");
}

Iterable<String> returnHTMLLinkURLs(String message) {
  // Returns a list of HTML links from a message
  return RegExp(r"<a href=([^>]*)>[^<]*</a>").allMatches(message).map((m) =>
      (m.group(1) ?? "")
          .replaceAll("\"", "")
          .replaceAll(" ", "")); // Removes quotes and spaces
}

int getMinutesTimeDifference(String time1, String time2) {
  // Where time1 and time2 are in the format "hh:mm"
  // The difference returned is in minutes
  final time1Split = time1.split(":");
  final time2Split = time2.split(":");
  final time1Hours = int.parse(time1Split[0]);
  final time1Minutes = int.parse(time1Split[1]);
  final time2Hours = int.parse(time2Split[0]);
  final time2Minutes = int.parse(time2Split[1]);
  return (time2Hours - time1Hours) * 60 + (time2Minutes - time1Minutes);
}

dynamic returnAsList(dynamic data) {
  // If the data is a list, return it as is. Otherwise, return it as a list with one item.
  if (data is List) {
    return data;
  } else {
    return [data];
  }
}

class ListAnalyser<T> {
  ListAnalyser(this.list);
  final List<T> list;

  bool get isEmpty =>
      list.isEmpty; // Dart getter, treated as a property, not a method

  int findIndex(bool Function(T) predicate) {
    // Finds the first index, if any, of an element in the list that satisfies the predicate. Any other duplicates are ignored.
    for (var i = 0; i < list.length; i++) {
      if (predicate(list[i])) {
        return i;
      }
    }
    return -1;
  }

  List<T> findItemsBetween(T firstItem, T secondItem, bool inclusive) {
    // Finds all items between the first and second items, inclusive specified by the boolean parameter.
    final firstIndex = list.indexOf(firstItem);
    final secondIndex = list.indexOf(secondItem);
    if (firstIndex == -1 || secondIndex == -1) {
      throw ArgumentError(
          "The first and second items must both be in the list (not found).");
    }
    if (firstIndex < secondIndex) {
      if (inclusive) {
        return list.sublist(firstIndex, secondIndex + 1);
      } else {
        return list.sublist(firstIndex + 1, secondIndex);
      }
    } else {
      throw ArgumentError(
          "The first item must be before the second item in the list.");
    }
  }

  int countItemsBetweenItems(T firstItem, T secondItem, bool inclusive) {
    try {
      return findItemsBetween(firstItem, secondItem, inclusive).length;
    } catch (e) {
      return -1;
    }
  }
}
