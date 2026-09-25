
mixin NotificationMixin {
  void triggerVibration() {
    print("📳 [VIBRATION]: Target Completed!");
  }
}


class Tasbeeh with NotificationMixin {
  // Private properties
  String _dhikrName;
  int _counter;
  int _target;

  // Default Constructor
  Tasbeeh({
    required String name,
    int target = 33,
  })  : _dhikrName = name,
        _counter = 0,
        _target = target;

 
  Tasbeeh.subhanAllah()
      : _dhikrName = "SubhanAllah",
        _counter = 0,
        _target = 33;

  // Named Constructor: Alhamdulillah
  Tasbeeh.alhamdulillah()
      : _dhikrName = "Alhamdulillah",
        _counter = 0,
        _target = 33;

  // Named Constructor: Allahu Akbar
  Tasbeeh.allahAkbar()
      : _dhikrName = "Allahu Akbar",
        _counter = 0,
        _target = 34;

  // Getters - Read-only access
  String get dhikrName => _dhikrName;

  int get counter => _counter;

  int get target => _target;

  // Boolean Getter
  bool get isCompleted => _counter == _target;

  // Increment Method
  void increment() {
    if (_counter < _target) {
      _counter++;

      print("Dhikr: $_dhikrName");
      print("Counter: $_counter / $_target");

      if (_counter == _target) {
        print("Target Reached for $_dhikrName!");
        triggerVibration();
      }
    } else {
      print("Target already completed!");
    }
  }

  // Reset Method
  void reset() {
    _counter = 0;
    print("$_dhikrName counter has been reset.");
  }
}

void main() {
  // Creating object using default constructor
  Tasbeeh tasbeeh1 = Tasbeeh(
    name: "Astaghfirullah",
    target: 5,
  );

  print("----- Default Constructor -----");
  print("Dhikr: ${tasbeeh1.dhikrName}");
  print("Target: ${tasbeeh1.target}");
  print("Counter: ${tasbeeh1.counter}");

  // Increment counter
  tasbeeh1.increment();
  tasbeeh1.increment();
  tasbeeh1.increment();
  tasbeeh1.increment();
  tasbeeh1.increment();

  print("Completed: ${tasbeeh1.isCompleted}");

  // Reset
  tasbeeh1.reset();

  print("\n----- Named Constructor -----");

  // SubhanAllah
  Tasbeeh subhan = Tasbeeh.subhanAllah();

  print("Dhikr: ${subhan.dhikrName}");
  print("Target: ${subhan.target}");

  // Alhamdulillah
  Tasbeeh alhamdulillah = Tasbeeh.alhamdulillah();

  print("\nDhikr: ${alhamdulillah.dhikrName}");
  print("Target: ${alhamdulillah.target}");

  // Allahu Akbar
  Tasbeeh allahuAkbar = Tasbeeh.allahAkbar();

  print("\nDhikr: ${allahuAkbar.dhikrName}");
  print("Target: ${allahuAkbar.target}");
}