import 'package:apiarium/shared/services/vc_service.dart';
import 'package:flutter/material.dart';

class VcInspectionView extends StatefulWidget {
  const VcInspectionView({super.key, required this.vcService});
  final VcService vcService;

  @override
  State<VcInspectionView> createState() => _VcInspectionViewState();
}

class _VcInspectionViewState extends State<VcInspectionView> {

  String resultText = 'Empty';
  @override
  void initState() {
    super.initState();
    widget.vcService.setResultHandler((r) =>
    {
      setState(() {
        resultText = r;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Text(
        resultText,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
  
}
