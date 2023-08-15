import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String? selectedFuelType;
  final String? selectedFuelQuantity;

  PaymentPage({required this.selectedFuelType, required this.selectedFuelQuantity});


  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "hello",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 120,vertical: 50),
               child: Image.asset("images/fuelrequest.png"),
             ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Text(
                      "Payment",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
             Divider(
              height: 1,
              thickness: 2,
              color: Colors.grey,
            ),

            Row(
              children: [
                Text("Fuel Type: " ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
