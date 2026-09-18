void main() {
  String name = "Aftab";
  int age = 20;
  double cgpa = 3.5;
  bool isStudent = true;

  print("===== STUDENT PROFILE =====");
  print("Name: $name");
  print("Age: $age");
  print("CGPA: $cgpa");
  print("Student: $isStudent");

 
  print("\n===== ACCESS & DISCOUNT =====");

  double discount = 0;

  if (isStudent) {
    print("Access Granted");

    if (cgpa >= 3.0) {
      discount = 10;
      print("You get 10% discount");
    } else {
      discount = 5;
      print("You get 5% discount");
    }
  } else {
    print("Access Denied");
  }
  print("\n===== CANTEEN MENU =====");

  List<String> items = [
    "Burger",
    "Pizza",
    "Biryani",
    "Cold Drink"
  ];

  List<double> prices = [
    250,
    400,
    200,
    100
  ];

  for (int i = 0; i < items.length; i++) {
    print("${i + 1}. ${items[i]} - Rs.${prices[i]}");
  }

  print("\n===== ORDER / BILL =====");

  int burgerQty = 2;
  int pizzaQty = 1;
  int biryaniQty = 1;
  int drinkQty = 2;

  double totalBill =
      (prices[0] * burgerQty) +
      (prices[1] * pizzaQty) +
      (prices[2] * biryaniQty) +
      (prices[3] * drinkQty);

  double discountAmount = totalBill * discount / 100;
  double finalBill = totalBill - discountAmount;

  print("Burger x $burgerQty = Rs.${prices[0] * burgerQty}");
  print("Pizza x $pizzaQty = Rs.${prices[1] * pizzaQty}");
  print("Biryani x $biryaniQty = Rs.${prices[2] * biryaniQty}");
  print("Cold Drink x $drinkQty = Rs.${prices[3] * drinkQty}");

  print("-------------------------");
  print("Total Bill: Rs.$totalBill");
  print("Discount: Rs.$discountAmount");
  print("Final Bill: Rs.$finalBill");

  print("\n===== PROGRAM COMPLETED =====");
}