import 'package:flut/bloc/register/register_bloc.dart';
import 'package:flut/models/job_model.dart';

class GraphQLRequester {
  static Map<String, dynamic> login(String email, String password) {
    return {
      "query": """
            mutation Login(\$password: String, \$email: String) {
              login(password: \$password, email: \$email) {
                token
                    user {
                      firstName
                      lastName
                      ccp
                      id
                      email
                      role
                      
                    }
                  }
                }
              """,
      "variables": {"email": "$email", "password": "$password"}
    };
  }

  static Map<String, dynamic> register_client(RegisterState state) {
    return {
      "query": """
          mutation CreateClient(\$input: Input!, \$interests: [String]) {
            createClient(input: \$input, interests: \$interests) {
              user {
                firstName
                lastName
                ccp
                id
                email
                role
              }
              token
            }
          }
        """,
      "variables": {
        "input": {
          "ccp": "12345678910",
          "dateOfBirth": state.birthday,
          "email": state.email,
          "firstName": state.first_name,
          "lastName": state.last_name,
          "password": state.password,
          "phoneNumber": state.phone_number,
          "willaya": state.wilaya
        },
        "interests": ["state.intersts"],
      }
    };
  }

  static Map<String, dynamic> register_freelancer(RegisterState state) {
    return {
      "query": """
        mutation CreateFreelancer(\$input: Input!, \$skills: [String]) {
          createFreelancer(input: \$input, skills: \$skills) {
          user {
            id
            firstName
            lastName
            photo
            email
            phoneNumber
            willaya
            dateOfBirth
            ccp
            role
          }
            token
          }
        }
        """,
      "variables": {
        "input": {
          "firstName": state.first_name,
          "lastName": state.last_name,
          "email": state.email,
          "password": state.password,
          "phoneNumber": state.phone_number,
          "willaya": state.wilaya,
          "dateOfBirth": state.birthday,
          "ccp": "123456789",
        },
        "skills": ["state.skills" + "asd"],
      }
    };
  }

  static Map<String, dynamic> seasion(String token) {
    return {
      "query": """
        query Session(\$token: ID) {
          session(token: \$token) {
            id
            type
            iat
            exp
          }
        }""",
      "variables": {"token": token}
    };
  }

  static Map<String, dynamic> load_freelancer_feed(
      String id, String? date, String? rate, String? type, String? query) {
    return {
      "query": """
        query GetFreelancerFeed(\$getFreelancerFeedId: ID!, \$date: String ,\$rate: Float, \$structure: String, \$query: String) {
          getFreelancerFeed(id: \$getFreelancerFeedId,rate: \$rate, structure: \$structure, date: \$date,query: \$query) {
            _id
            title
            description
            price
            deadline
            tags
            clientInfo {
              firstName
              lastName
            }
            payment_structure
              attachments {
      link
      kind
    }
          }
        }
        """,
      "variables": {
        "getFreelancerFeedId": id,
        "date": date,
        "rate": rate == null ? null : double.parse(rate),
        "structure": type,
        "query": query,
      }
    };
  }

  static Map<String, dynamic> post_job(String id, JobModel job) {
    return {
      "query": """
        mutation PostJob(\$input: jobInput!, \$user: ID!) {
          postJob(input: \$input, user: \$user) {
            message
          }
        }
        """,
      "variables": {
        "input": {
          "title": job.job_title,
          "description": job.description,
          "price": job.rate,
          "payment_structure": {
            "By mile stone": "By_Project",
            "By project": "By_Milestone",
          }[job.payment_structure],
          "job_size": job.experience,
          "deadline": job.deadline + "Z",
          "tags": [],
        },
        "user": id,
      }
    };
  }

  static Map<String, dynamic> post_proposal(
      String id, jobid, String description, int price, String duration) {
    return {
      "query": """
          mutation PostJobRequest(\$input: postJobRequestInput!, \$userid: ID!) {
            postJobRequest(input: \$input, userid: \$userid) {
              message
            }
          }""",
      "variables": {
        "input": {
          "description": description,
          "price": price,
          "deadline": "2020-08-24T23:11:02.376Z",
          "job": jobid
        },
        "userid": id
      }
    };
  }

  static Map<String, dynamic> get_profile_client(String id) {
    return {
      "query": """
query ClientProfile(\$clientProfileId: ID) {
  clientProfile(id: \$clientProfileId) {
    client {

    ccp
    dateOfBirth
    email
    firstName
    lastName
    phoneNumber
    role
    willaya
    photo
        bio

    }
  }
}
      """,
      "variables": {
        "clientProfileId": "$id",
      }
    };
  }

  static Map<String, dynamic> get_profile_freelancer(String id) {
    return {
      "query": """

    query Freelancer(\$freelancerProfileId: ID) {
  freelancerProfile(id: \$freelancerProfileId) {
    freelancer {
            id
        ccp
        dateOfBirth
        email
        firstName
        lastName
        phoneNumber
        role
        willaya
        photo
        bio
    }
  }
}
      """,
      "variables": {
        "freelancerProfileId": "$id",
      }
    };
  }

