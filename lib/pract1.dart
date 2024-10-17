import 'package:flutter/material.dart';

void main() => runApp(const pract1());

class pract1 extends StatelessWidget {
  const pract1({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle='Flutter layout demo';
    return MaterialApp(
      home: Scaffold(
        backgroundColor:Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red,
          title:const Text(appTitle,style: TextStyle(),),//style of thetext on the header
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              images(image: "assets/images/1.png"),
              TitleSection(
                name: 'Oeschinen Lake Campground',
                location: 'Kandersteg, Switzerland',
              ),
              ButtonSection(),
              descripe(description:  'Lake Oeschinen lies at the foot of the Blüemlisalp in the '
                  'Bernese Alps. Situated 1,578 meters above sea level, it '
                  'is one of the larger Alpine Lakes. A gondola ride from '
                  'Kandersteg, followed by a half-hour walk through pastures '
                  'and pine forest, leads you to the lake, which warms to 20 '
                  'degrees Celsius in the summer. Activities enjoyed here '
                  'include rowing, and riding the summer toboggan run.',),


            ],
          ),

        ),
      ),

    );
  }
}
class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.location,
  });
  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            //1-----------
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                //2---------------
                Padding(padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  location,style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          ),
          Icon(
            Icons.star,color: Colors.red,
          ),
          const Text('41'),
        ],
      ),
    );
  }
}
class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;
    return SizedBox(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWithText(color:Colors. red, icon: Icons.star_border, label: 'love'),
          ButtonWithText(color:Colors. red, icon: Icons.star_border, label: 'love'),
          ButtonWithText(color:Colors. red, icon: Icons.star_border, label: 'love'),

        ],
      ),
    );
  }
}
class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
class descripe extends StatelessWidget {
  const descripe({
    super.key,
    required this.description,
  });
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(padding:EdgeInsets.all(32),
      child: Text(description,softWrap: true,),
    );
  }
}
class images extends StatelessWidget {
  const images({super.key,
    required this.image
  });
  final String image;
  @override
  Widget build(BuildContext context) {
    return  Image.asset(image,
      width: 600,
      height: 240,
      fit:BoxFit.cover,
    );
  }
}
class gridv extends StatelessWidget {
  const gridv({super.key});
  @override
  Widget build(BuildContext context) {
    const String appTitle='Flutter layout demo';
    return MaterialApp(
      home: Scaffold(
          backgroundColor:Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.red,
            title:const Text(appTitle,style: TextStyle(),),
          ),
          body: GridView.count(crossAxisCount: 2,
            children: List.generate(100, (index) {
              return Center(
                child: Text(
                  'Item $index',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }),
          )
      ),
    );
  }
}






