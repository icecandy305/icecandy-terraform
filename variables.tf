variable "customers" {
  type = map(object({
    name = string
  }))
  default = {
    customerA = { name = "Customer_A" }
    customerB = { name = "Customer_B" }
  }
}

