import 'package:flutter/cupertino.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hapticsEnabled = true;
  int _styleSegment = 0;

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Новый диалог'),
        content: const Text(
          'Мягкие скругления, аккуратные отступы и ясная типографика в стиле iOS.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('crfthr iOS'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: CupertinoColors.systemGrey4,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'iOS 26 Controls',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Легкий, современный блок с выразительной кнопкой.',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () => _showDialog(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text('Показать диалог'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CupertinoFormSection.insetGrouped(
              header: const Text('Тумблеры и режимы'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('Тактильная отдача'),
                  child: CupertinoSwitch(
                    value: _hapticsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _hapticsEnabled = value;
                      });
                    },
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('Стиль интерфейса'),
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _styleSegment,
                    children: const {
                      0: Text('Светлый'),
                      1: Text('Мягкий'),
                      2: Text('Контраст'),
                    },
                    onValueChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _styleSegment = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Быстрое действие'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('Мгновенный отклик'),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () => _showDialog(context),
                    child: const Text('Открыть'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
