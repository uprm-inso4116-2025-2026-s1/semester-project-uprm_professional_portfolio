# **Strategy Pattern for  Matching Policies**

In the Matching algorithm we have different strategies  to match the jobseekers with the recruiters just as: skill-priority, GPA-priority, location-priority

**What do all these match strategies have in common?**  A common interface match()

But first, let's define:

**What is a strategy pattern?** 

"Strategy Design Pattern is a [behavioral design pattern](https://www.geeksforgeeks.org/system-design/behavioral-design-patterns/) that allows you to define a family of algorithms or behaviors, put each of them in a separate class, and make them interchangeable at runtime." (Extracted from Geek for Geeks website) 

**Why is useful and why we need it for our project?**

It is useful because it allows us to have more flexibility in terms of changing how the matching works without modifying the  rest of the code. It also allow us to reuse strategies across different parts of the system.

**The following is a pseudocode of how the Matching Policy should look like:** 


```
Interface Matching Policy
   Method match(jobseeker, job )
   RETURNS int
END INTERFACE


CLASS Skills IMPLEMENTS Matching Policy
  Method match(jobseeker, job)
  jobseekerSkills = SET(jobseeker.skills)
 requiredSkills = SET(job.skills)

 IF requiredSkills is EMPTY
     RETURN 1


 ELSE IF jobseekerSkills is EMPTY
   RETURN 0

 commonSkills = SIZE(jobseekerSkills.INTERSECTION(requiredSkills))

 RETURN commonSkills/SIZE(requiredSkills)

END CLASS


CLASS GPA IMPLEMENTS Matching Policy
  Method match(jobseeker, job)
   jobseekerGPA = jobseeker.GPA
   gpa = 4.00

RETURN jobseekerGPA/gpa

END CLASS


CLASS Location IMPLEMENTS Matching Policy
 Method match( jobseeker, job)


    IF jobseeker.location == job.location
        RETURN 1

     ELSE IF jobseeker.willing_to_realocate == TRUE
         RETURN 1 
    
     ELSE:
           RETURN 0

END CLASS
```








**Code Examples: Turning the pseudocode to Actual Dart code(This is a Mock example):** 

```
//Here goes the Jobseeker model import
abstract class MatchingPolicy{
  double match(JobSeekerProfile jobseeker,  Job job);
  
}

class SkillPriority implements MatchingPolicy{
  
 @override
  double match (JobSeekerProfile jobseeker,  Job job){
    final  jobseekerSkills = jobseeker.skills.toSet();
    final requiredSkills = job.skills.toSet();
    if(jobseekerSkills.isEmpty){
    return 0.0;
} 
  else if( requiredSkills.isEmpty){
     return 1.0; 
}

final commonSkills = jobseekerSkills.intersection(requiredSkills).length;

return commonSkills/ requiredSkills.length;



}
}
class GPAPriority implements MatchingPolicy{
@override
 double match (JobSeekerProfile jobseeker,  Job job){
  final  jobseekerGPA = jobseeker.gpa;
  const maxgpa = 4.00;

  return jobseekerGPA/maxgpa;
  

}
}


class  LocationPolicy implements MatchingPolicy{
@override
  double match(JobSeekerProfile jobseeker,  Job job){
     if (jobseeker.location == job.location){
        return 1.0; 
}

   else if ( jobseeker.willingToRelocate == true){
       return 1.0;
}

return 0.0; 
}

}





```
**Example of applying Strategy;** 
The matching criteria used for this test to determine if the jobseeker is a good match for the job are:
gpa = GPA score > 0.7
location = Location = 1 or willing to relocate = 1
skills = Skills score > 0.8

**To test the Strategy Pattern I used Dummy Jobseekers and jobs**


```
//Dummy Tester
void main(){
final List<Map<String, dynamic>> jobs = [
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
 final List<Map<String, dynamic>> jobseekers =[{
 'id': 'js1',
 'name': 'Jose',
 'email': 'jose@upr.edu',
 'role':'jobseeker'
 , 'description': 'Front End enthusiast',
 'willing_to_relocate': true,
 'gpa': 3.30,
 'skills': ['HTML & CSS', 'SQL', 'React.js'],
 'job_roles': ['Front-End Developer']},

 //Exception job seeker that matches exactly one job on skills
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

for( final js in jobseekers){
  print('Jobseeker name: ${js['name'] }');
  for (final jo in jobs){

    final skillScore = SkillPriority().match(js, jo);

    final gpaScore = GPAPriority().match(js, jo);

    final locationScr = LocationPolicy().match(js, jo
    );

    print("SkillScore: " + skillScore.toString());
    print("GPA Score: " + gpaScore.toString());
    print("Location Match: " + locationScr.toString());
  }

}





}
`
```

References:
Geek for Geeks, "Strategy Design Pattern", https://www.geeksforgeeks.org/system-design/strategy-pattern-set-1/

Geek for Geeks, "Strategy Design Pattern", https://www.geeksforgeeks.org/system-design/strategy-pattern-set-1/

