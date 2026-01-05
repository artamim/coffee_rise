locals {
  routing_rules = [
    {
      prefix           = "contact"
      replace_with     = "contact.html"
    },
  ]
}