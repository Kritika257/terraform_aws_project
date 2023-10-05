#Challenge: Create a file using Terraform in your local machine

resource "null_resource" "file" {
    provisioner "local-exec" {
    command = "echo 'Message: ${upper("hello world!")}' > challenge.txt" 
}
}