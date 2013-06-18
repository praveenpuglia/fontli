require "open-uri"

module FontFamily
  def self.font_autocomplete(query="")
    params = {:q => query}
    request('MyFontsSearch/autocomplete.json', params) || []
  end

  def self.font_details(query="")
    params = {:searchText => query, :resultType => "fonts"}
    resp = request('MyFontsSearch/search.json', params) || {'results' => []}

    resp["results"].collect do |result|
      sub_font_count = result["description"].match(/\d/).to_s
      {
        :name => result["name"], :image => result["sampleImage"],
        :font_url => result["myfontsURL"], :uniqueid => result["uniqueID"],
        :id => result["id"], :count => sub_font_count
      }
    end
  end

  def self.sub_font_details(font_unique_id)
    params = {:uniqueid => font_unique_id}
    resp = request('MyFontsDetails/getDetails.json', params) || []

    resp.collect do |result|
      result["styles"].collect do |style|
        font_url = style["myfontsURL"].blank? ? "" : "http://new.myfonts.com/" + style["myfontsURL"]
        {
          :name => style["name"], :image => style["sampleImage"],
          :font_url => font_url, :uniqueid => result["uniqueID"], :id => style["id"]
        }
      end
    end.flatten
  end

  def self.get_family_details(family_id)
    params = {:idlist => family_id}
    resp = request('MyFontsDetails/getFontFamilyDetails.json', params)

    if resp
      result = resp.first
      {
        :name => result["name"], :image => result["sampleImage"], :font_url => result["myfontsURL"],
        :uniqueid => result["uniqueID"], :id => result["id"],
        :desc => result['articles'].first['body'], :owner => result['owner']['name']
      }
    end
  end

  def self.font_sample(id, text)
    params = { :id => id, :render_string => text }
    request('MyFontsSample/familySample.json', params)
  end

private

  def self.client
    req_url = URI.parse("http://www.myfonts.com/")
    @client ||= Net::HTTP.new(req_url.host, req_url.port)
  end

  # accepts path string and params hash
  def self.request(path, params)
    url = '/rest/di493gjwir/' + path + "?#{params.to_param}"
    req = Net::HTTP::Get.new(url)
    res = client.request(req)

    if url.match(/\.json/)
      response = JSON.parse(res.body)
      response["success"] ? response["result"] : nil
    else
      res.body
    end
  end
end
