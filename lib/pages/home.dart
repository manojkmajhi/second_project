import 'package:flutter/material.dart';
import 'package:second_project/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = [
    "assets/images/Drill.png",
    "assets/images/InchTape.png",
    "assets/images/screwdriver.png",
    "assets/images/glove.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: Container(
        margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi, User", style: AppWidget.boldTextFieldStyle()),
                    Text(
                      "Welcome to ToolKit",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset(
                    "assets/logo/user.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search your tools",
                  hintStyle: AppWidget.lightTextFieldStyle(),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Categories", style: AppWidget.semiboldTextFieldStyle()),
                const Text(
                  "See All",
                  style: TextStyle(color: Color.fromARGB(135, 213, 91, 91)),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  height: 120,
                  margin: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    "All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListView.builder(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return CategoryTile(image: categories[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Products", style: AppWidget.semiboldTextFieldStyle()),
                const Text(
                  "See All",
                  style: TextStyle(color: Color.fromARGB(135, 213, 91, 91)),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 240,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Image.asset(
                          "assets/images/Drill.png",
                          height: 130,
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Drill",
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Nrs3000",
                              style: TextStyle(
                                color: Color.fromARGB(135, 213, 91, 91),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 50),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 251, 72, 56),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Image.asset(
                          "assets/images/screwdriver.jpg",
                          height: 130,
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Screw Driver",
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Nrs200",
                              style: TextStyle(
                                color: Color.fromARGB(135, 213, 91, 91),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 50),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 251, 72, 56),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Image.asset(
                          "assets/images/SideCutters.png",
                          height: 130,
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Side Cutters",
                          style: AppWidget.semiboldTextFieldStyle(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Nrs200",
                              style: TextStyle(
                                color: Color.fromARGB(135, 213, 91, 91),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 50),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 251, 72, 56),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String image;
  const CategoryTile({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(right: 20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        children: [
          Image.asset(image, height: 70, width: 70, fit: BoxFit.cover),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}
