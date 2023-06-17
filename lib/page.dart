import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({Key? key}) : super(key: key);

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  var productData = <String, Map<String, dynamic>>{};
  List<List<dynamic>> orderDetailsCsv = [];

  @override
  void initState() {
    _generateCsvFile();
    super.initState();
  }

  void _generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    Directory tempDir = await getTemporaryDirectory();
    String dir = tempDir.path;

    print("dir $dir");
    String file = dir;

    List orders = [
      {
        'order_id': 1,
        'product_id': 'P001',
        'quantity': 5,
        'product_name': 'Product A',
        'brand': 'Brand X',
        'delivery_area': 'Area 1'
      },
      {
        'order_id': 2,
        'product_id': 'P002',
        'quantity': 3,
        'product_name': 'Product B',
        'brand': 'Brand Y',
        'delivery_area': 'Area 2'
      },
    ];

    File f = File(file + "/filename.csv");
    // Aggregate data for each product
    for (var order in orders) {
      String productID = order['product_id'].toString();
      if (!productData.containsKey(productID)) {
        productData[productID] = {
          'total_quantity': 0,
          'brand_counts': <String, int>{},
        };
      }
      productData[productID]!['total_quantity'] += order['quantity'];
      var brandCounts = productData[productID]!['brand_counts'];
      var brand = order['brand'];
      brandCounts[brand] = (brandCounts[brand] ?? 0) + 1;
    }
    print(productData);

    orderDetailsCsv.add(
      ['Order ID', 'Delivery Area', 'Product Name', 'Quantity', 'Brand'],
    );
    for (var order in orders) {
      orderDetailsCsv.add([
        order['order_id'],
        order['delivery_area'],
        order['product_name'],
        order['quantity'],
        order['brand']
      ]);
    }
    String csv = const ListToCsvConverter().convert(orderDetailsCsv);
    f.writeAsString(csv);

    var averageQuantityFile = File(file + "/0_input_file_name.csv");
    List<List<dynamic>> averageQuantityCsv = [];
    averageQuantityCsv.add(['Product Name', 'Average Quantity']);
    for (var entry in productData.entries) {
      var totalQuantity = entry.value['total_quantity'];
      var averageQuantity = totalQuantity / orders.length;
      var productName = orders[0]['product_name'];
      averageQuantityCsv.add([productName, averageQuantity]);
    }
    print(averageQuantityCsv);
    averageQuantityFile
        .writeAsString(const ListToCsvConverter().convert(averageQuantityCsv));

    var popularBrandFile = File(file + "/1_input_file_name.csv");
    List<List<dynamic>> popularBrandCsv = [];
    popularBrandCsv.add(['Product Name', 'Most Popular Brand']);
    for (var entry in productData.entries) {
      var brandCounts = entry.value['brand_counts'];
      var popularBrand = brandCounts.keys.reduce(
          (String a, String b) => brandCounts[a]! > brandCounts[b]! ? a : b);
      var productName = orders[0]['product_name'];
      popularBrandCsv.add([productName, popularBrand]);
    }
    print(popularBrandCsv);
    popularBrandFile
        .writeAsString(const ListToCsvConverter().convert(popularBrandCsv));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: orderDetailsCsv.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    orderDetailsCsv[index][0].toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    orderDetailsCsv[index][1].toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    orderDetailsCsv[index][2].toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    orderDetailsCsv[index][3].toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    orderDetailsCsv[index][4].toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
