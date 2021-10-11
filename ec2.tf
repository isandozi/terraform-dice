resource "aws_instance" "bastion" {
  ami = data.aws_ami.example.id
  instance_type = "t2.micro"
  subnet_id = local.pub_sub_ids[0]
  source_dest_check = false
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.dice.key_name

  tags = {
    Name = "DiceVPC_Bastion"
  }
}

resource "aws_instance" "private" {
  count = length(local.az_names)
  ami = data.aws_ami.example.id
  instance_type = "t2.micro"
  subnet_id = local.priv_sub_ids[count.index]
  source_dest_check = false
  key_name = aws_key_pair.dice.key_name

  tags = {
    Name = "DiceVPC_Private_Instance${count.index + 1}"
  }
}

resource "aws_key_pair" "dice" {
  key_name = "DiceKey"
  public_key = file("scripts/dice.pub")
}
