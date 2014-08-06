require_relative '../spec_helper'

describe RestResource::Base do
  context "#find" do
    it "should retrieve a resource with a simple url" do
      response = { id: 15, name: 'Arsenal' }.to_json 
      stub_get('http://api.carwow.co.uk/teams/15', response)
      
      team = Team.find(15)

      expect(team.id).to eq 15
      expect(team.name).to eq 'Arsenal'
    end

    it "should retrieve a nested resource" do
      response = { id: 1, team_id: 15, name: 'David', santoro: 'Santoro' }.to_json 
      stub_get('http://api.carwow.co.uk/teams/15/players/1', response)

      player = Player.find(1, team_id: 15)
      
      expect(player.id).to eq 1
      expect(player.team_id).to eq 15
      expect(player.name).to eq 'David'
    end
  end

  context "#url" do
    it "should return the url set if no extra parameters are necessary" do
      Player.url = 'http://api.carwow.co.uk/players'

      expect(Player.url).to eq 'http://api.carwow.co.uk/players'
    end

    it "should return the url with the right parameters replaced" do
      Player.url = 'http://api.carwow.co.uk/teams/:team_id/players'

      expect(Player.url(team_id: 13)).to eq 'http://api.carwow.co.uk/teams/13/players'
    end

    it "should raise a parameter required exception if parameter needed and not provided" do
      Player.url = 'http://api.carwow.co.uk/countries/:country_slug/teams/:team_id/players'

      expected_error_message = 'You must pass values for the following parameters: [country_slug, team_id]'
      expect { Player.url }.to raise_error(RestResource::ParameterMissingError, expected_error_message)
    end
  end

  it "should act as an openstruct" do
    example = Player.new(name: 'David', surname: 'Santoro')

    expect(example.name).to eq 'David'
    expect(example.surname).to eq 'Santoro'
  end

  private
  def stub_get(url, fake_response)
    expect(RestClient).to receive(:get).
                          with(url).
                          and_return(fake_response)
  end
end

class Team < RestResource::Base
  self.url = "http://api.carwow.co.uk/teams"
end

class Player < RestResource::Base
  self.url = "http://api.carwow.co.uk/teams/:team_id/players"
end



