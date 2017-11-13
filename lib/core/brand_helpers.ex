defmodule Core.BrandHelpers do
  def logo_source("bnc"),
    do: "https://brandnewcongress.org/assets/1/0/bundles/sitetheorytemplatecustom/images/BNClogoFooter.png?v1497713350"

  def logo_source("jd"),
    do: "https://justicedemocrats.com/assets/1/0/bundles/sitetheorytemplatecustom/images/JDlogoMark.png?v1497022285"

  def press("bnc"), do: "press@brandnewcongress.org"
  def press("jd"), do: "press@justicedemocrats.com"

  def contact("bnc"), do: "us@brandnewcongress.org"
  def contact("jd"), do: "us@justicedemocrats.com"

  def copyright("bnc"), do: "Brand New Congress"
  def copyright("jd"), do: "Justice Democrats"

  def abbr("bnc"), do: "BNC"
  def abbr("jd"), do: "JD"

  def address("bnc"), do: "P. O. BOX 621264 CHARLOTTE, NC 28262"
  def address("jd"), do: "P. O. BOX 621264 CHARLOTTE, NC 28262"

  def homepage("bnc"), do: "https://brandnewcongress.org"
  def homepage("jd"), do: "https://justicedemocrats.com"

  def core_deployment("bnc"), do: "https://now.brandnewcongress.org"
  def core_deployment("jd"), do: "https://now.justicedemocrats.com"
end
