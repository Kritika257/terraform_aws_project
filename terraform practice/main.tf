# Single comment
#Learning HCL with me

/* this is multi line comment */

############################################################
// Block

resource "aws_instance" "example"{
    ami = "abc1234"
    instance_type = "t2.micro"
    count = 3
    enable = true
}

#############################################################
# Datatypes

type = "string"
number = 2
boolean = true

#LIST
list = ["item1", "item2", "item3"]

#MAPS 
local{
    my_map = { "name" = "Kritika", "age" = 22, "is_admin" = true}
}

age_of_kritika = local.my_map["age"]

#################################################
#Conditions

resource "aws_instance" "server" {
    instance_type = var.environment == "development" ? "t2.micro" : "t2.small"
}

##################################################################

#Functions

local{
    name = "Kritika"
    fruits = ["apple", "banana", "mango", "grapes"]
    message = "Hello ${upper(local.name)}! I know you like ${join(",", local.fruits)}"
}

# Hello Kritika! I know you like apple, banana, mango, grapes

#Resourcedependency

resource "aws_instance" "name"{
    vpc_security_group_ids = aws_security_group.mysg.id

}

resource "aws_security_group" "mysg"{
    #inbounnd rules

}

#########################################################################



########################################################################

#creating instance
/*
provider "aws" {
  region = "eu-north-1"
}

# Create a VPC
resource "aws_instance" "web" {
  ami = "ami-0989fb15ce71ba39e"
  instance_type = "t3.micro"


  tags = {
    Name = "HelloWorld"
    }
  }
  */

  #Creating Github Repository
/*
  resource "github_repository" "example"{
    name = "My_awesome_repo"
    description = "My git repo"
    visibility = "public"
  }

  provider "github" {
  # Configuration options
  token = "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"
}
*/
provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "web" {
  ami = var.os
  instance_type = var.size


  tags = {
    Name = var.name
    }
  }

  variable "os" {
    type = string
    default = "ami-0989fb15ce71ba39e"
    description = "This is my ID"
  }

variable "size"{
  default = "t2.micro"
}

variable "name"{
  default = "Instance1"
}
