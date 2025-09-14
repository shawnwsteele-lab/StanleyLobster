import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';

class TankPage extends StatefulWidget {
  final Tank tank;
  const TankPage({super.key, required this.tank});

  @override
  State<TankPage> createState() => _TankPageState();
}

class _TankPageState extends State<TankPage> {
  final Map<Category, TextEditingController> poundsControllers = {};
  final Map<Category, TextEditingController> deadControllers = {};

  @override
  void initState() {
    super.initState();
    for (var cat in widget.tank.categories) {
      poundsControllers[cat] =
          TextEditingController(text: cat.pounds.toString());
      deadControllers[cat] =
          TextEditingController(text: cat.dead.toString());
    }
  }

  @override
  void dispose() {
    for (var c in poundsControllers.values) c.dispose();
    for (var c in deadControllers.values) c.dispose();
    super.dispose();
  }

  void addPounds(Category cat, int delta) {
    cat.pounds += delta;
    if (cat.pounds < 0) cat.pounds = 0;
    poundsControllers[cat]!.text = cat.pounds.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tank.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Dead",
            onPressed: () {
              for (var cat in widget.tank.categories) {
                cat.dead = 0;
                deadControllers[cat]!.text = '0';
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        children: widget.tank.categories.map((cat) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(cat.name)),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => addPounds(cat, -100),
                        ),
                        Expanded(
                          child: TextField(
                            controller: poundsControllers[cat],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: "Pounds",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              cat.pounds = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addPounds(cat, 100),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: deadControllers[cat],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: "Dead",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        cat.dead = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        tooltip: "Done",
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
