// Local Repositories for jobseeker and recruiters

//Defining skills from issue #125
//Technical skills added for reference to create the repositories
const List<String>  technical_skills =['SQL', 'MySQL', 'Python', 'Java', 'C++', 'C#','HTML & CSS',
'React.js', 'GitHub', 'VS Code', 'PyCharm', 'Figma', 'Postman', 'Firebase','Dart', 'Flutter', 'AWS'
,'Tableau', 'Node.js', 'Express.js'];

//Job Roles added for reference
const List<String>	job_roles= ['Front-End Developer' ,'Back-End Developer',
                                	'Full-Stack Developer',
                                	'Data Scientist',
                                	'Data Analyst',
                                	'Cybersecurity Analyst',
                                	'UX/UI Designer',
                                	'Team Leaders',
                                	'App Developer',
                                	'Cloud Architect',
                                	'DevOps Engineer',
                                	'Quality Assurance Engineer',
                                	'IT Project Manager',
                                	'Product Manager',
                                	'Security Engineer',
                                	'Database Administrator',
                                	'Customer Support Specialist',
                                	'Machine Learning Engineer',
                                	'Marketing Specialist',
                                	'Business Analyst'];


//Jobs/Programs Repository(Attributes: id,title,description,location,skills, job role)

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

{'id' : 'job3',
   'title' : 'Cybersecurity Analyst',
   'description':'Identifying, mitigating, and responding to Information Security risks',
   'location':'Ponce',
   'skills': ['Python', 'MySQL' ,'SQL'],
   'job_role': 'Cybersecurity Analyst'},

{'id' : 'job4',
       'title' : 'Front-End Developer',
       'description':'Building and maintaining scalable and robust frontend applications ',
       'location':'Chicago',
       'skills': ['HTML & CSS', 'React.js'],
       'job_role': 'Front-End Developer'},


{'id' : 'job5',
       'title' : 'UX Designer Program',
       'description':'Design user interfaces',
       'location':'San German',
       'skills': ['HTML & CSS', 'Figma'],
       'job_role': 'UX/UI Designer'},

{'id' : 'job6',
       'title' : 'App Developer Internship',
       'description':'Develop mobile apps ',
       'location':'Mayaguez',
       'skills': ['Flutter', 'Dart', 'Figma'],
       'job_role': 'App Developer'},

{'id' : 'job7',
       'title' : 'Cloud Architect',
       'description':'Cloud infrastructure design ',
       'location':'Camuy',
       'skills': ['AWS', 'Python'],
       'job_role': 'Cloud Architect'},

{'id' : 'job8',
       'title' : 'QA Engineer',
       'description':'Quality assurance testing ',
       'location':'Carolina',
       'skills': ['Postman', 'Python'],
       'job_role': 'Quality Assurance Engineer'},
// This job9 is created intentionally to not have skills in common with job seekers
{'id' : 'job9',
       'title' : 'Testing Engineer',
       'description':'Test new software ',
       'location':'Bayamon',
       'skills': ['Go', 'Rust'],
       'job_role': 'Testing Engineer'},

{'id' : 'job10',
       'title' : 'Machine Learning Program',
       'description':'Machine Learning pipelines ',
       'location':'Remote',
       'skills': ['Python', 'SQL'],
       'job_role': 'Machine Learning Engineer'}
];
//Creating jobseekers repository
//job seeker attributes:
//(id,name,email,role(job seeker),description,willing to relocate(boolean),skills,job roles)
final List<Map<String, dynamic>> jobseekers =[{
'id': 'js1',
'name': 'Jose',
'email': 'jose@upr.edu',
'role':'jobseeker'
, 'description': 'Front End enthusiast',
'willing_to_relocate': true,
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
'skills': ['Python', 'SQL', 'MySQL'],
'job_roles': ['Cybersecurity Analyst']},

{
'id': 'js3',
'name': 'Gaul Pos',
'email': 'gaul@upr.edu',
'role':'jobseeker'
, 'description': 'Full stack developer',
'willing_to_relocate': false,
'skills': ['Java', 'Python', 'SQL', 'MySQL', 'HTML & CSS', 'React.js', 'C++' , 'C#'],
'job_roles': ['Front-End Developer', 'Back-End Developer']},

{
'id':'js4' ,
'name': 'Apu Junior',
'email': 'AJ@gmail.com',
'role':'jobseeker'
, 'description': 'Data Analyst',
'willing_to_relocate': true,
'skills': ['SQL', 'Python'],
'job_roles': ['Data Analyst']},

{
'id': 'js5',
'name': 'Kornim Paz',
'email': 'kornim1@upr.edu',
'role':'jobseeker'
, 'description': 'UX/UI Designer',
'willing_to_relocate': true,
'skills': ['Figma', 'HTML & CSS', 'Flutter', 'Dart'],
'job_roles': ['UX/UI Designer']},
{
'id':'js6' ,
'name': 'Charlie Brown',
'email': 'charlieB@yahoo.com',
'role':'jobseeker'
, 'description': ' Mobile App Developer',
'willing_to_relocate': false,
'skills': ['Figma', 'Dart', 'Python'],
'job_roles': ['App Developer']},

{
'id': 'js7',
'name': 'David  O.',
'email': 'david123@gmail.com',
'role':'jobseeker'
, 'description': 'Cloud Engineer',
'willing_to_relocate': true,
'skills': ['AWS', 'Java', 'Python'],
'job_roles': ['Cloud Architect']},

{
'id':'js8' ,
'name': 'Hans S.',
'email': 'hanss1@upr.edu',
'role':'jobseeker'
, 'description': 'Machine Learning Engineer ',
'willing_to_relocate': true,
'skills': ['Python', 'SQL'],
'job_roles': ['Machine Learning Engineer']},


{
'id':'js9' ,
'name': 'Colton',
'email': 'colton@gmail.com',
'role':'jobseeker'
, 'description': 'QA Engineer',
'willing_to_relocate': true,
'skills': ['Postman', 'Java', 'C++', 'C#', 'Python'],
'job_roles': ['Quality Assurance Engineer']},

{
'id':'js10' ,
'name': 'Kat ',
'email': 'kat@upr.edu',
'role':'jobseeker'
,'description': 'Data Analyst',
'willing_to_relocate': false,
'skills': ['MySQL', 'SQL','Python', 'Tableau', 'Java'],
'job_roles': ['Data Analyst']}
];


//Recruiters Repository
//recruiter attributes(id,job/program id,name,email,role(recruiter))
//job/program id references an existent job/program with this id.
final List<Map<String, dynamic>> recruiters =[{
'id': 'r1',
'job_id':'job1' ,
'name': 'Recruiter 1',
'email': 'recruiter1@example.com',
'role': 'recruiter',

},
{
'id': 'r2',
'job_id':'job2' ,
'name':'Recruiter 2',
'email': 'recruiter2@example.com',
'role': 'recruiter',

},
{
'id': 'r3',
'job_id': 'job3',
'name': 'Recruiter 3',
'email': 'recruiter3@example.com',
'role': 'recruiter',

},
{
'id': 'r4',
'job_id': 'job4' ,
'name': 'Recruiter 4',
'email': 'recruiter4@example.com',
'role': 'recruiter',

},
{
'id': 'r5',
'job_id': 'job5',
'name': 'Recruiter 5',
'email': 'recruiter5@example.com',
'role': 'recruiter',

}


];

