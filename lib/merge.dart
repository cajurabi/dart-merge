library merge;

import 'dart:async';
import 'dart:collection';
import 'package:composite_subscription/composite_subscription.dart';
import 'package:flat_map/flat_map.dart';

class Merge<S, T> extends StreamEventTransformer {

  final int _concurrency;

  const Merge(this._concurrency);

  Stream<T> bind(Stream<Stream<S>> stream) {
    var backlog       = new ListQueue();
    var subscriptions = new CompositeSubscription();
    return stream.transform(new FlatMap((Stream<S> data) {
      var controller   = new StreamController();
      var subscription = null;
      subscription     = data.listen(
        (S data) {
          controller.add(data);
        },
        onError: (error) {
          controller.addError(error);
          subscriptions.cancel();
        },
        onDone: () {
          subscriptions.remove(subscription);
          if (backlog.length > 0) {
            backlog.removeFirst().resume();
          }
        }
      );
      if (subscriptions.toList().length >= this._concurrency) {
        subscription.pause();
        backlog.add(subscription);
      }
      subscriptions.add(subscription);
      return controller.stream;
    }));
  }

}