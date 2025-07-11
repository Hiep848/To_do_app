import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/modules/blocs/todo_list.state.dart';
import 'package:todoapp/modules/blocs/todo_list_bloc.dart';
import 'package:todoapp/modules/models/todo.dart';
import 'package:todoapp/modules/pages/widget/bottom_navigation_bar.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê công việc'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<TodoListBloc, TodoListState>(
        builder: (context, state) {
          if (state.status == TodoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.todos.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu để thống kê.'));
          }

          // Xử lý dữ liệu để tính toán các chỉ số
          final allTodos = state.todos;
          final completedTodos = allTodos.where((t) => t.isCompleted).toList();
          final incompleteCount = allTodos.length - completedTodos.length;
          
          // Dữ liệu cho biểu đồ cột (7 ngày gần nhất)
          final Map<int, int> weeklyCompleted = { for (var i = 0; i < 7; i++) i: 0 };
          final today = DateTime.now();
          for (var todo in completedTodos) {
            final diff = today.difference(todo.lastModify).inDays;
            if (diff >= 0 && diff < 7) {
              weeklyCompleted[6 - diff] = (weeklyCompleted[6 - diff] ?? 0) + 1;
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('🎯 Tổng quan'),
                  const SizedBox(height: 12),
                  _buildSummaryGrid(completedTodos.length, incompleteCount),
                  const SizedBox(height: 36),
                  _buildSectionTitle('📊 Biểu đồ'),
                  const SizedBox(height: 12),
                  _buildBarChart(context, weeklyCompleted),
                  const SizedBox(height: 24),
                  _buildSectionTitle('📅 Lịch sử hoàn thành gần đây'),
                  const SizedBox(height: 12),
                  _buildHistoryList(completedTodos),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarCustom(),
    );
  }

  // --- WIDGETS BUILDER ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  // A. Widget cho phần tổng quan
  Widget _buildSummaryGrid(int completed, int incomplete) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(Icons.check_circle, completed.toString(), 'Đã hoàn thành', Colors.green),
        _buildStatCard(Icons.radio_button_unchecked, incomplete.toString(), 'Chưa hoàn thành', Colors.orange),
        _buildStatCard(Icons.list_alt, (completed + incomplete).toString(), 'Tổng số việc', Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // B. Widget cho biểu đồ cột
  Widget _buildBarChart(BuildContext context, Map<int, int> weeklyData) {
    final today = DateTime.now();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hoàn thành trong 7 ngày qua', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: weeklyData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [BarChartRodData(toY: entry.value.toDouble(), width: 15, color: Colors.blueAccent)],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        final day = today.subtract(Duration(days: 6 - value.toInt()));
                        return Text(DateFormat('E').format(day)); // 'E' for day of week (e.g., 'Mon')
                    })),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // C. Widget cho lịch sử
  Widget _buildHistoryList(List<ToDo> completedTodos) {
    if (completedTodos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Chưa có công việc nào được hoàn thành.'),
        ),
      );
    }

    completedTodos.sort((a, b) => b.lastModify.compareTo(a.lastModify));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: completedTodos.length > 5 ? 5 : completedTodos.length, // Chỉ hiện 5 task gần nhất
      itemBuilder: (context, index) {
        final todo = completedTodos[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            onTap: () {
              GoRouter.of(context).push('/todos/${todo.id}');
            },
            title: Text(todo.title),
            subtitle: Text('Hoàn thành ngày: ${DateFormat('dd/MM/yyyy').format(todo.lastModify)}'),
            leading: const Icon(Icons.history, color: Colors.grey),
          ),
        );
      },
    );
  }
}