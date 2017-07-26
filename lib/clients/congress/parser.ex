defmodule Congress.Parser do
  {:ok, legislators} = "./lib/clients/congress/legislators-current.json"
    |> File.read()
    |> (fn {:ok, raw} -> Poison.decode(raw) end).()

  @raw_legislators legislators

  def get_congress(district, legislators) do
    rep = legislators |> Enum.filter(&(is_rep_for(&1, district))) |> List.first()
    senate = legislators |> Enum.filter(&(is_sen_for(&1, district))) |> Enum.take(2)
    {district, %{house: rep, senate: senate}}
  end

  def is_rep(legislator) do
    case current_appointment(legislator) do
      %{"type" => "rep"} -> true
      _else -> false
    end
  end

  def state_of(legislator), do: current_appointment(legislator)["state"]
  def is_in_state(legislator, state), do: current_appointment(legislator)["state"] == state

  defp is_rep_for(legislator, district) do
    {state, district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "rep", "state" => ^state, "district" => ^district} -> true
      _else -> false
    end
  end

  defp is_sen_for(legislator, district) do
    {state, _district} = District.extract_int_form(district)
    case current_appointment(legislator) do
      %{"type" => "sen", "state" => ^state} -> true
      _else -> false
    end
  end

  def current_appointment(_legislator = %{"terms" => terms}), do: List.last(terms)

  def reps_by_state do
    areas = @raw_legislators
      |> Enum.map(&state_of/1)
      |> MapSet.new()

    legislators_by_area = Enum.map(areas, fn area ->
      {
        full_state_name(area),
        @raw_legislators
        |> Enum.filter(&(is_in_state(&1, area)))
        |> Enum.map(&extract_standup_attrs/1)
      }
    end)

    Enum.into(legislators_by_area, %{})
  end

  def extract_standup_attrs(legislator = %{"name" => %{"official_full" => name}}) do
    %{"party" => party, "district" => district, "state" => state}
      = case current_appointment(legislator) do
        %{"party" => party, "district" => district, "state" => state} ->
          %{"party" => party, "district" => district, "state" => state}
        %{"party" => party, "state" => state} ->
          %{"party" => party, "district" => "Senate", "state" => state}
      end

    add_image(%{"party" => party, "district" => district || "Senate", "state" => state, "name" => name})
  end

  def add_image(legislator) do
    %{"name" => name} = legislator
    %{body: %{"itemListElement" => entity_list}} = Entity.search(name)

    img = case List.first(entity_list) do
      %{"result" => %{"image" => %{"contentUrl" => img}}} -> img
      _else ->
        IO.puts "no image for #{name}. using: #{image_of(name)}"
        image_of(name)
    end

    Map.put(legislator, "img", img)
  end

  defp image_of("Henry C. \"Hank\" Johnson, Jr."), do: "http://cdn.cnsnews.com/images/hank%20johnson.jpg"
  defp image_of("David Scott"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/David_Scott_congressional_portrait.jpg/1200px-David_Scott_congressional_portrait.jpg"
  defp image_of("A. Drew Ferguson IV"), do: "https://upload.wikimedia.org/wikipedia/commons/9/94/Drew_Ferguson_official_congressional_photo.jpg"
  defp image_of("Ann M. Kuster"), do: "https://upload.wikimedia.org/wikipedia/commons/f/fb/Ann_McLane_Kuster_official_photo.jpg"
  defp image_of("Tom O’Halleran"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Tom_O%27Halleran_official_portrait.jpg/220px-Tom_O%27Halleran_official_portrait.jpg"
  defp image_of("Mike Johnson"), do: "https://pbs.twimg.com/profile_images/827283914297184257/JaccwIw2.jpg"
  defp image_of("Ralph Norman"), do: "https://az620379.vo.msecnd.net/images/Contracts/50075be6-631b-4510-8113-65f133bb665c.png"
  defp image_of("John R. Carter"), do: "https://www.congress.gov/img/member/114_rp_tx_31_carter_john.jpg"
  defp image_of("Randy K. Weber, Sr."), do: "https://pbs.twimg.com/profile_images/616654502184263680/na4q3hZH.jpg"
  defp image_of("Vicente Gonzalez"), do: "https://upload.wikimedia.org/wikipedia/commons/7/72/Vicente_Gonzalez_115th_congress_photo.jpg"
  defp image_of("Jodey C. Arrington"), do: "https://upload.wikimedia.org/wikipedia/commons/b/bd/Jodey_Arrington_115th_congress_photo.jpg"
  defp image_of("Roger W. Marshall"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Roger_Marshall%2C_115th_official_photo.jpg/200px-Roger_Marshall%2C_115th_official_photo.jpg"
  defp image_of("Ron Estes"), do: "https://en.wikipedia.org/wiki/Ron_Estes#/media/File:Ron_Estes,_115th_official_photo.jpg"
  defp image_of("Albio Sires"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Albio_sires.jpg/220px-Albio_sires.jpg"
  defp image_of("Brian Higgins"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Brian_Higgins%2C_official_Congressional_photo_portrait.JPG/220px-Brian_Higgins%2C_official_Congressional_photo_portrait.JPG"
  defp image_of("José E. Serrano"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Josieserrano.jpeg/220px-Josieserrano.jpeg"
  defp image_of("Paul Tonko"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Paul_Tonko_114th_Congress_photo.jpg/1200px-Paul_Tonko_114th_Congress_photo.jpg"
  defp image_of("Thomas Massie"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Thomas_Massie_official_portrait.jpg/1200px-Thomas_Massie_official_portrait.jpg"
  defp image_of("John R. Moolenaar"), do: "https://cdn.ballotpedia.org/images/9/90/John_Moolenaar.jpg"
  defp image_of("Paul Mitchell"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Paul_Mitchell_official_congressional_photo.jpg/440px-Paul_Mitchell_official_congressional_photo.jpg"
  defp image_of("Jim Banks"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Jim_Banks_official_portrait.jpg/1200px-Jim_Banks_official_portrait.jpg"
  defp image_of("Lisa Blunt Rochester"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Lisa_Blunt_Rochester_official_photo.jpg/440px-Lisa_Blunt_Rochester_official_photo.jpg"
  defp image_of("Robin L. Kelly"), do: "https://upload.wikimedia.org/wikipedia/commons/6/65/Robin_Kelly_official_photo.jpg"
  defp image_of("Raja Krishnamoorthi"), do: "https://upload.wikimedia.org/wikipedia/commons/a/aa/Raja_Krishnamoorthi_official_photo.jpg"
  defp image_of("Ted Budd"), do: "https://pbs.twimg.com/profile_images/735278019175174146/nBn5k5jJ.jpg"
  defp image_of("Anthony G. Brown"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Anthony_G._Brown_Official_State_Photo.jpg/220px-Anthony_G._Brown_Official_State_Photo.jpg"
  defp image_of("Rick Larsen"), do: "https://larsen.house.gov/sites/larsen.house.gov/files/images/copy_3000_color.jpg"
  defp image_of("Suzan K. DelBene"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Suzan_DelBene%2C_official_portrait%2C_112th_Congress.jpg/220px-Suzan_DelBene%2C_official_portrait%2C_112th_Congress.jpg"
  defp image_of("Denny Heck"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Denny_Heck%2C_Official_Portrait%2C_113th_Congress.jpg/220px-Denny_Heck%2C_Official_Portrait%2C_113th_Congress.jpg"
  defp image_of("Mike Thompson"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mike_Thompson.jpg/220px-Mike_Thompson.jpg"
  defp image_of("Stephen Knight"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Steve_Knight_official_congressional_photo.jpeg/440px-Steve_Knight_official_congressional_photo.jpeg"
  defp image_of("Salud O. Carbajal"), do: "https://saludcarbajal.com/files/2015/10/SaludHeadShot.jpg"
  defp image_of("J. Luis Correa"), do: "https://upload.wikimedia.org/wikipedia/commons/c/c0/Lou_Correa_official_portrait.jpg"
  defp image_of("Gary J. Palmer"), do: "https://pbs.twimg.com/profile_images/780775816561033217/WoFZdv71.jpg"
  defp image_of("Glenn Thompson"), do: "https://upload.wikimedia.org/wikipedia/commons/c/cd/GT_Thompson_%28111th%29.jpg"
  defp image_of("Keith J. Rothfus"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Keith_Rothfus_115th_official_photo.png/440px-Keith_Rothfus_115th_official_photo.png"
  defp image_of("Brian K. Fitzpatrick"), do: "https://upload.wikimedia.org/wikipedia/commons/3/3a/Brian_Fitzpatrick_official_congressional_photo.jpg"
  defp image_of("Ted S. Yoho"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Ted_Yoho%2C_official_portrait%2C_113th_Congress.jpg/220px-Ted_Yoho%2C_official_portrait%2C_113th_Congress.jpg"
  defp image_of("Matt Gaetz"), do: "https://upload.wikimedia.org/wikipedia/commons/f/f1/Matt_Gaetz.jpg"
  defp image_of("Neal P. Dunn"), do: "https://www.gannett-cdn.com/-mm-/3c920ce52e336798c98e94f2d11ae32693cbbe9b/c=0-0-3526-4701&r=537&c=0-0-534-712/local/-/media/2017/03/17/Tallahassee/Tallahassee/636253468385498354-Neal-Dunn-Headshot-10-2016.jpg"
  defp image_of("John H. Rutherford"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/John_Rutherford_115th_Congress_photo.jpg/440px-John_Rutherford_115th_Congress_photo.jpg"
  defp image_of("Al Lawson, Jr."), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Al_Lawson_115th_Congress_photo.jpg/440px-Al_Lawson_115th_Congress_photo.jpg"
  defp image_of("Stephanie N. Murphy"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Stephanie_Murphy_official_photo.jpg/440px-Stephanie_Murphy_official_photo.jpg"
  defp image_of("Brian J. Mast"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Brian_Mast_official_congressional_photo_%28cropped%29.jpg/440px-Brian_Mast_official_congressional_photo_%28cropped%29.jpg"
  defp image_of("Ed Perlmutter"), do: "https://upload.wikimedia.org/wikipedia/en/thumb/7/75/RepEdP.jpg/440px-RepEdP.jpg"
  defp image_of("Robert E. Latta"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Bob_Latta%2C_official_110th_Congress_photo_portrait.jpg/440px-Bob_Latta%2C_official_110th_Congress_photo_portrait.jpg"
  defp image_of("Brad R. Wenstrup"), do: "https://upload.wikimedia.org/wikipedia/commons/b/b4/Brad_Wenstrup_official.jpg"
  defp image_of("David P. Joyce"), do: "https://upload.wikimedia.org/wikipedia/commons/1/15/David_Joyce.jpg"
  defp image_of("Jim Cooper"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Jim_Cooper%2C_Official_Portrait%2C_ca2013.jpg/440px-Jim_Cooper%2C_Official_Portrait%2C_ca2013.jpg"
  defp image_of("Charles J. \"Chuck\" Fleischmann"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Chuck_Fleischmann_official_photo.jpg/440px-Chuck_Fleischmann_official_photo.jpg"
  defp image_of("Luther Strange"), do: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Luther_Strange_official_portrait.jpg/1200px-Luther_Strange_official_portrait.jpg"
  defp image_of(_else), do: "PANIC PANIC PANIC"

  defp full_state_name("AL"), do: "Alabama"
  defp full_state_name("AK"), do: "Alaska"
  defp full_state_name("AS"), do: "American Samoa"
  defp full_state_name("AZ"), do: "Arizona"
  defp full_state_name("AR"), do: "Arkansas"
  defp full_state_name("CA"), do: "California"
  defp full_state_name("CO"), do: "Colorado"
  defp full_state_name("CT"), do: "Connecticut"
  defp full_state_name("DE"), do: "Delaware"
  defp full_state_name("DC"), do: "District Of Columbia"
  defp full_state_name("FM"), do: "Federated States Of Micronesia"
  defp full_state_name("FL"), do: "Florida"
  defp full_state_name("GA"), do: "Georgia"
  defp full_state_name("GU"), do: "Guam"
  defp full_state_name("HI"), do: "Hawaii"
  defp full_state_name("ID"), do: "Idaho"
  defp full_state_name("IL"), do: "Illinois"
  defp full_state_name("IN"), do: "Indiana"
  defp full_state_name("IA"), do: "Iowa"
  defp full_state_name("KS"), do: "Kansas"
  defp full_state_name("KY"), do: "Kentucky"
  defp full_state_name("LA"), do: "Louisiana"
  defp full_state_name("ME"), do: "Maine"
  defp full_state_name("MH"), do: "Marshall Islands"
  defp full_state_name("MD"), do: "Maryland"
  defp full_state_name("MA"), do: "Massachusetts"
  defp full_state_name("MI"), do: "Michigan"
  defp full_state_name("MN"), do: "Minnesota"
  defp full_state_name("MS"), do: "Mississippi"
  defp full_state_name("MO"), do: "Missouri"
  defp full_state_name("MT"), do: "Montana"
  defp full_state_name("NE"), do: "Nebraska"
  defp full_state_name("NV"), do: "Nevada"
  defp full_state_name("NH"), do: "New Hampshire"
  defp full_state_name("NJ"), do: "New Jersey"
  defp full_state_name("NM"), do: "New Mexico"
  defp full_state_name("NY"), do: "New York"
  defp full_state_name("NC"), do: "North Carolina"
  defp full_state_name("ND"), do: "North Dakota"
  defp full_state_name("MP"), do: "Northern Mariana Islands"
  defp full_state_name("OH"), do: "Ohio"
  defp full_state_name("OK"), do: "Oklahoma"
  defp full_state_name("OR"), do: "Oregon"
  defp full_state_name("PW"), do: "Palau"
  defp full_state_name("PA"), do: "Pennsylvania"
  defp full_state_name("PR"), do: "Puerto Rico"
  defp full_state_name("RI"), do: "Rhode Island"
  defp full_state_name("SC"), do: "South Carolina"
  defp full_state_name("SD"), do: "South Dakota"
  defp full_state_name("TN"), do: "Tennessee"
  defp full_state_name("TX"), do: "Texas"
  defp full_state_name("UT"), do: "Utah"
  defp full_state_name("VT"), do: "Vermont"
  defp full_state_name("VI"), do: "Virgin Islands"
  defp full_state_name("VA"), do: "Virginia"
  defp full_state_name("WA"), do: "Washington"
  defp full_state_name("WV"), do: "West Virginia"
  defp full_state_name("WI"), do: "Wisconsin"
  defp full_state_name("WY"), do: "Wyoming"
end
