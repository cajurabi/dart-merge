import 'dart:async';
import 'package:merge/merge.dart';

main() {
  var controller = new StreamController();
  var numbers    = new StreamController();
  var letters    = new StreamController();
  var animals    = new StreamController();

  // create a merged stream with a concurrency of 2
  var merged = controller.stream.transform(new Merge(2)).listen(print);

  // pump the numbers, letters and animals stream through the main controller
  controller.add(numbers.stream);
  controller.add(letters.stream);
  controller.add(animals.stream);

  // Pump data through the animal stream first, nothing should happen
  // due to it being the third item w/ a concurrency of 2
  animals.add("Cat");
  animals.add("Dog");

  // Now lets push some numbers and letters through and close those streams
  numbers.add(1);
  letters.add('a');
  numbers.add(2);
  letters.add('b');
  numbers.close();
  letters.close();

  // push some more animals through and close that stream
  animals.add("Bird");
  animals.add("Fish");
  animals.close();
}