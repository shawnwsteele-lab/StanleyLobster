import 'package:flutter/material.dart';
import 'models.dart';
import 'tank_page.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  final List<Tank> tanks;
  const HomePage({super.key, required this.tanks});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();

  int get grandTotal =>
      widget.tanks.fold(0, (sum, tank) => sum + tank.categories.fold(0, (s, c) => s + c.pounds));

  Future<void> printReport() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} "
        "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";

    // Build table data from latest values
    final tableData = <List<String>>[];
    for (var tank in widget.tanks) {
      for (var cat in tank.categories) {
        final pounds = cat.pounds;
        final dead = cat.dead;
        tableData.add([
          tank.name,
          cat.name,
          pounds.toString(),
          dead.toString(),
          (pounds - dead).toString(),
        ]);
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Lobster Inventory Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Person Taking Inventory: ${_nameController.text}'),
              pw.Text('Printed on: $formattedDate'),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: ['Tank', 'Category', 'Pounds', 'Dead', 'Net'],
                data: tableData,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Grand Total Pounds: $grandTotal',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());

    // Reset Dead after printing
    for (var tank in widget.tanks) {
      for (var cat in tank.categories) {
        cat.dead = 0;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lobster Inventory")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Person Taking Inventory",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Grand Total: $grandTotal lbs",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.tanks.length,
                itemBuilder: (context, index) {
                  final tank = widget.tanks[index];
                  return ListTile(
                    title: Text(tank.name),
                    subtitle: Text(
                        "Total: ${tank.categories.fold(0, (s, c) => s + c.pounds)} lbs"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      final modified = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TankPage(tank: tank)),
                      );
                      if (modified == true) setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        tooltip: "Print Inventory Report",
        onPressed: printReport,
      ),
    );
  }
}
