require 'json'
require 'faraday'
require 'pry'

describe "sending a post request" do

 it "should POST a new todo" do
   # Execute
   todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "2017-05-04"})

   # Verify
   expect(todo.status).to eq 201
   expect(todo.body.include? "Oz and Nick").to eq true

   # Teardown
   resp = JSON.parse(todo.body)
   resp = resp['id']
   resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
   expect(resp.status).to eq 204 # No content response
 end

  it "should not create post with missing parameters" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick"})
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "You must provide the following parameters: <title> and <due>. You provided: ").to eq true
  end

  it "should not create a post with no parameters" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos")
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "You must provide the following parameters: <title> and <due>. You provided: ").to eq true
  end

end

describe "negative testing : expect failure" do

  it "should not create post with a due date in the past" do
    #Execute
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "1017-05-04"})
    #Verfiy
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "The following parameter <due> should be a date in the present or future").to eq true

    #Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

  it "should not create POST with a due date in the future" do
    #Execute
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "3017-05-04"})
    #Verify
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "The following parameter <due> should be a date in the present or past").to eq true
    #Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

  it "should not modify todo with invalid id using PATCH request" do
    #Execute
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "2017-05-04"})
    resp = JSON.parse(todo.body)
    resp = resp['id']

    modify = Faraday.patch("http://lacedeamon.spartaglobal.com/todos/761827", {title: "We are sparta"})
    mod_resp = JSON.parse(modify.body)
    #Verify
    expect(modify.status).to eq 200
    expect(mod_resp['title']).to eq "We are sparta"

    # Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

end

describe "GET existing posts" do

  it "should get an existing todo post" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "2017-05-04"})
    resp = JSON.parse(todo.body)
    resp = resp['id']
    get_post = Faraday.get("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    get_post = JSON.parse(get_post.body)
    expect(get_post['id']).to eq resp
    expect(get_post['title']).to eq "Oz and Nick"
    expect(get_post['due']).to eq "2017-05-04"

    # Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

  it "should respond with a status 404 given with an invalid id" do
    todo = Faraday.get("http://lacedeamon.spartaglobal.com/todos/7181829")
    expect(todo.status).to eq 404 # Not found
  end

end

describe "change existing posts using PATCH" do

  it "should be able to modify title of todo post with PATCH request" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "2017-05-04"})
    resp = JSON.parse(todo.body)
    resp = resp['id']

    modify = Faraday.patch("http://lacedeamon.spartaglobal.com/todos/#{resp}", {title: "We are sparta"})
    mod_resp = JSON.parse(modify.body)
    expect(modify.status).to eq 200
    expect(mod_resp['title']).to eq "We are sparta"

    # Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

  it "should be able to modify date of todo post with PATCH request" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "2017-05-04"})
    resp = JSON.parse(todo.body)
    resp = resp['id']

    modify = Faraday.patch("http://lacedeamon.spartaglobal.com/todos/#{resp}", {due: "2011-01-01"})
    mod_resp = JSON.parse(modify.body)
    expect(modify.status).to eq 200
    expect(mod_resp['due']).to eq "2011-01-01"

    # Teardown
    resp = JSON.parse(todo.body)
    resp = resp['id']
    resp = Faraday.delete("http://lacedeamon.spartaglobal.com/todos/#{resp}")
    expect(resp.status).to eq 204 # No content response
  end

end
