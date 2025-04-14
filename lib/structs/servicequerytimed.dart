import 'package:uklivetrains/structs/repeatingtimeselection.dart';
import 'package:uklivetrains/structs/uniqueserviceidentifier.dart';

class ServiceQueryTimed {
  UniqueServiceIdentifier uniqueServiceIdentifier;
  RepeatingTimeSelection repeatingTimeSelection;

  ServiceQueryTimed({
    required this.uniqueServiceIdentifier,
    required this.repeatingTimeSelection,
  });
}
