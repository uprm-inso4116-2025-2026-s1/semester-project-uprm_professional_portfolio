import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

//logic to show recruiter vs job seeker screen goes here a state for each
  @override
  State<MatchesScreen> createState() => MatchesState();
}

class MatchesState extends State<MatchesScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        //Header
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Image.asset('brand_white.png'),
        ),
        body: Align(
          child: SafeArea(
            child: Container(decoration : const BoxDecoration(color: Colors.white),
            child: Column(mainAxisAlignment : MainAxisAlignment.center,
             children: [Text("Matches Screen"),

         const Spacer(),

        Padding(
         padding: const EdgeInsets.only(bottom:10),

         child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[

             IconButton(
              onPressed: (){},
              icon : Image.asset('matches_accept_button.png', width:50),
               ), IconButton(

                      onPressed: (){},
                                icon : Image.asset('matches_skip_button.png', width:50),
                                 ),

            IconButton(
              onPressed: ()
              {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text('Profile Information'),
                      content: Text(
                        'TODO: Take information from jobseeker/recruiter profile and insert into information screen. Cannot be done currently because form fields have not been implemented in profiles.\n\n'
                            'Major:\n'
                            'Graduation Year:\n'
                            'Bio:\n'
                            'Skills:\n'
                            'Interests:\n'
                            'Portfolio Links:\n'
                            'Resume:\n'
                            'Job Preferences:',
                      ),
                    );
                  },
                );
              },
              icon: Image.asset(
                'matches_info_button.png',
                width: 50,
              ),
            ),

                   IconButton(

                   onPressed: (){},
                   icon : Image.asset('matches_star_button.png', width:50),
                                                    ),


                      ],
              ),),
              ],
              ),
              ),
              ),
              ),


        /// bottom navigation bar place-holder png, ALL work should be done above this,
        /// DON'T replace bottomNavigationBar with matchesScreen buttons
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Image.asset('NavBar.png'),
        ),
      );
}
