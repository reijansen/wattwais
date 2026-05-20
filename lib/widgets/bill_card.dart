import "package:flutter/material.dart";
import "package:wattwais/models/bill_entry.dart";
import "package:wattwais/utils/bill_utils.dart";

// Card widget that displays a single month's bill entry.
// Safe for compact, ultra-narrow mobile viewports.
class BillCard extends StatelessWidget {
  const BillCard({super.key, required this.entry});

  final BillEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header with a scaleDown safeguard
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatMonth(entry.monthId),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Dynamic Adaptive Grid Layout
            LayoutBuilder(
              builder: (context, constraints) {
                // If the context is narrower than a typical split view (e.g. 310px), 
                // stack inputs vertically to protect typography integrity.
                if (constraints.maxWidth < 310) {
                  return Column(
                    children: [
                      _buildBillField(),
                      const SizedBox(height: 14),
                      _buildKwhField(),
                    ],
                  );
                }

                // Otherwise, utilize a robust row setup
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBillField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKwhField()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillField() {
    return TextFormField(
      controller: entry.billController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Bill Amount',
        hintText: '3250',
        prefixText: '₱ ',
        border: OutlineInputBorder(),
        isDense: true, // Reduces internal padding for micro-viewports
        errorMaxLines: 1,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildKwhField() {
    return TextFormField(
      controller: entry.kwhController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'kWh Used', // Shortened label string to protect layout line height
        hintText: '285',
        suffixText: 'kWh',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}