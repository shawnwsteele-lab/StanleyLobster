import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(LobsterInventoryApp());
}

class LobsterInventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lobster Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InventoryHomePage(),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final List<String> categoryOrder = [
    'sm chx',
    'lg chx',
    '1/4’s',
    '1/2’s',
    '3/4’s',
    '2’s',
    '2 1/2’s',
    '3-4’s',
    '5-6’s',
    'dead',
  ];

  Map<String, Map<String, double>> lobsterInventory = {};
  String inventoryTaker = '';

  @override
  void initState() {
    super.initState();
    // Preload Tanks 1-5
    lobsterInventory = {
      'Tank 1': {
        'sm chx': 5.0,
        'lg chx': 10.5,
        '1/4’s': 3.2,
        '1/2’s': 4.0,
        '3/4’s': 1.5,
        '2’s': 6.0,
        '2 1/2’s': 2.5,
        '3-4’s': 3.0,
        '5-6’s': 1.0,
        'dead': 0.5,
      },
      'Tank 2': {
        'sm chx': 2.5,
        'lg chx': 8.0,
        '1/4’s': 1.2,
        '1/2’s': 3.5,
        '3/4’s': 2.0,
        '2’s': 5.0,
        '2 1/2’s': 1.5,
        '3-4’s': 2.0,
        '5-6’s': 0.5,
        'dead': 0.3,
      },
      'Tank 3': {for (var cat in categoryOrder) cat: 0.0},
      'Tank 4': {for (var cat in categoryOrder) cat: 0.0},
      'Tank 5': {for (var cat in categoryOrder) cat: 0.0},
    };
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> totals = {};
    for (var tank in lobsterInventory.values) {
      tank.forEach((category, weight) {
        totals[category] = (totals[category] ?? 0) + weight;
      });
    }
    return totals;
  }

  double getGrandTotal() {
    return getCategoryTotals().values.fold(0, (sum, val) => sum + val);
  }

  void updateWeight(String tank, String category, double newValue) {
    setState(() {
      lobsterInventory[tank]![category] = newValue;
    });
  }

  void addNewTank(String tankName) {
    if (!lobsterInventory.containsKey(tankName)) {
      setState(() {
        lobsterInventory[tankName] = {
          for (var category in categoryOrder) category: 0.0,
        };
      });
    }
  }

  void clearAll() {
    setState(() {
      lobsterInventory.forEach((tank, data) {
        for (var category in categoryOrder) {
          data[category] = 0.0;
        }
      });
      inventoryTaker = '';
    });
  }

  void printCategoryTotalsByTank() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Lobster Inventory Totals by Tank',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              if (inventoryTaker.isNotEmpty)
                pw.Text('Inventory Taker: $inventoryTaker',
                    style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              ...lobsterInventory.entries.map((tankEntry) {
                final tankName = tankEntry.key;
                final tankData = tankEntry.value;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('$tankName:',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    ...categoryOrder.map((category) {
                      double value = tankData[category] ?? 0.0;
                      return pw.Text(
                          '$category: ${value.toStringAsFixed(1)} lbs');
                    }),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.Text('Grand Total: ${getGrandTotal().toStringAsFixed(1)} lbs',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    // Clear dead category after printing
    setState(() {
      lobsterInventory.forEach((tank, data) {
        data['dead'] = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final totals = getCategoryTotals();
    final grandTotal = getGrandTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lobster Inventory'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: printCategoryTotalsByTank,
            tooltip: 'Print Totals by Tank',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 700;

            Widget mainContent = Column(
              children: [
                InventoryTakerCard(
                  inventoryTaker: inventoryTaker,
                  onChanged: (value) => setState(() => inventoryTaker = value),
                ),
                SizedBox(height: 12),
                TotalsCard(
                  categoryOrder: categoryOrder,
                  totals: totals,
                  grandTotal: grandTotal,
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.clear_all),
                  label: Text('Clear All'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: clearAll,
                ),
              ],
            );

            Widget tanksList = TanksListCard(
              lobsterInventory: lobsterInventory,
              categoryOrder: categoryOrder,
              onWeightChange: updateWeight,
              onAddTank: addNewTank,
            );

            if (isWideScreen) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: mainContent),
                  SizedBox(width: 12),
                  Expanded(flex: 1, child: tanksList),
                ],
              );
            } else {
              return ListView(
                children: [mainContent, SizedBox(height: 12), tanksList],
              );
            }
          },
        ),
      ),
    );
  }
}

// Helper widgets

class InventoryTakerCard extends StatelessWidget {
  final String inventoryTaker;
  final Function(String) onChanged;

  InventoryTakerCard({required this.inventoryTaker, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Inventory Taker Name',
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class TotalsCard extends StatelessWidget {
  final List<String> categoryOrder;
  final Map<String, double> totals;
  final double grandTotal;

  TotalsCard({required this.categoryOrder, required this.totals, required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Totals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700])),
            SizedBox(height: 8),
            DataTable(
              columns: const [
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Total (lbs)')),
              ],
              rows: categoryOrder.map((category) {
                int index = categoryOrder.indexOf(category);
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                      (states) => index % 2 == 0 ? Colors.teal[50] : Colors.white),
                  cells: [
                    DataCell(Text(category)),
                    DataCell(Text((totals[category] ?? 0.0).toStringAsFixed(1))),
                  ],
                );
              }).toList(),
            ),
            Divider(),
            Text('Grand Total: ${grandTotal.toStringAsFixed(1)} lbs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class TanksListCard extends StatelessWidget {
  final Map<String, Map<String, double>> lobsterInventory;
  final List<String> categoryOrder;
  final Function(String tank, String category, double newValue) onWeightChange;
  final Function(String newTankName) onAddTank;

  TanksListCard({
    required this.lobsterInventory,
    required this.categoryOrder,
    required this.onWeightChange,
    required this.onAddTank,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700])),
            SizedBox(height: 8),
            ...lobsterInventory.keys.map((tankName) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(tankName),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TankDetailPage(
                          tankName: tankName,
                          tankData: lobsterInventory[tankName]!,
                          categoryOrder: categoryOrder,
                          onWeightChange: onWeightChange,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            Divider(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Tank'),
                onPressed: () async {
                  String? newTankName = await _showAddTankDialog(context);
                  if (newTankName != null && newTankName.isNotEmpty) {
                    onAddTank(newTankName);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showAddTankDialog(BuildContext context) async {
    String newTankName = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Tank'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Tank Name'),
          onChanged: (value) => newTankName = value,
        ),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(child: Text('Add'), onPressed: () => Navigator.pop(context, newTankName)),
        ],
      ),
    );
  }
}

class TankDetailPage extends StatelessWidget {
  final String tankName;
  final Map<String, double> tankData;
  final List<String> categoryOrder;
  final Function(String tank, String category, double newValue) onWeightChange;

  TankDetailPage({
    required this.tankName,
    required this.tankData,
    required this.categoryOrder,
    required this.onWeightChange,
  });

  void clearTank() {
    for (var category in categoryOrder) {
      onWeightChange(tankName, category, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tankName)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.clear_all),
              label: Text('Clear Tank'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: clearTank,
            ),
            SizedBox(height: 12),
            ...categoryOrder.map((category) {
              double value = tankData[category] ?? 0.0;
              TextEditingController controller =
                  TextEditingController(text: value.toStringAsFixed(1));

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: TextStyle(fontSize: 16)),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(border: OutlineInputBorder()),
                          onSubmitted: (valueText) {
                            double newValue = double.tryParse(valueText) ?? 0.0;
                            onWeightChange(tankName, category, newValue);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
