import 'package:flutter/material.dart';
import 'package:sagahelper/components/tool_card.dart';
import 'package:sagahelper/pages/tools/recruitment_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Tools'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            ToolCard(
              title: 'Recruitment Calculator',
              subtitle: 'Find the best tag combinations',
              icon: Icons.how_to_reg,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const RecruitmentPage())),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}
