import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _officeHoursController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _officeHoursController =
        TextEditingController(text: settings.officeHours.toString());
    _startTimeController =
        TextEditingController(text: settings.officeStartTime);
    _endTimeController = TextEditingController(text: settings.officeEndTime);
  }

  @override
  void dispose() {
    _officeHoursController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    try {
      final newSettings = SettingsModel(
        officeHours: double.parse(_officeHoursController.text),
        officeStartTime: _startTimeController.text,
        officeEndTime: _endTimeController.text,
      );

      final success = await context.read<SettingsProvider>().updateSettings(
            newSettings,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Settings updated!' : 'Update failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configure Office Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _officeHoursController,
                hintText: 'Office Hours',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _startTimeController,
                hintText: 'Start Time (HH:mm)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _endTimeController,
                hintText: 'End Time (HH:mm)',
              ),
              const SizedBox(height: 32),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  return CustomButton(
                    text: 'Save Settings',
                    isLoading: settingsProvider.isLoading,
                    onPressed: _saveSettings,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
