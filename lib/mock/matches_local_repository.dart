// Local Repositories for jobseeker and recruiters

class LocalRepository {
  List<Map<String, dynamic>> Favorites = [];

//Defining skills from issue #125
//Technical skills added for reference to create the repositories
  void insertFavorite(Map<String, dynamic> favorite) {
    Favorites.add(favorite);
  }

  void removeFavorite() {
    if (Favorites.isNotEmpty) Favorites.removeLast();
  }

  List<Map<String, dynamic>> getFavorites() => Favorites;

  List<String> getSkills() {
    const List<String> technical_skills = [
      'SQL',
      'MySQL',
      'Python',
      'Java',
      'C++',
      'C#',
      'HTML & CSS',
      'React.js',
      'GitHub',
      'VS Code',
      'PyCharm',
      'Figma',
      'Postman',
      'Firebase',
      'Dart',
      'Flutter',
      'AWS',
      'Tableau',
      'Node.js',
      'Express.js'
    ];
    return technical_skills;
  }

//Job Roles added for reference
  static List<String> job_roles = [
    'Front-End Developer',
    'Back-End Developer',
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
    'Business Analyst'
  ];

//Jobs/Programs Repository(Attributes: id,title,description,location,skills, job role)
  List<Map<String, dynamic>> getJobs() {
    final List<Map<String, dynamic>> jobs = [
      {
        'id': 'job1',
        'title': 'Data Analyst',
        'description': 'Analyze data from internal systems',
        'location': 'Mayaguez',
        'skills': ['SQL', 'Python', 'Tableau'],
        'job_role': 'Data Analyst'
      },

      {
        'id': 'job2',
        'title': 'Full-Stack Developer',
        'description': 'Design optimal and scalable technological solutions',
        'location': 'San Juan',
        'skills': ['Java', 'Python', 'C++', 'C#', 'SQL'],
        'job_role': 'Full-Stack Developer'
      },

      {
        'id': 'job3',
        'title': 'Cybersecurity Analyst',
        'description':
            'Identifying, mitigating, and responding to Information Security risks',
        'location': 'Ponce',
        'skills': ['Python', 'MySQL', 'SQL'],
        'job_role': 'Cybersecurity Analyst'
      },

      {
        'id': 'job4',
        'title': 'Front-End Developer',
        'description':
            'Building and maintaining scalable and robust frontend applications ',
        'location': 'Chicago',
        'skills': ['HTML & CSS', 'React.js'],
        'job_role': 'Front-End Developer'
      },

      {
        'id': 'job5',
        'title': 'UX Designer Program',
        'description': 'Design user interfaces',
        'location': 'San German',
        'skills': ['HTML & CSS', 'Figma'],
        'job_role': 'UX/UI Designer'
      },

      {
        'id': 'job6',
        'title': 'App Developer Internship',
        'description': 'Develop mobile apps ',
        'location': 'Mayaguez',
        'skills': ['Flutter', 'Dart', 'Figma'],
        'job_role': 'App Developer'
      },

      {
        'id': 'job7',
        'title': 'Cloud Architect',
        'description': 'Cloud infrastructure design ',
        'location': 'Camuy',
        'skills': ['AWS', 'Python'],
        'job_role': 'Cloud Architect'
      },

      {
        'id': 'job8',
        'title': 'QA Engineer',
        'description': 'Quality assurance testing ',
        'location': 'Carolina',
        'skills': ['Postman', 'Python'],
        'job_role': 'Quality Assurance Engineer'
      },
// This job9 is created intentionally to not have skills in common with job seekers
      {
        'id': 'job9',
        'title': 'Testing Engineer',
        'description': 'Test new software ',
        'location': 'Bayamon',
        'skills': ['Go', 'Rust'],
        'job_role': 'Testing Engineer'
      },

      {
        'id': 'job10',
        'title': 'Machine Learning Program',
        'description': 'Machine Learning pipelines ',
        'location': 'Remote',
        'skills': ['Python', 'SQL'],
        'job_role': 'Machine Learning Engineer'
      }
    ];
    return jobs;
  }

//Creating jobseekers repository
//job seeker attributes:
//(id,name,email,role(job seeker),description,willing to relocate(boolean),skills,job roles)
  List<Map<String, dynamic>> getSeekers() {
    final List<Map<String, dynamic>> jobseekers = [
      {
        'id': 'js1',
        'graduationYear': 2026,
        'name': 'Jose',
        'email': 'jose@upr.edu',
        'role': 'jobseeker',
        'description': 'Front End enthusiast',
        'willing_to_relocate': true,
        'skills': ['HTML & CSS', 'SQL', 'React.js'],
        'job_roles': ['Front-End Developer']
      },

//Exception job seeker that matches exactly one job on skills
      {
        'id': 'js2',
        'graduationYear': 2030,
        'name': ' Ana L.',
        'email': 'ana@gmail.com',
        'role': 'jobseeker',
        'description': 'Interested in Cybersecurity',
        'willing_to_relocate': true,
        'skills': ['Python', 'SQL', 'MySQL'],
        'job_roles': ['Cybersecurity Analyst']
      },

      {
        'id': 'js3',
        'graduationYear': 2028,
        'name': 'Gaul Pos',
        'email': 'gaul@upr.edu',
        'role': 'jobseeker',
        'description': 'Full stack developer',
        'willing_to_relocate': false,
        'skills': [
          'Java',
          'Python',
          'SQL',
          'MySQL',
          'HTML & CSS',
          'React.js',
          'C++',
          'C#'
        ],
        'job_roles': ['Front-End Developer', 'Back-End Developer']
      },

      {
        'id': 'js4',
        'graduationYear': 2026,
        'name': 'Apu Junior',
        'email': 'AJ@gmail.com',
        'role': 'jobseeker',
        'description': 'Data Analyst',
        'willing_to_relocate': true,
        'skills': ['SQL', 'Python'],
        'job_roles': ['Data Analyst']
      },

      {
        'id': 'js5',
        'graduationYear': 2025,
        'name': 'Kornim Paz',
        'email': 'kornim1@upr.edu',
        'role': 'jobseeker',
        'description': 'UX/UI Designer',
        'willing_to_relocate': true,
        'skills': ['Figma', 'HTML & CSS', 'Flutter', 'Dart'],
        'job_roles': ['UX/UI Designer']
      },
      {
        'id': 'js6',
        'graduationYear': 2025,
        'name': 'Charlie Brown',
        'email': 'charlieB@yahoo.com',
        'role': 'jobseeker',
        'description': ' Mobile App Developer',
        'willing_to_relocate': false,
        'skills': ['Figma', 'Dart', 'Python'],
        'job_roles': ['App Developer']
      },

      {
        'id': 'js7',
        'graduationYear': 2026,
        'name': 'David  O.',
        'email': 'david123@gmail.com',
        'role': 'jobseeker',
        'description': 'Cloud Engineer',
        'willing_to_relocate': true,
        'skills': ['AWS', 'Java', 'Python'],
        'job_roles': ['Cloud Architect']
      },

      {
        'id': 'js8',
        'graduationYear': 2027,
        'name': 'Hans S.',
        'email': 'hanss1@upr.edu',
        'role': 'jobseeker',
        'description': 'Machine Learning Engineer ',
        'willing_to_relocate': true,
        'skills': ['Python', 'SQL'],
        'job_roles': ['Machine Learning Engineer']
      },

      {
        'id': 'js9',
        'graduationYear': 2028,
        'name': 'Colton',
        'email': 'colton@gmail.com',
        'role': 'jobseeker',
        'description': 'QA Engineer',
        'willing_to_relocate': true,
        'skills': ['Postman', 'Java', 'C++', 'C#', 'Python'],
        'job_roles': ['Quality Assurance Engineer']
      },

      {
        'id': 'js10',
        'graduationYear': 2028,
        'name': 'Kat ',
        'email': 'kat@upr.edu',
        'role': 'jobseeker',
        'description': 'Data Analyst',
        'willing_to_relocate': false,
        'skills': ['MySQL', 'SQL', 'Python', 'Tableau', 'Java'],
        'job_roles': ['Data Analyst']
      }
    ];
    return jobseekers;
  }

//Recruiters Repository
//recruiter attributes(id,job/program id,name,email,role(recruiter))
//job/program id references an existent job/program with this id.
  List<Map<String, dynamic>> getRecruiters() {
    final List<Map<String, dynamic>> recruiters = [
      {
        'id': 'r1',
        'job_id': 'job1',
        'name': 'Recruiter 1',
        'email': 'recruiter1@example.com',
        'role': 'recruiter',
      },
      {
        'id': 'r2',
        'job_id': 'job2',
        'name': 'Recruiter 2',
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
        'job_id': 'job4',
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
    return recruiters;
  }

  // Mock users
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Sarah Johnson',
      'age': 24,
      'major': 'Computer Science',
      'bio':
          'Passionate software developer looking for exciting opportunities in tech. Love hiking and photography!',
      'image': 'assets/profile1.jpg',
    },
    {
      'name': 'Alex Rodriguez',
      'age': 22,
      'major': 'Electrical Engineering',
      'bio':
          'Final year EE student specializing in embedded systems. Avid rock climber and coffee enthusiast.',
      'image': 'assets/profile2.jpg',
    },
    {
      'name': 'Maya Patel',
      'age': 23,
      'major': 'Business Analytics',
      'bio':
          'Data-driven problem solver seeking analyst roles. Enjoy reading and traveling to new places.',
      'image': 'assets/profile3.jpg',
    },
  ];
}
