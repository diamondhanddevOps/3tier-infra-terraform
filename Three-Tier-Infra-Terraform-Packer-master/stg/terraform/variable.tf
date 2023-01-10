variable "vpn_inbound_ports" {
  type = list(object({
    internal  = number
    external  = number
    protocol  = string
    CidrBlock = string
  }))
  default = [
    {
      internal  = 22
      external  = 22
      protocol  = "tcp"
      CidrBlock = "0.0.0.0/0"
    },
    {
      internal  = 80
      external  = 80
      protocol  = "tcp"
      CidrBlock = "0.0.0.0/0"
    }
    ,
    {
      internal  = 443
      external  = 443
      protocol  = "tcp"
      CidrBlock = "0.0.0.0/0"
    }
  ]
}
