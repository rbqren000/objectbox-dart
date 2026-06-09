import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model.dart';
import 'objectbox.g.dart';

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  late final Store store;

  late final Box<Task> taskBox;
  late final Box<Owner> ownerBox;
  late final Box<Event> eventBox;

  ObjectBox._create(this.store) {
    taskBox = Box<Task>(store);
    ownerBox = Box<Owner>(store);
    eventBox = Box<Event>(store);

    if (eventBox.isEmpty()) {
      _putDemoData();
    }
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Note: setting a unique directory is recommended if running on desktop
    // platforms. If none is specified, the default directory is created in the
    // users documents directory, which will not be unique between apps.
    // On mobile this is typically fine, as each app has its own directory
    // structure.

    // Note: set macosApplicationGroup for sandboxed macOS applications, see the
    // info boxes at https://docs.objectbox.io/getting-started for details.

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(
        directory: p.join((await getApplicationDocumentsDirectory()).path,
            "event_manager_objectbox"),
        macosApplicationGroup: "objectbox.demo");

    return ObjectBox._create(store);
  }

  void _putDemoData() {
    Event event =
        Event("Met Gala", date: DateTime.now(), location: "New York, USA");

    Owner owner1 = Owner('Eren');
    Owner owner2 = Owner('Annie');

    Task task1 = Task('This is Annie\'s task.');
    task1.owner.target = owner1; //set the relation

    Task task2 = Task('This is Eren\'s task.');
    task2.owner.target = owner2;

    event.tasks.add(task1);
    event.tasks.add(task2);

    // Task and Owner objects will also be put along with Event.
    // ToOne and ToMany will put new Objects when the source object is put.
    // If the target objects already existed, then only the relation is mapped.
    eventBox.put(event);
  }

  void addTask(String taskText, Owner owner, Event event) {
    Task newTask = Task(taskText);
    newTask.owner.target = owner;

    Event updatedEvent = event;
    updatedEvent.tasks.add(newTask);
    newTask.event.target = updatedEvent;

    eventBox.put(updatedEvent);

    debugPrint(
        "Added Task: ${newTask.text} assigned to ${newTask.owner.target?.name} in event: ${updatedEvent.name}");
  }

  void addEvent(String name, DateTime date, String location) {
    Event newEvent = Event(name, date: date, location: location);

    eventBox.put(newEvent);
    debugPrint("Added Event: ${newEvent.name}");
  }

  int addOwner(String newOwner) {
    Owner ownerToAdd = Owner(newOwner);
    int newObjectId = ownerBox.put(ownerToAdd);

    return newObjectId;
  }

  Stream<List<Event>> getEvents() {
    // Query for all events ordered by date.
    // https://docs.objectbox.io/queries
    final builder = eventBox.query()..order(Event_.date);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<List<Task>> getTasksOfEvent(int eventId) {
    final builder = taskBox.query()..order(Task_.id, flags: Order.descending);
    builder.link(Task_.event, Event_.id.equals(eventId));
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }
}
