import 'package:flutter/material.dart';
class DocVerificationPendingPage extends StatelessWidget {
  const DocVerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('images/pending_doc.png',scale: 4,),
          const SizedBox(height: 15,),
          Center(
            child: Text("Document under verification , we will notify once your document is verified",style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600
            ),textAlign: TextAlign.center
            ),
          ),
        ],
      ),
    );
  }
}
