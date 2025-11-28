# Side Effect Free  Match Score Function:

## **1.Why it is important for the calculation of the match score of the project?**

- The side effect free allows us to obtain the exact same score for the same inputs, making results consistent.
- Helps and facilitates testing and debugging 
- Avoids hidden behaviour
  
All this aspects are important because mantaning a  side-effect free  function ensures that match scores remain predictable and consistent across all parts of the platform.

## **2. Use of Strategy Patern**

In Lecture Topic (Task #298), we implemented a strategy pattern for three matching policies: skills,GPA and location. 
This policies are reused to calculate their respectives match scores. Each policy (e.g. SkillsPolicy) implements the
`Match Policy` interface and defines a `match(jobseeker,job)` method.
These strategies return a numeric score between 0.0 to 1.0.


**UML Diagram**


<img width="631" height="232" alt="Image" src="https://github.com/user-attachments/assets/8648da07-3985-4cfe-b8d1-ae92ac3f9309" />



**Implementation**

The  `MatchScore` class, aggregates all strategies and computes the final score as the average: 

```
`class MatchScore{
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
This function is side-effect free.

**Testing:** 
For testing purposes:
-A dummy threshold of 0.70 was added to detect a match. 
How it works?
If a jobseeker obtains a match score >=0.70 it is considered a match, otherwise, if the  score <0.70 there is no match. 
Note: The value 0.70 is only a testing placeholder and is not part of the algorithm logic.

- Dummy `Jobsekeer`and `Job` objects represented as `Map<String, dynamic>` structures.
  
```

`import 'StrategyPatternsTester.dart';


class MatchScore{
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


final  Score = MatchScore();

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
**The output obtained from the Testing:**

<img width="895" height="239" alt="Image" src="https://github.com/user-attachments/assets/4e8db766-ae19-46aa-9e68-9722bdae0adf" />


**The side effects (before) of the function above could've been: **
- All the side-effects were avoided by keeping the print statements and test loops outside the MatchSrore class.If they had been included inside the function
  would no longer be side-effect free.

References:

Hostragons, "Functional Programming and Side-Effect Management" , https://www.hostragons.com/en/blog/functional-programming-and-side-effect-management/
