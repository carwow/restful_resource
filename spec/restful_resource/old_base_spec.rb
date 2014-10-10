require_relative '../spec_helper'

describe RestfulResource::OldBase do
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
      expect { Player.url }.to raise_error(RestfulResource::ParameterMissingError, expected_error_message)
    end

    it "should not confuse port number as a parameter" do
      Player.url = 'http://api.carwow.co.uk:7000/teams/:team_id/players'

      expect { Player.url(team_id: 13) }.not_to raise_error
    end
  end

  context "#all" do
    it "should provide a paginated result if response contains rest pagination headers" do
      response = response_with_page_information()
      stub_new_resource('http://api.carwow.co.uk/teams', response)

      teams = Team.all

      expect(teams.previous_page).to be_nil
      expect(teams.next_page).to eq 2
      expect(teams.first.name).to eq 'Arsenal'
      expect(teams.last.name).to eq 'Chelsea'
    end
  end

  it "should act as an openstruct" do
    example = Player.new(name: 'David', surname: 'Santoro')

    expect(example.name).to eq 'David'
    expect(example.surname).to eq 'Santoro'
  end

  it "should use some params for the url and other for the query string" do
    stub_new_resource('http://api.carwow.co.uk/teams/15/players?name_like=Ars', response_with_page_information)

    players = Player.all(team_id: 15, name_like: 'Ars')
  end

  it "should raise an error when accessing a field that doesn't exist" do
    player = Player.new({name: 'David', surname: 'Santoro'})

    expect { player.age }.to raise_error(NoMethodError)
  end

  private
  def stub_new_resource(url, fake_response)
    resource = instance_double('RestClient::Resource', get: fake_response)
    allow(RestClient::Resource).to receive(:new).with(url).and_return resource
  end

  def stub_get(url, fake_response, params = {})
    expect(RestClient).to receive(:get).
                          with(url, params: params).
                          and_return(fake_response)
  end

  def response_with_page_information
    response = [{ id: 1, name: 'Arsenal'}, { id: 2, name: 'Chelsea' }].to_json
    allow(response).to receive(:headers) {
      {:links => '<http://api.carwow.co.uk/teams.json?page=6>;rel="last",<http://api.carwow.co.uk/teams.json?page=2>;rel="next"'}
    }
    response
  end
end

class Team < RestfulResource::OldBase
  self.url = "http://api.carwow.co.uk/teams"
end

class Player < RestfulResource::OldBase
  has_one :team

  self.url = "http://api.carwow.co.uk/teams/:team_id/players"
end



