resource "aws_security_group" "bastion_sg" {
  name = "DiceVPC_BastionSG"
  description = "Security group for Dice VPC Bastion"
  vpc_id = aws_vpc.my_app.id
}

resource "aws_security_group_rule" "bastion_sg_egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  security_group_id = aws_security_group.bastion_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_sg_ingress" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  cidr_blocks = ["24.148.18.72/32"]
}

