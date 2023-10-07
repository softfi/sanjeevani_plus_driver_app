import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/app_common.dart';


final String data='''<div class="container">
  <form action="action_page.php">

    <label for="fname">First Name</label>
    <input type="text" id="fname" name="firstname" placeholder="Your name..">

    <label for="lname">Last Name</label>
    <input type="text" id="lname" name="lastname" placeholder="Your last name..">

    <label for="country">Country</label>
    <select id="country" name="country">
      <option value="australia">Australia</option>
      <option value="canada">Canada</option>
      <option value="usa">USA</option>
    </select>

    <label for="subject">Subject</label>
    <textarea id="subject" name="subject" placeholder="Write something.." style="height:200px"></textarea>

    <input type="submit" value="Submit">

  </form>
</div>''';

class HelpAndSupport extends StatelessWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.helpAndSupport, style: boldTextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          supportItemWidget(Icons.health_and_safety_outlined, 'Safety', () {
            launchScreen(context, DetailScreenForHelpAndSupport(content:data,title:'Safety' ), pageRouteAnimation: PageRouteAnimation.Slide);
          }),
          supportItemWidget(Icons.my_library_books_outlined, 'All About Ambulance Services', () {
            launchScreen(context, DetailScreenForHelpAndSupport(content:data ,title:'All About Ambulance Services' ), pageRouteAnimation: PageRouteAnimation.Slide);
          }),
          supportItemWidget(Icons.integration_instructions_outlined, 'A Guide To Ambulance', () {
            launchScreen(context, DetailScreenForHelpAndSupport(content:data ,title:'A Guide To Ambulance' ), pageRouteAnimation: PageRouteAnimation.Slide);
          }),
          supportItemWidget(Icons.coronavirus_outlined, 'Covid 19', () {
            launchScreen(context, DetailScreenForHelpAndSupport(content:data ,title:'Covid 19' ), pageRouteAnimation: PageRouteAnimation.Slide);
          }),
        ],
      ),
    );
  }


  Widget supportItemWidget(IconData icon, String title, Function() onTap, {bool isLast = false, IconData? suffixIcon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 16, right: 16),
          leading: Icon(icon, size: 25, color: primaryColor),
          title: Text(title, style: primaryTextStyle()),
          trailing: suffixIcon != null ? Icon(suffixIcon, color: Colors.green) : Icon(Icons.navigate_next, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 0)
      ],
    );
  }



}






class DetailScreenForHelpAndSupport extends StatelessWidget {
  final String title;
  final String content;
  const DetailScreenForHelpAndSupport({super.key,required this.title,required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: boldTextStyle(color: Colors.white)),
      ),
      body: HtmlWidget(content,
        onLoadingBuilder: (context, element, loadingProgress) => CircularProgressIndicator(),
      ),
    );
  }
}
