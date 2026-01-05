locals {
  routing_rules = [
    { prefix = "contact",  replace_with = "contact.html" },
    { prefix = "contact/", replace_with = "contact.html" },
  ]
  s3_routing_rules_json = jsonencode(local.s3_routing_rules)
}