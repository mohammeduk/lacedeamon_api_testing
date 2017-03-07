require 'json'
require 'faraday'

describe "sending a post request" do

 it "should create a new todo" do
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
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "1017-05-04"})
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "The following parameter <due> should be a date in the present or future").to eq true
  end

  it "should not create post with a due date in the future" do
    todo = Faraday.post("http://lacedeamon.spartaglobal.com/todos", {title: "Oz and Nick", due: "3017-05-04"})
    expect(todo.status).to eq 422 # Unprocessable entity
    expect(todo.body.include? "The following parameter <due> should be a date in the present or past").to eq true
  end

end
