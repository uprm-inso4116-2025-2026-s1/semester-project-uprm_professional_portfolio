**Side Effect Free  Match Score Function:** 

Why it is important for the calculation of the match score of our project?
-The side effect free allows us to obtain the exact same score for the same inputs
-It helps and facilitates  testing and debugging 

From a Past Lecture Topic (Task #298), we defined a strategy pattern for skills,GPA and location. I am using what was implemented on that Lecture Topic Task to continue the Side-effect Free match score function.


```
`class MatchScrore{
    double claculationScore(Jobseeker js, Job job){
     final  List<double> strategyMatchPolicyScores= [SkillPriority().match(js, job), GPAPriority().match(js,job),            LocationPolicy().match(js,job)];

     double total = 0.0;
     for (double score in strategyMatchPolicyScores ){
          total += score;

}

      return total/strategyMatchPolicyScores.length;
}
     

}`




```

**Testing:** 
For testing purposes,  I added a threshold of 0.70 to detect a match. In other words if a jobseeker obtains a match score >=70 it is considered a match, otherwise, is not. 

Note: For testing purposes , I used dummy Jobseeker and Job objects represented as `Map<String, dynamic>`.
```

`import 'StrategyPatternsTester.dart';


class MatchScrore{
    double claculationScore(Map<String, dynamic> js, Map<String, dynamic> job){
     final  List<double> strategyMatchPolicyScores= [SkillPriority().match(js, job), GPAPriority().match(js,job),            LocationPolicy().match(js,job)];

     double total = 0.0;
     for (double score in strategyMatchPolicyScores ){
          total += score;

}

      return total/strategyMatchPolicyScores.length;
}


}



void main(){
final jobs = [
{'id' : 'job1',
'title' : 'Data Analyst',
'description':'Analyze data from internal systems',
'location':'Mayaguez',
'skills': ['SQL','Python', 'Tableau' ],
'job_role': 'Data Analyst'},

{'id' : 'job2',
 'title' : 'Full-Stack Developer',
 'description':'Design optimal and scalable technological solutions',
 'location':'San Juan',
 'skills': ['Java','Python', 'C++' , 'C#','SQL'],
 'job_role': 'Full-Stack Developer'},
 ];
 final jobseekers =[{
 'id': 'js1',
 'name': 'Jose',
 'email': 'jose@upr.edu',
 'role':'jobseeker'
 , 'description': 'Front End enthusiast',
 'willing_to_relocate': true,
 'gpa': 3.30,
 'skills': ['HTML & CSS', 'SQL', 'React.js'],
 'job_roles': ['Front-End Developer']},


 {
 'id': 'js2',
 'name': ' Ana L.',
 'email': 'ana@gmail.com',
 'role':'jobseeker'
 , 'description': 'Interested in Cybersecurity',
 'willing_to_relocate': true,
 'gpa': 2.50,
 'skills': ['Python', 'SQL', 'MySQL'],
 'job_roles': ['Cybersecurity Analyst']},
];


final  Score = MatchScrore();

 const double matchpercent = 0.70;
 int counter =0;

 String matchResult;

 for(var js in jobseekers){
   for(var jo in jobs){
    counter +=1;


     double score = Score.claculationScore( js,  jo);
     print('This is Test # ${counter}');
     print('Score for ${js['name']} - ${jo['title']}');

     if(score < 0.0 || score > 1.0){
      print('Score out of bounds');

     }

     if(score >= matchpercent){
        print('There is a match between the jobseeker and the job');

     }
    else if(score < matchpercent){
      print('There is NO match between the jobseeker and the job');
    }



   }

 }




}

```
`
**The output obtained from the Testing: **

<img width="895" height="239" alt="Image" src="https://github.com/user-attachments/assets/4e8db766-ae19-46aa-9e68-9722bdae0adf" />


**The side effects (before) of the function above could've been: **
- If I  had added the `void main()`  testing logic  inside of the MatchScore calculation, the function would have had many side effects caused by the  print statements and if/else logic. 


References:

Hostragons, "Functional Programming and Side-Effect Management" , https://www.hostragons.com/en/blog/functional-programming-and-side-effect-management/
