locals {
  routing_rules = [
    { prefix = "contact",  replace_with = "contact-page.html" },
    { prefix = "contact/", replace_with = "contact-page.html" },
  ]
}