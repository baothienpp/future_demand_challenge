# Future Demand Coding Challenge

This repository will deploy on a python function in to AWS Lambda.
The Lambda function will be triggered by a file upload action in S3 Bucket.


##Prerequisite

```
GCC ( to run Makefile)
Terraform v0.12.24

```

##Quick Start
```
git clone https://github.com/baothienpp/future_demand_challenge.git
cd future_demand_challenge
make apply

(Optional) In case you want to add a prefix to the bucket name 
(because the bucket name might have been already existed)

export PREFIX=<some-name>
make apply
```



