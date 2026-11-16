import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager - KHMT2411020',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. Model dữ liệu Giao dịch (Có hỗ trợ JSON để lưu bộ nhớ máy)
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome; // true: Thu nhập, false: Chi tiêu

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  // Chuyển đối tượng thành Map để lưu JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'isIncome': isIncome,
  };

  // Đọc JSON từ bộ nhớ thiết bị
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    isIncome: json['isIncome'],
  );
}

// 2. Màn hình chính chứa BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isBalanceVisible = true;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Tải dữ liệu đã lưu khi mở app
  }

  // Hàm lưu danh sách vào SharedPreferences
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _transactions.map((tx) => tx.toJson()).toList(),
    );
    await prefs.setString('saved_transactions', encodedData);
  }

  // Hàm tải danh sách từ SharedPreferences
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_transactions');

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      setState(() {
        _transactions = decodedData.map((item) => Transaction.fromJson(item)).toList();
      });
    } else {
      // Dữ liệu mẫu ban đầu nếu máy chưa có dữ liệu
      setState(() {
        _transactions = [
          Transaction(id: '1', title: 'Lương tháng', amount: 15000000, date: DateTime.now(), isIncome: true),
          Transaction(id: '2', title: 'Ăn uống', amount: 150000, date: DateTime.now(), isIncome: false),
          Transaction(id: '3', title: 'Tiền điện', amount: 500000, date: DateTime.now(), isIncome: false),
        ];
      });
      _saveTransactions();
    }
  }

  // Tính tổng thu nhập
  double get _totalIncome {
    return _transactions.where((tx) => tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }

  // Tính tổng chi tiêu
  double get _totalExpense {
    return _transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }

  // Số dư hiện tại động
  double get _currentBalance => _totalIncome - _totalExpense;

  // Thêm hoặc Sửa giao dịch và tự động lưu
  void _saveOrUpdateTransaction(Transaction tx) {
    setState(() {
      int index = _transactions.indexWhere((element) => element.id == tx.id);
      if (index >= 0) {
        _transactions[index] = tx; // Sửa giao dịch đã có
      } else {
        _transactions.insert(0, tx); // Thêm mới vào đầu danh sách
      }
    });
    _saveTransactions(); // Lưu lại vào bộ nhớ máy
  }

  // Xóa giao dịch và tự động lưu
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
    _saveTransactions(); // Lưu lại vào bộ nhớ máy
  }

  // Mở màn hình Thêm / Sửa
  void _openAddEditScreen(BuildContext context, {Transaction? transaction}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          existingTransaction: transaction,
          onSave: _saveOrUpdateTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // Tab 1: Trang chủ (Dashboard)
      DashboardTab(
        balance: _currentBalance,
        totalIncome: _totalIncome,
        totalExpense: _totalExpense,
        isBalanceVisible: _isBalanceVisible,
        onToggleVisibility: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
        transactions: _transactions,
        onDelete: _deleteTransaction,
        onEdit: (tx) => _openAddEditScreen(context, transaction: tx),
      ),
      // Tab 2: Danh sách giao dịch
      TransactionsTab(
        transactions: _transactions,
        onDelete: _deleteTransaction,
        onEdit: (tx) => _openAddEditScreen(context, transaction: tx),
      ),
      // Tab 3: Thống kê
      StatisticsTab(totalIncome: _totalIncome, totalExpense: _totalExpense),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditScreen(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        ],
      ),
    );
  }
}

// ================= TAB 1: TRANG CHỦ =================
class DashboardTab extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final List<Transaction> transactions;
  final Function(String) onDelete;
  final Function(Transaction) onEdit;

  const DashboardTab({
    Key? key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager - Lê Minh Thuận (KHMT2411020)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ hiển thị số dư động
            Card(
              color: Colors.blue.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số dư hiện tại', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: Icon(isBalanceVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: onToggleVisibility,
                        ),
                      ],
                    ),
                    Text(
                      isBalanceVisible ? '${balance.toStringAsFixed(0)} đ' : '••••••••',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Thu: ${totalIncome.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.green)),
                        Text('Chi: ${totalExpense.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.red)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Giao dịch gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Chưa có giao dịch nào'))
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (ctx, index) {
                  final tx = transactions[index];
                  return Dismissible(
                    key: Key(tx.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => onDelete(tx.id),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tx.isIncome ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                        trailing: Text(
                          '${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} đ',
                          style: TextStyle(
                            color: tx.isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => onEdit(tx),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TAB 2: DANH SÁCH GIAO DỊCH =================
class TransactionsTab extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) onDelete;
  final Function(Transaction) onEdit;

  const TransactionsTab({
    Key? key,
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả giao dịch')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (ctx, index) {
          final tx = transactions[index];
          return ListTile(
            title: Text(tx.title),
            subtitle: Text('${tx.amount} đ'),
            trailing: Text(tx.isIncome ? 'Thu' : 'Chi', style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red)),
            onTap: () => onEdit(tx),
          );
        },
      ),
    );
  }
}

// ================= TAB 3: THỐNG KÊ =================
class StatisticsTab extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const StatisticsTab({Key? key, required this.totalIncome, required this.totalExpense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê tài chính')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Tổng thu nhập'),
                trailing: Text('${totalIncome.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Tổng chi tiêu'),
                trailing: Text('${totalExpense.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MÀN HÌNH THÊM / SỬA GIAO DỊCH =================
class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;
  final Function(Transaction) onSave;

  const AddEditTransactionScreen({Key? key, this.existingTransaction, required this.onSave}) : super(key: key);

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _titleController.text = widget.existingTransaction!.title;
      _amountController.text = widget.existingTransaction!.amount.toString();
      _isIncome = widget.existingTransaction!.isIncome;
    } else {
      _isIncome = false;
    }
  }

  void _submitData() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (title.isEmpty || amount <= 0) return;

    final transaction = Transaction(
      id: widget.existingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: widget.existingTransaction?.date ?? DateTime.now(),
      isIncome: _isIncome,
    );

    widget.onSave(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTransaction != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên giao dịch'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(_isIncome ? 'Loại: Thu nhập' : 'Loại: Chi tiêu'),
              value: _isIncome,
              onChanged: (val) => setState(() => _isIncome = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: Text(isEditing ? 'Cập nhật' : 'Thêm giao dịch'),
            ),
          ],
        ),
      ),
    );
  }
}