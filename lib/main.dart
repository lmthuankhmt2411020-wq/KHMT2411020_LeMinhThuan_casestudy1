import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Danh sách giao dịch dùng chung cho toàn ứng dụng
  final List transactions = [
    {
      'title': 'Ăn trưa',
      'category': 'Ăn uống',
      'date': '03/09/2024',
      'amount': '-50.000 đ',
      'isIncome': false,
      'icon': Icons.restaurant,
      'color': Colors.orange
    },
    {
      'title': 'Xăng xe',
      'category': 'Di chuyển',
      'date': '03/09/2024',
      'amount': '-100.000 đ',
      'isIncome': false,
      'icon': Icons.directions_car,
      'color': Colors.blue
    },
    {
      'title': 'Lương tháng 9',
      'category': 'Thu nhập',
      'date': '01/09/2024',
      'amount': '+8.000.000 đ',
      'isIncome': true,
      'icon': Icons.account_balance_wallet,
      'color': Colors.green
    },
  ];

  void _addTransaction(Map<String, dynamic> newTx) {
    setState(() {
      transactions.insert(0, newTx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List screens = [
      DashboardTab(transactions: transactions),
      TransactionsTab(transactions: transactions),
      StatisticsTab(transactions: transactions), // Truyền danh sách vào màn hình Thống kê
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (result != null && result is Map<String, dynamic>) {
            _addTransaction(result);
          }
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class DashboardTab extends StatelessWidget {
  final List transactions;
  const DashboardTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text('Quản lý thu chi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('5.000.000 đ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            transactions.isEmpty
                ? const Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 3 ? 3 : transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (tx['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(tx['icon'] as IconData, color: tx['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(tx['category'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tx['amount'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: (tx['isIncome'] as bool) ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(tx['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsTab extends StatelessWidget {
  final List transactions;
  const TransactionsTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Lịch sử giao dịch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('Chưa có giao dịch nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (tx['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tx['icon'] as IconData, color: tx['color'] as Color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text(tx['category'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx['amount'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: (tx['isIncome'] as bool) ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(tx['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 3. Tab Thống kê động dựa trên dữ liệu thật
class StatisticsTab extends StatelessWidget {
  final List transactions;
  const StatisticsTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Tính toán tổng thu và tổng chi dựa trên danh sách giao dịch
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      String rawAmount = tx['amount'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      double val = double.tryParse(rawAmount) ?? 0;
      if (tx['isIncome'] == true) {
        totalIncome += val;
      } else {
        totalExpense += val;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Thống kê thu chi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text('Tổng quan tháng này', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Thu nhập', style: TextStyle(color: Colors.green)),
                          const SizedBox(height: 4),
                          Text('$totalIncome đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Chi tiêu', style: TextStyle(color: Colors.red)),
                          const SizedBox(height: 4),
                          Text('$totalExpense đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Danh sách phân tích chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu thống kê'))
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    leading: Icon(tx['icon'], color: tx['color']),
                    title: Text(tx['title']),
                    subtitle: Text(tx['category']),
                    trailing: Text(
                      tx['amount'],
                      style: TextStyle(
                        color: tx['isIncome'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
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

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  final _categoryController = TextEditingController(text: 'Ăn uống');
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(text: '12/04/2025');
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm giao dịch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpense ? const Color(0xFFFF5252) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: isExpense ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpense ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: !isExpense ? Colors.black : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: 'Nhập tên danh mục tùy ý',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                suffixText: 'đ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amountText = _amountController.text.trim();
                  if (amountText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập số tiền!')),
                    );
                    return;
                  }

                  final formattedAmount = '${isExpense ? '-' : '+'}$amountText đ';
                  final newTransaction = {
                    'title': _noteController.text.isEmpty ? _categoryController.text : _noteController.text,
                    'category': _categoryController.text,
                    'date': _dateController.text,
                    'amount': formattedAmount,
                    'isIncome': !isExpense,
                    'icon': isExpense ? Icons.restaurant : Icons.account_balance_wallet,
                    'color': isExpense ? Colors.orange : Colors.green,
                  };

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm giao dịch thành công!')),
                  );
                  Navigator.pop(context, newTransaction);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}