#! /bin/bash
# pr3-repository
 aws ecr create-repository --repository-name "$1" --region "$2"