# KQ Flight Notifier 
A serverless AWS application that notifies you whenever a Kenya Airways (KQ) plane lands at Jomo Kenyatta International Airport (JKIA) using the OpenSky Network API. Built with **Terraform**, **AWS Lambda**, and **SNS** for real-time flight tracking.

![Terraform](https://img.shields.io/badge/Terraform-0.15%2B-blueviolet)
![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-Python%203.11-orange)
![AWS SNS](https://img.shields.io/badge/AWS%20SNS-Notifications-brightgreen)

---

##  Project Features**  
- Real-time tracking of KQ flights approaching JKIA.  
- Automated notifications using AWS SNS.  
- Secure credential management with AWS Secrets Manager.  
- Fully automated with Terraform for easy deployment.  






## Getting Started
1. Clone the Repository
- git clone https://github.com/Copubah/KQ-flight-notifier
- cd kq-flight-notifier

2. Install Terraform
Make sure you have Terraform 0.15+ installed.
- terraform -version

3. Set Up OpenSky Credentials
- Create a terraform.tfvars file

4. Package the Lambda Function
- zip lambda_function.zip lambda_function.py

5. Deploy the Infrastructure
  - terraform init
  - terraform apply


6. Test the Lambda Function
Trigger the Lambda function manually or wait for the scheduled event to run



## Project Files
 kq-flight-notifier/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables for Terraform
├── terraform.tfvars       # Sensitive credentials
├── outputs.tf             # Terraform outputs
├── lambda_function.py     # Python Lambda function
├── lambda_function.zip    # Zipped Lambda function for deployment
├── .gitignore             # Git ignore file
└── README.md              # Project documentation



## Author
Built and maintained by Charles Opuba.

## License
This project is licensed under the MIT License - see the LICENSE file for details.





