
resource "aws_instance" "bastion" {
  ami = data.aws_ami.example.id
  instance_type = "t2.micro"
  subnet_id = local.pub_sub_ids[0]
  source_dest_check = false
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "DiceVPC_Bastion"
  }
}