  static Map<String, dynamic> get_profile_stats(String id) {
    return {
      "query": """
        query ClientProfile(\$clientCompletedJobsId: ID!, \$clientActiveJobsId: ID!) {
          clientCompletedJobs(id: \$clientCompletedJobsId) {
            price
          }
          clientActiveJobs(id: \$clientActiveJobsId) {
            id
          }
        }
      """,
      "variables": {"clientCompletedJobsId": id, "clientActiveJobsId": id}
    };
  }

  static Map<String, dynamic> update_client({
    String? phoneNumber = null,
    String? skills = null,
    String? willaya = null,
    String? lastName = null,
    String? firstName = null,
    String? dateOfBirth = null,
    String? ccp = null,
  }) {
    return {
      "query": """
          mutation UpdateClient(\$input: update, \$updateClientId: ID!) {
            updateClient(input: \$input, id: \$updateClientId) {
    id
    ccp
    dateOfBirth
    email
    firstName
    lastName
    password
    phoneNumber
    photo
    role
    willaya
            }
          }  
      """,
      "variables": {
        "input": {
          "phoneNumber": phoneNumber,
          // "skills": skills,
          "willaya": willaya,
          "lastName": lastName,
          "firstName": firstName,
          "dateOfBirth": dateOfBirth,
          "ccp": ccp
        },
        "updateClientId": "5e057689343745f2937a1fd6ff467f45"
      }
    };
  }

  static Map<String, dynamic> load_client_dash(String id) {
    return {
      "query": """

query ClientDash(\$clientDashId: ID!) {
  clientDash(id: \$clientDashId) {
              jobs {
                _id
                title
                description
                price
                payment_structure
                deadline
              }
              jobsProgress {
                _id
                title
                description
                price
                payment_structure
                deadline
              }
              jobsArchive {
                _id
                title
                description
                price
                payment_structure
                deadline
              }
  }
}          
      """,
      "variables": {
        "clientDashId": id,
      }
    };
  }

  static Map<String, dynamic> load_jobs_requests(String userid, String id) {
    return {
      "query": """
        query GetJobRequests(\$getJobRequestsId: ID!, \$userid: ID!) {
          getJobRequests(id: \$getJobRequestsId, userid: \$userid) {
            job
            requests {
              firstName
              lastName
              photo
              description
              price
              score
              bio
              _id
              deadline
            }
          }
        }""",
      "variables": {
        "getJobRequestsId": id,
        "userid": userid,
      }
    };
  }

  static Map<String, dynamic> accept_job(
      String id, String freelancerID, String jobID) {
    return {
      "query": """
      mutation AcceptJob(\$client: ID!, \$freelancer: ID!, \$job: ID!) {
        acceptJob(client: \$client, freelancer: \$freelancer, job: \$job) {
          message
        }
      }""",
      "variables": {
        "client": id,
        "freelancer": freelancerID,
        "job": jobID,
      },
    };
  }

  static Map<String, dynamic> freelancer_dash(String id) {
    return {
      "query": """
      query FreelancerDash(\$freelancerDashId: ID!) {
        freelancerDash(id: \$freelancerDashId) {
          jobsProgress {
            _id
            description
            title
            attachments {
              link
              kind
            }
            tags
            price
            payment_structure
            deadline
          }
          jobsArchive {
            _id
            title
            description
            attachments {
              link
              kind
            }
            tags
            price
            payment_structure
            deadline
          }
          requests {
            _id
            job {
                    _id
                    title
                    description
                    attachments {
                      link
                    }
                    tags
                    price
                    client
                    requests
                    payment_structure
                    job_size
                    expertize_level
                    deadline
                    createdAt
                  }            
          }
        }
      }""",
      "variables": {"freelancerDashId": id},
    };
  }

  static Map<String, dynamic> freelancers(String id) {
    return {
      "query": """
         query Freelancers(\$talentsId: ID) {
          talents(id: \$talentsId) {
            freelancers {
              description
              photo
              jobTitle
              lastName
              firstName
              _id
            }
            name
          }
        } """,
      "variables": {"talentsId": id},
    };
  }

  static Map<String, dynamic> get_job_requests(String id, String jobID) {
    return {
      "query": """
        query GetJobRequests(\$getJobRequestsId: ID!, \$userid: ID!) {
          getJobRequests(id: \$getJobRequestsId, userid: \$userid) {
            requests {
              _id
              firstName
              lastName
              description
              photo
              sum
              bio
              deadline
              price
            }
          }
        }""",
      "variables": {"getJobRequestsId": jobID, "userid": id},
    };
  }

  static Map<String, dynamic> get_chargily_link(String id, String jobID) {
    return {
      "query": """
        query GetChargilyLink(\$getChargilyLinkId: ID, \$job: ID) {
          getChargilyLink(id: \$getChargilyLinkId, job: \$job) {
            url
          }
        }""",
      "variables": {
            "getChargilyLinkId": id,
            "job":         jobID
      }
    };
  }
  static Map<String, dynamic> validate_job(String id, String jobID) {
    return {
      "query" : """
        mutation ValidateJob(\$job: ID!, \$client: ID!) {
          validateJob(job: \$job, client: \$client) {
            message
          }
        }""",
        "variables" : {
  "job": jobID,
  "client": id
        }
    };
  } 


}
