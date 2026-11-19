import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, int> _quantities = {};

  static const _products = <_Product>[
    _Product('1', 'Original Burger', 5.99, '11 item'),
    _Product('2', 'Double Burger', 10.99, '10 item'),
    _Product('3', 'Cheese Burger', 6.99, '7 item'),
    _Product('4', 'Double Cheese Burger', 12.99, '20 item'),
    _Product('5', 'Spicy Burger', 7.39, '12 item'),
    _Product('6', 'Special Black Burger', 7.39, '39 item'),
    _Product('7', 'Special Cheese Burger', 8.00, '2 item'),
    _Product('8', 'Jumbo Cheese Burger', 15.99, '2 item'),
    _Product('9', 'Spicy Burger', 7.39, '12 item'),
    _Product('10', 'Special Black Burger', 7.39, '39 item'),
    _Product('11', 'Special Cheese Burger', 8.00, '2 item'),
    _Product('12', 'Jumbo Cheese Burger', 15.99, '2 item'),
  ];

  void _add(_Product product) {
    setState(() => _quantities.update(product.id, (count) => count + 1,
        ifAbsent: () => 1));
  }

  void _remove(_Product product) {
    setState(() {
      final count = _quantities[product.id] ?? 0;
      if (count <= 1) {
        _quantities.remove(product.id);
      } else {
        _quantities[product.id] = count - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 760;
      final menu = _buildMenu();
      final order = _buildOrder();

      if (narrow) {
        return Column(children: [
          Expanded(flex: 3, child: menu),
          const SizedBox(height: 12),
          Expanded(flex: 2, child: order),
        ]);
      }

      return Row(children: [
        Expanded(flex: 3, child: menu),
        const SizedBox(width: 16),
        SizedBox(width: constraints.maxWidth * 0.29, child: order),
      ]);
    });
  }

  Widget _buildMenu() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Lorem Restaurant',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('20 October 2022',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),
        if (MediaQuery.sizeOf(context).width >= 600)
          SizedBox(width: 220, child: _search()),
      ]),
      const SizedBox(height: 14),
      SizedBox(
        height: 72,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: const [
            _Category(
                icon: 'assets/icons/icon-burger.png',
                title: 'Burger',
                active: true),
            _Category(icon: 'assets/icons/icon-noodles.png', title: 'Noodles'),
            _Category(icon: 'assets/icons/icon-drinks.png', title: 'Drinks'),
            _Category(
                icon: 'assets/icons/icon-desserts.png', title: 'Desserts'),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 850
              ? 4
              : constraints.maxWidth >= 560
                  ? 3
                  : constraints.maxWidth >= 340
                      ? 2
                      : 1;
          final ratio = columns == 4
              ? 0.82
              : columns == 3
                  ? 0.78
                  : 0.9;
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: ratio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return _ProductCard(
                product: product,
                quantity: _quantities[product.id] ?? 0,
                onAdd: () => _add(product),
              );
            },
          );
        }),
      ),
    ]);
  }

  Widget _buildOrder() {
    final ordered = _products
        .where((product) => (_quantities[product.id] ?? 0) > 0)
        .toList();
    final subtotal = _products.fold<double>(
      0,
      (sum, product) => sum + product.price * (_quantities[product.id] ?? 0),
    );
    final tax = subtotal * 0.107;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff1f2029),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Order · Table 8',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: ordered.isEmpty
              ? const Center(
                  child: Text('Tap a menu item to add it to the order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54)),
                )
              : ListView.builder(
                  itemCount: ordered.length,
                  itemBuilder: (context, index) {
                    final product = ordered[index];
                    final quantity = _quantities[product.id]!;
                    return _OrderItem(
                      product: product,
                      quantity: quantity,
                      onAdd: () => _add(product),
                      onRemove: () => _remove(product),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        _totalRow('Subtotal', subtotal),
        const SizedBox(height: 4),
        _totalRow('Tax', tax),
        const Divider(color: Colors.white38, height: 16),
        _totalRow('Total', subtotal + tax, bold: true),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: ordered.isEmpty ? null : () {},
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Print Bills'),
          ),
        ),
      ]),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    final style = TextStyle(
      color: Colors.white,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 13,
    );
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: style),
      Text('\$${amount.toStringAsFixed(2)}', style: style),
    ]);
  }

  Widget _search() => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xff1f2029),
        ),
        child: const Row(children: [
          Icon(Icons.search, color: Colors.white54, size: 19),
          SizedBox(width: 8),
          Expanded(
            child: Text('Search menu here...',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ]),
      );
}

class _Product {
  const _Product(this.id, this.name, this.price, this.stock);

  final String id;
  final String name;
  final double price;
  final String stock;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
  });

  final _Product product;
  final int quantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff1f2029),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: SizedBox.expand(
                child: Image.asset('assets/items/${product.id}.png',
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              if (quantity > 0)
                Text('×$quantity ',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              const Icon(Icons.add_circle, color: Colors.deepOrange, size: 20),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final _Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xff17181f),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/items/${product.id}.png',
              width: 44, height: 44, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text('\$${product.price.toStringAsFixed(2)} each',
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 30, height: 34),
          padding: EdgeInsets.zero,
          tooltip: 'Remove one ${product.name}',
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline,
              color: Colors.white70, size: 18),
        ),
        Text('$quantity',
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 30, height: 34),
          padding: EdgeInsets.zero,
          tooltip: 'Add one ${product.name}',
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline,
              color: Colors.deepOrange, size: 18),
        ),
      ]),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category(
      {required this.icon, required this.title, this.active = false});

  final String icon;
  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff1f2029),
        border: Border.all(
          color: active ? Colors.deepOrangeAccent : const Color(0xff1f2029),
          width: 2,
        ),
      ),
      child: Row(children: [
        Image.asset(icon, width: 34, height: 34, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
