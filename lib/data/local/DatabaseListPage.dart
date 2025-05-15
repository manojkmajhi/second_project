import 'package:flutter/material.dart';
import 'package:second_project/data/local/db_helper.dart';

class DatabaseListPage extends StatefulWidget {
  const DatabaseListPage({super.key});

  @override
  State<DatabaseListPage> createState() => _DatabaseListPageState();
}

class _DatabaseListPageState extends State<DatabaseListPage> {
  final Map<String, List<Map<String, dynamic>>> _tableData = {};
  final List<String> _tables = [
    DBHelper.tableName,
    DBHelper.productTableName,
    DBHelper.cartTableName,
    DBHelper.orderTableName,
    DBHelper.wishlistTableName,
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTables();
  }

  Future<void> _loadAllTables() async {
    final db = await DBHelper.instance.getDB();
    final data = <String, List<Map<String, dynamic>>>{};

    for (String table in _tables) {
      try {
        final rows = await db.query(table);
        data[table] = rows;
      } catch (e) {
        data[table] = [{'Error': e.toString()}];
      }
    }

    setState(() {
      _tableData.clear();
      _tableData.addAll(data);
      _isLoading = false;
    });
  }

  void _showEditDialog(String table, Map<String, dynamic> row, {bool isNew = false}) async {
    final keys = row.keys.where((k) => k != 'id').toList();
    final controllers = {for (var key in keys) key: TextEditingController(text: '${row[key]}')};

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isNew ? 'Add to $table' : 'Edit $table Record'),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries
                .map((entry) => TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final db = await DBHelper.instance.getDB();
              final data = {
                for (var entry in controllers.entries) entry.key: entry.value.text
              };
              if (isNew) {
                await db.insert(table, data);
              } else {
                await db.update(table, data, where: 'id = ?', whereArgs: [row['id']]);
              }
              Navigator.pop(context);
              _loadAllTables();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRow(String table, int id) async {
    final db = await DBHelper.instance.getDB();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    _loadAllTables();
  }

  Widget _buildDataTable(String tableName, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16), child: Text("No records found."));
    }

    final columns = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
        columns: [
          ...columns.map((col) => DataColumn(label: Text(col.toUpperCase()))),
          const DataColumn(label: Text('Actions')),
        ],
        rows: rows.map((row) {
          return DataRow(cells: [
            ...columns.map((col) => DataCell(Text('${row[col]}'))),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(tableName, row),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRow(tableName, row['id']),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTableSection(String table, List<Map<String, dynamic>> data) {
    return ExpansionTile(
      title: Text(table.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildDataTable(table, data),
        ),
        TextButton.icon(
          onPressed: () {
            final defaultRow = {
              for (var k in data.isNotEmpty ? data.first.keys.where((k) => k != 'id') : <String>['key']) k: ''
            };
            _showEditDialog(table, defaultRow, isNew: true);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Viewer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _tables
                  .map((table) => _buildTableSection(table, _tableData[table] ?? []))
                  .toList(),
            ),
    );
  }
}
